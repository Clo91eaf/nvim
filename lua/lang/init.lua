local register = require("pack").register

-- Interact with LSP server
register("neovim/nvim-lspconfig", {
  lazy = true,
  config = function()
    require("lang.icons").setup()
  end,
})

-- UI for builtin LSP function
register("glepnir/lspsaga.nvim", {
  event = "LspAttach",
  cmd = "LspSaga",
  config = function()
    require("lang.lspsaga")
  end,
})

-- Inject more LSP sources
register("jose-elias-alvarez/null-ls.nvim", {
  lazy = true,
})

-- Rust specific plugin
register("simrat39/rust-tools.nvim", {
  lazy = true,
})

-- Cargo.toml manager
register("saecki/crates.nvim", {
  event = "BufRead Cargo.toml",
  config = function()
    require("crates").setup({
      popup = {
        autofocus = true,
        border = "single",
      },
    })

    require("cmp").setup.buffer({
      sources = {
        { name = "crates" },
      },
    })

    -- Find buffer id for `Cargo.toml` file
    local existing_buffer = vim.api.nvim_list_bufs()
    local cargo_toml_buf_id = nil
    for _, buf_id in ipairs(existing_buffer) do
      local buf_name = vim.api.nvim_buf_get_name(buf_id)
      local filename = vim.fn.fnamemodify(buf_name, ":t")
      if filename == "Cargo.toml" then
        cargo_toml_buf_id = buf_id
      end
    end
    if cargo_toml_buf_id == nil then
      return
    end

    local crates = require("crates")

    -- this key mappings will only apply to the `Cargo.toml` file buffer
    require("libs.keymap").buf_map(cargo_toml_buf_id, "n", {
      { "<leader>cu", crates.upgrade_crate, desc = "Upgrade crate under current cursor" },
      { "<leader>cv", crates.show_versions_popup, desc = "Show current crate versions" },
      { "<leader>cf", crates.show_features_popup, desc = "Show current crate features" },
      { "<leader>cR", crates.open_repository, desc = "Open source code in browser" },
      { "<leader>cD", crates.open_documentation, desc = "Open docs.rs in browser" },
      { "ga", "<CMD>Lspsaga code_action<CR>", desc = "Open actions" },
    })

    local whichkey = require("which-key")

    local ngrp = {
      mode = "n",
      buffer = cargo_toml_buf_id,
      ["<leader>c"] = { name = "+Crates" },
    }
    whichkey.register(ngrp)
  end,
})

register("numToStr/Comment.nvim", {
  config = function()
    require("Comment").setup({})
  end,
  keys = {
    "gcc",
    "gbc",
    { mode = "x", "gc" },
    { mode = "x", "gb" },
  },
})

register("scalameta/nvim-metals", {
  lazy = true,
})

register("stevearc/conform.nvim", {
  ft = { "lua", "javascript", "nix", "haskell", "python" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        -- Use a sub-list to run only the first available formatter
        javascript = { { "prettierd", "prettier" } },
        nix = { "nixpkgs_fmt" },
        haskell = { "fourmolu" },
        python = { "black" },
      },
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.lua", "*.javascript", "*.nix", "*.hs", "*.lhs", "*.py" },
      callback = function(args)
        require("conform").format({ bufnr = args.buf })
      end,
    })
  end,
})

register("VidocqH/lsp-lens.nvim", {
  event = "LspAttach",
  config = function()
    require("lsp-lens").setup({})
  end,
})

local export = {}

---@param server string Server name
---@param extra table Extra config to override the default
function export.run_lsp(server, extra)
  local config = require("lang.config")
  if extra then
    -- This value might be nil, so we need to assign default values
    config.on_attach = extra.on_attach or require("lang.keymaps")
    config.settings = extra.settings or {}

    -- And finally try to merge other settings
    config = vim.tbl_deep_extend("force", config, extra)
  end

  local lspconfig = require("lspconfig")

  lspconfig[server].setup(config)
  -- manually setup because FileType event is behind BufReadPost event
  local bufnr = vim.api.nvim_get_current_buf()
  lspconfig[server].manager:try_add_wrapper(bufnr, nil)
end

return export
