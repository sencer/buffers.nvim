if vim.g.loaded_buffers_nvim ~= nil then
	return
end
vim.g.loaded_buffers_nvim = true

vim.keymap.set("n", "<Leader>c", "<C-w>c", { remap = false })
vim.keymap.set("n", "<Leader>o", "<C-w>o", { remap = false })

vim.keymap.set("n", "<Leader>w", ":up!<CR>", { remap = false })
vim.keymap.set("n", "<Leader>x", ":x!<CR>", { remap = false })

vim.keymap.set("n", "<Leader>q", require("sencer.buf").smart_close, { remap = false })
vim.keymap.set("n", "<Leader>Q", ":qa<CR>", { remap = false })

vim.keymap.set("n", "<Leader>z", "winnr('$')==1?':tabclose<CR>':':tab split<CR>'", { remap = false, expr = true })

vim.keymap.set("n", "]b", require("sencer.buf").smart_next, { remap = false })
vim.keymap.set("n", "[b", require("sencer.buf").smart_prev, { remap = false })

vim.api.nvim_create_augroup("BufferOpts", { clear = false })
vim.api.nvim_create_autocmd("CmdwinEnter", {
	group = "BufferOpts",
	pattern = "*",
	command = "nnoremap <buffer> <Leader>q :q<CR>",
})

-- Don't create backup for /dev/shm files.
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPre" }, {
	group = "BufferOpts",
	pattern = "/dev/shm/*",
	command = "setlocal noswapfile noundofile",
})

-- Go to most recent position.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = "BufferOpts",
	pattern = "*",
	command = [[
        if line("'\"") > 1 && line("'\"") <= line("$") |
          exe "normal! g`\"" |
        endif
  ]],
})
