-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
      end,
  },
}

-- Buffer management
vim.keymap.set('n', '<leader>bd', function() Snacks.bufdelete() end,          { desc = 'Delete buffer' })
vim.keymap.set('n', '<leader>bD', function() Snacks.bufdelete({ wipe = true }) end, { desc = 'Delete buffer and window' })
vim.keymap.set('n', '<leader>bb', '<cmd>e #<cr>',                             { desc = 'Switch to last buffer' })
vim.keymap.set('n', '<leader>bo', function() Snacks.bufdelete.other() end,    { desc = 'Delete other buffers' })
vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>',             { desc = 'Toggle pin buffer' })
vim.keymap.set('n', '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<cr>',  { desc = 'Delete non-pinned buffers' })

-- Window management
vim.keymap.set('n', '<leader>wd', '<cmd>close<cr>',      { desc = 'Close window' })
vim.keymap.set('n', '<leader>ww', '<C-w>w',              { desc = 'Switch window' })
vim.keymap.set('n', '<leader>w-', '<cmd>split<cr>',      { desc = 'Split window below' })
vim.keymap.set('n', '<leader>w|', '<cmd>vsplit<cr>',     { desc = 'Split window right' })

-- Jump list navigation
vim.keymap.set('n', '<C-o>', '<C-o>', { desc = 'Jump Backward' })
vim.keymap.set('n', '<C-i>', '<C-i>', { desc = 'Jump Forward' })
