# Project description

Awesome Dev Shell is a batteries-included, opinionated Home Manager environment that turns a fresh
Ubuntu-WSL (or any Linux with Nix) instance into a proper dev box in a few commands — no manual
`apt install` marathons, no "works on my machine."

## Guidelines

* Keep the configuration platform-agnostic whenever possible.
* Isolate host-specific configuration (e.g. WSL-specific hacks) in separate files, and keep the main configuration as clean and cross-platform as possible.
* Isolate well-defined components (e.g. the shell setup) in their own files to improve readability and maintainability.
* Use descriptive names for configuration files to make it clear what each one is responsible for.
* Always prefer declarative configuration over imperative scripts, leveraging the power of Nix flakes to ensure reproducibility and ease of maintenance.
* Adhere to the principle of least surprise: the configuration should do what a reasonably experienced user would expect it to do, without hidden side effects or non-obvious behavior.
* Document any non-trivial configuration choices or workarounds in the code comments to aid future maintainers (including future you).

## Project structure

* `./flake.nix` — the Nix flake that exposes `homeConfigurations.wsl` (and future platform targets).
* `./home.nix` — the main Home Manager entry point; imports all modules and enables features.
* `./modules/*.nix` — feature-specific Home Manager modules (shell, neovim, dev-tools, etc.).
* `./ads/` — the ADS CLI tool for seeding configuration templates.
* `./configs/` — static configuration files grouped by the tool they belong to.
