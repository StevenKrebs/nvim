# One-File Neovim Config

With the release of nvim v.0.12 I decided to explore what it means to run a custom nvim config instead of my usual reliance on community distributions.
This repo is the outcome of my efforts. A single init.lua that manages everything, heavily inspired by [LazyVim](https://www.lazyvim.org/).

## Requirements

| Dependency                                                                    | Purpose                                 |
| ----------------------------------------------------------------------------- | --------------------------------------- |
| [Neovim](https://neovim.io/) ≥ 0.12                                           | Uses `vim.pack`, native LSP APIs        |
| [ripgrep](https://github.com/BurntSushi/ripgrep)                              | File/text search (Snacks picker)        |
| [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/tree/master/cli) | Compile treesitter parsers (`TSUpdate`) |
| [lazygit](https://github.com/jesseduffield/lazygit)                           | Git TUI integration                     |
| A [Nerd Font](https://www.nerdfonts.com/)                                     | Icons via mini.icons                    |

### Optional

I personally use [ghostty](https://ghostty.org) as my terminal emulator of choice, combined with
[zsh](https://www.zsh.org/) and [starship](https://starship.rs/) for a modern shell experience. These are not required to use the nvim config, but they do complement it nicely.

External coding assistants are optional and kept outside the editor plugin graph. I use them in terminal splits instead of Neovim-specific integrations.

### LSP

LSP server configs live in `lsp/<name>.lua` — no plugin required. Neovim 0.12's native `vim.lsp.config` / `vim.lsp.enable` APIs load them automatically.

LSP servers must be installed manually (e.g. via Nix). Formatters and linters are only needed for the languages you use:

| Language          | Formatter      | Linter       | LSP                                                                      |
| ----------------- | -------------- | ------------ | ------------------------------------------------------------------------ |
| Nix               | `nixfmt`       | `statix`     | `nixd`                                                                   |
| Python            | `ruff`         | `ruff`       | `basedpyright`                                                           |
| Lua               | `stylua`       | —            | `lua-language-server`                                                    |
| Shell             | `shfmt`        | `shellcheck` | —                                                                        |
| Rust              | —              | —            | `rust-analyzer`                                                          |
| Go                | —              | —            | `gopls`                                                                  |
| JS/TS             | `prettier`     | —            | `typescript-language-server`                                             |
| JSON/YAML/HTML/MD | `prettier`     | —            | `vscode-langservers-extracted`, `yaml-language-server`, `markdown-oxide` |
| CSS / Tailwind    | `prettier`     | —            | `vscode-langservers-extracted`, `tailwindcss`                            |
| TOML              | `taplo`        | —            | `taplo`                                                                  |
| C/C++             | `clang-format` | —            | `clangd`                                                                 |
| Ruby              | `rubocop`      | `rubocop`    | `ruby-lsp`                                                               |
| Perl              | `perltidy`     | `perlcritic` | `perlls`                                                                 |
| PHP               | —              | —            | `intelephense`                                                           |
| SQL               | —              | —            | `sqls`                                                                   |
| Java              | —              | —            | `jdtls`                                                                  |
| Zig               | `zig fmt`      | —            | `zls`                                                                    |
| Dockerfile        | —              | —            | `dockerfile-language-server`                                             |

### DAP

Debug adapters are only needed for the languages you want to debug:

| Language | Adapter                        |
| -------- | ------------------------------ |
| JS / TS  | `js-debug` (`vscode-js-debug`) |

## Installation

```bash
git clone https://github.com/StevenKrebs/nvim ~/.config/nvim
nvim
```

Plugins are fetched automatically via `vim.pack` on first launch. Treesitter parsers are compiled after the `nvim-treesitter` plugin installs.

## Features

- **Built-in plugin manager** — `vim.pack` with a lockfile (`nvim-pack-lock.json`) for reproducible installs
- **Native LSP** — Neovim 0.12 APIs, no nvim-lspconfig; per-server configs in `lsp/`, 21 language servers, inlay hints, breadcrumb navigation
- **blink.cmp** — ghost text completion with Tab cycling, doc popups, muted Kanagawa theme
- **Terminal-first workflow** — external tools stay in terminal splits instead of editor-specific plugins
- **Auto-format on save** — via conform.nvim, per filetype
- **Treesitter** — syntax highlighting and text objects for 23 languages
- **Git** — gitsigns, fugitive, lazygit, and Snacks git pickers
- **DAP** — JS/TS debugging with sourcemap support via nvim-dap + vscode-js-debug (`<leader>d`)
- **Session persistence** — auto-save/restore via persistence.nvim
- **Enhanced UI** — native Neovim `ui2` cmdline/messages with custom message history helpers; Snacks dashboard with hidden statusline; Variable column guide
- **Kanagawa colorscheme** — wave variant with transparent background
- **which-key** — press `?` in any buffer to browse available keymaps

## Plugins

| Plugin                     | Purpose in this config                                                      |
| -------------------------- | --------------------------------------------------------------------------- |
| `mini.nvim`                | Icons mock for plugin compatibility, plus pairs, surround, and text objects |
| `snacks.nvim`              | Dashboard, picker, explorer, notifier, git helpers, lazygit, and indent UI  |
| `blink.cmp`                | Completion engine with ghost text and documentation popups                  |
| `conform.nvim`             | Format-on-save and manual formatting                                        |
| `nvim-lint`                | External linter integration                                                 |
| `nvim-treesitter`          | Syntax highlighting and parser-backed editing                               |
| `nvim-treesitter-textobjects` | Treesitter text objects and parameter swapping                           |
| `gitsigns.nvim`            | Inline git hunks and hunk actions                                           |
| `Comment.nvim`             | Comment toggling                                                            |
| `vim-fugitive`             | Git commands and diff workflow                                              |
| `persistence.nvim`         | Session save and restore                                                    |
| `nvim-dap`                | Core debug adapter protocol support                                         |
| `nvim-nio`                | Async dependency for DAP UI                                                 |
| `nvim-dap-ui`             | Debug panels and controls                                                   |
| `nvim-dap-virtual-text`   | Inline variable values while debugging                                      |
| `kanagawa.nvim`            | Colorscheme                                                                 |
| `bufferline.nvim`          | Buffer tabs                                                                 |
| `lualine.nvim`             | Statusline                                                                  |
| `nvim-navic`               | LSP breadcrumbs in the statusline                                           |
| `vim-illuminate`           | Repeated symbol highlighting                                                |
| `render-markdown.nvim`     | Rich markdown rendering                                                     |
| `flash.nvim`               | Fast jump motion and treesitter selection                                   |
| `which-key.nvim`           | Keymap discovery                                                            |
| `todo-comments.nvim`       | TODO/FIXME highlighting and navigation                                      |
| `trouble.nvim`             | Diagnostics, quickfix, and location list UI                                 |
| `nvim.undotree`            | Built-in optional undo history viewer                                       |
| `nvim.difftool`            | Built-in optional diff helper                                               |

## Key Bindings

`<leader>` is `Space`. `<localleader>` is `\`.

### Find (`<leader>f`)

| Key          | Action        |
| ------------ | ------------- |
| `<leader>ff` | Find files    |
| `<leader>fg` | Grep          |
| `<leader>fb` | Buffers       |
| `<leader>fr` | Recent files  |
| `<leader>fh` | Help          |
| `<leader>fd` | Diagnostics   |
| `<leader>e`  | File explorer |

### Git (`<leader>g`)

| Key                         | Action                   |
| --------------------------- | ------------------------ |
| `<leader>gg` / `<leader>gG` | Lazygit (root / cwd)     |
| `<leader>gl` / `<leader>gL` | Git log (root / cwd)     |
| `<leader>gb` / `<leader>gf` | Git blame / file history |
| `<leader>gB` / `<leader>gY` | Browse (open / copy URL) |
| `<leader>gc` / `<leader>gd` | Fugitive commit / diff   |
| `<leader>gh*`               | Gitsigns hunk operations |

### Terminal

| Key         | Action                     |
| ----------- | -------------------------- |
| `<leader>z` | Open bottom terminal split |

### UI

| Key         | Action                                                                 |
| ----------- | ---------------------------------------------------------------------- |
| `<leader>h` | Cycle `colorcolumn`: `off` -> `72` -> `80` -> `100` (default) -> `120` |

### Dashboard

The Snacks dashboard is the startup screen. It shows a custom header, grouped actions, recent files, detected projects, and the current Neovim version in the footer.

| Key | Action          |
| --- | --------------- |
| `n` | New file        |
| `f` | Find file       |
| `g` | Find text       |
| `r` | Restore session |
| `l` | Last session    |
| `s` | Select session  |
| `c` | Browse config   |
| `u` | Update plugins  |
| `q` | Quit            |

Dashboard session actions use the default `persistence.nvim` behavior:
- `r` restores the session for the current working directory, using branch-aware session files when available.
- `l` restores the most recently saved session overall.
- `s` opens `persistence.nvim`'s built-in session chooser.

### Sessions (`<leader>q`)

| Key          | Action                  |
| ------------ | ----------------------- |
| `<leader>qd` | Don't save session      |
| `<leader>ql` | Restore last session    |
| `<leader>qs` | Restore current session |

### Completion (Insert Mode)

| Key         | Action                      |
| ----------- | --------------------------- |
| `<Tab>`     | Next suggestion             |
| `<S-Tab>`   | Previous suggestion         |
| `<CR>`      | Accept suggestion           |
| `<C-e>`     | Dismiss                     |
| `<C-Space>` | Trigger completion manually |

### Code (`<leader>c` / LSP)

| Key          | Action                 |
| ------------ | ---------------------- |
| `<leader>ca` | Code action            |
| `<leader>rn` | Rename symbol          |
| `gd`         | Go to definition       |
| `gD`         | Go to declaration      |
| `gr`         | References             |
| `gi`         | Implementation         |
| `gy`         | Type definition        |
| `K`          | Hover docs             |
| `[d` / `]d`  | Prev / next diagnostic |

### Debug (`<leader>d`)

Requires `js-debug` (`vscode-js-debug`) on PATH. Sourcemaps are enabled — stack frames show `.ts` source paths, not compiled `.js`. The UI opens and closes automatically with the session.

| Key          | Action                 |
| ------------ | ---------------------- |
| `<leader>db` | Toggle breakpoint      |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue               |
| `<leader>di` | Step into              |
| `<leader>do` | Step over              |
| `<leader>dO` | Step out               |
| `<leader>dq` | Terminate              |
| `<leader>du` | Toggle UI              |
| `<leader>de` | Eval expression        |
| `<leader>dr` | REPL toggle            |
| `<leader>dl` | Run last               |
| `<F5>`       | Continue               |
| `<F10>`      | Step over              |
| `<F11>`      | Step into              |

**Adapter configs (JS/TS):** Launch file (Node), Attach (Node), Launch Chrome (`http://localhost:3000`).

### Diagnostics (`<leader>x`)

| Key                         | Action                   |
| --------------------------- | ------------------------ |
| `<leader>xx`                | Toggle all diagnostics   |
| `<leader>xX`                | Buffer diagnostics       |
| `<leader>xL` / `<leader>xQ` | Location / quickfix list |

### Messages (`<leader>sn`)

| Key               | Action                              |
| ----------------- | ----------------------------------- |
| `<leader>snl`     | Last editor message                 |
| `<leader>snh`     | Message history                     |
| `<leader>sna`     | Messages + notification history     |
| `<leader>snd`     | Dismiss active notifications        |
| `<S-Enter>`       | Run command-line command in a split |
| `<C-f>` / `<C-b>` | Scroll the active floating window   |

### Motion

| Key           | Action                         |
| ------------- | ------------------------------ |
| `s` / `S`     | Flash jump / treesitter select |
| `]]` / `[[`   | Next / prev reference          |
| `]m` / `[m`   | Next / prev function           |
| `<C-h/j/k/l>` | Window navigation              |

## Customization

LSP server settings live in `lsp/` as individual files (e.g. `lsp/basedpyright.lua`, `lsp/markdown_oxide.lua`). Each file returns a table with `cmd`, `filetypes`, `root_markers`, and optionally `settings` or `capabilities`. Add a new file and add the server name to `vim.lsp.enable({...})` in `init.lua`.

Formatter and linter mappings are in the `conform.nvim` and `nvim-lint` setup blocks in `init.lua`.
