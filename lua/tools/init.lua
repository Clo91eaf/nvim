local register = require("pack").register

-- Auto-pairs key mappings
register("hrsh7th/nvim-insx", {
  event = "InsertEnter",
  branch = "main",
  config = function()
    require("insx.preset.standard").setup()
  end,
})

-- Neovim API completion sources
register("ii14/emmylua-nvim", {
  lazy = true,
})

-- Neovim Library wrapper
register("nvim-lua/plenary.nvim", {
  lazy = true,
})

-- UI Library
register("MunifTanjim/nui.nvim", {
  lazy = true,
})

register("nvim-neo-tree/neo-tree.nvim", {
  branch = "v3.x",
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      pattern = "*",
      callback = function()
        -- User might using stdin
        if vim.fn.argc() == 0 then
          return
        end
        local first_arg = vim.fn.argv(0)
        if not first_arg or #first_arg == 0 or (first_arg[1] == "-" or first_arg[1] == "+") then
          return
        end

        vim.uv.fs_stat(
          first_arg,
          vim.schedule_wrap(function(err, stat)
            if err then
              return
            end

            if stat.type ~= "directory" then
              return
            end

            require("neo-tree.setup.netrw").hijack()
          end)
        )
      end,
    })
  end,
  config = function()
    vim.g.neo_tree_remove_legacy_commands = 1

    require("neo-tree").setup({
      close_if_last_window = true,
      sources = {
        "filesystem",
        "buffers",
        "git_status",
        "document_symbols",
      },
      filesystem = {
        hijack_netrw_behavior = "open_current",
      },
      open_files_do_not_replace_types = {
        "terminal",
        "trouble",
        "qf",
        "diff",
        "fugitive",
        "fugitiveblame",
        "notify",
      },
      window = {
        width = 28,
      },
      default_component_configs = {
        diagnostics = {
          symbols = {
            error = "",
            warn = "",
            hint = "",
            info = "",
          },
        },
        git_status = {
          symbols = {
            -- I don't need change type
            added = "",
            deleted = "",
            modified = "",
            renamed = "",
            -- Status type
            untracked = "",
            ignored = "",
            unstaged = "",
            staged = "",
            conflict = "",
          },
        },
      },
    })
  end,
  -- End of config
  keys = {
    {
      "<leader>t",
      "<CMD>Neotree action=focus toggle=true reveal=true position=left<CR>",
      desc = "Open file tree",
    },
    {
      "gl",
      "<CMD>Neotree action=focus toggle=true source=document_symbols position=float<CR>",
      desc = "[LSP] View document symbols",
    },
  },
  cmd = {
    "Neotree",
  },
})

local function my_ivy(opt)
  local my_opt = {
    borderchars = {
      prompt = { " " },
      results = { " " },
      preview = { " " },
    },
  }
  local exted = vim.tbl_deep_extend("force", my_opt, opt or {})
  return require("telescope.themes").get_ivy(exted)
end

-- Fuzzy Picker
register("nvim-telescope/telescope.nvim", {
  lazy = true,
  config = function()
    require("telescope").setup({
      defaults = {
        prompt_prefix = "  ",
        entry_prefix = "  ",
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--trim", -- add this value
          },
        },
      },
      pickers = {
        find_files = {
          -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    })
  end,
  keys = {
    {
      "<leader>ff",
      function()
        local function my_find_file(opt)
          if not vim.b._is_inside_git_worktree then
            vim.fn.system("git rev-parse --is-inside-work-tree")
            vim.b._is_inside_git_worktree = vim.v.shell_error == 0
          end
          if vim.b._is_inside_git_worktree then
            return require("telescope.builtin").git_files(opt)
          else
            return require("telescope.builtin").find_files(opt)
          end
        end

        my_find_file(my_ivy({ hidden = true }))
      end,
      desc = "Find file",
    },
    {
      "<leader>fs",
      function()
        require("telescope.builtin").lsp_dynamic_workspace_symbols(my_ivy())
      end,
      desc = "Find symbol",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep(my_ivy())
      end,
      desc = "Find keyword",
    },
  },
})

-- Quick select for text objects
register("sustech-data/wildfire.nvim", {
  keys = "<Enter>",
  config = function()
    require("wildfire").setup()
  end,
})

-- Surround operation
register("kylechui/nvim-surround", {
  keys = {
    "ys",
    "yS",
    "cs",
    "cS",
    "ds",
    "dS",
    { "gs",    mode = { "x" } },
    { "gS",    mode = { "x" } },
    { "<C-g>", mode = "i" },
  },
  config = function()
    require("nvim-surround").setup({
      keymaps = {
        visual = "gs",
      },
      -- add new object "y" for operating on Types. For example: `Vector<String>`
      surrounds = {
        ["y"] = {
          add = function()
            local result = require("nvim-surround.config").get_input("Enter the type name: ")
            if result then
              return { { result .. "<" }, { ">" } }
            end
          end,
          find = function()
            return require("nvim-surround.config").get_selection({
              pattern = "[^=%s%(%)]+%b<>",
            })
          end,
          delete = "^(.-<)().-(>)()$",
          change = {
            target = "^.-([%w_]+)()<.->()()$",
            replacement = function()
              local result =
                  require("nvim-surround.config").get_input("Enter new type replacement: ")
              if result then
                return { { result }, { "" } }
              end
            end,
          },
        },
      },
    })
  end,
})

-- Quick moving by two character searching
register("ggandor/leap.nvim", {
  keys = {
    {
      "gj",
      require("tools.line_leap").leap_to_line,
      mode = { "n", "o", "x" },
      desc = "Leap to line",
    },
    {
      "gk",
      require("tools.line_leap").leap_to_line,
      mode = { "n", "o", "x" },
      desc = "Leap to line",
    },
    { "s",  "<Plug>(leap-forward-to)",    mode = { "n", "x", "o" }, desc = "Leap forward to" },
    { "S",  "<Plug>(leap-backward-to)",   mode = { "n", "x", "o" }, desc = "Leap backward to" },
    { "x",  "<Plug>(leap-forward-till)",  mode = { "x", "o" },      desc = "Leap forward until" },
    { "X",  "<Plug>(leap-backward-till)", mode = { "x", "o" },      desc = "Leap backward until" },
    { "gw", "<Plug>(leap-from-window)",   mode = { "n" },           desc = "Leap from window" },
    { "gW", "<Plug>(leap-cross-window)",  mode = { "n" },           desc = "Leap cross window" },
  },
  -- when flit.nvim is loaded, it will try to load leap.nvim
  module = true,
})

register("ggandor/flit.nvim", {
  keys = {
    "f",
    "F",
    "t",
    "T",
  },
  config = function()
    require("flit").setup({})
  end,
})

-- sort the number or text
register("sQVe/sort.nvim", {
  config = function()
    require("sort").setup({})
  end,
  cmd = "Sort",
})

-- Better search and replace (With Rust regex)
-- Load it with command `:Sed`
register("windwp/nvim-spectre", {
  lazy = true,
  init = function()
    vim.api.nvim_create_user_command("Sed", function()
      require("spectre").open()
    end, {})
  end,
})

-- Highlight search matches
register("kevinhwang91/nvim-hlslens", {
  keys = {
    {
      "n",
      [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>zz]],
    },
    {
      "N",
      [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>zz]],
    },
    { "*",     [[*<Cmd>lua require('hlslens').start()<CR>]] },
    { "#",     [[#<Cmd>lua require('hlslens').start()<CR>]] },
    { "g*",    [[g*<Cmd>lua require('hlslens').start()<CR>]] },
    { "g#",    [[g#<Cmd>lua require('hlslens').start()<CR>]] },
    { "<ESC>", [[<cmd>noh<CR><cmd>lua require('hlslens').stop()<CR>]] },
  },
  config = function()
    require("scrollbar.handlers.search").setup()
  end,
})

-- Auto matically setting tab width by projects
register("tpope/vim-sleuth")

--- Color utils
register("uga-rosa/ccc.nvim", {
  config = function()
    require("ccc").setup()
  end,
  cmd = {
    "CccPick",
    "CccHighlighterEnable",
  },
})

-- Easy aligning text
register("junegunn/vim-easy-align", {
  cmd = "EasyAlign",
  keys = { { "<space>e", ":EasyAlign<CR>", mode = "x" } },
})

-- Show key stroke
register("folke/which-key.nvim", {
  event = "VeryLazy",
  config = function()
    local whichkey = require("which-key")
    whichkey.setup({
      plugins = {
        mark = false,
        register = false,
      },
      window = {
        winblend = 10,
      },
      layout = {
        align = "center",
      },
    })

    local ngrp = {
      mode = "n",
      ["<leader>g"] = { name = "+Git" },
      ["<leader>f"] = { name = "+Telescope" },
    }
    whichkey.register(ngrp)
  end,
})

-- Split and Join
register("Wansmer/treesj", {
  keys = {
    {
      "J",
      function()
        require("treesj").toggle()
      end,
      desc = "Split or Join multiple line",
    },
  },
  config = function()
    require("treesj").setup({
      use_default_keymaps = false,
    })
  end,
})

local function gen_spider_keys()
  local keys = { "w", "e", "b" }
  local final = {}
  for _, k in ipairs(keys) do
    table.insert(final, {
      k,
      function()
        require("spider").motion(k)
      end,
      desc = "Spider motion " .. k,
    })
  end
  return final
end
register("chrisgrieser/nvim-spider", {
  keys = gen_spider_keys(),
  lazy = true,
})

register("Avimitin/NeoTerm.lua", {
  lazy = true,
  branch = "global_buf_support",
  keys = {
    { "<C-t>", vim.cmd.NeoTermToggle, mode = { "n", "t" } },
    { "<C-n>", "<C-\\><C-n>",         mode = "t" },
  },
  init = function()
    -- auto-insert on enter term-buf of NeoTerm.
    local id = vim.api.nvim_create_augroup("NeoTermUserCommands", {})
    vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
      group = id,
      pattern = "*",
      callback = function()
        if vim.bo.filetype ~= "neo-term" or vim.bo.buftype ~= "terminal" then
          return
        end
        vim.cmd.startinsert()
        vim.wo.number = false
      end,
    })
    -- cancel-insert on exit term-buf of NeoTerm.
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
      group = id,
      pattern = "*",
      callback = function()
        if vim.bo.filetype ~= "neo-term" or vim.bo.buftype ~= "terminal" then
          return
        end
        vim.cmd.stopinsert()
        vim.wo.number = true
      end,
    })
  end,
  config = function()
    require("neo-term").setup({
      enable_global_term = true,
      term_mode_hl = "Normal",
    })
  end,
})

register("willothy/flatten.nvim", {
  config = function()
    require("flatten").setup({})
  end,
  -- This plugin only read `vim.env.NVIM` on start up, there is no overhead.
  -- But lazy loading it will instead causing multiple issues, so just don't be lazy here.
  lazy = false,
  priority = 1001,
})

register("kevinhwang91/nvim-bqf", {
  ft = "qf",
})

-- Open buffer manager
register("j-morano/buffer_manager.nvim", {
  lazy = true,
  config = function()
    require("buffer_manager").setup({})
  end,
})

-- Cycle through buffers
register("ghillb/cybu.nvim", {
  lazy = true,
  config = function()
    require("cybu").setup({
      style = {
        border = "none",
        padding = 5,
      },
      display_time = 500,
      exclude = {
        "neo-tree",
        "qf",
        "neo-term",
      },
    })
  end,
})

-- GitHub Manager
register("pwntester/octo.nvim", {
  cmd = "Octo",
  config = function()
    require("octo").setup({})
  end,
})
