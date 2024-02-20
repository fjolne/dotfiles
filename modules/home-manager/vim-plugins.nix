{ inputs }:

final: prev: {
  customVim = with final; {
    vim-copilot = vimUtils.buildVimPlugin {
      name = "vim-copilot";
      src = inputs.vim-copilot;
    };

    # nvim-comment = vimUtils.buildVimPlugin {
    #   name = "nvim-comment";
    #   src = inputs.nvim-comment;
    #   buildPhase = ":";
    # };

    nvim-plenary = vimUtils.buildVimPlugin {
      name = "nvim-plenary";
      src = inputs.nvim-plenary;
      # buildPhase = ":";
    };

    nvim-telescope = vimUtils.buildVimPlugin {
      name = "nvim-telescope";
      src = inputs.nvim-telescope;
      # buildPhase = ":";
    };

    nvim-conform = vimUtils.buildVimPlugin {
      name = "nvim-conform";
      src = inputs.nvim-conform;
    };

    nvim-treesitter = vimUtils.buildVimPlugin {
      name = "nvim-treesitter";
      src = inputs.nvim-treesitter;
    };

    # nvim-lspconfig = vimUtils.buildVimPlugin {
    #   name = "nvim-lspconfig";
    #   src = inputs.nvim-lspconfig;

    #   # We have to do this because the build phase runs tests which require
    #   # git and I don't know how to get git into here.
    #   buildPhase = ":";
    # };

    # nvim-lspinstall = vimUtils.buildVimPlugin {
    #   name = "nvim-lspinstall";
    #   src = inputs.nvim-lspinstall;
    # };
  };
}
