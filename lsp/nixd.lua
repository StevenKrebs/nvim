local flake = vim.fn.expand("~") .. "/.dotfiles/.config/nix"
local hostname = vim.uv.os_gethostname()
local username = vim.env.USER
local is_darwin = vim.uv.os_uname().sysname == "Darwin"
local system_options_expr = table.concat({
  "(let",
  '  flake = builtins.getFlake "' .. flake .. '";',
  "  configs = if "
    .. tostring(is_darwin)
    .. " && flake ? darwinConfigurations then flake.darwinConfigurations"
    .. " else if flake ? nixosConfigurations then flake.nixosConfigurations"
    .. " else if flake ? darwinConfigurations then flake.darwinConfigurations"
    .. " else {};",
  "  names = builtins.attrNames configs;",
  '  preferred = "' .. hostname .. '";',
  "in",
  "  if configs ? ${preferred} then configs.${preferred}.options",
  "  else if names == [] then {}",
  "  else configs.${builtins.head names}.options)",
}, " ")

local home_manager_options_expr = table.concat({
  "(let",
  '  flake = builtins.getFlake "' .. flake .. '";',
  "  configs = if flake ? homeConfigurations then flake.homeConfigurations else {};",
  "  names = builtins.attrNames configs;",
  '  preferredHost = "' .. username .. "@" .. hostname .. '";',
  '  preferredUser = "' .. username .. '";',
  "in",
  "  if configs ? ${preferredHost} then configs.${preferredHost}.options",
  "  else if configs ? ${preferredUser} then configs.${preferredUser}.options",
  '  else if configs ? "default" then configs.default.options',
  "  else if names == [] then {}",
  "  else configs.${builtins.head names}.options)",
}, " ")

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
          expr = system_options_expr,
        },
        home_manager = {
          expr = home_manager_options_expr,
        },
      },
    },
  },
}
