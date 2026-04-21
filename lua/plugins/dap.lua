local dap = require("dap")
local dapui = require("dapui")
local map = vim.keymap.set

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

local function project_python()
	local cwd = vim.fn.getcwd()
	local current_file = vim.api.nvim_buf_get_name(0)
	local file_dir = current_file ~= "" and vim.fs.dirname(current_file) or nil

	for _, path in ipairs(unique_paths({
		vim.env.VIRTUAL_ENV and vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python") or nil,
		file_dir and vim.fs.joinpath(file_dir, ".venv", "bin", "python") or nil,
		file_dir and vim.fs.joinpath(file_dir, "venv", "bin", "python") or nil,
		vim.fs.joinpath(cwd, ".venv", "bin", "python"),
		vim.fs.joinpath(cwd, "venv", "bin", "python"),
		vim.fn.exepath("python3"),
		vim.fn.exepath("python"),
	})) do
		return path
	end

	return "python3"
end

local function has_debugpy(python)
	vim.fn.system({ python, "-c", "import debugpy" })
	return vim.v.shell_error == 0
end

-- Adapter registration
-- `js-debug` is provided externally, so the DAP layer only needs to point
-- Neovim at the executable and declare the supported adapters.
local js_debug = vim.fn.exepath("js-debug")

dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = { command = js_debug, args = { "${port}" } },
}

dap.adapters["pwa-chrome"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = { command = js_debug, args = { "${port}" } },
}

dap.adapters.python = function(callback)
	for _, python in ipairs(unique_paths({
		project_python(),
		vim.fn.exepath("python3"),
		vim.fn.exepath("python"),
	})) do
		if has_debugpy(python) then
			callback({
				type = "executable",
				command = python,
				args = { "-m", "debugpy.adapter" },
			})
			return
		end
	end

	local uv = vim.fn.exepath("uv")
	if uv ~= "" then
		callback({
			type = "executable",
			command = uv,
			args = { "run", "--with", "debugpy", "python", "-m", "debugpy.adapter" },
		})
		return
	end

	vim.notify(
		("No Python interpreter with debugpy was found. Install it with `%s -m pip install debugpy`."):format(
			project_python()
		),
		vim.log.levels.ERROR
	)
end

-- JavaScript / TypeScript launch profiles
-- Share the same adapter setup across JS, TS, and React variants.
for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
	dap.configurations[lang] = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file (Node)",
			program = "${file}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach (Node)",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
		},
		{
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome",
			url = "http://localhost:3000",
			webRoot = "${workspaceFolder}",
			sourceMaps = true,
		},
	}
end

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file (Python)",
		program = "${file}",
		cwd = "${fileDirname}",
		pythonPath = project_python,
	},
}

-- Session UI
-- Keep the debug panels open only while a session is active.

dapui.setup()
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

require("nvim-dap-virtual-text").setup()

-- Debug keymaps

map("n", "<F5>", function()
	dap.continue()
end, { desc = "DAP continue" })
map("n", "<F10>", function()
	dap.step_over()
end, { desc = "DAP step over" })
map("n", "<F11>", function()
	dap.step_into()
end, { desc = "DAP step into" })

map("n", "<leader>db", function()
	dap.toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
map("n", "<leader>dc", function()
	dap.continue()
end, { desc = "Continue" })
map({ "n", "v" }, "<leader>de", function()
	dapui.eval()
end, { desc = "Eval expression" })
map("n", "<leader>di", function()
	dap.step_into()
end, { desc = "Step into" })
map("n", "<leader>dl", function()
	dap.run_last()
end, { desc = "Run last" })
map("n", "<leader>do", function()
	dap.step_over()
end, { desc = "Step over" })
map("n", "<leader>dq", function()
	dap.terminate()
end, { desc = "Terminate" })
map("n", "<leader>dr", function()
	dap.repl.toggle()
end, { desc = "REPL toggle" })
map("n", "<leader>du", function()
	dapui.toggle()
end, { desc = "Toggle UI" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dO", function()
	dap.step_out()
end, { desc = "Step out" })
