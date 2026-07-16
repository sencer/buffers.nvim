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

	-- If this is an unlisted buffer, like a quickfix window, just close it.
	if vim.fn.buflisted(vim.fn.bufnr()) == 0 then
		vim.cmd("q")
		return
	end

	-- If there are multiple buffers, just delete the buffer.
	if nbuffers > 1 then
		vim.cmd("confirm bd")
		return
	end

	-- Otherwise close everything.
	vim.cmd("qa")
end

local function smart_next_buffer(fwd)
	local visible = {}
	for i = 1, vim.fn.winnr("$") do
		visible[vim.fn.winbufnr(i)] = true
	end

	local listed = vim.tbl_map(function(b) return b.bufnr end, vim.fn.getbufinfo({ buflisted = 1 }))
	local nlisted = #listed
	if nlisted == 0 then return end

	local curbuf = vim.fn.bufnr()
	local cur_idx = 1
	for i, b in ipairs(listed) do
		if b == curbuf then
			cur_idx = i
			break
		end
	end

	local dir = fwd and 1 or -1
	for step = 1, nlisted do
		local idx = ((cur_idx - 1 + step * dir) % nlisted) + 1
		local buf = listed[idx]
		if not visible[buf] then
			vim.cmd("b" .. buf)
			return
		end
	end

	vim.cmd(fwd and "bnext" or "bprev")
end

M.smart_next = function()
	smart_next_buffer(true)
end

M.smart_prev = function()
	smart_next_buffer(false)
end

return M
