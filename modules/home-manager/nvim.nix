{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  # pkgs = pkgs-unstable;
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
  xdg.dataFile."nvim/site/pack/nix/start/nvim-treesitter".source =
    pkgs.vimPlugins.nvim-treesitter.withPlugins (parsers: [
      parsers.markdown
      parsers.markdown_inline
    ]);
  xdg.dataFile."nvim/site/pack/nix/start/render-markdown-nvim".source =
    pkgs.vimPlugins.render-markdown-nvim;
  home.packages = with pkgs; [
    marksman
    neovim-unwrapped

    # LSP servers
    nil
    nixpkgs-fmt
    pyright
    typescript-language-server
    rust-analyzer
  ];
}
