-- Kotlin LSP, pinned to a build newer than the one in the official mason-registry
-- (which is stuck on 262.9593.0 and does not start).
--
-- Download URLs come from:
-- https://github.com/Kotlin/kotlin-lsp/issues/270#issuecomment-5551783635
--
-- To bump: change `version` below and check that the archive still unpacks into
-- kotlin-server-<version>/bin/intellij-server.
local version = "263.4421.0"

local base = "https://download.jetbrains.com/language-server/kotlin-server/" .. version

---@param archive string
local function url(archive)
  return ("%s/kotlin-server-%s%s"):format(base, version, archive)
end

local unix_bin = ("kotlin-server-%s/bin/intellij-server"):format(version)

return {
  schema = "registry+v1",
  name = "kotlin-lsp",
  description = "Kotlin Language Server and plugin for Visual Studio Code",
  homepage = "https://github.com/Kotlin/kotlin-lsp",
  licenses = { "Apache-2.0" },
  languages = { "Kotlin" },
  categories = { "LSP" },

  source = {
    id = "pkg:generic/Kotlin/kotlin-lsp@" .. version,
    download = {
      {
        target = "darwin_x64",
        files = { ["kotlin-lsp.zip"] = url ".sit" },
        bin = unix_bin,
      },
      {
        target = "darwin_arm64",
        files = { ["kotlin-lsp.zip"] = url "-aarch64.sit" },
        bin = unix_bin,
      },
      {
        target = "linux_x64",
        files = { ["kotlin-lsp.tar.gz"] = url ".tar.gz" },
        bin = unix_bin,
      },
      {
        target = "linux_arm64",
        files = { ["kotlin-lsp.tar.gz"] = url "-aarch64.tar.gz" },
        bin = unix_bin,
      },
      {
        target = "win_x64",
        files = { ["kotlin-lsp.zip"] = url ".win.zip" },
        bin = "bin/intellij-server.exe",
      },
      {
        target = "win_arm64",
        files = { ["kotlin-lsp.zip"] = url "-aarch64.win.zip" },
        bin = "bin/intellij-server.exe",
      },
    },
  },

  bin = {
    ["intellij-server"] = "{{source.download.bin}}",
  },

  neovim = {
    lspconfig = "kotlin_lsp",
  },
}
