-- Highlights TODO/FIXME/HACK/NOTE/... comments and makes them searchable.
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TodoTrouble" },
	opts = {},
	keys = {
		{ "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
		{ "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
		{ "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo comments" },
		{
			"<leader>sT",
			function()
				Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
			end,
			desc = "Todo/Fix/Fixme comments",
		},
		{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo comments (Trouble)" },
	},
}
