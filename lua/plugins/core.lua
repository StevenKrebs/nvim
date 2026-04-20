-- Foundational plugins
-- Load these first because later modules depend on `mini.icons` and `Snacks`.

require("mini.icons").setup({
	file = {
		[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
	},
})

package.preload["nvim-web-devicons"] = function()
	require("mini.icons").mock_nvim_web_devicons()
	return package.loaded["nvim-web-devicons"]
end

require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.ai").setup()

-- Snacks powers the dashboard, picker, notifier, and several utility actions
-- used across the rest of the UI layer.
require("snacks").setup({
	indent = { enabled = true },
	notifier = {
		enabled = true,
		top_down = false,
		margin = { top = 0, right = 1, bottom = 1 },
	},
	dashboard = {
		sections = {
			{ section = "header" },
			{
				title = "Files",
				padding = 1,
				{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
				{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
				{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
			},
			{
				title = "Sessions",
				padding = 1,
				{ icon = " ", key = "r", desc = "Restore Session", action = ":lua require('persistence').load()" },
				{
					icon = " ",
					key = "l",
					desc = "Last Session",
					action = ":lua require('persistence').load({ last = true })",
				},
				{
					icon = "󰱼 ",
					key = "s",
					desc = "Select Session",
					action = ":lua require('persistence').select()",
				},
			},
			{
				title = "Menu",
				padding = 1,
				{
					icon = " ",
					key = "c",
					desc = "Config",
					action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })",
				},
				{ icon = " ", key = "u", desc = "Update Plugins", action = ":PackUpdate" },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
			{ title = "Recent Files", section = "recent_files", padding = 2 },
			{ title = "Projects", section = "projects", padding = 2 },
			{
				text = { { "  nvim v" .. tostring(vim.version()), hl = "SnacksDashboardFooter" } },
				align = "center",
				padding = 1,
			},
		},
		preset = {
			pick = function(cmd, opts)
				return Snacks.picker[cmd](opts)
			end,
			header = [[
"The Work is Mysterious and Important."
                      -Mark Scout
]],
		},
	},
	picker = {
		enabled = true,
		sources = {
			explorer = {
				hidden = true,
				ignored = true,
				exclude = { ".DS_Store", "node_modules", ".git" },
				auto_close = false,
				jump = { close = false },
			},
			files = {
				hidden = true,
				ignored = false,
			},
		},
	},
})
