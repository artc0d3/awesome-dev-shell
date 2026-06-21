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
- **1Password-native** — secrets and SSH keys flow in from your Windows vault automatically.
- **AI on tap** — `claude-code` pre-installed for pair-programming from the terminal.

## Loadout

Built on **Nix** with **Home Manager 25.11** managing the user environment on top of Ubuntu-WSL.

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

- **1Password CLI** — pull secrets and SSH keys straight from your vault.
- **git** — wired up to use the 1Password SSH agent via npiperelay bridge.

### AI

- **claude-code** — Anthropic's official CLI for pair-programming with Claude.

## Getting started

### 1. Create the Ubuntu WSL instance

Make sure WSL2 is installed and enabled on your Windows machine. Open PowerShell and run:

```powershell
wsl --install Ubuntu
```

This downloads and creates an Ubuntu instance. You'll be prompted to create a Unix username and password.
Use `dev` as the username to match the default configuration (or change the username in `flake.nix`).

If Ubuntu is already installed, you can create a fresh instance under a custom name:

```powershell
wsl --install Ubuntu --name awesome-dev-shell
```

Enter the instance:

```powershell
wsl -d Ubuntu
# or: wsl -d awesome-dev-shell
```

When setting up, use `dev` as user name (**important**) and set the password of your choice. Then, update the Ubuntu packages:

```bash
sudo apt update
sudo apt upgrade
```

### 2. Install the Nix package manager

We use the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer)
which enables flakes and the `nix` command out of the box:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Close and reopen your terminal (or run `source /etc/profile`) so that `nix` is on your PATH.

Verify the installation:

```bash
nix --version
```

### 3. Apply Awesome Dev Shell

Run Home Manager with the flake:

```bash
nix run home-manager -- switch --flake "github:artc0d3/awesome-dev-shell?ref=main#wsl"
```

This installs all packages and writes all configuration files. On the first run it may take a few
minutes to download and build everything.

### 4. Set zsh as default shell

```bash
echo $(which zsh) | sudo tee -a /etc/shells
chsh -s $(which zsh)
```

Log out and back in (or restart WSL) for the change to take effect.

### 5. Set up 1Password SSH agent (optional)

The setup forwards SSH requests from WSL to the 1Password SSH agent running on Windows, so you can
authenticate with SSH keys stored in 1Password without managing separate keys.

**On Windows:**

1. Install the 1Password desktop app and sign in.
2. Enable the SSH agent in 1Password: **Settings > Developer > SSH Agent**.
3. Install [npiperelay](https://github.com/jstarks/npiperelay) — needed to bridge the Windows
   named pipe to a Unix socket:

   ```powershell
   winget install --id=Jstarks.Npiperelay
   ```

   Restart your terminal after installation so `npiperelay.exe` is on your PATH.

**Back in WSL:**

The SSH agent bridge runs as a user-level systemd service (started automatically). Check its status:

```bash
systemctl --user status ssh-agent-bridge
```

### 6. Set up rootless Podman (optional)

Podman is installed by Home Manager, but rootless containers need a small amount of system-level
setup on Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y uidmap slirp4netns
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
