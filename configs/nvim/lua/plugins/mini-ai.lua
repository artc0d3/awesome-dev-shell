-- Extended a/i text objects: brackets, quotes, function calls (f), arguments
-- (a), tags (t), and more, plus "next"/"last" variants such as `cin(` or `dal"`.
return {
	"nvim-mini/mini.ai",
	event = "VeryLazy",
	opts = {
		-- Search this many lines around the cursor for a matching object
		-- (default 50), so objects spanning larger blocks are still found.
		n_lines = 500,
	},
}
