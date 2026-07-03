#Requires -Version 5.1

<#
.SYNOPSIS
    Bootstraps Awesome Dev Shell on a fresh Ubuntu WSL instance.

.DESCRIPTION
    Automates every step described in README.md: creates a named Ubuntu WSL
    distribution, provisions the `dev` user with passwordless sudo, installs
    Nix via the Determinate Systems installer, applies the Home Manager flake,
    and sets zsh as the login shell.

.EXAMPLE
    .\install.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$env:WSL_UTF8 = '1'

$script:FlakeTemplate = 'github:artc0d3/awesome-dev-shell?ref={0}#wsl'

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

$script:Glyph = @{
    Step    = [char]0x2192  # →
    Success = [char]0x2713  # ✓
    Fail    = [char]0x2717  # ✗
    Warn    = [char]0x26A0  # ⚠
    Info    = [char]0x2139  # ℹ
    Section = [char]0x25B6  # ▶
}

function Write-Banner {
    param([string]$Text, [ConsoleColor]$Color = 'Cyan')
    $line = ('=' * 70)
    Write-Host ''
    Write-Host $line -ForegroundColor $Color
    Write-Host ("  {0}" -f $Text) -ForegroundColor $Color
    Write-Host $line -ForegroundColor $Color
    Write-Host ''
}

function Write-Section {
    param([string]$Title)
    Write-Host ''
    Write-Host ("{0} {1}" -f $script:Glyph.Section, $Title) -ForegroundColor Cyan
    Write-Host ('-' * 70) -ForegroundColor DarkGray
}

function Write-Step    { Write-Host ("  {0} {1}" -f $script:Glyph.Step,    $args[0]) -ForegroundColor White }
function Write-Success { Write-Host ("  {0} {1}" -f $script:Glyph.Success, $args[0]) -ForegroundColor Green }
function Write-Info    { Write-Host ("  {0} {1}" -f $script:Glyph.Info,    $args[0]) -ForegroundColor Gray }
function Write-Warn    { Write-Host ("  {0} {1}" -f $script:Glyph.Warn,    $args[0]) -ForegroundColor Yellow }
function Write-Fail    { Write-Host ("  {0} {1}" -f $script:Glyph.Fail,    $args[0]) -ForegroundColor Red }

# ---------------------------------------------------------------------------
# Prompt helpers
# ---------------------------------------------------------------------------

function Read-WithDefault {
    param([string]$Prompt, [string]$Default)
    $value = Read-Host -Prompt ("{0} [{1}]" -f $Prompt, $Default)
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    return $value.Trim()
}

function Read-YesNo {
    param([string]$Prompt, [bool]$Default = $true)
    $label = if ($Default) { 'Y/n' } else { 'y/N' }
    while ($true) {
        $value = Read-Host -Prompt ("{0} [{1}]" -f $Prompt, $label)
        if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
        switch -Regex ($value.Trim().ToLowerInvariant()) {
            '^(y|yes)$' { return $true }
            '^(n|no)$'  { return $false }
            default     { Write-Warn "Please answer 'yes' or 'no'." }
        }
    }
}

# ---------------------------------------------------------------------------
# WSL helpers
# ---------------------------------------------------------------------------

function Invoke-WslRoot {
    param([string]$Distro, [string]$Script)
    & wsl.exe -d $Distro -u root -- bash -c $Script
    if ($LASTEXITCODE -ne 0) { throw ("WSL (root) command failed with exit {0}" -f $LASTEXITCODE) }
}

function Invoke-WslDev {
    param([string]$Distro, [string]$Script)
    # `bash -lc` ensures /etc/profile.d/*.sh is sourced so Nix is on PATH.
    & wsl.exe -d $Distro -u dev -- bash -lc $Script
    if ($LASTEXITCODE -ne 0) { throw ("WSL (dev) command failed with exit {0}" -f $LASTEXITCODE) }
}

function Test-DistroExists {
    param([string]$Distro)
    $list = & wsl.exe -l -q 2>$null
    if ($LASTEXITCODE -ne 0) { return $false }
    foreach ($entry in $list) {
        if ($entry.Trim() -eq $Distro) { return $true }
    }
    return $false
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

Write-Banner 'Awesome Dev Shell - WSL bootstrap installer'

# Pre-flight ----------------------------------------------------------------
Write-Section 'Pre-flight checks'

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Write-Fail 'wsl.exe is not on PATH. Install WSL2 first: https://learn.microsoft.com/windows/wsl/install'
    exit 1
}
Write-Success 'WSL is available.'

# Gather user input ---------------------------------------------------------
Write-Section 'Configuration'

$distroName    = Read-WithDefault -Prompt 'WSL distribution name' -Default 'ads'
$makeDefault   = Read-YesNo       -Prompt 'Make this distribution the default WSL distribution?' -Default $true
$version       = Read-WithDefault -Prompt 'Version to install (Git branch or tag)' -Default 'main'
$flakeRef      = $script:FlakeTemplate -f $version

Write-Host ''
Write-Info ("Distribution name      : {0}" -f $distroName)
Write-Info ("Make default WSL distro: {0}" -f $makeDefault)
Write-Info ("Version                : {0}" -f $version)
Write-Info ("Flake reference        : {0}" -f $flakeRef)
Write-Host ''
if (-not (Read-YesNo -Prompt 'Proceed with installation?' -Default $true)) {
    Write-Warn 'Aborted by user.'
    exit 0
}

if (Test-DistroExists -Distro $distroName) {
    Write-Fail ("A WSL distribution named '{0}' already exists. Pick a different name or remove it first (wsl --unregister {0})." -f $distroName)
    exit 1
}

$totalSteps = 8
function Step-Header {
    param([int]$N, [string]$Title)
    Write-Section ("[{0}/{1}] {2}" -f $N, $totalSteps, $Title)
}

# 1. Create distro ----------------------------------------------------------
Step-Header 1 ("Creating WSL distribution '{0}'" -f $distroName)
Write-Step 'wsl --install Ubuntu --name <distro> --no-launch'
& wsl.exe --install Ubuntu --name $distroName --no-launch
if ($LASTEXITCODE -ne 0) { throw 'wsl --install failed.' }
Write-Success 'Distribution registered.'

# 2. Provision dev user -----------------------------------------------------
Step-Header 2 "Provisioning the 'dev' user"
$provision = @'
set -euo pipefail
if ! id -u dev >/dev/null 2>&1; then
    useradd --create-home --shell /bin/bash --groups sudo dev
    passwd -d dev
fi
install -m 0440 /dev/null /etc/sudoers.d/dev
echo 'dev ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/dev
chmod 0440 /etc/sudoers.d/dev
cat > /etc/wsl.conf <<'EOF'
[user]
default=dev
[boot]
systemd=true
EOF
'@
Write-Step "Creating 'dev' user with passwordless sudo and setting it as the default WSL user"
Invoke-WslRoot -Distro $distroName -Script $provision
Write-Step 'Terminating distribution so /etc/wsl.conf takes effect'
& wsl.exe -t $distroName | Out-Null
Write-Success "User 'dev' is ready."

# 3. apt update / upgrade ---------------------------------------------------
Step-Header 3 'Updating apt packages'
Invoke-WslDev -Distro $distroName -Script 'sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y'
Write-Success 'System packages updated.'

# 4. Rootless Podman prerequisites ------------------------------------------
Step-Header 4 'Installing rootless Podman prerequisites'
Invoke-WslDev -Distro $distroName -Script 'sudo DEBIAN_FRONTEND=noninteractive apt-get install -y uidmap slirp4netns'
Invoke-WslRoot -Distro $distroName -Script 'usermod --add-subuids 200000-201000 --add-subgids 200000-201000 dev'
Write-Success 'Podman prerequisites configured.'

# 5. Install Nix ------------------------------------------------------------
Step-Header 5 'Installing Nix (Determinate Systems installer)'
$nixInstall = "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --no-confirm"
Invoke-WslDev -Distro $distroName -Script $nixInstall
Write-Success 'Nix installed.'

# 6. Apply Home Manager flake -----------------------------------------------
Step-Header 6 'Applying the Home Manager flake'
Write-Info ("Flake: {0}" -f $flakeRef)
$hmCmd = "nix run --accept-flake-config home-manager -- switch --flake '{0}'" -f $flakeRef
Invoke-WslDev -Distro $distroName -Script $hmCmd
Write-Success 'Home Manager configuration applied.'

# 7. zsh as default shell ---------------------------------------------------
Step-Header 7 'Setting zsh as default shell'
$zshSetup = @'
command -v zsh | sudo tee -a /etc/shells
chsh -s \$(which zsh)
'@
Invoke-WslDev -Distro $distroName -Script $zshSetup
Write-Success 'Default shell set to zsh.'

# 8. Finalize ---------------------------------------------------------------
Step-Header 8 'Finalizing'
if ($makeDefault) {
    Write-Step ("Setting '{0}' as the default WSL distribution" -f $distroName)
    & wsl.exe --set-default $distroName
    if ($LASTEXITCODE -ne 0) { throw 'wsl --set-default failed.' }
    Write-Success 'Default distribution set.'
} else {
    Write-Info 'Leaving default WSL distribution unchanged.'
}
Write-Step 'Terminating distribution so the new login shell takes effect on next launch'
& wsl.exe -t $distroName | Out-Null
Write-Success 'All steps completed.'

Write-Banner 'Installation complete!' Green
Write-Info ("Launch your new dev shell with:  wsl -d {0}" -f $distroName)
Write-Host ''
