-- Theme and statusline colors
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
			SnacksPickerPreviewBorder = { fg = theme.ui.special, bg = "none" },
			SnacksPickerPreviewTitle = { fg = theme.ui.special, bg = "none", bold = true },
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
