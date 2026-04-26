# Awesome dev shell

A batteries-included, opinionated **NixOS-on-WSL** environment that turns a fresh Windows laptop into a proper dev box
in a few commands — no manual `apt install` marathons, no "works on my machine."

🎯 **Built for** software developers living mostly in the **Node.js** and **Java/JVM** worlds who want a polished
Linux shell on Windows without becoming part-time sysadmins.

✨ **What you get:**

- 🧊 **Reproducible** — one Nix flake describes the whole setup; rebuild it anywhere, get the same shell.
- ⚡ **Fast & modern CLI** — zsh + starship + the full `eza`/`bat`/`fd`/`ripgrep` lineup out of the box.
- 🔁 **Polyglot runtimes** — `vfox` for Node/Java/Go/Python versions, `uv` for Python projects.
- 🐳 **Containers ready** — rootless podman with Docker compatibility.
- 🔐 **1Password-native** — secrets and SSH keys flow in from your Windows vault automatically.
- 🤖 **AI on tap** — `claude-code` pre-installed for pair-programming from the terminal.

If that sounds like your kind of Tuesday, read on. ⬇️

## Loadout

Built on **NixOS 25.11** (via [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)) with home-manager 25.11 managing
the user environment.

### 🐚 Shell & prompt

- **zsh** + **oh-my-zsh** — the shell, with autosuggestions and syntax highlighting baked in.
- **starship** — fast, minimal, infinitely customizable prompt.
- **zoxide** — `cd` that learns where you actually go.
- **fzf** — fuzzy finder for files, history, and anything piped into it.

### 🛠️ Modern CLI essentials

- **eza** — a friendlier `ls` with icons and git status.
- **bat** — `cat` with syntax highlighting and paging.
- **fd** — a faster, saner `find`.
- **ripgrep** — blazing-fast recursive grep.
- **sd** — intuitive `sed` replacement for find-and-replace.
- **jq** — slice and dice JSON from the command line.
- **cloc** — count lines of code, grouped by language.

### ✍️ Editor

- **neovim** — modal editing, configured to taste.

### 📦 Dev tooling & version managers

- **vfox** — polyglot version manager (Node, Python, Go, JDK, …).
- **uv** — ultra-fast Python package and project manager.

### 🐳 Containers

- **podman** (with Docker compat) — daemonless, rootless container runtime.
- **podman-compose** — `docker-compose` for podman.

### 🔐 Secrets & Git

- **1Password CLI** — pull secrets and SSH keys straight from your vault.
- **git** — wired up to use the 1Password SSH agent via `ssh.exe`.

### 🤖 AI

- **claude-code** — Anthropic's official CLI for pair-programming with Claude.

## Installation

1. Make sure WSL2 is installed and enabled on your Windows machine. You can follow the official Microsoft documentation
   to set up WSL2: [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install).
2. Download the release tarball for NixOS-WSL 25.11
   from [nix-community/NixOS-WSL GitHub releases](https://github.com/nix-community/NixOS-WSL/releases/tag/2511.7.1).
3. Import it into WSL:
    ```bash
    # From the directory where you downloaded the tarball:
    wsl --import nixos "$HOME\nixos" nixos.wsl --version 2
    ```
4. Enter the NixOS shell:
    ```bash
    wsl -d nixos
    ```
5. Update the package list and install updates:
    ```bash
    sudo nix-channel --update
    sudo nixos-rebuild switch
    ```
6. Apply awesome-dev-shell configuration:
    ```bash
    sudo nixos-rebuild switch --flake "github:artc0d3/awesome-dev-shell?ref=main#wsl" --no-write-lock-file --refresh
    ```

### 1Password

To use 1Password CLI, you need to have 1Password installed on your Windows machine and be signed in to your account.
The 1Password CLI will be available in the NixOS shell, allowing you to manage your secrets directly from the terminal.
Git is already configured to use 1Password SSH agent.

Follow these steps to make sure that 1Password CLI works in the NixOS shell:

1. Install 1Password desktop app on your Windows machine and sign in to your account.
2. Setup 1Password as your SSH agent. You can follow the official 1Password documentation to do
   this: [1Password SSH Agent](https://developer.1password.com/docs/ssh/agent/).
3. In NixOS shell, ensure that WSL interop is enabled:
    ```bash
    cat /etc/wsl.conf
   
    # Should contain this section:
    [interop]
    appendWindowsPath=true
    enabled=true
    ```

## Customization

This project is **not** meant to be a DIY project where you pick and choose your tools; it's more of a ready-made
setup that you can use as-is or fork and modify if you want to maintain your own version.

Once installed, the setup is rather rigid with only few customization possibilities. Nix disallows editing configuration
files managed by it, so you won't be able to change the Nix-managed configuration directly. There are few escape hatches
for the most common extension points though.

### ZSH

You can include your own ZSH configuration in `~/.zshrc.local`, which is sourced at the end of the main `~/.zshrc`.

### Other tools

Most of the personal configuration living somewhere in you home directory is not managed by Nix and can be edited
directly.
