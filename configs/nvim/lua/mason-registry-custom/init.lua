-- Custom Mason registry.
--
-- Registered via `registries` in lua/plugins/lsp.lua as "lua:mason-registry-custom".
-- Mason resolves packages by iterating registries in order, so every package
-- listed here shadows the one from the official mason-registry.
--
-- Keys are package names, values are modules returning a registry+v1 spec.
return {
  ["kotlin-lsp"] = "mason-registry-custom.packages.kotlin-lsp",
}
