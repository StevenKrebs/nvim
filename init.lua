vim.loader.enable()

-- Must be set before any keymaps or plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

-- NOTE: ── Plugins ───────────────────────────────────────────────────────────────────

vim.pack.add({
  -- Foundational (must load first: provides nvim-web-devicons mock)
  { src = "https://github.com/echasnovski/mini.nvim",  name = "mini" },
  { src = "https://github.com/folke/snacks.nvim",      name = "snacks" },

  -- LSP / completion / syntax
  { src = "https://github.com/neovim/nvim-lspconfig",                       name = "lspconfig",             version = vim.version.range("2.x") },
  { src = "https://github.com/stevearc/conform.nvim",                       name = "conform" },
  { src = "https://github.com/mfussenegger/nvim-lint",                      name = "nvim-lint" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",             name = "nvim-treesitter",       version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", name = "treesitter-textobjects" },

  -- Tools
  { src = "https://github.com/coder/claudecode.nvim",   name = "claudecode" },
  { src = "https://github.com/github/copilot.vim",      name = "copilot" },
  { src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
  { src = "https://github.com/numToStr/Comment.nvim",   name = "comment" },
  { src = "https://github.com/tpope/vim-fugitive",      name = "fugitive" },
  { src = "https://github.com/folke/persistence.nvim",  name = "persistence" },

  -- Debug
  { src = "https://github.com/mfussenegger/nvim-dap",          name = "nvim-dap" },
  { src = "https://github.com/nvim-neotest/nvim-nio",           name = "nvim-nio" },
  { src = "https://github.com/rcarriga/nvim-dap-ui",            name = "nvim-dap-ui" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text", name = "nvim-dap-virtual-text" },

  -- UI
  { src = "https://github.com/rebelot/kanagawa.nvim",                         name = "kanagawa" },
  { src = "https://github.com/akinsho/bufferline.nvim",                       name = "bufferline" },
  { src = "https://github.com/nvim-lualine/lualine.nvim",                     name = "lualine" },
  { src = "https://github.com/SmiteshP/nvim-navic",                           name = "navic" },
  { src = "https://github.com/RRethy/vim-illuminate",                         name = "illuminate" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",     name = "render-markdown" },
  { src = "https://github.com/folke/flash.nvim",                              name = "flash" },
  { src = "https://github.com/folke/which-key.nvim",                          name = "which-key" },
  { src = "https://github.com/folke/todo-comments.nvim",                      name = "todo-comments" },
  { src = "https://github.com/folke/trouble.nvim",                            name = "trouble" },
  { src = "https://github.com/folke/noice.nvim",                              name = "noice" },
  { src = "https://github.com/MunifTanjim/nui.nvim",                          name = "nui" },
})

-- Built-in optional packages
vim.cmd("packadd nvim.undotree")
vim.cmd("packadd nvim.difftool")

-- NOTE: ── mini ──────────────────────────────────────────────────────────────────────

-- Icons (mocks nvim-web-devicons for plugin compatibility)
require("mini.icons").setup({
  file = {
    [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
  },
})
package.preload["nvim-web-devicons"] = function()
  require("mini.icons").mock_nvim_web_devicons()
  return package.loaded["nvim-web-devicons"]
end

-- Auto-pairs
require("mini.pairs").setup()

-- Surround: sa (add), sd (delete), sr (replace)
require("mini.surround").setup()

-- Better text objects: function, class, argument, etc.
require("mini.ai").setup()

-- NOTE: ── snacks ────────────────────────────────────────────────────────────────────

require("snacks").setup({
  indent   = { enabled = true },
  notifier = { enabled = true },
  dashboard = {
    sections = {
      { section = "header" },
      {
        title = "Files",
        padding = 1,
        { icon = " ", key = "n", desc = "New File",   action = ":ene | startinsert" },
        { icon = " ", key = "f", desc = "Find File",  action = ":lua Snacks.picker.files()" },
        { icon = " ", key = "g", desc = "Find Text",  action = ":lua Snacks.picker.grep()" },
      },
      {
        title = "Sessions",
        padding = 1,
        { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
        { icon = " ", key = "l", desc = "Last Session",    action = ":lua require('persistence').load({ last = true })" },
      },
      {
        title = "Menu",
        padding = 1,
        { icon = " ", key = "c", desc = "Config",         action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
        { icon = " ", key = "u", desc = "Update Plugins", action = ":PackUpdate" },
        { icon = " ", key = "q", desc = "Quit",           action = ":qa" },
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

vim.keymap.set("n", "<leader>e",  function() Snacks.picker.explorer()    end, { desc = "File explorer" })
vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files()       end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function() Snacks.picker.grep()        end, { desc = "Grep" })
vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers()     end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", function() Snacks.picker.recent()      end, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fh", function() Snacks.picker.help()        end, { desc = "Help" })
vim.keymap.set("n", "<leader>fd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })

-- NOTE: ── Core ──────────────────────────────────────────────────────────────────────

local opt = vim.opt

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.showmode = false
opt.winborder = "rounded"
opt.pumheight = 10
opt.splitbelow = true
opt.splitright = true
opt.laststatus = 3        -- global statusline

-- Editing
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.shiftround = true
opt.wrap = false
opt.autowrite = true
opt.virtualedit = "block"
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Files
opt.confirm = true
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Performance
opt.updatetime = 300
opt.synmaxcol = 300
opt.redrawtime = 10000
opt.timeoutlen = 300

-- Terminal
vim.keymap.set("t", "<Esc>", function()
  return vim.bo.filetype == "fzf" and "<Esc>" or "<C-\\><C-n>"
end, { expr = true, desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>z", function()
  vim.cmd("10split | terminal")
end, { desc = "Open terminal in bottom split" })

-- Navigation: wrapped line movement with jump list support for counts
vim.keymap.set("n", "k", function()
  return vim.v.count > 0 and "m'" .. vim.v.count .. "k" or "gk"
end, { expr = true, desc = "Up" })

vim.keymap.set("n", "j", function()
  return vim.v.count > 0 and "m'" .. vim.v.count .. "j" or "gj"
end, { expr = true, desc = "Down" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Editing
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Unindent" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent" })

-- Splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Auto-cd to git root on startup
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local root = Snacks.git.get_root()
    if root then vim.fn.chdir(root) end
  end,
})

-- Toggle relative line numbers based on mode
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function() vim.opt.relativenumber = false end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function() vim.opt.relativenumber = true end,
})

-- Terminal: no line numbers, auto-enter insert mode
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.cmd("startinsert")
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  callback = function()
    vim.wo.number = true
    vim.wo.relativenumber = true
  end,
})

-- Restart when the last named listed buffer is deleted
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    local remaining = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_is_valid(b)
        and vim.bo[b].buflisted
        and b ~= args.buf
        and vim.api.nvim_buf_get_name(b) ~= ""
    end, vim.api.nvim_list_bufs())
    if #remaining == 0 then
      vim.schedule(function() vim.cmd("restart") end)
    end
  end,
})

-- Ghostty: update terminal title with current directory
if vim.fn.getenv("TERM_PROGRAM") == "ghostty" then
  local function set_title()
    local bufname = vim.api.nvim_buf_get_name(0)
    local dir = bufname ~= "" and vim.fn.fnamemodify(bufname, ":h:t") or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    io.write("\027]0;" .. dir .. " - nvim\007")
    io.flush()
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "DirChanged" }, {
    callback = set_title,
  })

  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
      io.write("\027]0;" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "\007")
      io.flush()
    end,
  })
end

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
  vim.notify("All plugins updated!", vim.log.levels.INFO)
end, { desc = "Update all plugins" })

-- NOTE: ── LSP ───────────────────────────────────────────────────────────────────────

local function lsp_complete() return vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 })) end

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
  vim.defer_fn(function() vim.api.nvim_exec_autocmds("FileType", { buffer = 0 }) end, 500)
end, { nargs = "?", complete = lsp_complete, desc = "Restart LSP client(s)" })

-- nvim-lspconfig provides default cmd, filetypes, and root_markers for all servers
vim.lsp.config("*", {
  root_markers = { ".git" },
})

-- Enable all servers (picks up lsp/<name>.lua for custom settings)
vim.lsp.enable({
  "nixd",
  "basedpyright",
  "rust_analyzer",
  "gopls",
  "lua_ls",
  "yamlls",
  "taplo",
  "zls",
  "marksman",
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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local opts = { buffer = ev.buf }

    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,      opts)
    vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,      opts)
    vim.keymap.set("n", "gr",         vim.lsp.buf.references,       opts)
    vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,   opts)
    vim.keymap.set("n", "gy",         vim.lsp.buf.type_definition,  opts)
    vim.keymap.set("n", "K",          vim.lsp.buf.hover,            opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,           opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,      opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count =  1 }) end, opts)

    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    -- Built-in completion
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- Navic (breadcrumbs)
    if client and client:supports_method("textDocument/documentSymbol") then
      require("nvim-navic").attach(client, ev.buf)
    end
  end,
})

local signs = {
  [vim.diagnostic.severity.ERROR] = "\xEF\x81\x97 ", -- U+F057 nf-fa-times_circle
  [vim.diagnostic.severity.WARN]  = "\xEF\x81\xB1 ", -- U+F071 nf-fa-exclamation_triangle
  [vim.diagnostic.severity.INFO]  = "\xEF\x84\xA9 ", -- U+F129 nf-fa-info_circle
  [vim.diagnostic.severity.HINT]  = "\xEF\x83\xAB ", -- U+F0EB nf-fa-lightbulb
}

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  signs = { text = signs },
  virtual_text = {
    prefix = function(d) return signs[d.severity] .. " " end,
  },
})

-- Format on save for Nix files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.nix",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

require("conform").setup({
  formatters_by_ft = {
    nix        = { "nixfmt" },
    python     = { "ruff_format" },
    lua        = { "stylua" },
    sh         = { "shfmt" },
    json       = { "prettier" },
    jsonc      = { "prettier" },
    yaml       = { "prettier" },
    html       = { "prettier" },
    css        = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    markdown   = { "prettier" },
    toml       = { "taplo" },
    c          = { "clang_format" },
    cpp        = { "clang_format" },
    zig        = { "zigfmt" },
    ruby       = { "rubocop" },
    perl       = { "perltidy" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

require("lint").linters_by_ft = {
  python = { "ruff" },
  sh     = { "shellcheck" },
  nix    = { "statix" },
  ruby   = { "rubocop" },
  perl   = { "perlcritic" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  callback = function() require("lint").try_lint() end,
})

require("nvim-treesitter").install({
  "nix", "lua", "python", "rust", "go",
  "c", "cpp", "java",
  "javascript", "typescript", "tsx",
  "json", "yaml", "toml",
  "html", "css", "bash",
  "ruby", "perl", "sql",
  "markdown", "dockerfile", "vim", "zig",
})

-- Enable built-in treesitter highlighting for any filetype that has a parser
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
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
    goto_next_start     = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
    goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
  },
  swap = {
    enable = true,
    swap_next     = { ["<leader>sx"] = "@parameter.inner" },
    swap_previous = { ["<leader>sX"] = "@parameter.inner" },
  },
})

-- NOTE: ── Tools ─────────────────────────────────────────────────────────────────────

require("claudecode").setup()

vim.keymap.set("n",          "<leader>ac", "<cmd>ClaudeCode<cr>",                 { desc = "Toggle Claude" })
vim.keymap.set("n",          "<leader>af", "<cmd>ClaudeCodeFocus<cr>",            { desc = "Focus Claude" })
vim.keymap.set("n",          "<leader>ar", "<cmd>ClaudeCode --resume<cr>",        { desc = "Resume Claude" })
vim.keymap.set("n",          "<leader>aC", "<cmd>ClaudeCode --continue<cr>",      { desc = "Continue Claude" })
vim.keymap.set("n",          "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",            { desc = "Add current buffer" })
vim.keymap.set("v",          "<leader>as", "<cmd>ClaudeCodeSend<cr>",             { desc = "Send to Claude" })
vim.keymap.set("n",          "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",       { desc = "Accept diff" })
vim.keymap.set("n",          "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",         { desc = "Deny diff" })

-- Copilot
vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
  markdown = false,
  gitcommit = false,
  text = false,
}

-- Accept full suggestion (falls back to normal Enter if no suggestion)
vim.keymap.set("i", "<CR>", 'copilot#Accept("<CR>")', { expr = true, replace_keycodes = false, desc = "Copilot accept or enter" })

vim.keymap.set("i", "<Tab>",   "<Plug>(copilot-next)",         { desc = "Copilot next suggestion" })
vim.keymap.set("i", "<S-Tab>", "<Plug>(copilot-previous)",     { desc = "Copilot prev suggestion" })
vim.keymap.set("i", "<M-w>",   "<Plug>(copilot-accept-word)",  { desc = "Copilot accept word" })
vim.keymap.set("i", "<M-l>",   "<Plug>(copilot-accept-line)",  { desc = "Copilot accept line" })
vim.keymap.set("i", "<M-e>",   "<Plug>(copilot-dismiss)",      { desc = "Copilot dismiss" })
vim.keymap.set("n", "<leader>ap", "<cmd>Copilot panel<CR>",     { desc = "Copilot panel" })
vim.keymap.set("n", "<leader>at", function()
  local enabled = vim.b.copilot_enabled
  vim.b.copilot_enabled = (enabled == false) and true or false
  vim.notify("Copilot " .. (vim.b.copilot_enabled == false and "disabled" or "enabled"))
end, { desc = "Toggle copilot" })

-- Git (Snacks)
if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit({ cwd = Snacks.git.get_root() }) end, { desc = "Lazygit (root)" })
  vim.keymap.set("n", "<leader>gG", function() Snacks.lazygit() end,                                { desc = "Lazygit (cwd)" })
end

vim.keymap.set("n",          "<leader>gl", function() Snacks.picker.git_log({ cwd = Snacks.git.get_root() }) end, { desc = "Git log" })
vim.keymap.set("n",          "<leader>gL", function() Snacks.picker.git_log() end,                               { desc = "Git log (cwd)" })
vim.keymap.set("n",          "<leader>gb", function() Snacks.picker.git_log_line() end,                          { desc = "Git blame line" })
vim.keymap.set("n",          "<leader>gf", function() Snacks.picker.git_log_file() end,                          { desc = "Git file history" })
vim.keymap.set({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end,                                    { desc = "Git browse" })
vim.keymap.set({ "n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git browse (copy URL)" })

-- Gitsigns
require("gitsigns").setup({
  signs = {
    add          = { text = '+' },
    change       = { text = '~' },
    delete       = { text = '-' },
    topdelete    = { text = '-' },
    changedelete = { text = '~' },
    untracked    = { text = '?' },
  },
  on_attach = function(buf)
    local gs = require("gitsigns")

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- Hunk navigation (respects vim diff mode)
    map("n", "]h", function()
      if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
    end, "Next hunk")
    map("n", "[h", function()
      if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
    end, "Prev hunk")
    map("n", "]H", function() gs.nav_hunk("last") end,  "Last hunk")
    map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")

    map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<cr>",      "Stage hunk")
    map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<cr>",      "Reset hunk")
    map("n",          "<leader>ghS", gs.stage_buffer,                  "Stage buffer")
    map("n",          "<leader>ghR", gs.reset_buffer,                  "Reset buffer")
    map("n",          "<leader>ghu", gs.undo_stage_hunk,               "Undo stage hunk")
    map("n",          "<leader>ghp", gs.preview_hunk_inline,           "Preview hunk")
    map("n",          "<leader>ghb", gs.blame_line,                    "Blame line")
    map("n",          "<leader>ghd", gs.diffthis,                      "Diff this")
    map("n",          "<leader>ghD", function() gs.diffthis("~") end,  "Diff this ~")

    -- Text object: ih = inner hunk
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", "Gitsigns hunk")
  end,
})

-- Comment.nvim
require("Comment").setup()

-- Fugitive
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>",      { desc = "Git commit" })
vim.keymap.set("n", "<leader>gd", "<cmd>Git diff<cr>",        { desc = "Git diff" })
vim.keymap.set("n", "<leader>gD", "<cmd>Gvdiffsplit<cr>",     { desc = "Git diff split" })
vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>",          { desc = "Git write (stage)" })

-- Session management
vim.opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,terminal"

require("persistence").setup()

vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end,               { desc = "Restore session" })
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end,               { desc = "Don't save session" })

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.Undotree, { desc = "Undotree" })

-- Difftool
vim.keymap.set("n", "<leader>gt", "<cmd>DiffTool<cr>", { desc = "Diff tool" })

-- NOTE: ── UI ────────────────────────────────────────────────────────────────────────

-- Colorscheme
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
      Pmenu      = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
      PmenuSel   = { fg = "NONE", bg = theme.ui.bg_p2 },
      PmenuSbar  = { bg = theme.ui.bg_m1 },
      PmenuThumb = { bg = theme.ui.bg_p2 },
      NormalFloat = { bg = "none" },
      FloatBorder = { bg = "none" },
      FloatTitle  = { bg = "none" },
      NormalDark  = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
      DiagnosticVirtualTextHint  = diag_color(theme.diag.hint),
      DiagnosticVirtualTextInfo  = diag_color(theme.diag.info),
      DiagnosticVirtualTextWarn  = diag_color(theme.diag.warning),
      DiagnosticVirtualTextError = diag_color(theme.diag.error),
    }
  end,
})

vim.cmd.colorscheme("kanagawa-wave")

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local _notify = vim.notify
    vim.notify = function(msg, ...) if msg ~= "Kanagawa: compiled successfully!" then _notify(msg, ...) end end
    vim.cmd("KanagawaCompile")
    vim.notify = _notify
  end,
})

-- Bufferline
require("bufferline").setup({
  options = {
    close_command       = function(n) Snacks.bufdelete(n) end,
    right_mouse_command = function(n) Snacks.bufdelete(n) end,
    diagnostics         = "nvim_lsp",
    always_show_bufferline = false,
    diagnostics_indicator = function(_, _, diag)
      local ret = (diag.error   and " " .. diag.error   .. " " or "")
               .. (diag.warning and " " .. diag.warning       or "")
      return vim.trim(ret)
    end,
    offsets = {
      { filetype = "snacks_layout_box" },
    },
  },
})

-- Fix bufferline when restoring a session
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
  callback = function()
    vim.schedule(function() pcall(nvim_bufferline) end)
  end,
})

vim.keymap.set("n", "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",            { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>",      "<cmd>BufferLineCycleNext<cr>",            { desc = "Next buffer" })
vim.keymap.set("n", "[b",         "<cmd>BufferLineCyclePrev<cr>",            { desc = "Prev buffer" })
vim.keymap.set("n", "]b",         "<cmd>BufferLineCycleNext<cr>",            { desc = "Next buffer" })
vim.keymap.set("n", "[B",         "<cmd>BufferLineMovePrev<cr>",             { desc = "Move buffer prev" })
vim.keymap.set("n", "]B",         "<cmd>BufferLineMoveNext<cr>",             { desc = "Move buffer next" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>",            { desc = "Toggle pin" })
vim.keymap.set("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Delete non-pinned buffers" })
vim.keymap.set("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>",           { desc = "Delete buffers to the right" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>",            { desc = "Delete buffers to the left" })
vim.keymap.set("n", "<leader>bj", "<cmd>BufferLinePick<cr>",                 { desc = "Pick buffer" })
vim.keymap.set("n", "<leader>bd", function() Snacks.bufdelete() end,          { desc = "Delete current buffer" })

-- Navic (breadcrumbs)
require("nvim-navic").setup()

-- Lualine
local icons = {
  diagnostics = {
    error = "\xEF\x81\x97 ", -- U+F057
    warn  = "\xEF\x81\xB1 ", -- U+F071
    info  = "\xEF\x84\xA9 ", -- U+F129
    hint  = "\xEF\x83\xAB ", -- U+F0EB
  },
  git = { added = "+", modified = "~", removed = "-" },
}

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { { "branch", icon = "\xEF\x90\x98 " } },
    lualine_c = {
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { "filename", path = 1, symbols = { modified = "  ", readonly = "  " } },
      { "diagnostics", symbols = icons.diagnostics },
      { "navic", color_correction = "static" },
    },
    lualine_x = {
      {
        "diff",
        symbols = icons.git,
        source = function()
          local gs = vim.b.gitsigns_status_dict
          if gs then
            return { added = gs.added, modified = gs.changed, removed = gs.removed }
          end
        end,
      },
      {
        function()
          local status = vim.fn["copilot#Enabled"]()
          return status == 1 and " " or " off"
        end,
        color = { fg = "#957fb8" },
      },
    },
    lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    },
    lualine_z = {},
  },
  extensions = { "fzf" },
})

-- Noice
require("noice").setup({
  lsp = {
    hover = {
      enabled = false,
    },
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
        },
      },
      view = "mini",
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
  },
})

vim.keymap.set("n", "<leader>sn",  "",                                                      { desc = "+noice" })
vim.keymap.set("n", "<leader>snl", function() require("noice").cmd("last") end,             { desc = "Last message" })
vim.keymap.set("n", "<leader>snh", function() require("noice").cmd("history") end,          { desc = "History" })
vim.keymap.set("n", "<leader>sna", function() require("noice").cmd("all") end,              { desc = "All" })
vim.keymap.set("n", "<leader>snd", function() require("noice").cmd("dismiss") end,          { desc = "Dismiss all" })
vim.keymap.set("c", "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end, { desc = "Redirect cmdline" })

vim.keymap.set({ "i", "n", "s" }, "<c-f>", function()
  if not require("noice.lsp").scroll(4) then return "<c-f>" end
end, { silent = true, expr = true, desc = "Scroll forward" })

vim.keymap.set({ "i", "n", "s" }, "<c-b>", function()
  if not require("noice.lsp").scroll(-4) then return "<c-b>" end
end, { silent = true, expr = true, desc = "Scroll backward" })

-- Illuminate
local function set_illuminate_hl()
  vim.api.nvim_set_hl(0, "IlluminatedWordText",  { underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordRead",  { underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { underline = true })
end
set_illuminate_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_illuminate_hl })

require("illuminate").configure({
  providers = { "treesitter", "regex" },
  delay = 200,
  large_file_cutoff = 2000,
  filetypes_denylist = { "snacks_dashboard", "snacks_picker" },
})

vim.keymap.set("n", "]]", function() require("illuminate").goto_next_reference() end, { desc = "Next reference" })
vim.keymap.set("n", "[[", function() require("illuminate").goto_prev_reference() end, { desc = "Prev reference" })

-- Render Markdown
require("render-markdown").setup({
  file_types = { "markdown", "Avante" },
})

-- Flash
require("flash").setup()

vim.keymap.set({ "n", "x", "o" }, "s",     function() require("flash").jump() end,             { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S",     function() require("flash").treesitter() end,        { desc = "Flash treesitter" })
vim.keymap.set("o",               "r",     function() require("flash").remote() end,             { desc = "Flash remote" })
vim.keymap.set({ "o", "x" },      "R",     function() require("flash").treesitter_search() end, { desc = "Flash treesitter search" })
vim.keymap.set("c",               "<C-s>", function() require("flash").toggle() end,             { desc = "Flash toggle search" })

-- NOTE: ── DAP ───────────────────────────────────────────────────────────────────────

local dap    = require("dap")
local dapui  = require("dapui")

-- vscode-js-debug adapter (installed via Nix as `js-debug`)
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

for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
  dap.configurations[lang] = {
    {
      type    = "pwa-node",
      request = "launch",
      name    = "Launch file (Node)",
      program = "${file}",
      cwd     = "${workspaceFolder}",
      sourceMaps = true,
      resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
    },
    {
      type      = "pwa-node",
      request   = "attach",
      name      = "Attach (Node)",
      processId = require("dap.utils").pick_process,
      cwd       = "${workspaceFolder}",
      sourceMaps = true,
    },
    {
      type    = "pwa-chrome",
      request = "launch",
      name    = "Launch Chrome",
      url     = "http://localhost:3000",
      webRoot = "${workspaceFolder}",
      sourceMaps = true,
    },
  }
end

-- Auto-open/close UI with debug session
dapui.setup()
dap.listeners.before.attach.dapui_config           = function() dapui.open() end
dap.listeners.before.launch.dapui_config           = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end

-- Inline variable values while stepping
require("nvim-dap-virtual-text").setup()

vim.keymap.set("n",        "<leader>db", function() dap.toggle_breakpoint() end,                         { desc = "Toggle breakpoint" })
vim.keymap.set("n",        "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, { desc = "Conditional breakpoint" })
vim.keymap.set("n",        "<leader>dc", function() dap.continue() end,                                  { desc = "Continue" })
vim.keymap.set("n",        "<leader>di", function() dap.step_into() end,                                 { desc = "Step into" })
vim.keymap.set("n",        "<leader>do", function() dap.step_over() end,                                 { desc = "Step over" })
vim.keymap.set("n",        "<leader>dO", function() dap.step_out() end,                                  { desc = "Step out" })
vim.keymap.set("n",        "<leader>dr", function() dap.repl.toggle() end,                               { desc = "REPL toggle" })
vim.keymap.set("n",        "<leader>dl", function() dap.run_last() end,                                  { desc = "Run last" })
vim.keymap.set("n",        "<leader>dq", function() dap.terminate() end,                                 { desc = "Terminate" })
vim.keymap.set("n",        "<leader>du", function() dapui.toggle() end,                                  { desc = "Toggle UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", function() dapui.eval() end,                                  { desc = "Eval expression" })
vim.keymap.set("n", "<F5>",  function() dap.continue() end,   { desc = "DAP continue" })
vim.keymap.set("n", "<F10>", function() dap.step_over() end,  { desc = "DAP step over" })
vim.keymap.set("n", "<F11>", function() dap.step_into() end,  { desc = "DAP step into" })

-- Which-key
require("which-key").setup({
  preset = "helix",
  spec = {
    { "<leader>a",  group = "ai",          mode = { "n", "v" } },
    { "<leader>d",  group = "debug",       mode = { "n", "v" } },
    { "<leader>b",  group = "buffer",      mode = { "n", "v" } },
    { "<leader>c",  group = "code",        mode = { "n", "v" } },
    { "<leader>f",  group = "file/find",   mode = { "n", "v" } },
    { "<leader>g",  group = "git",         mode = { "n", "v" } },
    { "<leader>gh", group = "hunks",       mode = { "n", "v" } },
    { "<leader>r",  group = "rename",      mode = { "n", "v" } },
    { "<leader>s",  group = "search",      mode = { "n", "v" } },
    { "<leader>q",  group = "session",     mode = { "n", "v" } },
    { "<leader>x",  group = "diagnostics", mode = { "n", "v" } },
    { "<leader>w",  group = "windows",     proxy = "<c-w>",
      expand = function() return require("which-key.extras").expand.win() end },
    { "[", group = "prev" },
    { "]", group = "next" },
    { "g", group = "goto" },
  },
})

vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer keymaps" })

-- Todo comments
require("todo-comments").setup()

vim.keymap.set("n", "]t",         function() require("todo-comments").jump_next() end, { desc = "Next todo" })
vim.keymap.set("n", "[t",         function() require("todo-comments").jump_prev() end, { desc = "Prev todo" })
vim.keymap.set("n", "<leader>st", function() Snacks.picker.todo_comments() end,        { desc = "Todo comments" })

-- Trouble
require("trouble").setup()

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            { desc = "Location list" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             { desc = "Quickfix list" })
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                { desc = "Symbols" })
vim.keymap.set("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP definitions/references" })
