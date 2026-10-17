-- Git hunks in the sign column, with per-hunk staging, reset and blame.
-- Handy for reviewing a coding agent's changes hunk by hunk before committing.
-- The signs are rendered by Snacks.statuscolumn (see snacks.lua).
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		on_attach = function(buf)
			local gs = require("gitsigns")

			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
			end

			-- Navigation
			map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
			map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
			map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
			map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")

			-- Staging and resetting. stage_hunk toggles, so it also unstages a
			-- staged hunk. In visual mode only the selected lines are affected.
			map("n", "<leader>ghs", gs.stage_hunk, "Stage/unstage hunk")
			map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
			map("x", "<leader>ghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage/unstage lines")
			map("x", "<leader>ghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset lines")
			map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
			map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")

			-- Inspection
			map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
			map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
			map("n", "<leader>ghB", gs.blame, "Blame buffer")
			map("n", "<leader>ghd", gs.diffthis, "Diff this against index")
			map("n", "<leader>ght", gs.toggle_current_line_blame, "Toggle inline line blame")

			-- Text object: `ih` selects the hunk under the cursor, e.g. `dih`, `vih`
			map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
		end,
	},
}
