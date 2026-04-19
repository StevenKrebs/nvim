local opt = vim.opt
local map = vim.keymap.set

-- Core editor options
-- Keep these grouped by concern so scanning the file answers "what policy do we
-- enforce?" before getting into autocmds and keymaps.

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.sidescroll = 1
opt.colorcolumn = "100"
opt.showmode = false
opt.winborder = "rounded"
opt.pumheight = 10
opt.splitbelow = true
opt.splitright = true
opt.laststatus = 3
opt.cmdheight = 0
opt.shortmess:append("W")

-- Editing
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.shiftround = true
opt.wrap = false
opt.autowrite = true
opt.virtualedit = "block"
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Files
opt.confirm = true
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.sessionoptions = opt.sessionoptions - "options"
opt.viewoptions = opt.viewoptions - "options"

-- Performance
opt.updatetime = 300
opt.synmaxcol = 300
opt.redrawtime = 10000
opt.timeoutlen = 300

-- Global keymaps
-- These are editor-level behaviors, not plugin-specific maps.

map("t", "<Esc>", function()
	return vim.bo.filetype == "fzf" and "<Esc>" or "<C-\\><C-n>"
end, { expr = true, desc = "Exit terminal mode" })

map("n", "k", function()
	return vim.v.count > 0 and "m'" .. vim.v.count .. "k" or "gk"
end, { expr = true, desc = "Up" })

map("n", "j", function()
	return vim.v.count > 0 and "m'" .. vim.v.count .. "j" or "gj"
end, { expr = true, desc = "Down" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "J", "mzJ`z", { desc = "Join lines" })

map("i", "<C-U>", "<C-G>u<C-U>")
map("i", "<C-W>", "<C-G>u<C-W>")

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv", { desc = "Unindent" })
map("v", ">", ">gv", { desc = "Indent" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

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

local function is_real_file_buffer(buf, exclude_buf)
	return vim.api.nvim_buf_is_valid(buf)
		and vim.bo[buf].buflisted
		and buf ~= exclude_buf
		and vim.bo[buf].buftype == ""
		and vim.api.nvim_buf_get_name(buf) ~= ""
end

local function has_real_file_buffers(exclude_buf)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if is_real_file_buffer(buf, exclude_buf) then
			return true
		end
	end
	return false
end

local function is_synthetic_empty_buffer(buf)
	return vim.api.nvim_buf_get_name(buf) == ""
		and vim.bo[buf].buflisted
		and vim.bo[buf].buftype == ""
		and vim.bo[buf].filetype == ""
end

vim.api.nvim_create_autocmd("BufDelete", {
	group = restart_on_last_buffer_group,
	callback = function(args)
		pending_restart_after_last_buffer_delete = not has_real_file_buffers(args.buf)
	end,
})

vim.api.nvim_create_autocmd("SafeState", {
	group = restart_on_last_buffer_group,
	callback = function()
		if not pending_restart_after_last_buffer_delete then
			return
		end

		local current_buf = vim.api.nvim_get_current_buf()
		if has_real_file_buffers() or not is_synthetic_empty_buffer(current_buf) then
			return
		end

		pending_restart_after_last_buffer_delete = false
		vim.cmd("restart")
	end,
})

-- Terminal integration
-- Keep the Ghostty title in sync with the active buffer or cwd.

if vim.fn.getenv("TERM_PROGRAM") == "ghostty" then
	local function set_title()
		local bufname = vim.api.nvim_buf_get_name(0)
		local dir = bufname ~= "" and vim.fn.fnamemodify(bufname, ":h:t") or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
		io.write("\027]0;" .. dir .. " - nvim\007")
		io.flush()
	end

	vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "DirChanged" }, {
		callback = set_title,
	})

	vim.api.nvim_create_autocmd("VimLeave", {
		callback = function()
			io.write("\027]0;" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "\007")
			io.flush()
		end,
	})
end

-- User commands

vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
	vim.notify("All plugins updated!", vim.log.levels.INFO)
end, { desc = "Update all plugins" })
