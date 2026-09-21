local set = vim.opt_local

set.spell = true
set.linebreak = true
set.formatoptions:append("t")
set.smartindent = false

-- Inherit the current window's colorcolumn so the shared default remains off.
-- <leader>h continues to control both values together.
require("plugins.ui.navigation").set_colorcolumn(vim.wo.colorcolumn)
