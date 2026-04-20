local opt = vim.opt

-- Core editor options
-- Keep these grouped by concern so scanning the file answers "what policy do we
-- enforce?" before getting into autocmds and keymaps.

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.sidescroll = 1
opt.colorcolumn = "100"
opt.showmode = false
opt.winborder = "rounded"
opt.pumheight = 10
opt.splitbelow = true
opt.splitright = true
opt.laststatus = 3
opt.cmdheight = 0
opt.shortmess:append("W")

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
opt.sessionoptions = opt.sessionoptions - "options"
opt.viewoptions = opt.viewoptions - "options"

-- Performance
opt.updatetime = 300
opt.synmaxcol = 300
opt.redrawtime = 10000
opt.timeoutlen = 300
