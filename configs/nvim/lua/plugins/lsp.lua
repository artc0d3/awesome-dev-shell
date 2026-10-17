return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		opts = {
			-- Listed first so it takes precedence over the official registry.
			-- See lua/mason-registry-custom/init.lua
			registries = {
				"lua:mason-registry-custom",
				"github:mason-org/mason-registry",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)

					-- Bind key to an action
					local function map(lhs, rhs, desc, mode, opts)
						vim.keymap.set(
							mode or "n",
							lhs,
							rhs,
							vim.tbl_extend("force", {
								buffer = args.buf,
								silent = true,
								desc = desc,
							}, opts or {})
						)
					end

					-- Check if given LSP method is supported
					local function supports(method)
						if type(method) == "string" then
							return client:supports_method(method)
						end
						for _, m in ipairs(method) do
							if client:supports_method(m) then
								return true
							end
						end
						return false
					end

					-- Bind key to an action if the given LSP method is supported
					local function map_if(lhs, method, rhs, desc, mode, opts)
						if supports(method) then
							map(lhs, rhs, desc, mode, opts)
						end
					end

					map("<leader>cl", function()
						Snacks.picker.lsp_config()
					end, "Lsp Info")
					map_if("<leader>ca", "textDocument/codeAction", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
					map_if("<leader>cc", "textDocument/codeLens", vim.lsp.codelens.run, "Run Codelens", { "n", "x" })
					map_if("<leader>cC", "textDocument/codeLens", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
					map_if("<leader>ci", "callHierarchy/incomingCalls", vim.lsp.buf.incoming_calls, "Incoming calls")
					map_if("<leader>cr", "textDocument/rename", vim.lsp.buf.rename, "Rename")
					map_if("<leader>cs", "textDocument/documentSymbol", function()
						Snacks.picker.lsp_symbols()
					end, "Buffer symbols")
					map_if("<leader>cS", "workspace/symbol", function()
						Snacks.picker.lsp_workspace_symbols()
					end, "Workspace symbols")
					map_if("<leader>ct", "textDocument/prepareTypeHierarchy", vim.lsp.buf.typehierarchy, "Show type hierarchy")
					map_if("<leader>cT", "textDocument/typeDefinition", function()
						Snacks.picker.lsp_type_definitions()
					end, "Show type hierarchy")
					map_if("<leader>cR", {
						"workspace/didRenameFiles",
						"workspace/willRenameFiles",
					}, function()
						Snacks.rename.rename_file()
					end, "Rename File")
					map_if("gd", "textDocument/definition", vim.lsp.buf.definition, "Goto Definition")
					map_if("gD", "textDocument/declaration", vim.lsp.buf.declaration, "Goto Declaration")
					map_if("gr", "textDocument/references", function()
						Snacks.picker.lsp_references()
					end, "References", nil, { nowait = true })
					map_if("gi", "textDocument/implementation", vim.lsp.buf.implementation, "Goto Implementation")
					map_if("gT", "textDocument/typeDefinition", vim.lsp.buf.type_definition, "Goto Type Definition")
					map_if("gK", "textDocument/signatureHelp", function()
						return vim.lsp.buf.signature_help()
					end, "Signature Help")
					map_if("K", "textDocument/hover", function()
						return vim.lsp.buf.hover()
					end, "Hover")
				end,
			})
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"kotlin_lsp", "lua_ls", "vtsls",
				"marksman", "jsonls", "yamlls", "taplo", "bashls", "html", "cssls",
			},
			automatic_enable = true,
		},
	},
}
