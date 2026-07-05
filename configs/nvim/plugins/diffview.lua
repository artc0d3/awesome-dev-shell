return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff View Open" },
		{ "<leader>gx", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff File History" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diff Repo History" },
		{ "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diff View Close" },
	},
	opts = {},
}
