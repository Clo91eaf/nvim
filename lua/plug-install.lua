local install_path = "~/.local/share/nvim/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
	vim.api.nvim_command([[
		function PackerSetup()
			PackerCompile
			PackerInstall
		endfunction
		autocmd VimEnter * call PackerSetup()
	]])
end

vim.api.nvim_exec(
  [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]],
  false
)

local use = require('packer').use
require('packer').startup(function()
	use 'lukas-reineke/indent-blankline.nvim'

  --telescope: extensible fuzzy file finder--
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'

  --nvim-bufferline: better buffer line--
  use 'akinsho/nvim-bufferline.lua'

  --nvim-lspinstall: lsp manager--
  use 'kabouzeid/nvim-lspinstall'

  --nvim-compe: code completion--
  use 'hrsh7th/nvim-compe'

  --nvim-lspconfig: built-in lsp--
  use 'neovim/nvim-lspconfig'

  --nvim-tree.lua--
  use 'kyazdani42/nvim-tree.lua'

  --TrueZen.nvim: zen mode in neovim--
  use 'Pocco81/TrueZen.nvim'

  --asyncrun.vim: run command in background--
  use 'skywind3000/asyncrun.vim'

  --vim-commentary: for quickly commenting--
  use 'tpope/vim-commentary'

  --vim-smoothie: smooth scrolling--
  use 'psliwka/vim-smoothie'

  --barbar.nvim: bufferline bar--
  use 'kyazdani42/nvim-web-devicons'

  --fancy start page--
  use 'mhinz/vim-startify'

  --markdown preview
	use {
		'iamcco/markdown-preview.nvim',
		run = function() vim.fn['mkdp#util#install']() end,
		cmd = 'MarkdownPreviewk'
	}

  --mulit cursor
	use {
		'mg979/vim-visual-multi',
		branch = 'master',
	}

  --open file when forget sudo
  use 'lambdalisue/suda.vim'

  --treesitter: support more colorful highlighting
	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  --neovim color theme
  use 'Avimitin/neovim-deus'
  use 'morhetz/gruvbox'

  --status bar
	use {
		'Avimitin/nerd-galaxyline',
		requires = {
			'glepnir/galaxyline.nvim',
			branch='main',
			requires = {'kyazdani42/nvim-web-devicons'}
		}
	}

  --highlight all the word below the cursor
  use 'RRethy/vim-illuminate'

  --file navigation
  use 'mcchrish/nnn.vim'
  use 'airblade/vim-rooter'
  use 'pechorin/any-jump.vim'

  --list function/module/struct tag
  use 'liuchengxu/vista.vim'

  --show git diff in sign column
  use 'airblade/vim-gitgutter'

  --Golang support
	use {
		'fatih/vim-go',
	}

  --Select text object
  use 'gcmt/wildfire.vim'

  --surrounding select text with given text
  use 'tpope/vim-surround'

  --auto pair bracket
  use 'jiangmiao/auto-pairs'

  --amazing icon
  use 'ryanoasis/vim-devicons'

  --align
  use 'junegunn/vim-easy-align'

  --find and replace
  use 'brooth/far.vim'

  --lazygit
  use 'kdheepak/lazygit.nvim'

  --modify text after object
  use 'junegunn/vim-after-object'

  --markdown toc
  use 'mzlogin/vim-markdown-toc'

  --clang-format
  use 'rhysd/vim-clang-format'

  --rust
  use 'rust-lang/rust.vim'

  --easy motion
  use 'easymotion/vim-easymotion'

  -- usein for cmake
  use 'cdelledonne/vim-cmake'

  -- open a big terminal
  use 'numtostr/FTerm.nvim'
end)