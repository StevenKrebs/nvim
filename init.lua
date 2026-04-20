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
	-- Foundational (must load first: provides nvim-web-devicons mock)
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/folke/snacks.nvim",

	-- LSP / completion / syntax
	{ src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1") },
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",

	-- Tools
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/numToStr/Comment.nvim",
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/folke/persistence.nvim",

	-- Debug
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/theHamsta/nvim-dap-virtual-text",

	-- UI
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/SmiteshP/nvim-navic",
	"https://github.com/RRethy/vim-illuminate",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/folke/trouble.nvim",
})

vim.cmd("packadd nvim.undotree")
vim.cmd("packadd nvim.difftool")

-- Work around Neovim 0.12 bug: MenuPopup assert error in vim/ui.lua _get_urls
pcall(vim.api.nvim_clear_autocmds, { event = "MenuPopup", group = "nvim_defaults" })

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("plugins.ui")
require("plugins.lsp")
require("plugins.dap")
