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
	-- Get buffers already visible.
	local visible = {}
	for i = 1, vim.fn.winnr("$") do
		visible[vim.fn.winbufnr(i)] = true
	end

	-- If all available buffers are visible then use bnext/bprev.
	local listed = vim.fn.map(vim.fn.getbufinfo({ buflisted = 1 }), "v:val.bufnr")
	local nlisted = #listed
	if #visible == nlisted then
		vim.cmd(fwd and "bnext" or "bprev")
		return
	end

	local dir = fwd and 1 or -1
	local curbuf = start and start
		or (function(cb)
			for i, buf in ipairs(listed) do
				if buf == cb then
					return i
				end
			end
		end)(vim.fn.bufnr())

	-- Otherwise load the next non-visible listed buffer.
	local theend = fwd and nlisted or 1
	for p = curbuf + dir, theend, dir do
		local buf = listed[p]
		if not visible[buf] then
			vim.cmd("b" .. buf)
			return
		end
	end

	smart_next_buffer(fwd, fwd and 0 or nlisted + 1)
end

M.smart_next = function()
	smart_next_buffer(true)
end

M.smart_prev = function()
	smart_next_buffer(false)
end

return M
