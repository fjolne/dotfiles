{ config, pkgs, pkgs-unstable, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  codediff-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "codediff.nvim";
    version = "2.43.15";
    src = pkgs.fetchFromGitHub {
      owner = "esmuellert";
      repo = "codediff.nvim";
      rev = "v2.43.15";
      hash = "sha256-gaPLjH33+nBgpSZJ8b/4aneodt8wg+Jy44yXAjemToA=";
    };
    nativeBuildInputs = with pkgs; [
      cmake
    ];
    buildPhase = ''
      runHook preBuild

      cmake -B build -S .
      cmake --build build
      cp ${pkgs.gcc.cc.lib}/lib/libgomp.so.1 .

      runHook postBuild
    '';
  };
  review-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "review.nvim";
    version = "1.9.1";
    src = pkgs.fetchFromGitHub {
      owner = "georgeguimaraes";
      repo = "review.nvim";
      rev = "v1.9.1";
      hash = "sha256-/iP4ALu1oGamZe34FvP32qrzmg6wCsa5mmDaVUhIt0c=";
    };
    dependencies = [
      codediff-nvim
      pkgs.vimPlugins.nui-nvim
    ];
  };
in
{
  # Out-of-store symlinks for configs that change frequently
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/configs/nvim";

  # Neovim plugins from nix (symlinked to packpath)
  xdg.dataFile."nvim/site/pack/nix/start/everforest".source = pkgs.vimPlugins.everforest;
  xdg.dataFile."nvim/site/pack/nix/start/fff-nvim".source = pkgs-unstable.vimPlugins.fff-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/gitsigns-nvim".source = pkgs.vimPlugins.gitsigns-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/mini-nvim".source = pkgs.vimPlugins.mini-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/vim-surround".source = pkgs.vimPlugins.vim-surround;
  xdg.dataFile."nvim/site/pack/nix/start/nvim-treesitter".source =
    pkgs.vimPlugins.nvim-treesitter.withPlugins (parsers: [
      parsers.markdown
      parsers.markdown_inline
    ]);
  xdg.dataFile."nvim/site/pack/nix/start/render-markdown-nvim".source =
    pkgs.vimPlugins.render-markdown-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/codediff-nvim".source = codediff-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/nui-nvim".source = pkgs.vimPlugins.nui-nvim;
  xdg.dataFile."nvim/site/pack/nix/start/review-nvim".source = review-nvim;
  home.packages = with pkgs; [
    neovim-unwrapped

    # markdown
    marksman
    # nix
    nil
    nixpkgs-fmt
    # python
    pyright
    ruff
    # typescript
    typescript-language-server
    # go
    gopls
    # rust
    # use https://github.com/fjolne/flake
  ];
}
