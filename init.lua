vim.loader.enable()

-- Must be set before any keymaps or plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add({
	-- Core (`plugins.core`)
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/folke/snacks.nvim",

	-- UI (`plugins.ui`)
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/numToStr/Comment.nvim",
	"https://github.com/folke/persistence.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/RRethy/vim-illuminate",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/tpope/vim-fugitive",

	-- LSP / completion / syntax (`plugins.lsp`)
	{ src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1") },
	"https://github.com/SmiteshP/nvim-navic",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",

	-- Debug (`plugins.dap`)
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/theHamsta/nvim-dap-virtual-text",
})

vim.cmd("packadd nvim.undotree")
vim.cmd("packadd nvim.difftool")

-- Work around Neovim 0.12 bug: MenuPopup assert error in vim/ui.lua _get_urls
pcall(vim.api.nvim_clear_autocmds, { event = "MenuPopup", group = "nvim_defaults" })

local helpers = {}

-- Buffer state helpers
-- These keep the restart-on-last-buffer logic readable in `config.autocmds`.
function helpers.is_real_file_buffer(buf, exclude_buf)
	return vim.api.nvim_buf_is_valid(buf)
		and vim.bo[buf].buflisted
		and buf ~= exclude_buf
		and vim.bo[buf].buftype == ""
		and vim.api.nvim_buf_get_name(buf) ~= ""
end

-- Return whether any listed, named file buffers remain after excluding one.
function helpers.has_real_file_buffers(exclude_buf)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if helpers.is_real_file_buffer(buf, exclude_buf) then
			return true
		end
	end
	return false
end

-- Detect the empty placeholder buffer Neovim lands on after the final file closes.
function helpers.is_synthetic_empty_buffer(buf)
	return vim.api.nvim_buf_get_name(buf) == ""
		and vim.bo[buf].buflisted
		and vim.bo[buf].buftype == ""
		and vim.bo[buf].filetype == ""
end

-- Build the Ghostty window title from the active buffer directory or cwd.
function helpers.ghostty_title()
	local bufname = vim.api.nvim_buf_get_name(0)
	local dir = bufname ~= "" and vim.fn.fnamemodify(bufname, ":h:t") or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	return dir .. " - nvim"
end

package.loaded["config.helpers"] = helpers

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("plugins.core")
require("plugins.ui")
require("plugins.lsp")
require("plugins.dap")
