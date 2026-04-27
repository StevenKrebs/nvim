local map = vim.keymap.set

-- Project annotations and problem lists
require("todo-comments").setup()

map("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo" })

map("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Prev todo" })

map("n", "<leader>st", function()
	Snacks.picker.todo_comments()
end, { desc = "Todo comments" })

require("trouble").setup()

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location list" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
