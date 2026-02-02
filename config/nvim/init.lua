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
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")

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
        vim.keymap.set("n", "gh", vim.lsp.buf.hover, o)
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

----------------------------------------------------------------------
-- Molten (Jupyter kernel integration)
----------------------------------------------------------------------
vim.g.molten_auto_open_output = true
vim.g.molten_output_win_max_height = 20
vim.g.molten_split_direction = "right"
vim.g.molten_virt_text_output = true
vim.g.molten_wrap_output = true

-- Image.nvim setup (for inline plots via kitty graphics protocol)
local image_ok, image = pcall(require, "image")
if image_ok then
    image.setup({
        backend = "kitty",
        processor = "magick_cli",
        max_height_window_percentage = 40,
        integrations = {
            markdown = { enabled = false },
            neorg = { enabled = false },
        },
    })
    vim.g.molten_image_provider = "image.nvim"
end

-- Cell navigation helper functions
local function goto_next_cell()
    vim.fn.search("^# %%", "W")
end

local function goto_prev_cell()
    vim.fn.search("^# %%", "bW")
end

local function get_cell_range()
    local save_pos = vim.api.nvim_win_get_cursor(0)
    local start_line, end_line

    -- Find start of current cell (search backwards including current line)
    local found = vim.fn.search("^# %%", "bcW")
    if found == 0 then
        start_line = 1
    else
        start_line = found
    end

    -- Find end of current cell (next marker or EOF)
    vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    local next_marker = vim.fn.search("^# %%", "W")
    if next_marker == 0 then
        end_line = vim.api.nvim_buf_line_count(0)
    else
        end_line = next_marker - 1
    end

    vim.api.nvim_win_set_cursor(0, save_pos)
    return start_line, end_line
end

local function run_cell()
    local start_line, end_line = get_cell_range()
    vim.fn.MoltenEvaluateRange(start_line, end_line)
end

local function run_cell_and_move()
    run_cell()
    goto_next_cell()
end

-- Molten keybindings
vim.keymap.set("n", "<leader>mi", ":MoltenInit python3<CR>", { noremap = true, silent = true, desc = "Init Molten kernel" })
vim.keymap.set("n", "<leader>mr", run_cell, { noremap = true, silent = true, desc = "Run current cell" })
vim.keymap.set("n", "<leader>mn", run_cell_and_move, { noremap = true, silent = true, desc = "Run cell and move to next" })
vim.keymap.set("n", "<leader>mo", ":MoltenShowOutput<CR>", { noremap = true, silent = true, desc = "Show Molten output" })
vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { noremap = true, silent = true, desc = "Hide Molten output" })

-- Cell navigation
vim.keymap.set("n", "]c", goto_next_cell, { noremap = true, silent = true, desc = "Next cell" })
vim.keymap.set("n", "[c", goto_prev_cell, { noremap = true, silent = true, desc = "Previous cell" })
vim.keymap.set("n", "<C-A-Down>", goto_next_cell, { noremap = true, silent = true, desc = "Next cell" })
vim.keymap.set("n", "<C-A-Up>", goto_prev_cell, { noremap = true, silent = true, desc = "Previous cell" })

-- Ctrl+Enter and Shift+Enter (terminal may need proper key codes)
vim.keymap.set("n", "<C-CR>", run_cell, { noremap = true, silent = true, desc = "Run current cell" })
vim.keymap.set("n", "<S-CR>", run_cell_and_move, { noremap = true, silent = true, desc = "Run cell and move to next" })

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
