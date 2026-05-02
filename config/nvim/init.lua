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

local gruvbox_ok, gruvbox = pcall(require, "gruvbox")
if gruvbox_ok then
    gruvbox.setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
            strings = true,
            emphasis = true,
            comments = true,
            operators = false,
            folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true,
        contrast = "",
        palette_overrides = {},
        overrides = {
            DiffAdd = { bg = "#32361a" },
            DiffChange = { bg = "#0f3638" },
            DiffDelete = { bg = "#3c1f1e" },
            DiffText = { bg = "#665c54", fg = "#fbf1c7" },
        },
        dim_inactive = false,
        transparent_mode = false,
    })
end
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
-- Filetype Detection
----------------------------------------------------------------------
vim.filetype.add({
    extension = {
        jsonl = "json",
    },
})

----------------------------------------------------------------------
-- Key Mappings
----------------------------------------------------------------------
local opts = { noremap = true, silent = true }

pcall(vim.keymap.del, "n", "<C-l>")

local function navigate_hunk(direction, diff_key)
    if vim.wo.diff then
        vim.cmd("normal! " .. diff_key)
        return
    end

    local ok, gs = pcall(require, "gitsigns")
    if ok then
        pcall(gs.nav_hunk, direction)
    end
end

vim.keymap.set("n", "<S-Down>", function() navigate_hunk("next", "]c") end, { desc = "Next hunk" })
vim.keymap.set("n", "<S-Up>", function() navigate_hunk("prev", "[c") end, { desc = "Previous hunk" })

-- Explicit system clipboard paste shortcuts
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', opts)
vim.keymap.set("n", "<leader>P", '"+P', opts)
vim.keymap.set("v", "<C-p>", '"0p', opts)

local function copy_current_file_path(modifier)
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        vim.notify("No file path for current buffer", vim.log.levels.WARN)
        return
    end

    path = vim.fn.fnamemodify(path, modifier)
    vim.fn.setreg('"', path)
    pcall(vim.fn.setreg, "+", path)
    vim.notify("Copied " .. path)
end

vim.keymap.set("n", "<leader>y", function() copy_current_file_path(":.") end, { noremap = true, silent = true, desc = "Copy relative file path" })
vim.keymap.set("n", "<leader>Y", function() copy_current_file_path(":p") end, { noremap = true, silent = true, desc = "Copy absolute file path" })

-- Mirror yanks to the system clipboard while preserving normal registers.
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        local event = vim.v.event
        if event.operator == "y" and event.regname ~= "+" then
            pcall(vim.fn.setreg, "+", event.regcontents, event.regtype)
        end
    end,
})

-- Clear search highlight
vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch | cclose<CR>", { noremap = true, silent = true, desc = "Clear search and close quickfix" })

-- Save buffer
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>write<CR>", { noremap = true, silent = true, desc = "Save buffer" })

-- Toggle visual line wrapping
vim.keymap.set("n", "<leader>w", "<cmd>set wrap!<CR>", { noremap = true, silent = true, desc = "Toggle line wrap" })

-- Markdown rendering
vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", { desc = "Markdown render toggle" })

-- cd to current file's directory
vim.keymap.set("n", "<leader>cd", ":cd %:h<CR>", opts)

-- Terminal mode escape
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)

vim.keymap.set("n", "<leader>t", ":terminal<CR>", opts)

local function delete_buffer_or_quit()
    if #vim.fn.getbufinfo({ buflisted = 1 }) <= 1 then
        vim.cmd("quit")
    else
        vim.cmd("bdelete")
    end
end

-- Tab navigation
vim.keymap.set("n", "<C-t>", "<cmd>tabnew<CR>", { noremap = true, silent = true, desc = "New tab" })
vim.keymap.set("n", "<M-Left>", "<cmd>tabprevious<CR>", { noremap = true, silent = true, desc = "Previous tab" })
vim.keymap.set("n", "<M-Right>", "<cmd>tabnext<CR>", { noremap = true, silent = true, desc = "Next tab" })
vim.keymap.set("n", "<M-w>", delete_buffer_or_quit, { noremap = true, silent = true, desc = "Delete buffer or quit" })

-- Buffer navigation
vim.keymap.set("n", "<S-Left>", "<cmd>bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<S-Right>", "<cmd>bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })

-- Window navigation
vim.keymap.set("n", "<M-Up>", "<C-w>k", { noremap = true, silent = true, desc = "Window up" })
vim.keymap.set("n", "<M-Down>", "<C-w>j", { noremap = true, silent = true, desc = "Window down" })

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
    local actions = require("telescope.actions")
    telescope.setup({
        defaults = {
            file_ignore_patterns = { "node_modules", ".git/", "%.lock" },
            initial_mode = "insert",
            mappings = {
                i = {
                    ["<Esc>"] = actions.close,
                },
            },
        },
    })
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>ff", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
end

----------------------------------------------------------------------
-- CodeDiff
----------------------------------------------------------------------
local codediff_ok, codediff = pcall(require, "codediff")
if codediff_ok then
    codediff.setup({
        keymaps = {
            view = {
                next_hunk = false,
                prev_hunk = false,
            },
        },
    })
end

----------------------------------------------------------------------
-- Review
----------------------------------------------------------------------
local review_ok, review = pcall(require, "review")
if review_ok then
    review.setup({
        keymaps = {
            next_file = "<S-Right>",
            prev_file = "<S-Left>",
        },
    })
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

            vim.keymap.set("n", "]c", function() navigate_hunk("next", "]c") end, { buffer = bufnr, desc = "Next hunk" })
            vim.keymap.set("n", "[c", function() navigate_hunk("prev", "[c") end, { buffer = bufnr, desc = "Previous hunk" })

            vim.keymap.set("n", "<leader>hs", gs.stage_hunk, o)
            vim.keymap.set("n", "<leader>hr", gs.reset_hunk, o)
            vim.keymap.set("v", "<leader>hr", function()
                gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, o)
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
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local o = { noremap = true, silent = true, buffer = bufnr }

        if client and client:supports_method("textDocument/completion", bufnr) then
            vim.lsp.completion.enable(true, client.id, bufnr)
            vim.keymap.set("i", "<C-Space>", function()
                vim.lsp.completion.get()
            end, { noremap = true, silent = true, buffer = bufnr, desc = "LSP completion" })
        end

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

-- JSON formatting (jq)
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "json", "jsonl" },
    callback = function(ev)
        vim.wo.foldmethod = "syntax"
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) and vim.api.nvim_get_current_buf() == ev.buf then
                vim.cmd("normal! zR")
            end
        end)

        vim.keymap.set("n", "<leader>f", function()
            if vim.fn.executable("jq") == 0 then
                vim.notify("jq not found", vim.log.levels.WARN)
                return
            end

            local view = vim.fn.winsaveview()
            vim.cmd("%!jq .")
            vim.fn.winrestview(view)
        end, { noremap = true, silent = true, buffer = ev.buf, desc = "Format JSON with jq" })
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
