vim.lsp.set_log_level = 'INFO'

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = false

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

vim.o.lazyredraw = true
vim.o.ttyfast = true

vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = true

vim.o.clipboard = 'unnamedplus'

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'no'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.smartindent = true
vim.o.confirm = true

vim.o.foldmethod = 'indent'
vim.o.foldlevelstart = 99

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'json',
    'yaml',
  },
  callback = function(args)
    local ft = args.match
    local opts = {
      json = 2,
      yaml = 2,
    }
    local shiftwidth = opts[ft] or 2
    vim.bo.shiftwidth = shiftwidth
    vim.bo.tabstop = shiftwidth
    vim.bo.softtabstop = shiftwidth
    vim.bo.expandtab = true
  end,
})

vim.keymap.set('n', '<C-v>', 'a<C-r>+<Esc>', { noremap = true })
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true })
vim.keymap.set('c', '<C-v>', '<C-r>+', { noremap = true })

---@diagnostic disable-next-line: undefined-field
vim.opt.iskeyword:append { '-' }

vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Q', 'q', {})

vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })

vim.keymap.set({ 'n', 'v' }, '<S-Enter>', function() end)

vim.keymap.set({ 'n', 'v' }, '<M-x>', '"_dd', { desc = 'Cut the current line without yanking' })

vim.keymap.set({ 'n', 'v' }, 'x', '"_x', { desc = 'Delete character without yanking' })
vim.keymap.set({ 'n', 'v' }, 's', '"_s', { desc = 'Replace character without yanking' })

vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste without yanking' })

vim.keymap.set('n', 'gb', '<c-o>', { desc = '[G]o [B]ack' })
vim.keymap.set({ 'n', 'v' }, 'qq', ':bp<bar>bd #<CR>', { desc = 'Close current buffer and go to previous' })

vim.keymap.set('n', '<C-d>', 'yyp', { desc = 'Duplicate current line [D]own' })
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select all [A]' })

vim.keymap.set({ 'i', 'n', 'v' }, '<F1>', function() end, { desc = 'Disable documentation' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-w>h', '<cmd>split<CR>', { desc = 'Split window horizontally' })

vim.keymap.set('n', '<leader>fw', function()
  local ok, result = pcall(function()
    return vim.api.nvim_exec2('messages', { output = true }).output
  end)
  if not ok then
    result = vim.api.nvim_exec('messages', true)
  end

  local lines = vim.split(result, '\n', { plain = true })

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.max(60, math.floor(vim.o.columns * 0.6))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.5))

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })
end, { desc = 'Show :messages in a floating window' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { '*.c', '*.cpp', '*.h', '*.hpp' },
  callback = function()
    vim.bo.commentstring = '// %s'
    vim.keymap.set('n', '<F1>', ':ClangdSwitchSourceHeader<cr>', { desc = 'ClangdSwitchSourceHeader' })
  end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { '*.h', '*.hpp' },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    if #lines == 1 and lines[1] == '' then
      local file_path = vim.fn.expand '%:p'
      local file_name = vim.fn.expand('%:t:r'):upper()
      local dir_name = vim.fn.fnamemodify(file_path, ':h:t'):upper()

      local guard_format = string.format('%s_%s_H_', dir_name, file_name)
      local guard = string.format('#ifndef %s\n#define %s\n\n#endif  // %s', guard_format, guard_format, guard_format)

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(guard, '\n'))
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { 'main.py' },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    if #lines == 1 and lines[1] == '' then
      vim.api.nvim_buf_set_lines(
        bufnr,
        0,
        -1,
        false,
        vim.split('def main() -> None:\n    pass\n\n\nif __name__ == "__main__":\n    main()', '\n')
      )
    end
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        commentStyle = { italic = false },
        dimInactive = false,
        theme = 'wave',
      }
      vim.cmd 'colorscheme kanagawa'
    end,
  },
  {
    'mg979/vim-visual-multi',
    event = { 'BufReadPre' },
  },
  {
    'folke/which-key.nvim',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  {
    'ibhagwan/fzf-lua',
    opts = {},
    config = function()
      local fzf = require 'fzf-lua'
      fzf.setup {
        winopts = {
          treesitter = { enabled = false },
        },
        previewers = {
          builtin = {
            treesitter = {
              enabled = false,
            },
          },
        },
      }

      vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', fzf.live_grep_native, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sD', fzf.lsp_document_symbols, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>s/', fzf.grep_curbuf, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>sn', function()
        fzf.files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',

    opts = {
      appearance = {
        nerd_font_variant = vim.g.have_nerd_font and 'mono' or 'normal',
      },
      signature = { enabled = true },
      completion = {
        documentation = { auto_show = true },
        accept = { auto_brackets = { enabled = true } },
      },
      sources = {
        default = { 'lsp' },
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'mason-org/mason.nvim',
        cmd = 'Mason',
        opts = {},
      },
      'saghen/blink.cmp',
      'ibhagwan/fzf-lua',
    },
    config = function()
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          do
            local fzf = require 'fzf-lua'

            map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
            map('gra', fzf.lsp_code_actions, '[G]oto Code [A]ction', { 'n', 'x' })
            map('grr', fzf.lsp_references, '[G]oto [R]eferences')
            map('gri', fzf.lsp_implementations, '[G]oto [I]mplementation')
            map('grd', fzf.lsp_definitions, '[G]oto [D]efinitions')
            map('grD', fzf.lsp_declarations, '[G]oto [D]eclaration')
            map('gO', fzf.lsp_document_symbols, 'Open Document Symbols')
            map('gW', fzf.lsp_live_workspace_symbols, 'Open Workspace Symbols')
            map('grt', fzf.lsp_typedefs, '[G]oto [T]ype Definition')
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds {
                  group = 'kickstart-lsp-highlight',
                  buffer = event2.buf,
                }
              end,
            })
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      do
        local servers = {
          basedpyright = {
            cmd = {
              'basedpyright-langserver',
              '--stdio',
              '--threads',
              tostring(#vim.uv.cpu_info() / 2),
            },
            settings = {
              basedpyright = {
                disableOrganizeImports = true,
                disableTaggedHints = true,
                analysis = {
                  autoImportCompletions = true,
                  autoSearchPaths = true,
                  diagnosticMode = 'openFilesOnly',
                  logLevel = 'Information',
                  typeCheckingMode = 'standard',
                  useLibraryCodeForTypes = true,
                },
              },
            },
          },
          lua_ls = {
            on_init = function(client)
              if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if
                  path ~= vim.fn.stdpath 'config'
                  and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
                then
                  return
                end
              end

              client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                  version = 'LuaJIT',
                },
                workspace = {
                  checkThirdParty = false,
                  library = {
                    vim.env.VIMRUNTIME,
                    '${3rd}/luv/library',
                    '${3rd}/busted/library',
                    vim.fn.stdpath 'data' .. '/lazy',
                  },
                },
              })
            end,
            settings = {
              Lua = {
                diagnostics = {
                  globals = {
                    'vim',
                    'require',
                  },
                },
                completion = {
                  callSnippet = 'Replace',
                },
              },
            },
          },
          clangd = {
            cmd = {
              'clangd',
              '--offset-encoding=utf-16',
              '--clang-tidy',
              '--completion-style=bundled',
              '--cross-file-rename',
            },
            init_options = {
              clangdFileStatus = true,
              usePlaceholders = true,
              completeUnimported = true,
              semanticHighlighting = true,
            },
          },
        }

        local capabilities = require('blink.cmp').get_lsp_capabilities()
        for server, config in pairs(servers) do
          config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
          vim.lsp.config(server, config)
          vim.lsp.enable(server)
        end
      end
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      log_level = vim.log.levels.INFO,
      notify_on_error = false,
      format_after_save = {
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = {
          'isort',
          'ruff_format',
        },
        json = { 'jq', 'prettierd', 'prettier' },
        go = { 'gofmt', 'goimports' },
        cmake = { 'cmake_format' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        htmldjango = { 'djlint' },
        css = { 'prettierd', 'prettier' },
        javascript = { 'prettierd', 'prettier' },
        typescript = { 'prettierd', 'prettier' },
        yaml = { 'prettierd', 'prettier' },
        zig = { 'zigfmt' },
      },
    },

    config = function(_, opts)
      local conform = require 'conform'
      conform.setup(opts)

      conform.formatters.isort = {
        args = function(_, _)
          return {
            '--stdout',
            '--filename',
            '$FILENAME',
            '-',
          }
        end,
      }

      conform.formatters.ruff_format = {
        args = function()
          local cwd = vim.fn.getcwd()
          local config_path = nil

          if vim.uv.fs_stat(cwd .. '/ruff.toml') then
            config_path = cwd .. '/ruff.toml'
          elseif vim.uv.fs_stat(cwd .. '/pyproject.toml') then
            config_path = cwd .. '/pyproject.toml'
          end

          local args = {
            'format',
            '--force-exclude',
            '--stdin-filename',
            '$FILENAME',
            '-',
          }

          if config_path then
            table.insert(args, 2, config_path)
            table.insert(args, 2, '--config')
          end

          return args
        end,
      }

      conform.formatters.stylua = {
        prepend_args = {
          '--column-width',
          '120',
          '--line-endings',
          'Unix',
          '--indent-type',
          'Spaces',
          '--indent-width',
          '2',
          '--quote-style',
          'AutoPreferSingle',
          '--call-parentheses',
          'None',
        },
      }

      conform.formatters.clang_format = {
        args = function(_, _)
          return {
            '-style',
            'google',
          }
        end,
      }

      conform.formatters.djlint = {
        prepend_args = {
          '--quiet',
          '--blank-line-after-tag',
          'load,extends,include',
          '--blank-line-before-tag',
          'load,extends,include',
          '--close-void-tags',
        },
      }

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*',
        callback = function(args)
          conform.format { bufnr = args.buf }
        end,
      })
    end,
  },
  {
    'mfussenegger/nvim-lint',
    event = 'BufWritePre',
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        python = { 'ruff' },
        c = { 'cpplint', 'clangtidy' },
        cpp = { 'cpplint', 'clangtidy' },
        lua = { 'selene' },
      }

      local selene = lint.linters.selene
      selene.args = {
        '--config',
        vim.fn.stdpath 'config' .. 'selene.toml',
        '--num-threads',
        tostring(#vim.uv.cpu_info() / 2),
        '--display-style',
        'json',
        '-',
      }

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        group = lint_augroup,
        callback = function()
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
  {
    'stevearc/oil.nvim',
    keys = {
      {
        '\\',
        function()
          if vim.bo.filetype ~= 'oil' then
            vim.cmd 'Oil'
          end
        end,
      },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      keymaps = {
        ['g?'] = 'actions.show_help',
        ['<CR>'] = 'actions.select',
        ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
        ['<C-h>'] = { mode = 'n', rhs = '<C-w><C-h>', desc = 'Move focus to the left window' },
        ['<C-t>'] = { 'actions.select', opts = { tab = true } },
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = { 'actions.close', mode = 'n' },
        ['<C-l>'] = { mode = 'n', rhs = '<C-w><C-l>', desc = 'Move focus to the right window' },
        ['-'] = 'actions.parent',
        ['_'] = 'actions.open_cwd',
        ['`'] = 'actions.cd',
        ['~'] = { 'actions.cd', opts = { scope = 'tab' } },
        ['gs'] = function() end,
        ['gx'] = function() end,
        ['g.'] = function() end,
        ['g\\'] = 'actions.toggle_trash',
      },
      view_options = {
        show_hidden = true,
        natural_order = 'fast',
      },
    },
  },
  {
    'nvim-mini/mini.nvim',
    event = { 'BufReadPre' },
    config = function()
      require('mini.surround').setup()
      require('mini.pairs').setup()
      require('mini.trailspace').setup()

      do
        local indentscope = require 'mini.indentscope'
        indentscope.setup {
          draw = {
            delay = 0,
            animation = indentscope.gen_animation.none(),
          },
          options = {
            n_lines = vim.api.nvim_win_get_height(0),
          },
          symbol = '│',
        }
      end

      do
        local hipatterns = require 'mini.hipatterns'
        hipatterns.setup {
          highlighters = {
            fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
            hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
            todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
            note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        }
      end

      do
        local statusline = require 'mini.statusline'
        statusline.setup { use_icons = vim.g.have_nerd_font }
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
          return '%2l:%-2v'
        end
      end
    end,
  },
}, {
  ui = {
    icons = {},
  },
})
