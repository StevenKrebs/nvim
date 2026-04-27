local map = vim.keymap.set

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

map("n", "<leader>h", toggle_colorcolumn, { desc = "Cycle colorcolumn" })
