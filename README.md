# nvim

With the release of nvim v.0.12 I decided to explore what it means to run a custom nvim config instead of my usual reliance on community distributions.
This repo is the outcome of my efforts.

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

Formatters and linters are only needed for the languages you use. Install the relevant ones on your `PATH`:

| Language              | Formatter      | Linter       | LSP                                                                |
| --------------------- | -------------- | ------------ | ------------------------------------------------------------------ |
| Nix                   | `nixfmt`       | `statix`     | `nixd`                                                             |
| Python                | `ruff`         | `ruff`       | `basedpyright`                                                     |
| Lua                   | `stylua`       | —            | `lua-language-server`                                              |
| Shell                 | `shfmt`        | `shellcheck` | —                                                                  |
| Rust                  | —              | —            | `rust-analyzer`                                                    |
| Go                    | —              | —            | `gopls`                                                            |
| JS/TS                 | `prettier`     | —            | `typescript-language-server`                                       |
| JSON/YAML/HTML/MD     | `prettier`     | —            | `vscode-langservers-extracted`, `yaml-language-server`, `marksman` |
| CSS / Tailwind        | `prettier`     | —            | `vscode-langservers-extracted`, `tailwindcss`                      |
| TOML                  | `taplo`        | —            | `taplo`                                                            |
| C/C++                 | `clang-format` | —            | `clangd`                                                           |
| Ruby                  | `rubocop`      | `rubocop`    | `ruby-lsp`                                                         |
| Perl                  | `perltidy`     | `perlcritic` | `perlls`                                                           |
| PHP                   | —              | —            | `intelephense`                                                     |
| SQL                   | —              | —            | `sqls`                                                             |
| Java                  | —              | —            | `jdtls`                                                            |
| Zig                   | —              | —            | `zls`                                                              |
| Dockerfile            | —              | —            | `dockerfile-language-server`                                       |

## Installation

```bash
git clone https://github.com/StevenKrebs/nvim ~/.config/nvim
nvim
```

Plugins are fetched automatically via `vim.pack` on first launch. Treesitter parsers are compiled after the `nvim-treesitter` plugin installs.

## Features

- **Built-in plugin manager** — `vim.pack` with a lockfile (`nvim-pack-lock.json`) for reproducible installs
- **AI integration** — Claude Code (`<leader>a`) and GitHub Copilot (Enter to accept)
- **Full LSP** — 20 language servers, inlay hints, built-in completion, breadcrumb navigation
- **Auto-format on save** — via conform.nvim, per filetype
- **Treesitter** — syntax highlighting and text objects for 23 languages
- **Git** — gitsigns, fugitive, lazygit, and Snacks git pickers
- **Session persistence** — auto-save/restore via persistence.nvim
- **Kanagawa colorscheme** — wave variant with transparent background
- **which-key** — press `?` in any buffer to browse available keymaps

## Plugins

| Category   | Plugin                                                                                                 |
| ---------- | ------------------------------------------------------------------------------------------------------ |
| UI         | kanagawa.nvim, bufferline.nvim, lualine.nvim, noice.nvim, which-key.nvim, render-markdown.nvim         |
| Navigation | snacks.nvim (picker, dashboard, lazygit), flash.nvim, nvim-navic                                       |
| LSP        | nvim-lspconfig, conform.nvim, nvim-lint                                                                |
| Syntax     | nvim-treesitter, nvim-treesitter-textobjects                                                           |
| Git        | gitsigns.nvim, vim-fugitive                                                                            |
| AI         | claudecode.nvim, copilot.vim                                                                           |
| Editing    | mini.nvim (icons, pairs, surround, ai), Comment.nvim, vim-illuminate, todo-comments.nvim, trouble.nvim |
| Sessions   | persistence.nvim                                                                                       |

## Key Bindings

`<leader>` is `Space`. `<localleader>` is `\`.

### Find (`<leader>f`)

| Key                                                                                           | Action        |
| --------------------------------------------------------------------------------------------- | ------------- |
| `<leader>ff`                                                                                  | Find files    |
| `<leader>fg`                                                                                  | Grep          |
| `<leader>fb`                                                                                  | Buffers       |
| `<leader>fr`                                                                                  | Recent files  |
| `<leader>fh`                                                                                  | Help          |
| `<leader>fd`                                                                                  | Diagnostics   |
| `<leader>e`                                                                                   | File explorer |

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

| Key                         | Action                    |
| --------------------------- | ------------------------- |
| `<leader>ac`                | Toggle Claude             |
| `<leader>af`                | Focus Claude              |
| `<leader>ab`                | Add current buffer        |
| `<leader>as`                | Send selection            |
| `<leader>aa` / `<leader>ad` | Accept / deny diff        |
| `Enter` (insert)            | Accept Copilot suggestion |

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

### Diagnostics (`<leader>x`)

| Key                         | Action                   |
| --------------------------- | ------------------------ |
| `<leader>xx`                | Toggle all diagnostics   |
| `<leader>xX`                | Buffer diagnostics       |
| `<leader>xL` / `<leader>xQ` | Location / quickfix list |

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
