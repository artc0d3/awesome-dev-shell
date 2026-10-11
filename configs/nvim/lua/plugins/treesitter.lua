return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			local ts = require("nvim-treesitter")

			-- Install parsers on startup
			ts.install({
				"kotlin",
				"lua",
				"typescript",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
			})

			-- Auto-install parser when opening a filetype with a known parser
			local parsers = require("nvim-treesitter.parsers")
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if lang and parsers[lang] then
						pcall(ts.install, { lang })
					end
				end,
			})
		end,
	},
}
