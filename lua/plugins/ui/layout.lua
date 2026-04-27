local map = vim.keymap.set

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

local function smart_window_quit()
	local explorer = Snacks.picker.get({ source = "explorer", tab = false })[1]
	if not explorer then
		vim.cmd("close")
		return
	end

	local current = vim.api.nvim_get_current_win()
	if explorer:current_win() then
		explorer:close()
		return
	end

	local explorer_wins = {}
	for _, win in pairs(explorer.layout.wins or {}) do
		if win.win and vim.api.nvim_win_is_valid(win.win) then
			explorer_wins[win.win] = true
		end
	end
	for _, win in pairs(explorer.layout.box_wins or {}) do
		if win.win and vim.api.nvim_win_is_valid(win.win) then
			explorer_wins[win.win] = true
		end
	end
	if explorer.layout.root and explorer.layout.root.win and vim.api.nvim_win_is_valid(explorer.layout.root.win) then
		explorer_wins[explorer.layout.root.win] = true
	end

	local editable_wins = {}
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative == "" and not explorer_wins[win] then
			table.insert(editable_wins, win)
		end
	end

	if #editable_wins == 1 and editable_wins[1] == current then
		Snacks.bufdelete()
		return
	end

	vim.cmd("close")
end

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

local function open_explorer()
	local buf = vim.api.nvim_get_current_buf()
	local file = vim.api.nvim_buf_get_name(buf)

	if vim.bo[buf].buftype == "" and file ~= "" then
		local root = Snacks.git.get_root(file) or vim.fs.dirname(file)
		local explorer = Snacks.picker.get({ source = "explorer", tab = false })[1]

		if explorer then
			local actions = require("snacks.explorer.actions")
			explorer:set_cwd(root)
			actions.update(explorer, { target = file, refresh = true })
			return
		end

		Snacks.picker.explorer({
			cwd = root,
			on_show = function(picker)
				require("snacks.explorer.actions").update(picker, { target = file, refresh = true })
			end,
		})
		return
	end

	Snacks.picker.explorer()
end

map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "[B", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer prev" })
map("n", "]B", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer next" })

map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete current buffer" })
map("n", "<leader>bj", "<cmd>BufferLinePick<cr>", { desc = "Pick buffer" })
map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", { desc = "Delete buffers to the left" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin" })
map("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", { desc = "Delete buffers to the right" })
map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Delete non-pinned buffers" })

map("n", "<leader>e", open_explorer, { desc = "File explorer" })

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

map("n", "<leader>wq", smart_window_quit, { desc = "Quit window" })
map("n", "<C-w>q", smart_window_quit, { desc = "Quit window" })
map("n", "<leader>z", function()
	vim.cmd("10split | terminal")
end, { desc = "Open terminal in bottom split" })
