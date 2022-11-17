local M = {}

M.smart_close = function()
	-- Number of listed buffers.
	local nbuffers = #vim.fn.getbufinfo({ buflisted = 1 })

	-- Plus, number of help buffers that is *visible*.
	for i = 1, vim.fn.winnr("$") do
		local buf = vim.fn.winbufnr(i)
		if vim.fn.getbufvar(buf, "&bt") == "help" then
			nbuffers = nbuffers + 1
		end
	end

	-- If there are multiple buffers, just delete the buffer.
	if nbuffers > 1 then
		vim.cmd("bd")
		return
	end

	-- If this is an unlisted buffer, like a quickfix window, just close it.
	if vim.fn.buflisted(vim.fn.bufnr()) == 0 then
		vim.cmd("q")
		return
	end

	-- Otherwise close everything.
	vim.cmd("qa")
end

local function smart_next_buffer(fwd, start)
	local dir = fwd and 1 or -1
	local curbuf = start and start or vim.fn.bufnr()

	-- Get buffers already visible.
	local visible = {}
	for i = 1, vim.fn.winnr("$") do
		visible[vim.fn.winbufnr(i)] = true
	end

	-- If all available buffers are visible then use bnext/bprev.
	if #visible == #vim.fn.getbufinfo({ buflisted = 1 }) then
		vim.cmd(fwd and "bnext" or "bprev")
		return
	end

	-- Otherwise load the next non-visible.
	local theend = fwd and vim.fn.bufnr("$") or 1
	for buf = curbuf + dir, theend, dir do
		if not visible[buf] then
			vim.cmd("b" .. buf)
			return
		end
	end

	smart_next_buffer(fwd, fwd and 0 or vim.fn.bufnr("$") + 1)
end

M.smart_next = function()
	smart_next_buffer(true)
end

M.smart_prev = function()
	smart_next_buffer(false)
end

return M

-- nnoremap <silent> ]b :call <SID>next_buffer(1)<CR>
-- nnoremap <silent> [b :call <SID>next_buffer(0)<CR>
--
-- " Functions {{{
-- function! s:next_buffer(fwd) abort
--   let s:buffers = []
--   for s:buf in getbufinfo({'buflisted': 1})
--     if s:buf.hidden || !s:buf.loaded
--       call add(s:buffers, s:buf.bufnr)
--     endif
--   endfor
--
--   if empty(s:buffers)
--     if a:fwd | bnext | else | bprev | endif
--     return
--   endif
--
--   let s:i = 0
--   let s:bufnr = bufnr()
--   while  s:i < len(s:buffers) && s:buffers[s:i] < s:bufnr
--     let s:i += 1
--   endwhile
--
--   if a:fwd
--     exec 'b'.(s:i < len(s:buffers) ? s:buffers[s:i] : s:buffers[0])
--   else
--     exec 'b'.(s:i > 0 ? s:buffers[s:i-1] : s:buffers[-1])
--   end
--
-- endfunction
