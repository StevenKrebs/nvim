local map = vim.keymap.set

map("n", "<leader>u", vim.cmd.Undotree, { desc = "Undotree" })
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
		{ "<leader>s", group = "search", mode = { "n", "v" } },
		{ "<leader>sn", group = "messages", mode = { "n", "v" } },
		{ "<leader>st", desc = "Todo comments", mode = { "n", "v" } },
		{ "<leader>sx", desc = "Swap next parameter", mode = { "n", "v" } },
		{ "<leader>sX", desc = "Swap previous parameter", mode = { "n", "v" } },
		{ "<leader>t", group = "test", mode = { "n", "v" } },
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
