{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    vimAlias = true;

    globals.mapleader = " ";
    globals.maplocalleader = " ";
    options = {
      autoindent = true;
      clipboard = "unnamedplus";
      ignorecase = true;
      inccommand = "split";
      list = true;
      listchars = { tab = "» "; trail = "·"; nbsp = "␣"; };
      number = true;
      relativenumber = true;
      scrolloff = 999; # keep cursor centered
      shiftwidth = 2; # tab width, but mostly managed by vim-sleuth
      smartcase = true;
      termguicolors = true;
      timeoutlen = 300;
      updatetime = 250;
    };

    colorschemes.gruvbox.enable = true;

    keymaps = [
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
      { mode = [ "n" "i" ]; key = "<C-s>"; action = "<cmd>write<CR>"; }
      # exit terminal mode
      { mode = "t"; key = "<C-i>"; action = "<C-\\><C-n>"; }
      # send lines to a neighboring terminal window
      { mode = [ "v" ]; key = "<C-CR>"; action = "y<C-w>wpa<CR><C-\\><C-n><C-w>p"; }
      { mode = [ "n" "i" ]; key = "<C-CR>"; action = "yy<C-w>wpa<CR><C-\\><C-n><C-w>p"; }
      { mode = [ "n" "i" ]; key = "<S-CR>"; action = "yy<C-w>wpa<CR><C-\\><C-n><C-w>pj"; }
    ];

    plugins.gitsigns.enable = true;
    plugins.diffview.enable = true;
    plugins.comment-nvim.enable = true;
    plugins.auto-session.enable = true;
    plugins.which-key.enable = true;
    plugins.surround.enable = true;

    # NB maybe I'll need it one day, but for now I'm good
    # plugins.treesitter = {
    #   enable = true;
    #   ensureInstalled = [ "bash" "go" "python" ];
    # };

    plugins.mini = {
      enable = true;
      modules = {
        ai = { };
        # surround = { };
        pairs = { };
      };
    };

    plugins.telescope = {
      enable = true;
      keymaps = {
        "<C-p>" = "find_files";
        "<C-f>" = "live_grep";
        "<C-M-p>" = "buffers";
        "<C-/>" = "help_tags";
      };
    };

    # nvim-cmp requires some snippet plugin (the choice of luasnip is arbitrary)
    plugins.luasnip.enable = true;
    plugins.nvim-cmp = {
      enable = true;
      autoEnableSources = true;
      sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
        # { name = "luasnip"; }
      ];
      snippet.expand = "luasnip";
      mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-g>" = "cmp.mapping.close()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<up>" = {
          action = "cmp.mapping.select_prev_item()";
          modes = [ "i" "s" ];
        };
        "<down>" = {
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
        zls.enable = true;
        zls.installLanguageServer = false;
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
