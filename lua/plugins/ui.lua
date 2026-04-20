local map = vim.keymap.set

-- Shared helpers

local function split_output(text)
	text = vim.trim(text or "")
	return text == "" and {} or vim.split(text, "\n", { plain = true })
end

local function format_bytes(bytes)
	if not bytes or bytes < 1024 then
		return ("%dB"):format(bytes or 0)
	end

	local size = bytes / 1024
	for _, unit in ipairs({ "K", "M", "G", "T" }) do
		if size < 1024 or unit == "T" then
			if size >= 10 then
				return ("%d%s"):format(math.floor(size + 0.5), unit)
			end
			return ("%.1f%s"):format(size, unit)
		end
		size = size / 1024
	end
end

-- Message and command output UI
-- This wraps the built-in message history and Snacks notifications in a single
-- searchable window interface.

local message_ui = {}

function message_ui.show(title, lines, opts)
	lines = type(lines) == "string" and split_output(lines) or lines
	if not lines or vim.tbl_isempty(lines) then
		lines = { "No output" }
	end

	return Snacks.win(vim.tbl_deep_extend("force", {
		position = "bottom",
		height = 0.35,
		width = 0.9,
		enter = true,
		minimal = false,
		backdrop = false,
		border = "rounded",
		title = (" %s "):format(title),
		ft = "markdown",
		text = lines,
		bo = {
			buftype = "nofile",
			bufhidden = "wipe",
			buflisted = false,
			swapfile = false,
		},
		wo = {
			wrap = false,
			spell = false,
			number = false,
			relativenumber = false,
			signcolumn = "no",
			statuscolumn = "",
		},
	}, opts or {}))
end

function message_ui.messages()
	local ok, result = pcall(vim.api.nvim_exec2, "messages", { output = true })
	return ok and (result.output or "") or ""
end

function message_ui.show_history()
	return message_ui.show("Message History", message_ui.messages(), { ft = "vim" })
end

function message_ui.show_last()
	local lines = split_output(message_ui.messages())
	return message_ui.show("Last Message", { lines[#lines] or "No messages" }, {
		ft = "text",
		height = 0.2,
		width = 0.6,
	})
end

function message_ui.notification_lines()
	local lines = {}
	for _, notif in ipairs(Snacks.notifier.get_history({ reverse = true })) do
		local header = ("[%s] %s"):format(os.date("%R", notif.added), notif.level:upper())
		if notif.title and notif.title ~= "" then
			header = ("%s %s"):format(header, notif.title)
		end
		table.insert(lines, header)
		vim.list_extend(lines, vim.split(notif.msg, "\n", { plain = true }))
		table.insert(lines, "")
	end
	return lines
end

function message_ui.show_all()
	local lines = {}
	local messages = split_output(message_ui.messages())
	local notifications = message_ui.notification_lines()

	if not vim.tbl_isempty(messages) then
		vim.list_extend(lines, { "# Messages", "" })
		vim.list_extend(lines, messages)
	end

	if not vim.tbl_isempty(notifications) then
		if not vim.tbl_isempty(lines) then
			table.insert(lines, "")
		end
		vim.list_extend(lines, { "# Notifications", "" })
		vim.list_extend(lines, notifications)
	end

	return message_ui.show("Editor Activity", lines)
end

function message_ui.dismiss()
	Snacks.notifier.hide()
end

function message_ui.redirect_cmdline()
	local cmdtype = vim.fn.getcmdtype()
	local cmdline = vim.trim(vim.fn.getcmdline())

	if cmdtype ~= ":" or cmdline == "" then
		return "<CR>"
	end

	vim.schedule(function()
		local ok, result = pcall(vim.api.nvim_exec2, cmdline, { output = true })
		if not ok then
			vim.notify(tostring(result), vim.log.levels.ERROR, {
				title = "Command failed",
			})
			return
		end

		local output = split_output(result.output)
		if vim.tbl_isempty(output) then
			vim.notify(("Executed: %s"):format(cmdline), vim.log.levels.INFO, {
				title = "Command",
				timeout = 1200,
			})
			return
		end

		message_ui.show(cmdline, output, { ft = "vim" })
	end)

	return "<C-c>"
end

-- Floating window scrolling
-- Reuse <C-f>/<C-b> for hover, docs, and other transient UI without breaking
-- their normal behavior when no float is focused.

local function find_float()
	local current = vim.api.nvim_get_current_win()
	local floats = {}

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then
			table.insert(floats, {
				win = win,
				current = win == current and 1 or 0,
				zindex = config.zindex or 0,
			})
		end
	end

	table.sort(floats, function(a, b)
		if a.current ~= b.current then
			return a.current > b.current
		end
		if a.zindex ~= b.zindex then
			return a.zindex > b.zindex
		end
		return a.win > b.win
	end)

	return floats[1] and floats[1].win or nil
end

local function scroll_float(delta)
	local win = find_float()
	if not win then
		return false
	end

	local buf = vim.api.nvim_win_get_buf(win)
	local cursor = vim.api.nvim_win_get_cursor(win)
	local line = math.max(1, math.min(vim.api.nvim_buf_line_count(buf), cursor[1] + delta))
	if line == cursor[1] then
		return true
	end

	vim.api.nvim_win_set_cursor(win, { line, cursor[2] })
	return true
end

local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
if ok_ui2 then
	ui2.enable({
		enable = true,
		msg = {
			targets = {
				[""] = "msg",
				empty = "cmd",
				bufwrite = "msg",
				confirm = "cmd",
				emsg = "pager",
				echo = "msg",
				echomsg = "msg",
				echoerr = "pager",
				completion = "cmd",
				list_cmd = "pager",
				lua_error = "pager",
				lua_print = "msg",
				progress = "pager",
				rpc_error = "pager",
				quickfix = "msg",
				search_cmd = "cmd",
				search_count = "cmd",
				shell_cmd = "pager",
				shell_err = "pager",
				shell_out = "pager",
				shell_ret = "msg",
				undo = "msg",
				verbose = "pager",
				wildlist = "cmd",
				wmsg = "msg",
				typed_cmd = "cmd",
			},
			cmd = { height = 0.5 },
			dialog = { height = 0.5 },
			msg = { height = 0.3, timeout = 5000 },
			pager = { height = 0.5 },
		},
	})
end

-- Save notifications and commandline UI

vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("custom_message_ui", { clear = true }),
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		local name = vim.api.nvim_buf_get_name(args.buf)
		if name == "" then
			return
		end

		local stat = vim.uv.fs_stat(name)
		local label = vim.fn.fnamemodify(name, ":~:.")
		local lines = vim.api.nvim_buf_line_count(args.buf)
		vim.notify(("%s  %dL  %s"):format(label, lines, format_bytes(stat and stat.size or 0)), vim.log.levels.INFO, {
			id = "bufwrite:" .. name,
			title = "Saved",
			timeout = 1200,
		})
	end,
})

-- Git and session UI

require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "-" },
		topdelete = { text = "-" },
		changedelete = { text = "~" },
		untracked = { text = "?" },
	},
	on_attach = function(buf)
		local gs = require("gitsigns")

		local function buf_map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
		end

		buf_map("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, "Next hunk")

		buf_map("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, "Prev hunk")

		buf_map("n", "]H", function()
			gs.nav_hunk("last")
		end, "Last hunk")

		buf_map("n", "[H", function()
			gs.nav_hunk("first")
		end, "First hunk")

		buf_map("n", "<leader>ghb", gs.blame_line, "Blame line")
		buf_map("n", "<leader>ghd", gs.diffthis, "Diff this")
		buf_map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk")
		buf_map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<cr>", "Reset hunk")
		buf_map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<cr>", "Stage hunk")
		buf_map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
		buf_map("n", "<leader>ghD", function()
			gs.diffthis("~")
		end, "Diff this ~")
		buf_map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
		buf_map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
		buf_map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", "Gitsigns hunk")
	end,
})

require("Comment").setup()

vim.opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,terminal"
require("persistence").setup()

-- Theme and statusline

require("kanagawa").setup({
	transparent = true,
	compile = true,
	colors = {
		theme = { all = { ui = { bg_gutter = "none" } } },
	},
	overrides = function(colors)
		local theme = colors.theme
		local c = require("kanagawa.lib.color")

		local function diag_color(color)
			return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
		end

		return {
			Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
			PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
			PmenuSbar = { bg = theme.ui.bg_m1 },
			PmenuThumb = { bg = theme.ui.bg_p2 },
			NormalFloat = { bg = "none" },
			FloatBorder = { bg = "none" },
			FloatTitle = { bg = "none" },
			NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
			DiagnosticVirtualTextHint = diag_color(theme.diag.hint),
			DiagnosticVirtualTextInfo = diag_color(theme.diag.info),
			DiagnosticVirtualTextWarn = diag_color(theme.diag.warning),
			DiagnosticVirtualTextError = diag_color(theme.diag.error),
		}
	end,
})

vim.cmd.colorscheme("kanagawa-wave")

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local notify = vim.notify
		---@diagnostic disable-next-line: duplicate-set-field
		vim.notify = function(msg, ...)
			if msg ~= "Kanagawa: compiled successfully!" then
				notify(msg, ...)
			end
		end
		vim.cmd("KanagawaCompile")
		vim.notify = notify
	end,
})

-- Bufferline relies on a global refresh entrypoint exposed by the plugin.
-- Keep the redraw fix close to the setup that needs it.
require("bufferline").setup({
	options = {
		close_command = function(n)
			Snacks.bufdelete(n)
		end,
		right_mouse_command = function(n)
			Snacks.bufdelete(n)
		end,
		diagnostics = "nvim_lsp",
		always_show_bufferline = false,
		diagnostics_indicator = function(_, _, diag)
			local ret = (diag.error and " " .. diag.error .. " " or "") .. (diag.warning and " " .. diag.warning or "")
			return vim.trim(ret)
		end,
		offsets = {
			{
				filetype = "snacks_layout_box",
				highlight = "BufferLineFill",
				separator = false,
			},
		},
	},
})

vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
	callback = function()
		vim.schedule(function()
			pcall(nvim_bufferline)
		end)
	end,
})

-- The command-line UI can temporarily change the available grid height when the
-- sidebar explorer is open. Refresh both the tabline and the explorer layout so
-- the offset segment stays aligned with the sidebar.
local function refresh_sidebar_tabline_layout()
	vim.schedule(function()
		pcall(nvim_bufferline)

		local explorer = Snacks.picker.get({ source = "explorer", tab = false })[1]
		if explorer and explorer.layout then
			pcall(function()
				explorer.layout:update()
			end)
		end
	end)
end

vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
	callback = refresh_sidebar_tabline_layout,
})

map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "[B", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer prev" })
map("n", "]B", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer next" })

local icons = {
	diagnostics = {
		error = "\xEF\x81\x97 ",
		warn = "\xEF\x81\xB1 ",
		info = "\xEF\x84\xA9 ",
		hint = "\xEF\x83\xAB ",
	},
	git = { added = "+", modified = "~", removed = "-" },
}

require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { { "branch", icon = "\xEF\x90\x98 " } },
		lualine_c = {
			{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
			{ "filename", path = 1, symbols = { modified = "  ", readonly = "  " } },
			{ "diagnostics", symbols = icons.diagnostics },
			{ "navic", color_correction = "static" },
		},
		lualine_x = {
			{
				"diff",
				symbols = icons.git,
				source = function()
					local gs = vim.b.gitsigns_status_dict
					if gs then
						return { added = gs.added, modified = gs.changed, removed = gs.removed }
					end
				end,
			},
		},
		lualine_y = {
			{ "progress", separator = " ", padding = { left = 1, right = 0 } },
			{ "location", padding = { left = 0, right = 1 } },
		},
		lualine_z = {},
	},
	extensions = { "fzf" },
})

map("c", "<S-Enter>", message_ui.redirect_cmdline, { expr = true, desc = "Redirect cmdline" })

map({ "i", "n", "s" }, "<C-f>", function()
	if not scroll_float(4) then
		return "<C-f>"
	end
end, { expr = true, silent = true, desc = "Scroll forward" })

map({ "i", "n", "s" }, "<C-b>", function()
	if not scroll_float(-4) then
		return "<C-b>"
	end
end, { expr = true, silent = true, desc = "Scroll backward" })

-- Navigation and reading helpers

local function set_illuminate_hl()
	vim.api.nvim_set_hl(0, "IlluminatedWordText", { underline = true })
	vim.api.nvim_set_hl(0, "IlluminatedWordRead", { underline = true })
	vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { underline = true })
end

set_illuminate_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_illuminate_hl })

require("illuminate").configure({
	providers = { "treesitter", "regex" },
	delay = 200,
	large_file_cutoff = 2000,
	filetypes_denylist = { "snacks_dashboard", "snacks_picker" },
})

map("n", "]]", function()
	require("illuminate").goto_next_reference()
end, { desc = "Next reference" })

map("n", "[[", function()
	require("illuminate").goto_prev_reference()
end, { desc = "Prev reference" })

require("render-markdown").setup({
	file_types = { "markdown", "Avante" },
})

require("flash").setup()

map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash jump" })

map({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash treesitter" })

map("o", "r", function()
	require("flash").remote()
end, { desc = "Flash remote" })

map({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Flash treesitter search" })

map("c", "<C-s>", function()
	require("flash").toggle()
end, { desc = "Flash toggle search" })

-- Leader keymaps
-- Keep these grouped by prefix so they line up with which-key registrations.

local colorcolumn_cycle = { "", "72", "80", "100", "120" }

local function toggle_colorcolumn()
	local current = vim.wo.colorcolumn
	local next_index = 1

	for index, value in ipairs(colorcolumn_cycle) do
		if value == current then
			next_index = (index % #colorcolumn_cycle) + 1
			break
		end
	end

	local next_value = colorcolumn_cycle[next_index]
	vim.opt.colorcolumn = next_value

	local label = next_value == "" and "off" or next_value
	vim.notify("Colorcolumn: " .. label, vim.log.levels.INFO)
end

map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete current buffer" })
map("n", "<leader>bj", "<cmd>BufferLinePick<cr>", { desc = "Pick buffer" })
map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", { desc = "Delete buffers to the left" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin" })
map("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", { desc = "Delete buffers to the right" })
map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Delete non-pinned buffers" })

map("n", "<leader>e", function()
	Snacks.picker.explorer()
end, { desc = "File explorer" })

map("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
	Snacks.picker.grep()
end, { desc = "Grep" })
map("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Help" })
map("n", "<leader>fr", function()
	Snacks.picker.recent()
end, { desc = "Recent files" })

map("n", "<leader>gb", function()
	Snacks.picker.git_log_line()
end, { desc = "Git blame line" })
map({ "n", "x" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git browse" })
map("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
map("n", "<leader>gd", "<cmd>Git diff<cr>", { desc = "Git diff" })
map("n", "<leader>gf", function()
	Snacks.picker.git_log_file()
end, { desc = "Git file history" })
if vim.fn.executable("lazygit") == 1 then
	map("n", "<leader>gg", function()
		Snacks.lazygit({ cwd = Snacks.git.get_root() })
	end, { desc = "Lazygit (root)" })
end
map("n", "<leader>gl", function()
	Snacks.picker.git_log({ cwd = Snacks.git.get_root() })
end, { desc = "Git log" })
map("n", "<leader>gt", "<cmd>DiffTool<cr>", { desc = "Diff tool" })
map("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git write (stage)" })
map("n", "<leader>gD", "<cmd>Gvdiffsplit<cr>", { desc = "Git diff split" })
if vim.fn.executable("lazygit") == 1 then
	map("n", "<leader>gG", function()
		Snacks.lazygit()
	end, { desc = "Lazygit (cwd)" })
end
map("n", "<leader>gL", function()
	Snacks.picker.git_log()
end, { desc = "Git log (cwd)" })
map({ "n", "x" }, "<leader>gY", function()
	Snacks.gitbrowse({
		open = function(url)
			vim.fn.setreg("+", url)
		end,
		notify = false,
	})
end, { desc = "Git browse (copy URL)" })

map("n", "<leader>h", toggle_colorcolumn, { desc = "Cycle colorcolumn" })

map("n", "<leader>qd", function()
	require("persistence").stop()
end, { desc = "Don't save session" })
map("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, { desc = "Restore last session" })
map("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Restore session" })

map("n", "<leader>sn", "", { desc = "+messages" })
map("n", "<leader>sna", function()
	message_ui.show_all()
end, { desc = "All" })
map("n", "<leader>snd", function()
	message_ui.dismiss()
end, { desc = "Dismiss all" })
map("n", "<leader>snh", function()
	message_ui.show_history()
end, { desc = "History" })
map("n", "<leader>snl", function()
	message_ui.show_last()
end, { desc = "Last message" })
map("n", "<leader>st", function()
	Snacks.picker.todo_comments()
end, { desc = "Todo comments" })

map("n", "<leader>u", vim.cmd.Undotree, { desc = "Undotree" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location list" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })

map("n", "<leader>z", function()
	vim.cmd("10split | terminal")
end, { desc = "Open terminal in bottom split" })

map("n", "<leader>r", ":restart<CR><CR>", { desc = "Restart Nvim" })
map("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer keymaps" })

-- Keymap discoverability

require("which-key").setup({
	preset = "helix",
	sort = { "manual" },
	spec = {
		{ "<leader>b", group = "buffer", mode = { "n", "v" } },
		{ "<leader>c", group = "code", mode = { "n", "v" } },
		{ "<leader>d", group = "debug", mode = { "n", "v" } },
		{ "<leader>e", desc = "File explorer", mode = { "n", "v" } },
		{ "<leader>f", group = "file/find", mode = { "n", "v" } },
		{ "<leader>g", group = "git", mode = { "n", "v" } },
		{ "<leader>gh", group = "hunks", mode = { "n", "v" } },
		{ "<leader>h", desc = "Cycle colorcolumn", mode = { "n", "v" } },
		{ "<leader>q", group = "session", mode = { "n", "v" } },
		{ "<leader>r", desc = "Restart Nvim", mode = { "n", "v" } },
		{ "<leader>s", group = "search", mode = { "n", "v" } },
		{ "<leader>sn", group = "messages", mode = { "n", "v" } },
		{ "<leader>st", desc = "Todo comments", mode = { "n", "v" } },
		{ "<leader>sx", desc = "Swap next parameter", mode = { "n", "v" } },
		{ "<leader>sX", desc = "Swap previous parameter", mode = { "n", "v" } },
		{ "<leader>u", desc = "Undotree", mode = { "n", "v" } },
		{
			"<leader>w",
			group = "windows",
			proxy = "<C-w>",
			expand = function()
				return require("which-key.extras").expand.win()
			end,
		},
		{ "<leader>x", group = "diagnostics", mode = { "n", "v" } },
		{ "<leader>z", desc = "Open terminal in bottom split", mode = { "n", "v" } },
		{ "<leader>?", desc = "Buffer keymaps", mode = { "n", "v" } },
		{ "g", group = "goto" },
		{ "[", group = "prev" },
		{ "]", group = "next" },
	},
})

-- Project annotations and problem lists

require("todo-comments").setup()

map("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo" })

map("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Prev todo" })

require("trouble").setup()
