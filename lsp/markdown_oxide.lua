return {
  cmd       = { "markdown-oxide" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".moxide.toml", ".obsidian", ".git" },
  -- markdown-oxide relies on watched file registration for workspace updates.
  capabilities = vim.tbl_deep_extend("force", require("blink.cmp").get_lsp_capabilities(), {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  }),
}
