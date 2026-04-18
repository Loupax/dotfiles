vim.opt.number = true
vim.opt.conceallevel = 1
vim.opt.relativenumber = true
vim.g.mapleader = ' '
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.g.vimwiki_list = {
  {
    path = '~/vimwiki/',
    syntax = 'markdown',
    ext = 'md'
  }
}

if vim.env.TMUX then
  local tmux_info = vim.fn.system("tmux display-message -p '#S_#I'"):gsub("%s+", "")
  local pipe_path = "/tmp/nvim_" .. tmux_info .. ".pipe"
  
  -- Check if the server is already active to avoid erroring
  if not vim.uv.fs_stat(pipe_path) then
    vim.fn.serverstart(pipe_path)
  end
end

local builtin = require('telescope.builtin')

-- Clipboard
vim.keymap.set({'n', 'x'}, 'gy', '"+y')
vim.keymap.set({'n', 'x'}, 'gp', '"+p')

-- Telescope (using direct Lua calls)
vim.keymap.set({'n', 'x'}, '<leader><space>', builtin.find_files, { desc = 'Telescope Find Files' })
vim.keymap.set({'n', 'x'}, '<leader><space>b', builtin.buffers, { desc = 'Telescope Buffers' })
vim.keymap.set({'n', 'x'}, '<leader><space>g', builtin.live_grep, { desc = 'Telescope Live Grep' })

-- Diagnostics
vim.keymap.set({'n', 'x'}, '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
vim.keymap.set('n', '<leader>ej', ':lua vim.diagnostic.goto_next({float=true})<CR>', { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<leader>ek', ':lua vim.diagnostic.goto_prev({float=true})<CR>', { desc = 'Go to previous diagnostic' })

-- Replace setqflist with Telescope for buffer diagnostics
vim.keymap.set('n', '<leader>ee', builtin.diagnostics, { noremap = true, desc = 'Show buffer diagnostics (Telescope)' })

-- Add a new mapping for workspace-wide diagnostics
vim.keymap.set('n', '<leader>eE', function()
  builtin.diagnostics({ bufnr = 0 })
end, { noremap = true, desc = 'Show workspace diagnostics (Telescope)' })

-- Terminal
vim.keymap.set('n', '<leader>t', '<cmd>botright split | terminal<CR>i', { noremap = true, desc = 'Open terminal' })

-- Autocommand to close quickfix and location list windows with Escape
vim.api.nvim_create_autocmd('FileType', {
  -- The corrected pattern targets both 'qf' (quickfix) and 'lo' (location list)
  pattern = { 'qf', 'lo' },
  callback = function(args)
    -- Creates a mapping that is local *only* to the quickfix/location list buffer.
    -- <C-w>q is a reliable command to close the current window.
    vim.keymap.set('n', '<Esc>', '<C-w>q', { buffer = args.buf, silent = true })
  end,
  desc = 'Close quickfix/location list with Escape',
})
local cmp = require('cmp')
cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(), -- This will now trigger nvim-cmp completion
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item.
                                                      -- Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- LSP completion source
  }, {
    { name = 'buffer' },   -- Current buffer words
    { name = 'path' },     -- File system paths
  })
})
--cmp.setup.cmdline(':', {
--  mapping = cmp.mapping.preset.cmdline(),
--  sources = cmp.config.sources({
--    { name = 'path' }
--  }, {
--    { name = 'cmdline' }
--  })
--})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- LspAttach autocmd for buffer-local keymaps
-- Note: Neovim 0.12 provides defaults for K, grn, gra, grr, gri, grt, CTRL-S, omnifunc
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufopts = { noremap=true, silent=true, buffer=args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  end,
})

-- LSP server configurations
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = {'vim'}
      }
    }
  }
})

vim.lsp.config('gopls', {
  capabilities = capabilities,
  settings = {
    gopls = {
      ["ui.inlayhint.hints"] = {
        compositeLiteralFields = true,
        constantValues = true,
        parameterNames = true
      },
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
    }
  },
})

vim.lsp.config('rust_analyzer', {
  capabilities = capabilities,
})

vim.lsp.config('gdscript', {
  capabilities = capabilities,
  cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
})

vim.lsp.enable({ 'lua_ls', 'gopls', 'rust_analyzer', 'gdscript' })

local dap = require("dap")

dap.adapters.gdscript = {
  type = "server",
  host = "127.0.0.1",
  port = 6006,
}

dap.configurations.gdscript = {
  {
    type = "gdscript",
    request = "launch",
    name = "Launch scene",
    project = "${workspaceFolder}",
    launch_scene = true,
  },
}

require("dapui").setup()
require("lualine").setup({
  sections = {
    lualine_c = {{'filename',path = 1,}}
  },
})
require("nvim-web-devicons").setup()
vim.cmd("colorscheme catppuccin")
