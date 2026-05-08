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
vim.o.title = true
vim.o.titlestring = "nvim"

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

local function copy_text(text)
    vim.fn.setreg('"', text)
    pcall(vim.fn.setreg, "+", text)
    vim.notify("Copied " .. text)
end

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
    copy_text(path)
end

local function copy_current_file_location(modifier)
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        vim.notify("No file path for current buffer", vim.log.levels.WARN)
        return
    end

    local location = vim.fn.fnamemodify(path, modifier) .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
    copy_text(location)
end

local function copy_current_file_range(modifier)
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        vim.notify("No file path for current buffer", vim.log.levels.WARN)
        return
    end

    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    local location = vim.fn.fnamemodify(path, modifier) .. ":" .. start_line .. "-" .. end_line
    copy_text(location)
end

vim.keymap.set("n", "<leader>y", function() copy_current_file_path(":.") end, { noremap = true, silent = true, desc = "Copy relative file path" })
vim.keymap.set("n", "<leader>Y", function() copy_current_file_path(":p") end, { noremap = true, silent = true, desc = "Copy absolute file path" })
vim.keymap.set("n", "<leader>l", function() copy_current_file_location(":.") end, { noremap = true, silent = true, desc = "Copy relative file location" })
vim.keymap.set("v", "<leader>l", function() copy_current_file_range(":.") end, { noremap = true, silent = true, desc = "Copy relative file range" })
vim.keymap.set("n", "<leader>L", function() copy_current_file_location(":p") end, { noremap = true, silent = true, desc = "Copy absolute file location" })
vim.keymap.set("v", "<leader>L", function() copy_current_file_range(":p") end, { noremap = true, silent = true, desc = "Copy absolute file range" })

-- Mirror yanks to the system clipboard while preserving normal registers.
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        local event = vim.v.event
        if event.operator == "y" and event.regname ~= "+" then
            pcall(vim.fn.setreg, "+", event.regcontents, event.regtype)
        end
    end,
})

-- Create missing parent directories before writing a file.
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(event)
        local filename = event.match
        if filename == "" or vim.bo[event.buf].buftype ~= "" then
            return
        end

        local parent = vim.fn.fnamemodify(filename, ":p:h")
        if parent ~= "" and vim.fn.isdirectory(parent) == 0 then
            vim.fn.mkdir(parent, "p")
        end
    end,
})

local qf_item_match

local function clear_qf_item_match()
    if qf_item_match and vim.api.nvim_win_is_valid(qf_item_match.win) then
        pcall(vim.fn.matchdelete, qf_item_match.id, qf_item_match.win)
    end

    qf_item_match = nil
end

-- Clear search highlight
vim.keymap.set("n", "<C-c>", function()
    clear_qf_item_match()
    vim.cmd("nohlsearch")
    vim.cmd("cclose")
    vim.cmd("lclose")
end, { noremap = true, silent = true, desc = "Clear search and close lists" })

local function select_qf_item_keep_focus()
    local list_win = vim.api.nvim_get_current_win()
    local list_info = vim.fn.getwininfo(list_win)[1]
    if not list_info or list_info.quickfix ~= 1 then
        return
    end

    local command = list_info.loclist == 1 and "ll" or "cc"
    local line = vim.api.nvim_win_get_cursor(list_win)[1]
    local ok, err = pcall(vim.cmd, command .. " " .. line)
    if not ok then
        vim.notify(err, vim.log.levels.WARN)
    else
        local target_win = vim.api.nvim_get_current_win()
        clear_qf_item_match()
        qf_item_match = {
            win = target_win,
            id = vim.api.nvim_win_call(target_win, function()
                return vim.fn.matchaddpos("Search", { { vim.api.nvim_win_get_cursor(0)[1] } }, 10)
            end),
        }
    end

    if vim.api.nvim_win_is_valid(list_win) then
        vim.api.nvim_set_current_win(list_win)
        local next_line = math.min(line + 1, vim.api.nvim_buf_line_count(0))
        vim.api.nvim_win_set_cursor(list_win, { next_line, 0 })
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function(event)
        vim.keymap.set("n", "<S-CR>", select_qf_item_keep_focus, {
            buffer = event.buf,
            noremap = true,
            silent = true,
            desc = "Select item and keep list focus",
        })
    end,
})

-- Save buffer
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>write<CR>", { noremap = true, silent = true, desc = "Save buffer" })

-- Toggle visual line wrapping
vim.keymap.set("n", "<leader>w", "<cmd>set wrap!<CR>", { noremap = true, silent = true, desc = "Toggle line wrap" })

local function toggle_line_centering()
    if vim.o.scrolloff == 999 then
        vim.o.scrolloff = 0
        vim.notify("Line centering off")
    else
        vim.o.scrolloff = 999
        vim.notify("Line centering on")
    end
end

vim.keymap.set("n", "<leader>z", toggle_line_centering, { noremap = true, silent = true, desc = "Toggle line centering" })

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

-- File naviation
vim.g.netrw_liststyle = 1
vim.g.netrw_sizestyle = "H"
vim.g.netrw_list_hide = [[\%(\d\+/\)\=\.\.\=/\s]]
vim.keymap.set("n", "<C-e>", vim.cmd.Explore)

local function copy_netrw_path(modifier)
    local curdir = vim.b.netrw_curdir
    if not curdir or curdir == "" then
        vim.notify("No netrw directory for current buffer", vim.log.levels.WARN)
        return
    end

    local name = vim.fn["netrw#Call"]("NetrwGetWord")
    if name == "" or name == "./" then
        vim.notify("No netrw file under cursor", vim.log.levels.WARN)
        return
    end

    local path = vim.fn["netrw#Call"]("ComposePath", curdir, name)
    copy_text(vim.fn.fnamemodify(path, modifier))
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function(event)
        vim.keymap.set("n", "<M-y>", function()
            copy_netrw_path(":.")
        end, { buffer = event.buf, noremap = true, silent = true, desc = "Copy netrw relative path" })
        vim.keymap.set("n", "<M-Y>", function()
            copy_netrw_path(":p")
        end, { buffer = event.buf, noremap = true, silent = true, desc = "Copy netrw absolute path" })
    end,
})

----------------------------------------------------------------------
-- FFF (fuzzy finder)
----------------------------------------------------------------------
local fff_ok, fff = pcall(require, "fff")
if fff_ok then
    local function get_visual_selection()
        local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
        return table.concat(lines, "\n")
    end

    local function exit_visual_mode()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
    end

    fff.setup({
        lazy_sync = true,
        prompt_vim_mode = false,
        keymaps = {
            preview_scroll_up = "<PageUp>",
            preview_scroll_down = "<PageDown>",
        },
        debug = {
            enabled = true,
            show_scores = true,
        },
    })

    vim.keymap.set("n", "<C-p>", function() fff.find_files() end, { desc = "FFFind files" })
    vim.keymap.set("n", "<C-f>", function()
        fff.live_grep({ grep = { modes = { "fuzzy", "plain" } } })
    end, { desc = "Live fffuzy grep" })
    vim.keymap.set("n", "<leader>fr", function()
        fff.scan_files()
        fff.refresh_git_status()
    end, { desc = "Refresh FFF files and git status" })
    vim.keymap.set("x", "<C-f>", function()
        local query = get_visual_selection()
        if query:match("%S") then
            exit_visual_mode()
            vim.schedule(function()
                fff.live_grep({ query = query })
            end)
        end
    end, { desc = "Search selection" })
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
                stage_hunk = false,
                unstage_hunk = false,
                discard_hunk = false,
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

    local review_hooks_ok, review_hooks = pcall(require, "review.hooks")
    local review_buffer_options = review_hooks_ok and (review_hooks._restore_buffer_options or {}) or {}
    local review_augroup = vim.api.nvim_create_augroup("review_buffer_options", { clear = true })

    if review_hooks_ok then
        review_hooks._restore_buffer_options = review_buffer_options
    end

    local function remember_review_buffer_options(tabpage)
        local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
        if not ok then
            return
        end

        local orig_buf, mod_buf = lifecycle.get_buffers(tabpage or vim.api.nvim_get_current_tabpage())
        for _, bufnr in ipairs({ orig_buf, mod_buf }) do
            if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
                local name = vim.api.nvim_buf_get_name(bufnr)
                if name ~= "" and vim.bo[bufnr].buftype == "" and not review_buffer_options[bufnr] then
                    review_buffer_options[bufnr] = {
                        readonly = vim.bo[bufnr].readonly,
                        modifiable = vim.bo[bufnr].modifiable,
                    }
                end
            end
        end
    end

    if review_hooks_ok then
        review_hooks._remember_buffer_options = remember_review_buffer_options
        if not review_hooks._restore_buffer_options_wrapped then
            local on_session_created = review_hooks.on_session_created

            review_hooks.on_session_created = function(tabpage)
                review_hooks._remember_buffer_options(tabpage)
                return on_session_created(tabpage)
            end

            review_hooks._restore_buffer_options_wrapped = true
        end
    end

    local function restore_review_buffer_options()
        for bufnr, options in pairs(review_buffer_options) do
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.bo[bufnr].readonly = options.readonly
                vim.bo[bufnr].modifiable = options.modifiable
            end
        end
        review_buffer_options = {}
    end

    vim.api.nvim_create_autocmd("User", {
        group = review_augroup,
        pattern = "CodeDiffClose",
        callback = restore_review_buffer_options,
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
        attach_to_untracked = true,
        on_attach = function(bufnr)
            local gs = require("gitsigns")
            local o = { noremap = true, silent = true, buffer = bufnr }

            vim.keymap.set("n", "]c", function() navigate_hunk("next", "]c") end, { buffer = bufnr, desc = "Next hunk" })
            vim.keymap.set("n", "[c", function() navigate_hunk("prev", "[c") end, { buffer = bufnr, desc = "Previous hunk" })

            vim.keymap.set("n", "<leader>hs", gs.stage_hunk, o)
            vim.keymap.set("v", "<leader>hs", function()
                gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, o)
            vim.keymap.set("n", "<leader>hr", gs.reset_hunk, o)
            vim.keymap.set("v", "<leader>hr", function()
                gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, o)
            vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, o)
            vim.keymap.set("n", "<leader>hS", gs.stage_buffer, o)
            vim.keymap.set("n", "<leader>hU", gs.reset_buffer_index, o)
            vim.keymap.set("n", "<leader>hR", gs.reset_buffer, o)
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
        vim.keymap.set("n", "ge", vim.diagnostic.open_float, o)
        vim.keymap.set("n", "gE", vim.diagnostic.setloclist, o)
        vim.keymap.set("n", "gh", vim.lsp.buf.hover, o)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
        vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, o)
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, o)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
        vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, o)
    end,
})

local function get_root_dir(bufnr, markers)
    return vim.fs.root(bufnr, markers) or vim.fn.getcwd()
end

-- Python (pyright)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(ev)
        vim.lsp.start({
            name = "pyright",
            cmd = { "pyright-langserver", "--stdio" },
            root_dir = get_root_dir(ev.buf, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }),
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
            root_dir = get_root_dir(ev.buf, { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" }),
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
            root_dir = get_root_dir(ev.buf, { "tsconfig.json", "jsconfig.json", "package.json", ".git" }),
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
            root_dir = get_root_dir(ev.buf, { "Cargo.toml", ".git" }),
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
            root_dir = get_root_dir(ev.buf, { "flake.nix", ".git" }),
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
            root_dir = get_root_dir(ev.buf, { ".marksman.toml", ".git" }),
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
