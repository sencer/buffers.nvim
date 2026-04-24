if vim.g.loaded_buffers_nvim ~= nil then
	return
end
vim.g.loaded_buffers_nvim = true

vim.keymap.set("n", "<Leader>c", "<C-w>c")
vim.keymap.set("n", "<Leader>o", "<C-w>o")

vim.keymap.set("n", "<Leader>w", ":up!<CR>")
vim.keymap.set("n", "<Leader>x", ":x!<CR>")

vim.keymap.set("n", "<Leader>q", require("sencer.buf").smart_close)
vim.keymap.set("n", "<Leader>Q", ":qa<CR>")

vim.keymap.set("n", "<Leader>z", function()
	vim.cmd(#vim.api.nvim_tabpage_list_wins(0) == 1 and "tabclose" or "tab split")
end, { desc = "Toggle tab split or close" })

vim.keymap.set("n", "]b", require("sencer.buf").smart_next)
vim.keymap.set("n", "[b", require("sencer.buf").smart_prev)

vim.api.nvim_create_augroup("BufferOpts", { clear = true })

vim.api.nvim_create_autocmd("CmdwinEnter", {
	group = "BufferOpts",
	pattern = "*",
	callback = function(opts)
		vim.keymap.set("n", "<Leader>q", ":q<CR>", { buffer = opts.buf, silent = true })
	end,
})

-- Don't create backup for /dev/shm files.
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPre" }, {
	group = "BufferOpts",
	pattern = "/dev/shm/*",
	callback = function(opts)
		vim.bo[opts.buf].swapfile = false
		vim.bo[opts.buf].undofile = false
	end,
})

-- Go to most recent position.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = "BufferOpts",
	pattern = "*",
	callback = function(opts)
		local mark = vim.api.nvim_buf_get_mark(opts.buf, '"')
		local lnum = mark[1]
		local col = mark[2]
		local count = vim.api.nvim_buf_line_count(opts.buf)
		if lnum > 1 and lnum <= count then
			pcall(vim.api.nvim_win_set_cursor, 0, { lnum, col })
		end
	end,
})
