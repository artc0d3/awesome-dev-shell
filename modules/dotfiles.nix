# Location of this repository's working tree on the target machine.
#
# Several configs are linked into place with out-of-store symlinks
# (config.lib.file.mkOutOfStoreSymlink) rather than copied into the immutable
# Nix store. That lets them be edited live in the checked-out repo — changes
# take effect immediately, are committed straight to git, and can be restored
# with `git checkout` — without redeploying Home Manager. Such a symlink points
# at an absolute path, which is what this option supplies.
{
  config,
  lib,
  ...
}:
{
  options.ads.dotfilesRoot = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/code/awesome-dev-shell";
    example = "/home/dev/code/awesome-dev-shell";
    description = ''
      Absolute path to this repository's working tree on the target machine.
      Used as the target for out-of-store symlinks (nvim, nono, tmux, tuicr, ...), so
      those configs can be edited in place and committed without a redeploy.

      The repository MUST be checked out at this path for the links to resolve;
      override it here (or in a host module) if you clone it elsewhere.
    '';
  };
}
