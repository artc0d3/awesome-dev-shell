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

### Installation

Make sure WSL2 is installed and enabled on Windows, then run from an elevated PowerShell prompt:

```powershell
irm https://raw.githubusercontent.com/artc0d3/awesome-dev-shell/main/install.ps1 | iex
```

When it finishes, launch your new shell with `wsl -d <distro-name>` (or just `wsl` if you set it as
the default).

### Configuration

That are few manual steps that you might want to perform just after the installation.

#### Set up SSH keys

Git authentication and commit signing use a **Linux-native OpenSSH agent** running as a
persistent systemd user service. Store your passphrase-protected key(s) in `~/.ssh` and
unlock them once per boot; the agent then serves them to every shell — and to any tool
launched from a shell, such as a coding agent — without further prompts.

1. Place your key(s) in `~/.ssh`:
   - **Authentication:** Authentication key used to sign-in into Git repositories. Expected at location `~/.ssh/id-key` (public half `~/.ssh/signing-key.pub`).
   - **Commit signing:** Key used to sign your commits. Expected at location `~/.ssh/signing-key` (public half `~/.ssh/signing-key.pub`).

2. After each WSL boot, you will be prompted for every key passphrase. After unlocking, the keys will be available in the SSH agent without any further manual input.

3. To verify Git commit signatures locally (`git log --show-signature`, `git verify-commit`), populate the **allowed-signers file** located in `~/.config/git/allowed_signers`.
   Each line maps one or more principals (emails) to a public key. The key portion is exactly the contents of your `~/.ssh/signing-key.pub`. A sample line looks like:

   ```
   your.email@example.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your@host
   ```

   The quickest way to add your own entry:

   ```bash
   mkdir -p ~/.config/git
   echo "your.email@example.com $(cat ~/.ssh/signing-key.pub)" >> ~/.config/git/allowed_signers
   ```

#### Setup Git identity

You can setup your global Git identity via the following commands:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## Updating

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
