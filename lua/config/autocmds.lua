local helpers = require("config.helpers")

-- Core autocmds
-- These toggle small pieces of editor state that should always exist.

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local root = Snacks.git.get_root()
		if root then
			vim.fn.chdir(root)
		end
	end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		vim.opt.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		vim.opt.relativenumber = true
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.cmd("startinsert")
	end,
})

vim.api.nvim_create_autocmd("TermClose", {
	callback = function()
		vim.wo.number = true
		vim.wo.relativenumber = true
	end,
})

-- Buffer lifecycle
-- Restart Neovim when the final real file buffer is closed, but only after the
-- editor has settled on the synthetic empty buffer state.

local restart_on_last_buffer_group = vim.api.nvim_create_augroup("restart_on_last_buffer", { clear = true })
local pending_restart_after_last_buffer_delete = false

vim.api.nvim_create_autocmd("BufDelete", {
	group = restart_on_last_buffer_group,
	callback = function(args)
		pending_restart_after_last_buffer_delete = not helpers.has_real_file_buffers(args.buf)
	end,
})

vim.api.nvim_create_autocmd("SafeState", {
	group = restart_on_last_buffer_group,
	callback = function()
		if not pending_restart_after_last_buffer_delete then
			return
		end

		local current_buf = vim.api.nvim_get_current_buf()
		if helpers.has_real_file_buffers() or not helpers.is_synthetic_empty_buffer(current_buf) then
			return
		end

		pending_restart_after_last_buffer_delete = false
		vim.cmd("restart")
	end,
})

-- Terminal integration
-- Keep the Ghostty title in sync with the active buffer or cwd.

if vim.fn.getenv("TERM_PROGRAM") == "ghostty" then
	local function set_title(title)
		io.write("\027]0;" .. title .. "\007")
		io.flush()
	end

	vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "DirChanged" }, {
		callback = function()
			set_title(helpers.ghostty_title())
		end,
	})

	vim.api.nvim_create_autocmd("VimLeave", {
		callback = function()
			set_title(vim.fn.fnamemodify(vim.fn.getcwd(), ":t"))
		end,
	})
end

-- User commands

vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
	vim.notify("All plugins updated!", vim.log.levels.INFO)
end, { desc = "Update all plugins" })
