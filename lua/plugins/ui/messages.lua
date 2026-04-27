local map = vim.keymap.set

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

map("c", "<S-Enter>", message_ui.redirect_cmdline, { expr = true, desc = "Redirect cmdline" })

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

return message_ui
