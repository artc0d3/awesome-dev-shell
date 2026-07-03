# OpenSSH Agent Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Linux-native OpenSSH agent (systemd user service) that serves Git SSH authentication and SSH commit signing, replacing the already-removed 1Password bridge.

**Architecture:** A new `modules/ssh.nix` enables `services.ssh-agent` (persistent systemd user service that also exports `SSH_AUTH_SOCK`) and `programs.ssh` with `AddKeysToAgent yes`. Git SSH commit signing is configured in the existing `modules/dev-tools.nix` alongside the rest of `programs.git`. `home.nix` imports and enables the new module. `README.md` documents the one-time `ssh-add` unlock flow.

**Tech Stack:** Nix flakes, Home Manager (release-26.05), OpenSSH, systemd user services.

## Global Constraints

- Home Manager release: **26.05** (pinned in `flake.nix`); use only options valid in that release.
- Platform-agnostic: no WSL/Windows-specific logic in the SSH module (WSL provides systemd, which is all the agent needs).
- Follow existing module pattern: `options.ads.<name>.enable = lib.mkEnableOption "…"; config = lib.mkIf cfg.enable { … };`.
- Signing key path is fixed: **`~/.ssh/signing-key.pub`**.
- The design spec this implements: `docs/superpowers/specs/2026-07-03-openssh-agent-design.md`.
- Keys are user-provided at runtime in `~/.ssh`; do NOT generate, template, or manage key files in Nix.

## File Structure

- **Create** `modules/ssh.nix` — SSH client + agent (`ads.ssh.enable`). One responsibility: SSH transport/agent.
- **Modify** `home.nix` — import `./modules/ssh.nix`, set `ads.ssh.enable = true`.
- **Modify** `modules/dev-tools.nix` — change `programs.git.signing` from `format = null` to the SSH signing block.
- **Modify** `README.md` — add the SSH setup section and refresh the Git loadout bullet.

---

### Task 1: SSH agent + client module

**Files:**
- Create: `modules/ssh.nix`
- Modify: `home.nix` (imports list + enable flag)

**Interfaces:**
- Produces: option `ads.ssh.enable` (bool, `mkEnableOption`). When true: `services.ssh-agent.enable = true`, `programs.ssh.enable = true`, `programs.ssh.addKeysToAgent = "yes"`. Home Manager's `services.ssh-agent` additionally exports `home.sessionVariables.SSH_AUTH_SOCK` (→ `$XDG_RUNTIME_DIR/ssh-agent`).
- Consumes: nothing from other tasks.

- [ ] **Step 1: Create `modules/ssh.nix`**

```nix
# Linux-native OpenSSH agent and client.
#
# Runs ssh-agent as a persistent systemd user service. Once a passphrase-protected
# key is unlocked with `ssh-add`, it stays available across all shells and to any
# process launched from them (e.g. coding agents), until the next reboot.
#
# This module handles SSH transport (auth). Git SSH *commit signing* is configured
# alongside git in dev-tools.nix, since it is git configuration.
{
  config,
  lib,
  ...
}:
let
  cfg = config.ads.ssh;
in
{
  options.ads.ssh = {
    enable = lib.mkEnableOption "Linux-native OpenSSH agent and client";
  };

  config = lib.mkIf cfg.enable {
    # Persistent user-level ssh-agent. Also exports SSH_AUTH_SOCK as a session
    # variable so interactive shells and their child processes inherit it.
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      # Cache the auth key in the agent on first use, for the rest of the session.
      addKeysToAgent = "yes";
    };
  };
}
```

- [ ] **Step 2: Add the import to `home.nix`**

In the `imports` list, add `./modules/ssh.nix` after `./modules/shell-tools.nix` (keeps the list sorted). The list becomes:

```nix
  imports = [
    ./modules/ads-tools.nix
    ./modules/ai.nix
    ./modules/dev-tools.nix
    ./modules/neovim.nix
    ./modules/op-wsl.nix
    ./modules/podman.nix
    ./modules/shell.nix
    ./modules/shell-tools.nix
    ./modules/ssh.nix
  ];
```

- [ ] **Step 3: Enable the module in `home.nix`**

After the `ads.shell-tools.enable = true;` line, add:

```nix
  ads.ssh.enable = true;
```

- [ ] **Step 4: Build and verify evaluation succeeds**

Run: `nix build ".#homeConfigurations.wsl.activationPackage" --no-link 2>&1 | tail -5; echo "EXIT: ${PIPESTATUS[0]}"`
Expected: builds without error, `EXIT: 0`.

- [ ] **Step 5: Verify the resolved config has the expected values**

Run:
```bash
nix eval ".#homeConfigurations.wsl.config.services.ssh-agent.enable"
nix eval ".#homeConfigurations.wsl.config.programs.ssh.addKeysToAgent"
```
Expected output:
```
true
"yes"
```

- [ ] **Step 6: Verify the generated ssh config contains AddKeysToAgent**

Run: `nix build ".#homeConfigurations.wsl.config.home-files" --no-link --print-out-paths | xargs -I{} grep -i "AddKeysToAgent" {}/.ssh/config`
Expected: a line containing `AddKeysToAgent yes`.

- [ ] **Step 7: Commit**

```bash
git add modules/ssh.nix home.nix
git commit -m "feat(ssh): add native OpenSSH agent and client module

Runs ssh-agent as a persistent systemd user service and writes
AddKeysToAgent yes into the ssh config, so an unlocked key stays
available to all shells and coding agents until reboot.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: Git SSH commit signing

**Files:**
- Modify: `modules/dev-tools.nix` (the `programs.git` block)

**Interfaces:**
- Consumes: the agent from Task 1 (the signing key must be in the agent for prompt-free signing; not a build-time dependency).
- Produces: git config `gpg.format = ssh`, `user.signingKey = ~/.ssh/signing-key.pub`, `commit.gpgSign = true`.

- [ ] **Step 1: Replace the signing config in `modules/dev-tools.nix`**

Change the existing `programs.git` block from:

```nix
    programs.git = {
      enable = true;
      signing.format = null;
    };
```

to:

```nix
    programs.git = {
      enable = true;
      signing = {
        # SSH-based commit signing; the private key is served by the ssh-agent
        # (see modules/ssh.nix). The signing key is expected at ~/.ssh/signing-key.
        format = "ssh";
        key = "~/.ssh/signing-key.pub";
        signByDefault = true;
      };
    };
```

- [ ] **Step 2: Build and verify evaluation succeeds**

Run: `nix build ".#homeConfigurations.wsl.activationPackage" --no-link 2>&1 | tail -5; echo "EXIT: ${PIPESTATUS[0]}"`
Expected: builds without error, `EXIT: 0`.

- [ ] **Step 3: Verify the resolved signing config**

Run:
```bash
nix eval ".#homeConfigurations.wsl.config.programs.git.signing.format"
nix eval --raw ".#homeConfigurations.wsl.config.programs.git.signing.key"; echo
nix eval ".#homeConfigurations.wsl.config.programs.git.signing.signByDefault"
```
Expected output:
```
"ssh"
~/.ssh/signing-key.pub
true
```

- [ ] **Step 4: Verify the generated gitconfig**

Run: `nix build ".#homeConfigurations.wsl.config.home-files" --no-link --print-out-paths | xargs -I{} grep -iE "format = ssh|signingkey|gpgsign" {}/.config/git/config`
Expected: lines showing `format = ssh`, a `signingkey = ~/.ssh/signing-key.pub`, and `gpgsign = true` (exact key casing/paths as emitted by Home Manager).

- [ ] **Step 5: Commit**

```bash
git add modules/dev-tools.nix
git commit -m "feat(ssh): sign Git commits with SSH key via the agent

Switch git signing from disabled to SSH format, using
~/.ssh/signing-key.pub and signing commits by default. Signatures
are produced through the ssh-agent, so no passphrase prompt once the
key is loaded.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: Document the SSH setup in README

**Files:**
- Modify: `README.md` (Getting Started section + the "Secrets & Git" loadout bullet)

**Interfaces:**
- Consumes: behavior established in Tasks 1–2 (agent, `AddKeysToAgent`, signing key path).
- Produces: user-facing docs only.

- [ ] **Step 1: Refresh the Git loadout bullet**

In the "Secrets & Git" list, change the git bullet from:

```markdown
- **git** — sensible defaults, ready for a Linux-native SSH agent.
```

to:

```markdown
- **git** — SSH authentication and commit signing via a Linux-native OpenSSH agent.
```

- [ ] **Step 2: Add the SSH setup section**

The "Set up rootless Podman (optional)" section is currently numbered `#### 5.`. Insert a new SSH section **before** it as `#### 5.`, and renumber the Podman heading to `#### 6.`.

Insert this new section:

```markdown
#### 5. Set up SSH keys (optional)

Git authentication and commit signing use a **Linux-native OpenSSH agent** running as a
persistent systemd user service. Store your passphrase-protected key(s) in `~/.ssh` and
unlock them once per boot; the agent then serves them to every shell — and to automated
tools such as coding agents — without further prompts.

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
```

- [ ] **Step 3: Renumber the Podman heading**

Change `#### 5. Set up rootless Podman (optional)` to `#### 6. Set up rootless Podman (optional)`.

- [ ] **Step 4: Verify README numbering and content**

Run: `grep -nE "^#### [0-9]\." README.md`
Expected: the Getting Started subsections are sequentially numbered 1–6 with no duplicate `5.` and the SSH section sitting at `5.` before Podman at `6.`.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: document native OpenSSH agent setup

Explain storing keys in ~/.ssh, the once-per-boot ssh-add unlock, the
signing-key convention, and the optional allowed_signers file for local
signature verification.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review

**Spec coverage:**
- Native agent as systemd user service → Task 1 (`services.ssh-agent.enable`). ✓
- `SSH_AUTH_SOCK` inherited by shells/coding agents → Task 1 (exported by the HM module). ✓
- `AddKeysToAgent yes` lazy auth loading → Task 1 (`programs.ssh.addKeysToAgent`). ✓
- SSH commit signing with `~/.ssh/signing-key.pub`, sign by default → Task 2. ✓
- `op-wsl` keeps only the CLI → already done in commit `b621dba` (out of this plan's scope). ✓
- Lazy unlock / `ssh-add` once per boot documented → Task 3 step 2. ✓
- Caveat 1 (`allowed_signers` deferred, documented as manual step) → Task 3 step 2 item 3. ✓
- Caveat 2 (signing does not auto-add) → Task 3 step 2 (explicit note). ✓
- README SSH section re-added → Task 3. ✓

**Placeholder scan:** No TBD/TODO; every code and command step contains concrete content. The `your.email@example.com` string is an intentional user-facing placeholder in documentation, not an unfilled plan gap.

**Type consistency:** Option name `ads.ssh.enable` used identically in Task 1 module and `home.nix`. Signing key path `~/.ssh/signing-key.pub` identical across spec, Task 2, and Task 3. `services.ssh-agent.enable`, `programs.ssh.addKeysToAgent`, and `programs.git.signing.{format,key,signByDefault}` are the correct Home Manager 26.05 option names.
