{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
{
  # Out-of-store symlinks for configs that change frequently
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";

  # Neovim plugins from nix (symlinked to packpath)
  xdg.dataFile."nvim/site/pack/nix/start/gruvbox-nvim".source = pkgs.vimPlugins.gruvbox-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/plenary-nvim".source = pkgs.vimPlugins.plenary-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/telescope-nvim".source = pkgs.vimPlugins.telescope-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/gitsigns-nvim".source = pkgs.vimPlugins.gitsigns-nvim;
  home.packages = with pkgs; [
    neovim-unwrapped

    # LSP servers
    nil
    nixpkgs-fmt
    pyright
    rust-analyzer
    typescript-language-server
  ];
}
