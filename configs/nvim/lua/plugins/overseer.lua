return {
	"stevearc/overseer.nvim",
	cmd = { "OverseerRun", "OverseerToggle", "OverseerInfo" },
	keys = {
		{ "<leader>tl", "<cmd>OverseerToggle<cr>", desc = "Task list" },
		{ "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Run task" },
	},
	opts = {},
}
