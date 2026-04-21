local map = vim.keymap.set
local neotest = require("neotest")

local function executable(path)
	return path ~= nil and path ~= "" and vim.fn.executable(path) == 1
end

local function unique_paths(paths)
	local seen = {}
	local result = {}

	for _, path in ipairs(paths) do
		if executable(path) and not seen[path] then
			seen[path] = true
			table.insert(result, path)
		end
	end

	return result
end

local function project_root(path, markers)
	local start = path and path ~= "" and vim.fs.dirname(path) or vim.fn.getcwd()
	local match = vim.fs.find(markers, { path = start, upward = true })[1]
	return match and vim.fs.dirname(match) or vim.fn.getcwd()
end

local function project_python(path)
	local file_dir = path and path ~= "" and vim.fs.dirname(path) or nil
	local cwd = vim.fn.getcwd()

	for _, candidate in
		ipairs(unique_paths({
			vim.env.VIRTUAL_ENV and vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python") or nil,
			file_dir and vim.fs.joinpath(file_dir, ".venv", "bin", "python") or nil,
			file_dir and vim.fs.joinpath(file_dir, "venv", "bin", "python") or nil,
			vim.fs.joinpath(cwd, ".venv", "bin", "python"),
			vim.fs.joinpath(cwd, "venv", "bin", "python"),
			vim.fn.exepath("python3"),
			vim.fn.exepath("python"),
		}))
	do
		return candidate
	end

	return "python3"
end

local function js_root(path)
	return project_root(path, {
		"package.json",
		"pnpm-workspace.yaml",
		"package-lock.json",
		"yarn.lock",
		"bun.lock",
		"bun.lockb",
		"jest.config.ts",
		"jest.config.mts",
		"jest.config.cts",
		"jest.config.js",
		"jest.config.mjs",
		"jest.config.cjs",
		"vitest.config.ts",
		"vitest.config.mts",
		"vitest.config.cts",
		"vitest.config.js",
		"vitest.config.mjs",
		"vitest.config.cjs",
	})
end

local function current_path()
	return vim.api.nvim_buf_get_name(0)
end

local function run_project()
	neotest.run.run(project_root(current_path(), {
		".git",
		"pyproject.toml",
		"Cargo.toml",
		"package.json",
		"pnpm-workspace.yaml",
		"jest.config.ts",
		"jest.config.mts",
		"jest.config.cts",
		"jest.config.js",
		"jest.config.mjs",
		"jest.config.cjs",
		"vitest.config.ts",
		"vitest.config.mts",
		"vitest.config.cts",
		"vitest.config.js",
		"vitest.config.mjs",
		"vitest.config.cjs",
	}))
end

neotest.setup({
	adapters = {
		require("neotest-python")({
			python = project_python,
			dap = { justMyCode = false },
		}),
		require("neotest-rust")({
			args = { "--no-capture" },
		}),
		require("neotest-jest")({
			cwd = js_root,
		}),
		require("neotest-vitest")({
			filter_dir = function(name)
				return not vim.tbl_contains({ ".git", ".next", "dist", "node_modules" }, name)
			end,
		}),
	},
})

map("n", "<leader>ta", function()
	neotest.run.attach()
end, { desc = "Attach to test" })
map("n", "<leader>td", function()
	neotest.run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })
map("n", "<leader>tf", function()
	neotest.run.run(current_path())
end, { desc = "Run file tests" })
map("n", "<leader>tn", function()
	neotest.run.run()
end, { desc = "Run nearest test" })
map("n", "<leader>to", function()
	neotest.output.open({ enter = true, auto_close = true })
end, { desc = "Open test output" })
map("n", "<leader>tO", function()
	neotest.output_panel.toggle()
end, { desc = "Toggle test output panel" })
map("n", "<leader>tr", function()
	run_project()
end, { desc = "Run project tests" })
map("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Toggle test summary" })
map("n", "<leader>tx", function()
	neotest.run.stop()
end, { desc = "Stop tests" })
