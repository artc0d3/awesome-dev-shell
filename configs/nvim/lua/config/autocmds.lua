-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Reload buffers changed on disk by something else, e.g. a coding agent in
-- another tmux pane. 'autoread' alone only acts when Neovim happens to check
-- the file, so trigger the check on focus (tmux forwards focus events, see
-- `focus-events` in tmux.conf), on buffer switch, and after the cursor has
-- rested for 'updatetime'. Buffers with unsaved edits are never overwritten;
-- Neovim asks instead.
vim.o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'TermLeave' }, {
  desc = 'Reload files changed outside of Neovim',
  group = vim.api.nvim_create_augroup('checktime', { clear = true }),
  callback = function()
    -- checktime is not allowed in the command-line window
    if vim.fn.getcmdwintype() == '' then vim.cmd.checktime() end
  end,
})
