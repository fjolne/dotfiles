-- Neovim configuration
-- This file is symlinked out-of-store for quick iteration

----------------------------------------------------------------------
-- Basic Options
----------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.o.number = true
vim.o.scrolloff = 999          -- Keep cursor centered
vim.o.showmatch = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.termguicolors = true
vim.o.laststatus = 3           -- Global statusline
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")

-- Invisible characters
vim.o.list = true
vim.opt.listchars = { tab = "› ", trail = "⋅" }
vim.o.showbreak = "↪"

-- Keep swapfiles and temporary write-time backups, but do not leave persistent *~ files.
vim.o.swapfile = true
vim.o.backup = false
vim.o.undofile = true
vim.o.writebackup = true

-- Search
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.smartcase = true

-- Tabs (4 spaces)
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

----------------------------------------------------------------------
-- Key Mappings
----------------------------------------------------------------------
local opts = { noremap = true, silent = true }

-- Visual j/k movement (respects wrapped lines)
vim.keymap.set("n", "j", "gj", opts)
vim.keymap.set("n", "k", "gk", opts)

-- Split navigation with Ctrl+hjkl
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Explicit system clipboard shortcuts
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', opts)
vim.keymap.set("n", "<leader>P", '"+P', opts)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>Y", '"+Y', opts)

-- Clear search highlight
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", opts)

-- Save buffer
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>write<CR>", { noremap = true, silent = true, desc = "Save buffer" })

-- Markdown rendering
vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", { desc = "Markdown render toggle" })

-- cd to current file's directory
vim.keymap.set("n", "<leader>cd", ":cd %:h<CR>", opts)
vim.keymap.set("n", "<leader>c", "<cmd>cclose<CR>", { noremap = true, silent = true, desc = "Close quickfix" })

-- Terminal mode escape
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)

vim.keymap.set("n", "<leader>t", ":terminal<CR>", opts)

local function format_current_buffer()
    local bufnr = vim.api.nvim_get_current_buf()

    if #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" }) == 0 then
        vim.notify("No formatter configured for this buffer", vim.log.levels.WARN)
        return
    end

    vim.lsp.buf.format({ async = true })
end

vim.keymap.set("n", "<leader>f", format_current_buffer, { noremap = true, silent = true, desc = "Format buffer" })

----------------------------------------------------------------------
-- Telescope (fuzzy finder)
----------------------------------------------------------------------
local telescope_ok, telescope = pcall(require, "telescope")
if telescope_ok then
    telescope.setup({
        defaults = {
            file_ignore_patterns = { "node_modules", ".git/", "%.lock" },
        },
    })
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
end

----------------------------------------------------------------------
-- Review
----------------------------------------------------------------------
local review_ok, review = pcall(require, "review")
if review_ok then
    review.setup({})
    vim.keymap.set("n", "<leader>r", "<cmd>Review<CR>", { desc = "Review" })
    vim.keymap.set("n", "<leader>R", "<cmd>Review commits<CR>", { desc = "Review commits" })
end

----------------------------------------------------------------------
-- Gitsigns (git gutter)
----------------------------------------------------------------------
local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if gitsigns_ok then
    gitsigns.setup({
        on_attach = function(bufnr)
            local gs = require("gitsigns")
            local o = { noremap = true, silent = true, buffer = bufnr }

            vim.keymap.set("n", "]c", function()
                if vim.wo.diff then return "]c" end
                vim.schedule(function() gs.nav_hunk("next") end)
                return "<Ignore>"
            end, { expr = true, buffer = bufnr, desc = "Next hunk" })

            vim.keymap.set("n", "[c", function()
                if vim.wo.diff then return "[c" end
                vim.schedule(function() gs.nav_hunk("prev") end)
                return "<Ignore>"
            end, { expr = true, buffer = bufnr, desc = "Previous hunk" })

            vim.keymap.set("n", "<leader>hs", gs.stage_hunk, o)
            vim.keymap.set("n", "<leader>hr", gs.reset_hunk, o)
            vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, o)
            vim.keymap.set("n", "<leader>hp", gs.preview_hunk, o)
            vim.keymap.set("n", "<leader>hb", function() gs.blame_line({ full = true }) end, o)
        end,
    })
end

----------------------------------------------------------------------
-- Treesitter
----------------------------------------------------------------------
local treesitter_ok, treesitter = pcall(require, "nvim-treesitter.configs")
if treesitter_ok then
    treesitter.setup({
        highlight = {
            enable = true,
        },
    })
end

----------------------------------------------------------------------
-- Render Markdown
----------------------------------------------------------------------
local render_markdown_ok, render_markdown = pcall(require, "render-markdown")
if render_markdown_ok then
    render_markdown.setup({
        enabled = false,
        anti_conceal = {
            enabled = false,
        },
    })
end

----------------------------------------------------------------------
-- LSP
----------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local o = { noremap = true, silent = true, buffer = bufnr }

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
        vim.keymap.set("n", "gh", vim.lsp.buf.hover, o)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
        vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, o)
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, o)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, o)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, o)
    end,
})

local function get_root_dir(bufpath, markers)
    local root_files = vim.fs.find(markers, { path = bufpath, upward = true })
    return root_files[1] and vim.fn.fnamemodify(vim.fs.dirname(root_files[1]), ":p") or vim.fn.getcwd()
end

local function get_bufpath(ev)
    return ev.match ~= "" and vim.fn.fnamemodify(ev.match, ":p:h") or vim.fn.getcwd()
end

-- Python (pyright)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(ev)
        vim.lsp.start({
            name = "pyright",
            cmd = { "pyright-langserver", "--stdio" },
            root_dir = get_root_dir(get_bufpath(ev), { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }),
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                    },
                },
            },
        })
        vim.lsp.start({
            name = "ruff",
            cmd = { "ruff", "server" },
            root_dir = get_root_dir(get_bufpath(ev), { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" }),
        })
    end,
})

-- TypeScript/JavaScript (typescript-language-server)
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    callback = function(ev)
        vim.lsp.start({
            name = "tsserver",
            cmd = { "typescript-language-server", "--stdio" },
            root_dir = get_root_dir(get_bufpath(ev), { "tsconfig.json", "jsconfig.json", "package.json", ".git" }),
        })
    end,
})

-- Rust (rust-analyzer)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    callback = function(ev)
        vim.lsp.start({
            name = "rust-analyzer",
            cmd = { "rust-analyzer" },
            root_dir = get_root_dir(get_bufpath(ev), { "Cargo.toml", ".git" }),
        })
    end,
})

-- Nix (nil)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "nix",
    callback = function(ev)
        vim.lsp.start({
            name = "nil",
            cmd = { "nil", "--stdio" },
            root_dir = get_root_dir(get_bufpath(ev), { "flake.nix", ".git" }),
            settings = {
                ["nil"] = {
                    formatting = { command = { "nixpkgs-fmt" } },
                },
            },
        })
    end,
})

-- Markdown (marksman)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(ev)
        vim.lsp.start({
            name = "marksman",
            cmd = { "marksman", "server" },
            root_dir = get_root_dir(get_bufpath(ev), { ".marksman.toml", ".git" }),
        })
    end,
})

----------------------------------------------------------------------
-- Autocommands
----------------------------------------------------------------------
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

-- Disable folding
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.o.foldlevel = 999999
    end,
})
