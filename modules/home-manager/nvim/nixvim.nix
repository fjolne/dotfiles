{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    vimAlias = true;

    globals.mapleader = " ";
    globals.maplocalleader = " ";
    options = {
      clipboard = "unnamedplus";
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2; # Tab width should be 2
    };

    colorschemes.gruvbox.enable = true;

    keymaps = [
      {
        action = "<cmd>Telescope find_files<CR>";
        key = "<C-p>";
      }
      {
        action = "<cmd>Telescope live_grep<CR>";
        key = "<C-f>";
      }
      {
        action = "<cmd>Telescope buffers<CR>";
        key = "<C-b>";
      }
      {
        action = "<cmd>Telescope help_tags<CR>";
        key = "<C-/>";
      }
    ];

    plugins.telescope = {
      enable = true;
    };

    plugins.nvim-cmp = {
      enable = true;
      autoEnableSources = true;
      sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
        { name = "luasnip"; }
      ];
      mapping = {
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<Tab>" = {
          action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expandable() then
                luasnip.expand()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif check_backspace() then
                fallback()
              else
                fallback()
              end
            end
          '';
          modes = [ "i" "s" ];
        };
      };
    };

    plugins.lsp = {
      enable = true;
      servers = {
        nil_ls.enable = true;
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
      {
        plugin = comment-nvim;
        config = "lua require(\"Comment\").setup()";
      }
    ];
  };
}
