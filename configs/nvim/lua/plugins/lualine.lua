-- Status line widget.
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = function()
		-- Shows formatters applicable to the current buffer
		local function formatters()
			local ok, conform = pcall(require, "conform")
			if not ok then
				return ""
			end
			local names = vim.tbl_map(function(f)
				return f.name
			end, conform.list_formatters_to_run(0))
			return #names > 0 and ("󰉼 " .. table.concat(names, " ")) or ""
		end

		local function lsp_progress()
			local p = vim.lsp.status()
			return p ~= "" and "󰔟 " or ""
		end

		local opts = {
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = { "diff", "diagnostics" },
				lualine_x = { formatters, "lsp_status", lsp_progress, "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		}
		return opts
	end,
}
