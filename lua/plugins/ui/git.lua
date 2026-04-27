local map = vim.keymap.set

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

map("n", "<leader>qd", function()
	require("persistence").stop()
end, { desc = "Don't save session" })
map("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, { desc = "Restore last session" })
map("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Restore session" })
