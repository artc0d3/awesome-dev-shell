return {
	"folke/flash.nvim",
	event = "VeryLazy",
	vscode = true,
	---@type Flash.Config
	opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
    { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    -- Simulate nvim-treesitter incremental selection
    {
      "<C-s>",
      mode = { "n", "o", "x" },
      function()
        require("flash").treesitter({
          actions = {
            ["<C-s>"] = "next",
            ["<BS>"] = "prev"
          }
        })
      end,
      desc = "Treesitter Incremental Selection"
    },
  },
}
