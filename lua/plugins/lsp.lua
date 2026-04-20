local notification_ui = {}
local map = vim.keymap.set

-- LSP notifications
-- Keep long-running progress and attach events visible in the same notifier
-- pipeline as the rest of the UI.

local lsp_notification_progress = vim.defaulttable(function()
	return {}
end)

local lsp_notification_spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function lsp_notification_title(client)
	local root = client and (client.root_dir or client.config.root_dir) or nil
	local project = root and vim.fn.fnamemodify(root, ":t") or nil
	return project and ("%s · %s"):format(client.name, project) or client.name
end

function notification_ui.lsp_progress(client, token, value)
	if not client or type(value) ~= "table" then
		return
	end

	local progress = lsp_notification_progress[client.id]
	for i = 1, #progress + 1 do
		if i == #progress + 1 or progress[i].token == token then
			local message = value.message and (" %s"):format(value.message) or ""
			progress[i] = {
				token = token,
				msg = ("[%3d%%] %s%s"):format(
					value.kind == "end" and 100 or value.percentage or 100,
					value.title or "",
					message
				),
				done = value.kind == "end",
			}
			break
		end
	end

	local lines = {} ---@type string[]
	lsp_notification_progress[client.id] = vim.tbl_filter(function(item)
		table.insert(lines, item.msg)
		return not item.done
	end, progress)

	local complete = #lsp_notification_progress[client.id] == 0
	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
		id = "lsp-progress:" .. client.id,
		title = lsp_notification_title(client),
		timeout = complete and 1500 or false,
		opts = function(notif)
			notif.icon = complete and " "
				or lsp_notification_spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #lsp_notification_spinner + 1]
		end,
	})
end

function notification_ui.lsp_attached(client, bufnr)
	if not client then
		return
	end

	local bufname = vim.api.nvim_buf_get_name(bufnr)
	vim.notify(
		bufname == "" and "LSP attached" or ("Attached to %s"):format(vim.fn.fnamemodify(bufname, ":t")),
		vim.log.levels.INFO,
		{
			id = ("lsp-attach:%d:%d"):format(client.id, bufnr),
			title = client.name,
			timeout = 1200,
		}
	)
end

-- Completion UI

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<C-e>"] = { "hide", "fallback" },
		["<C-Space>"] = { "show" },
	},
	completion = {
		ghost_text = { enabled = true },
		list = { selection = { preselect = true, auto_insert = false } },
		documentation = { auto_show = true, auto_show_delay_ms = 200 },
	},
	fuzzy = { implementation = "lua" },
})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#1F1F28" })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "#1F1F28", fg = "#363646" })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#2A2A37" })
		vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#1F1F28" })
		vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = "#1F1F28", fg = "#363646" })
	end,
})

-- LSP commands and server activation

local function lsp_complete()
	return vim.tbl_map(function(client)
		return client.name
	end, vim.lsp.get_clients({ bufnr = 0 }))
end

vim.api.nvim_create_autocmd("LspProgress", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		notification_ui.lsp_progress(client, ev.data.params.token, ev.data.params.value)
	end,
})

vim.api.nvim_create_user_command("LspStop", function(opts)
	local name = opts.args ~= "" and opts.args or nil
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = name })) do
		client:stop()
	end
end, { nargs = "?", complete = lsp_complete, desc = "Stop LSP client(s)" })

vim.api.nvim_create_user_command("LspStart", function()
	vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
end, { desc = "Start LSP client(s) for current buffer" })

vim.api.nvim_create_user_command("LspRestart", function(opts)
	local name = opts.args ~= "" and opts.args or nil
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = name })) do
		client:stop()
	end
	vim.defer_fn(function()
		vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
	end, 500)
end, { nargs = "?", complete = lsp_complete, desc = "Restart LSP client(s)" })

-- Server definitions live in `lsp/<name>.lua`; this module only defines shared
-- defaults and the set of servers to enable.
vim.lsp.config("*", {
	root_markers = { ".git" },
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.enable({
	"nixd",
	"basedpyright",
	"rust_analyzer",
	"gopls",
	"lua_ls",
	"yamlls",
	"taplo",
	"zls",
	"markdown_oxide",
	"jsonls",
	"html",
	"cssls",
	"tailwindcss",
	"ts_ls",
	"intelephense",
	"dockerls",
	"sqls",
	"clangd",
	"jdtls",
	"ruby_lsp",
	"perlls",
})

-- Buffer-local LSP UX
-- Attach keymaps only after a client is present so we can safely call LSP APIs
-- and gate optional features like inlay hints and breadcrumbs.

require("nvim-navic").setup()

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		local function bufopts(desc)
			return { buffer = ev.buf, desc = desc }
		end

		map("n", "gd", vim.lsp.buf.definition, bufopts("Goto definition"))
		map("n", "gD", vim.lsp.buf.declaration, bufopts("Goto declaration"))
		map("n", "gr", vim.lsp.buf.references, bufopts("Goto references"))
		map("n", "gi", vim.lsp.buf.implementation, bufopts("Goto implementation"))
		map("n", "gy", vim.lsp.buf.type_definition, bufopts("Goto type definition"))
		map("n", "K", vim.lsp.buf.hover, bufopts("Hover"))
		map("n", "<leader>ca", vim.lsp.buf.code_action, bufopts("Code action"))
		map(
			"n",
			"<leader>cl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			bufopts("LSP definitions/references")
		)
		map("n", "<leader>cr", vim.lsp.buf.rename, bufopts("Rename symbol"))
		map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", bufopts("Symbols"))
		map("n", "[d", function()
			vim.diagnostic.jump({ count = -1 })
		end, bufopts("Previous diagnostic"))
		map("n", "]d", function()
			vim.diagnostic.jump({ count = 1 })
		end, bufopts("Next diagnostic"))

		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
		end

		if client and client:supports_method("textDocument/documentSymbol") then
			require("nvim-navic").attach(client, ev.buf)
		end

		notification_ui.lsp_attached(client, ev.buf)
	end,
})

-- Diagnostics, formatting, and linting

local signs = {
	[vim.diagnostic.severity.ERROR] = "\xEF\x81\x97 ",
	[vim.diagnostic.severity.WARN] = "\xEF\x81\xB1 ",
	[vim.diagnostic.severity.INFO] = "\xEF\x84\xA9 ",
	[vim.diagnostic.severity.HINT] = "\xEF\x83\xAB ",
}

vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	signs = { text = signs },
	virtual_text = {
		prefix = function(diagnostic)
			return signs[diagnostic.severity] .. " "
		end,
	},
})

-- Treesitter and textobjects
-- Parser installation stays close to the textobject config so language support
-- is managed in one place.

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.nix",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

require("conform").setup({
	formatters_by_ft = {
		nix = { "nixfmt" },
		python = { "ruff_format" },
		lua = { "stylua" },
		sh = { "shfmt" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		markdown = { "prettier" },
		toml = { "taplo" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		zig = { "zigfmt" },
		ruby = { "rubocop" },
		perl = { "perltidy" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

require("lint").linters_by_ft = {
	python = { "ruff" },
	sh = { "shellcheck" },
	nix = { "statix" },
	ruby = { "rubocop" },
	perl = { "perlcritic" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

require("nvim-treesitter").install({
	"nix",
	"lua",
	"python",
	"rust",
	"go",
	"c",
	"cpp",
	"java",
	"javascript",
	"typescript",
	"tsx",
	"json",
	"yaml",
	"toml",
	"html",
	"css",
	"bash",
	"ruby",
	"perl",
	"sql",
	"markdown",
	"dockerfile",
	"vim",
	"zig",
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		pcall(vim.treesitter.start, ev.buf)
	end,
})

require("nvim-treesitter-textobjects").setup({
	select = {
		enable = true,
		lookahead = true,
		keymaps = {
			["af"] = "@function.outer",
			["if"] = "@function.inner",
			["ac"] = "@class.outer",
			["ic"] = "@class.inner",
			["aa"] = "@parameter.outer",
			["ia"] = "@parameter.inner",
		},
	},
	move = {
		enable = true,
		set_jumps = true,
		goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
		goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
	},
	swap = {
		enable = true,
		swap_next = { ["<leader>sx"] = "@parameter.inner" },
		swap_previous = { ["<leader>sX"] = "@parameter.inner" },
	},
})
