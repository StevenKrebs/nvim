local flake = vim.fn.expand("~") .. "/.dotfiles/.config/nix"

return {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    nixd = {
      diagnostic = {
        suppress = { "sema-unused-def-lambda-noarg-formal" },
      },
      nixpkgs = {
        expr = 'import (builtins.getFlake "' .. flake .. '").inputs.nixpkgs { }',
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake "' .. flake .. '").darwinConfigurations."macOS".options',
        },
        home_manager = {
          expr = '(builtins.getFlake "' .. flake .. '").homeConfigurations."default".options',
        },
      },
    },
  },
}
