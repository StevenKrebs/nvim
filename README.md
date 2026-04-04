# One-File Neovim Config

With the release of nvim v.0.12 I decided to explore what it means to run a custom nvim config instead of my usual reliance on community distributions.
This repo is the outcome of my efforts. A single init.lua that manages everything, heavily inspired by [LazyVim](https://www.lazyvim.org/).

## Requirements

| Dependency                                                                    | Purpose                                 |
| ----------------------------------------------------------------------------- | --------------------------------------- |
| [Neovim](https://neovim.io/) ≥ 0.12                                           | Uses `vim.pack` API                     |
| [ripgrep](https://github.com/BurntSushi/ripgrep)                              | For File/text search (Snacks picker)    |
| [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/tree/master/cli) | Compile treesitter parsers (`TSUpdate`) |
| [lazygit](https://github.com/jesseduffield/lazygit)                           | Git TUI integration                     |
| [Claude Code](https://github.com/anthropics/claude-code)                      | AI pair programming via claudecode.nvim |
| Node.js                                                                       | GitHub Copilot                          |
| A [Nerd Font](https://www.nerdfonts.com/)                                     | Icons via mini.icons                    |

### Optional

I personally use [ghostty](https://ghostty.org) as my terminal emulator of choice, combined with
[zsh](https://www.zsh.org/) and [starship](https://starship.rs/) for a modern shell experience. These are not required to use the nvim config, but they do complement it nicely.

### LSP

LSP servers have to be installed manually (I personally use nix for that btw).
Formatters and linters are only needed for the languages you use. Install the relevant ones on your `PATH`:

| Language          | Formatter      | Linter       | LSP                                                                |
| ----------------- | -------------- | ------------ | ------------------------------------------------------------------ |
| Nix               | `nixfmt`       | `statix`     | `nixd`                                                             |
| Python            | `ruff`         | `ruff`       | `basedpyright`                                                     |
| Lua               | `stylua`       | —            | `lua-language-server`                                              |
| Shell             | `shfmt`        | `shellcheck` | —                                                                  |
| Rust              | —              | —            | `rust-analyzer`                                                    |
| Go                | —              | —            | `gopls`                                                            |
| JS/TS             | `prettier`     | —            | `typescript-language-server`                                       |
| JSON/YAML/HTML/MD | `prettier`     | —            | `vscode-langservers-extracted`, `yaml-language-server`, `marksman` |
| CSS / Tailwind    | `prettier`     | —            | `vscode-langservers-extracted`, `tailwindcss`                      |
| TOML              | `taplo`        | —            | `taplo`                                                            |
| C/C++             | `clang-format` | —            | `clangd`                                                           |
| Ruby              | `rubocop`      | `rubocop`    | `ruby-lsp`                                                         |
| Perl              | `perltidy`     | `perlcritic` | `perlls`                                                           |
| PHP               | —              | —            | `intelephense`                                                     |
| SQL               | —              | —            | `sqls`                                                             |
| Java              | —              | —            | `jdtls`                                                            |
| Zig               | `zig fmt`      | —            | `zls`                                                              |
| Dockerfile        | —              | —            | `dockerfile-language-server`                                       |

Specific configuration options (e.g. inlay hints, hover actions) are set in the respective server config files in `lsp/` (e.g. `lsp/basedpyright.lua`).

### DAP

Debug adapters are only needed for the languages you want to debug. Install the relevant ones on your `PATH`:

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
- **AI integration** — Claude Code (`<leader>a`) and GitHub Copilot (granular acceptance: word/line/full, panel view, per-buffer toggle)
- **Full LSP** — 20 language servers, inlay hints, built-in completion, breadcrumb navigation
- **Auto-format on save** — via conform.nvim, per filetype
- **Treesitter** — syntax highlighting and text objects for 23 languages
- **Git** — gitsigns, fugitive, lazygit, and Snacks git pickers
- **DAP** — JS/TS debugging with sourcemap support via nvim-dap + vscode-js-debug (`<leader>d`)
- **Session persistence** — auto-save/restore via persistence.nvim
- **Enhanced UI** — noice.nvim for cleaner cmdline and messages; Snacks dashboard with hidden statusline
- **Kanagawa colorscheme** — wave variant with transparent background
- **which-key** — press `?` in any buffer to browse available keymaps

## Plugins

| Category   | Plugin                                                                                                 |
| ---------- | ------------------------------------------------------------------------------------------------------ |
| UI         | kanagawa.nvim, bufferline.nvim, lualine.nvim, noice.nvim, which-key.nvim, render-markdown.nvim         |
| Navigation | snacks.nvim (picker, dashboard, lazygit, notifier, indent), flash.nvim, nvim-navic                     |
| LSP        | nvim-lspconfig, conform.nvim, nvim-lint                                                                |
| Syntax     | nvim-treesitter, nvim-treesitter-textobjects                                                           |
| Git        | gitsigns.nvim, vim-fugitive                                                                            |
| AI         | claudecode.nvim, copilot.vim                                                                           |
| Debug      | nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, nvim-nio                                                 |
| Editing    | mini.nvim (icons, pairs, surround, ai), Comment.nvim, vim-illuminate, todo-comments.nvim, trouble.nvim |
| Sessions   | persistence.nvim                                                                                       |
| Built-in   | nvim.undotree, nvim.difftool                                                                           |

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

### AI (`<leader>a`)

#### Claude Code
| Key                         | Action                    |
| --------------------------- | ------------------------- |
| `<leader>ac`                | Toggle Claude             |
| `<leader>af`                | Focus Claude              |
| `<leader>ab`                | Add current buffer        |
| `<leader>as`                | Send selection            |
| `<leader>aa` / `<leader>ad` | Accept / deny diff        |

#### Copilot (Insert Mode)
| Key        | Action                    |
| ---------- | ------------------------- |
| `<CR>`     | Accept full suggestion    |
| `<Tab>`    | Next suggestion           |
| `<S-Tab>`  | Previous suggestion       |
| `<M-w>`    | Accept word               |
| `<M-l>`    | Accept line               |
| `<M-e>`    | Dismiss suggestion        |

#### Copilot (Normal Mode)
| Key          | Action                    |
| ------------ | ------------------------- |
| `<leader>ap` | Open Copilot panel        |
| `<leader>at` | Toggle Copilot on/off     |

### Code (`<leader>c` / LSP)

| Key          | Action                 |
| ------------ | ---------------------- |
| `<leader>ca` | Code action            |
| `gd`         | Go to definition       |
| `gD`         | Go to declaration      |
| `gr`         | References             |
| `gi`         | Implementation         |
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
| `<leader>snl`     | Last message                        |
| `<leader>snh`     | Message history                     |
| `<leader>sna`     | All messages                        |
| `<leader>snd`     | Dismiss all messages                |
| `<C-f>` / `<C-b>` | Scroll hover doc forward / backward |

### Motion

| Key           | Action                         |
| ------------- | ------------------------------ |
| `s` / `S`     | Flash jump / treesitter select |
| `]]` / `[[`   | Next / prev reference          |
| `]m` / `[m`   | Next / prev function           |
| `<C-h/j/k/l>` | Window navigation              |

## Customization

LSP server settings live in `lsp/` as individual files (e.g. `lsp/basedpyright.lua`). Add a new file and reference it in the `lspconfig` setup block in `init.lua` to configure an additional server.

Formatter and linter mappings are in the `conform.nvim` and `nvim-lint` setup blocks in `init.lua`.

## Copilot Notes

Copilot provides inline code suggestions in insert mode. It is **disabled** in:
- Markdown (where Claude Code is more useful for writing)
- Git commit messages
- Plain text files

The statusline shows a Copilot icon (right side, kanagawa purple) indicating whether Copilot is active for the current buffer.
