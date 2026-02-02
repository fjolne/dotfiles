-- Neovim configuration
-- This file is symlinked out-of-store for quick iteration

----------------------------------------------------------------------
-- Basic Options
----------------------------------------------------------------------
vim.g.mapleader = " "

vim.o.clipboard = "unnamedplus"
vim.o.number = true
vim.o.colorcolumn = "80"
vim.o.scrolloff = 999          -- Keep cursor centered
vim.o.showmatch = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.termguicolors = true
vim.o.laststatus = 3           -- Global statusline

-- Invisible characters
vim.o.list = true
vim.opt.listchars = { tab = "› ", eol = "¬", trail = "⋅" }
vim.o.showbreak = "↪"

-- Backup/undo
vim.o.backup = true
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

-- System clipboard shortcuts
vim.keymap.set("n", "<leader>y", '"+y', opts)
vim.keymap.set("v", "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>p", '"+p', opts)

-- Clear search highlight
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", opts)

-- Buffer management
vim.keymap.set("n", "<leader>d", ":bd<CR>", opts)

-- cd to current file's directory
vim.keymap.set("n", "<leader>cd", ":cd %:h<CR>", opts)

-- Terminal mode escape
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)

vim.keymap.set("n", "<leader>c", ":terminal<CR>", opts)

----------------------------------------------------------------------
-- LSP
----------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local o = { noremap = true, silent = true, buffer = bufnr }

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
        vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, o)
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, o)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
        vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, o)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, o)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, o)
    end,
})

-- Python (pyright)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(ev)
        local bufpath = ev.match ~= "" and vim.fn.fnamemodify(ev.match, ":p:h") or vim.fn.getcwd()
        local root_files = vim.fs.find({ "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }, {
            path = bufpath,
            upward = true,
        })
        local root_dir = root_files[1] and vim.fn.fnamemodify(vim.fs.dirname(root_files[1]), ":p") or vim.fn.getcwd()

        vim.lsp.start({
            name = "pyright",
            cmd = { "pyright-langserver", "--stdio" },
            root_dir = root_dir,
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                    },
                },
            },
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
