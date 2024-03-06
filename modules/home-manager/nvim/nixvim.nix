{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    vimAlias = true;

    globals.mapleader = " ";
    globals.maplocalleader = " ";
    options = {
      clipboard = "unnamedplus";
      number = true;
      relativenumber = true;
      shiftwidth = 2; # tab width, but mostly managed by vim-sleuth
      ignorecase = true;
      smartcase = true;
      updatetime = 250;
      timeoutlen = 300;
      inccommand = "split";
      scrolloff = 999; # keep cursor centered
      list = true;
      listchars = { tab = "» "; trail = "·"; nbsp = "␣"; };
      termguicolors = true;
    };

    colorschemes.gruvbox.enable = true;

    keymaps = [
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
      { mode = "n"; key = "<C-s>"; action = "<cmd>write<CR>"; }
      { mode = "t"; key = "<C-i>"; action = "<C-\\><C-n>"; }
      # conjure
      { mode = [ "n" ]; key = "<C-CR>"; action = "<cmd>ConjureEval<CR>"; }
      { mode = [ "v" ]; key = "<C-CR>"; action = "<cmd>ConjureEvalVisual<CR>"; }
    ];

    plugins.gitsigns.enable = true;
    plugins.diffview.enable = true;
    plugins.comment-nvim.enable = true;
    plugins.auto-session.enable = true;
    plugins.which-key.enable = true;
    plugins.conjure.enable = true; # for python REPL

    plugins.treesitter = {
      enable = true;
      ensureInstalled = [ "bash" "go" "python" ];
    };

    plugins.mini = {
      enable = true;
      modules = {
        ai = { };
        surround = { };
        pairs = { };
      };
    };

    plugins.toggleterm = {
      enable = true;
      openMapping = "<C-`>";
      size = 48;
    };

    plugins.telescope = {
      enable = true;
      keymaps = {
        "<C-p>" = "find_files";
        "<C-f>" = "live_grep";
        "<C-b>" = "buffers";
        "<C-/>" = "help_tags";
      };
    };

    plugins.nvim-cmp = {
      enable = true;
      autoEnableSources = true;
      sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
        # { name = "luasnip"; }
      ];
      mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-e>" = "cmp.mapping.close()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<S-Tab>" = {
          action = "cmp.mapping.select_prev_item()";
          modes = [ "i" "s" ];
        };
        "<Tab>" = {
          action = "cmp.mapping.select_next_item()";
          modes = [ "i" "s" ];
        };
        # "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        # "<C-f>" = "cmp.mapping.scroll_docs(4)";
      };
    };

    plugins.lsp = {
      enable = true;
      keymaps.lspBuf = {
        gh = "hover";
        gD = "references";
        gd = "definition";
        gi = "implementation";
        gt = "type_definition";
        "<leader>af" = "format";
        "<leader>ar" = "rename";
      };
      servers = {
        pyright.enable = true;
        nil_ls = {
          enable = true;
          settings.formatting.command = [ "nixpkgs-fmt" ];
        };
        lua-ls = {
          enable = true;
          settings.telemetry.enable = false;
        };
        rust-analyzer = {
          enable = true;
          installRustc = false;
          installCargo = false;
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-sleuth
    ];
  };
}
