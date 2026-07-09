# Awesome Dev Shell

A batteries-included, opinionated **Home Manager** environment that turns a fresh machine into a
proper dev box in a few commands — no manual package-manager marathons, no "works on my machine."

Supports **Ubuntu on WSL2** and **macOS**.

**What you get:**

- **Reproducible** — one Nix flake describes the whole setup; rebuild it anywhere, get the same shell.
- **Modern shell** — zsh + starship + the full `eza`/`bat`/`fd`/`ripgrep` lineup out of the box.
- **Polyglot runtimes** — `mise` for SDK management.
- **Containers ready** — podman (WSL) or Colima (macOS) with Docker compatibility.
- **AI on tap** — `claude-code` and `pi` pre-installed for pair-programming from the terminal.

## Loadout

Built on **Nix** with **Home Manager 26.05** managing the user environment.

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

- **podman** + **podman-compose** — daemonless, rootless container runtime with Docker compatibility *(WSL only)*.
- **Colima** + **docker CLI** — lightweight macOS container runtime, auto-started on login *(macOS only)*.

### Secrets & Git

- **1Password CLI** — pull secrets straight from your vault (e.g. `op inject`) *(WSL only)*.
- **git** — SSH authentication and commit signing via a persistent OpenSSH agent.

### AI

- **claude-code** — Anthropic's official CLI for pair-programming with Claude.
- **pi** - ultra-light customizable coding agent.
- **nono** - coding agent sandboxing.

## Getting started

### macOS

#### Prerequisites

- **Xcode Command Line Tools** — run `xcode-select --install` and follow the prompt.
- **Nix** — install via the [Determinate Systems installer](https://determinate.systems/nix/), which handles the macOS APFS volume correctly and enables flakes by default:

  ```bash
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  ```

#### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/artc0d3/awesome-dev-shell.git ~/awesome-dev-shell
   cd ~/awesome-dev-shell
   ```

2. Open `flake.nix` and set your macOS username (the output of `whoami`) on the marked line:

   ```nix
   username = "changeme"; # ← set this to your macOS username
   ```

3. Apply the configuration (this may take a while):

   ```bash
   nix run home-manager/release-26.05 -- switch --flake .#mac
   ```

4. Start Colima once manually:

   ```bash
   colima start
   ```

   From the next login onwards, Colima starts automatically.

---

### WSL

Make sure WSL2 is installed and enabled on Windows, then run from an elevated PowerShell prompt:

```powershell
irm https://raw.githubusercontent.com/artc0d3/awesome-dev-shell/main/install.ps1 | iex
```

When it finishes, launch your new shell with `wsl -d <distro-name>` (or just `wsl` if you set it
as the default).

---

### Set up SSH keys

Applies to both macOS and WSL. `keychain` maintains a single long-lived SSH agent per machine and
loads your keys into it. A passphrase is entered once after each reboot; from then on the agent
serves the keys to every shell and any tool launched from one (e.g. a coding agent).

1. Place your key(s) in `~/.ssh`:
   - **Authentication key** — used to authenticate with Git hosts. Expected at `~/.ssh/id-key`.
   - **Commit-signing key** — used to sign commits. Expected at `~/.ssh/signing-key` (public half at `~/.ssh/signing-key.pub`).

2. After each boot you will be prompted for each key's passphrase once. After unlocking, the keys
   remain available without further manual input.

3. To verify Git commit signatures locally (`git log --show-signature`, `git verify-commit`),
   populate the **allowed-signers file** at `~/.config/git/allowed_signers`. Each line maps one or
   more email addresses to a public key — the key portion is the contents of `~/.ssh/signing-key.pub`:

   ```
   your.email@example.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your@host
   ```

   The quickest way to add your own entry:

   ```bash
   mkdir -p ~/.config/git
   echo "your.email@example.com $(cat ~/.ssh/signing-key.pub)" >> ~/.config/git/allowed_signers
   ```

### Set up Git identity

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## Updating

If you've cloned the repo locally and made changes, apply them with:

```bash
# macOS
nix run home-manager/release-26.05 -- switch --flake .#mac

# WSL
home-manager switch --flake .#wsl
```

To pull and apply the latest remote version without cloning:

```bash
# macOS
nix run home-manager/release-26.05 -- switch --flake "github:artc0d3/awesome-dev-shell?ref=main#mac" --refresh

# WSL
nix run home-manager -- switch --flake "github:artc0d3/awesome-dev-shell?ref=main#wsl" --refresh
```

## Customization

This project is **not** meant to be a DIY project where you pick and choose your tools; it's more of
a ready-made setup that you can use as-is or fork and modify if you want to maintain your own version.

Once installed, the setup is rather rigid with only a few customization possibilities. Nix disallows
editing configuration files it manages directly. There are a few escape hatches for the most common
extension points.

### ZSH

You can include your own ZSH configuration in `~/.zshrc.local`, which is sourced at the end of the
main `~/.zshrc`.

### Configuration templates

Some config files can't be managed by Nix because tools need to modify them at runtime. ADS ships
opinionated templates and copies them on demand — once copied, the files are yours to edit freely.

```bash
ads config list          # show available tools and their config files
ads config init <tool>   # copy templates (skips existing files)
```

### Git configuration

Git's base configuration (commit signing, allowed signers path) is managed by Nix and lives at
`~/.config/git/config` — do not edit it directly, as it is an immutable symlink into the Nix store.

For personal overrides (identity, aliases, local preferences), use `~/.gitconfig`. The setup seeds
an empty one on first install so that `git config --global` commands have a writable target. Anything
written there takes precedence over the Nix-managed config.

### Other tools

Most personal configuration living in your home directory is not managed by Nix and can be edited
directly.
