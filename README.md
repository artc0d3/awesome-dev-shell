# Awesome Dev Shell

A batteries-included, opinionated **Home Manager** environment that turns a fresh Ubuntu-WSL instance
into a proper dev box in a few commands — no manual `apt install` marathons, no "works on my machine."

Built for software developers living mostly in the **Node.js** and **Java/JVM** worlds who want a polished
Linux shell on Windows without becoming part-time sysadmins.

**What you get:**

- **Reproducible** — one Nix flake describes the whole setup; rebuild it anywhere, get the same shell.
- **Fast & modern CLI** — zsh + starship + the full `eza`/`bat`/`fd`/`ripgrep` lineup out of the box.
- **Polyglot runtimes** — `vfox` for Node/Java/Go/Python versions, `uv` for Python projects.
- **Containers ready** — podman with Docker compatibility.
- **1Password-native** — secrets flow in from your Windows vault via the 1Password CLI.
- **AI on tap** — `claude-code` pre-installed for pair-programming from the terminal.

## Loadout

Built on **Nix** with **Home Manager 26.05** managing the user environment on top of Ubuntu-WSL.

### Shell & prompt

- **zsh** + **oh-my-zsh** — the shell, with autosuggestions and syntax highlighting baked in.
- **starship** — fast, minimal, infinitely customizable prompt.
- **zoxide** — `cd` that learns where you actually go.
- **fzf** — fuzzy finder for files, history, and anything piped into it.

### Modern CLI essentials

- **eza** — a friendlier `ls` with icons and git status.
- **bat** — `cat` with syntax highlighting and paging.
- **fd** — a faster, saner `find`.
- **ripgrep** — blazing-fast recursive grep.
- **sd** — intuitive `sed` replacement for find-and-replace.
- **jq** — slice and dice JSON from the command line.
- **cloc** — count lines of code, grouped by language.

### Editor

- **neovim** — modal editing with LazyVim starter configuration.

### Dev tooling & version managers

- **vfox** — polyglot version manager (Node, Python, Go, JDK, ...).
- **uv** — ultra-fast Python package and project manager.

### Containers

- **podman** — daemonless, rootless container runtime with Docker compatibility.
- **podman-compose** — `docker-compose` for podman.

### Secrets & Git

- **1Password CLI** — pull secrets straight from your vault (e.g. `op inject`).
- **git** — SSH authentication and commit signing via a Linux-native OpenSSH agent.

### AI

- **claude-code** — Anthropic's official CLI for pair-programming with Claude.

## Getting started

The fastest way to get up and running is the bundled PowerShell installer. If you'd rather see (or
customize) each step, the manual walkthrough further down covers the same ground.

### Quick install (recommended)

Make sure WSL2 is installed and enabled on Windows, then run from an elevated PowerShell prompt:

```powershell
irm https://raw.githubusercontent.com/artc0d3/awesome-dev-shell/main/install.ps1 | iex
```

When it finishes, launch your new shell with `wsl -d <distro-name>` (or just `wsl` if you set it as
the default).

### Manual installation

#### 1. Create the Ubuntu WSL instance

Make sure WSL2 is installed and enabled on your Windows machine. Open PowerShell and create a fresh instance:

```powershell
wsl --install Ubuntu --name ads
```

This downloads and creates an Ubuntu instance. You'll be prompted to create a Unix username and password.
Use `dev` as the username to match the default configuration (or change the username in `flake.nix`).

Update the Ubuntu packages:

```bash
sudo apt update
sudo apt upgrade
```

#### 2. Install the Nix package manager

We use the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer)
which enables flakes and the `nix` command out of the box:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Close and reopen your terminal so that `nix` is on your PATH:

```bash
exit
wsl -d ads
```

Verify the installation:

```bash
nix --version
```

#### 3. Apply Awesome Dev Shell

Run Home Manager with the flake:

```bash
nix run home-manager -- switch --flake "github:artc0d3/awesome-dev-shell?ref=main#wsl"
```

This installs all packages and writes all configuration files. On the first run it may take a few
minutes to download and build everything.

#### 4. Set zsh as default shell

```bash
echo $(which zsh) | sudo tee -a /etc/shells
chsh -s $(which zsh)
```

Log out and and restart WSL instance for the changes to take effect:

```bash
exit
wsl -t ads
wsl -d ads
```

#### 5. Set up SSH keys (optional)

Git authentication and commit signing use a **Linux-native OpenSSH agent** running as a
persistent systemd user service. Store your passphrase-protected key(s) in `~/.ssh` and
unlock them once per boot; the agent then serves them to every shell — and to any tool
launched from a shell, such as a coding agent — without further prompts.

> **Note:** `SSH_AUTH_SOCK` is exported through your shell init (`~/.zshenv`), so tools
> reach the agent when launched from a shell (the usual case). A process started *outside*
> a shell — directly via `systemctl --user`, a desktop entry, or a headless/cron context —
> will not inherit the socket.

1. Place your key(s) in `~/.ssh`:
   - **Authentication:** any conventional key, e.g. `~/.ssh/id_ed25519`.
   - **Commit signing:** ADS expects the signing key at `~/.ssh/signing-key` (public half
     `~/.ssh/signing-key.pub`). It may be the same key as your auth key or a separate one.

2. After each WSL boot, load the key(s) into the agent once:

   ```bash
   ssh-add ~/.ssh/id_ed25519 ~/.ssh/signing-key
   ssh-add -l   # verify the keys are loaded
   ```

   You'll be prompted for each passphrase once; the keys then stay unlocked in the agent
   until the next reboot. Your **auth** key is also loaded lazily by `AddKeysToAgent yes`
   the first time you use Git over SSH — but the **signing** key must be added explicitly,
   because commit signing does not auto-add keys.

3. (Optional) To verify signatures locally (`git log --show-signature`), create an
   allowed-signers file mapping your email to your public signing key:

   ```bash
   echo "your.email@example.com $(cat ~/.ssh/signing-key.pub)" >> ~/.ssh/allowed_signers
   git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
   ```

#### 6. Set up rootless Podman (optional)

Podman is installed by Home Manager, but rootless containers need a small amount of system-level
setup on Ubuntu:

```bash
sudo apt update
sudo apt install uidmap slirp4netns
```

Verify:

```bash
podman run --rm docker.io/library/hello-world
```

## Rebuilding after changes

If you've cloned the repo locally and made changes:

```bash
home-manager switch --flake .#wsl
```

To pull the latest remote version:

```bash
nix run home-manager -- switch --flake "github:artc0d3/awesome-dev-shell?ref=main#wsl" --refresh
```

## Customization

This project is **not** meant to be a DIY project where you pick and choose your tools; it's more of a ready-made
setup that you can use as-is or fork and modify if you want to maintain your own version.

Once installed, the setup is rather rigid with only few customization possibilities. Nix disallows editing configuration
files managed by it, so you won't be able to change the Nix-managed configuration directly. There are few escape hatches
for the most common extension points though.

### ZSH

You can include your own ZSH configuration in `~/.zshrc.local`, which is sourced at the end of the main `~/.zshrc`.

### Configuration templates

Some config files can't be managed by Nix because tools need to modify them at runtime. ADS ships opinionated
templates and copies them on demand — once copied, the files are yours to edit freely.

```bash
ads config list          # show available tools and their config files
ads config init <tool>   # copy templates (skips existing files)
```

### Other tools

Most of the personal configuration living somewhere in your home directory is not managed by Nix and can be edited
directly.
