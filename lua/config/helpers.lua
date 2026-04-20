local M = {}

-- Buffer state helpers
-- These keep the restart-on-last-buffer logic readable in `config.autocmds`.

function M.is_real_file_buffer(buf, exclude_buf)
	return vim.api.nvim_buf_is_valid(buf)
		and vim.bo[buf].buflisted
		and buf ~= exclude_buf
		and vim.bo[buf].buftype == ""
		and vim.api.nvim_buf_get_name(buf) ~= ""
end

-- Return whether any listed, named file buffers remain after excluding one.
function M.has_real_file_buffers(exclude_buf)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if M.is_real_file_buffer(buf, exclude_buf) then
			return true
		end
	end
	return false
end

-- Detect the empty placeholder buffer Neovim lands on after the final file closes.
function M.is_synthetic_empty_buffer(buf)
	return vim.api.nvim_buf_get_name(buf) == ""
		and vim.bo[buf].buflisted
		and vim.bo[buf].buftype == ""
		and vim.bo[buf].filetype == ""
end

-- Build the Ghostty window title from the active buffer directory or cwd.
function M.ghostty_title()
	local bufname = vim.api.nvim_buf_get_name(0)
	local dir = bufname ~= "" and vim.fn.fnamemodify(bufname, ":h:t") or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	return dir .. " - nvim"
end

return M
