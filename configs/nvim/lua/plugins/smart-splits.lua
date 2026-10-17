-- Smart pane navigation, integrates with tmux.
--
-- Must not be lazy loaded: the marker is only set once setup() runs. The tmux
-- bindings wrap at the edge, matching the default `move.at_edge = "wrap"`.
return {
	"mrjones2014/smart-splits.nvim",
	lazy = false,
	dependencies = {
		{ "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
	},
	opts = {
		mux = { backend = "smart-splits-backend-tmux" },
	},
	keys = {
		{
			"<C-h>",
			function()
				require("smart-splits").move_cursor_left()
			end,
			desc = "Move to left split",
		},
		{
			"<C-j>",
			function()
				require("smart-splits").move_cursor_down()
			end,
			desc = "Move to below split",
		},
		{
			"<C-k>",
			function()
				require("smart-splits").move_cursor_up()
			end,
			desc = "Move to above split",
		},
		{
			"<C-l>",
			function()
				require("smart-splits").move_cursor_right()
			end,
			desc = "Move to right split",
		},
	},
}
