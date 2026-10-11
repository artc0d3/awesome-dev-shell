return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open (shows conflicts during merge/rebase)" },
		{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
	},
	opts = function()
		local actions = require "diffview.actions"

		return {
			keymaps = {
				disable_defaults = true,

				view = {
					-- Conflict resolution ("git conflict choose ...")
					{ "n", "<leader>gco", actions.conflict_choose "ours",   { desc = "Git Conflict: choose ours" } },
					{ "n", "<leader>gct", actions.conflict_choose "theirs", { desc = "Git Conflict: choose theirs" } },
					{ "n", "<leader>gcb", actions.conflict_choose "base",   { desc = "Git Conflict: choose base" } },
					{ "n", "<leader>gca", actions.conflict_choose "all",    { desc = "Git Conflict: choose all" } },
					{ "n", "<leader>gcd", actions.conflict_choose "none",   { desc = "Git Conflict: discard (choose none)" } },
					{ "n", "<leader>gcn", actions.next_conflict,            { desc = "Git Conflict: next conflict" } },
					{ "n", "<leader>gcp", actions.prev_conflict,            { desc = "Git Conflict: previous conflict" } },

					-- Panel/session navigation (kept close to plugin defaults;
					-- not part of the conflict-resolution mnemonic scheme)
					{ "n", "<tab>",   actions.select_next_entry, { desc = "Open diff for next file" } },
					{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Open diff for previous file" } },
					{ "n", "<cr>",    actions.select_entry,      { desc = "Open diff for selected entry" } },
					{ "n", "gf",      actions.goto_file_edit,    { desc = "Open file in a new split" } },
					{ "n", "<leader>b", actions.toggle_files,    { desc = "Toggle file panel" } },
					{ "n", "<leader>e", actions.focus_files,     { desc = "Focus file panel" } },
				},

				file_panel = {
					{ "n", "j",     actions.next_entry,        { desc = "Next file entry" } },
					{ "n", "k",     actions.prev_entry,        { desc = "Previous file entry" } },
					{ "n", "<cr>",  actions.select_entry,      { desc = "Open diff for selected entry" } },
					{ "n", "o",     actions.select_entry,      { desc = "Open diff for selected entry" } },
					{ "n", "R",     actions.refresh_files,     { desc = "Refresh file list" } },
					{ "n", "<tab>", actions.select_next_entry, { desc = "Open diff for next file" } },
					{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Open diff for previous file" } },
					{ "n", "<leader>b", actions.toggle_files,  { desc = "Toggle file panel" } },
					{ "n", "<leader>e", actions.focus_files,   { desc = "Focus file panel" } },
				},

				file_history_panel = {
					{ "n", "j",    actions.next_entry,   { desc = "Next entry" } },
					{ "n", "k",    actions.prev_entry,   { desc = "Previous entry" } },
					{ "n", "<cr>", actions.select_entry, { desc = "Open diff for selected entry" } },
				},
			},
		}
	end,
}
