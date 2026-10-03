-- Explicit descriptions for Neovim's built-in jumplist navigation, so they
-- show up with labels in which-key instead of relying on undocumented defaults.
vim.keymap.set("n", "<C-o>", "<C-o>", { desc = "Jump Backward" })
vim.keymap.set("n", "<C-i>", "<C-i>", { desc = "Jump Forward" })
