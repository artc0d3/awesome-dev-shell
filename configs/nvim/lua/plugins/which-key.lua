return {
	"folke/which-key.nvim",
	dependencies = { "nvim-mini/mini.icons" },
	event = "VeryLazy",
	opts = {
		preset = "helix",
		spec = {
			{ "<leader>b", group = "Buffer" },
			{ "<leader>c", group = "Code" },
			{ "<leader>f", group = "Files" },
			{ "<leader>g", group = "Git" },
			{ "<leader>s", group = "Search" },
			{ "<leader>t", group = "Tasks" },
			{ "<leader>w", group = "Window" },
			{ "<leader>x", group = "Diagnostics" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
