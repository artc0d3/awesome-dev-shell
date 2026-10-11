return {
	"stevearc/conform.nvim",
	dependencies = { "mason.nvim" },
	lazy = true,
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format()
			end,
			mode = { "n", "x" },
			desc = "Format",
		},
		{
			"<leader>cF",
			function()
				require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
			end,
			mode = { "n", "x" },
			desc = "Format Injected Langs",
		},
	},
	opts = {
		default_format_opts = {
			timeout_ms = 3000,
			async = false,
			quiet = false,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			kotlin     = { "ktlint" },
			lua        = { "stylua" },
			sh         = { "shfmt" },
			bash       = { "shfmt" },
			markdown   = { "prettier" },
			json       = { "prettier" },
			jsonc      = { "prettier" },
			yaml       = { "prettier" },
			toml       = { "taplo" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			html       = { "prettier" },
			css        = { "prettier" },
		},
		formatters = {
			injected = { options = { ignore_errors = true } },
			-- # Example of using dprint only when a dprint.json file is present
			-- dprint = {
			--   condition = function(ctx)
			--     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
			--   end,
			-- },
			--
			-- # Example of using shfmt with extra args
			-- shfmt = {
			--   prepend_args = { "-i", "2", "-ci" },
			-- },
		},
	},
}
