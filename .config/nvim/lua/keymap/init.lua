local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_args = bind.map_args
require('keymap.config')

local plug_map = {
  -- ["i|<TAB>"]      = map_cmd('v:lua.tab_complete()'):with_expr():with_silent(),
  -- ["i|<S-TAB>"]    = map_cmd('v:lua.s_tab_complete()'):with_silent():with_expr(),
  -- ["i|<CR>"]       = map_cmd([[compe#confirm({ 'keys': "\<Plug>delimitMateCR", 'mode': '' })]]):with_noremap():with_expr():with_nowait(),
  -- person keymap
  -- ["n|mf"]             = map_cr("<cmd>lua require('internal.fsevent').file_event()<CR>"):with_silent():with_nowait():with_noremap();
  -- ["n|gb"]             = map_cr("BufferLinePick"):with_noremap():with_silent(),
  -- Packer
  ["n|<leader>pu"]            = map_cr("PackerUpdate"):with_noremap():with_nowait(),
  ["n|<leader>pi"]            = map_cr("PackerInstall"):with_noremap():with_nowait(),
  ["n|<leader>pc"]            = map_cr("PackerCompile"):with_noremap():with_nowait(),
  -- Lsp mapp work when insertenter and lsp start
  ["n|<leader>li"]            = map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>ll"]            = map_cr("LspLog"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>lr"]            = map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
  -- ["n|<C-f>"]          = map_cmd("<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>"):with_silent():with_noremap(),
  -- ["n|<C-b>"]          = map_cmd("<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>"):with_silent():with_noremap(),
  ["n|]e"]                    = map_cr('Lspsaga diagnostic_jump_next'):with_noremap():with_silent(),
  ["n|[e"]                    = map_cr('Lspsaga diagnostic_jump_prev'):with_noremap():with_silent(),
  ["n|K"]                     = map_cr("Lspsaga hover_doc"):with_noremap():with_silent(),
  ["n|ga"]                    = map_cr("Lspsaga code_action"):with_noremap():with_silent(),
  ["v|ga"]                    = map_cu("Lspsaga range_code_action"):with_noremap():with_silent(),
  ["n|gD"]                    = map_cr('Lspsaga preview_definition'):with_noremap():with_silent(),
  ["n|gd"]                    = map_cmd("<cmd>lua vim.lsp.buf.definition()<CR>"):with_noremap():with_silent(),
  ["n|<leader>gd"]            = map_cmd("<cmd>vsp<CR><cmd>lua vim.lsp.buf.definition()<CR>"):with_noremap():with_silent(),
  ["n|gi"]                    = map_cmd("<cmd>lua vim.lsp.buf.implementation()<CR>"):with_noremap():with_silent(),
  ["n|gs"]                    = map_cr('Lspsaga signature_help'):with_noremap(),
  ["n|gr"]                    = map_cr('Lspsaga rename'):with_noremap():with_silent(),
  ["n|gh"]                    = map_cr('Lspsaga finder'):with_noremap():with_silent(),
  ["n|<leader>so"]            = map_cr('Lspsaga outline'):with_noremap():with_silent(),
  ["n|<leader>gt"]            = map_cmd('<cmd>lua vim.lsp.buf.type_definition()<CR>'):with_noremap():with_silent(),
  ["n|<Leader>w"]             = map_cmd('<cmd>lua vim.lsp.buf.workspace_symbol()<CR>'):with_noremap():with_silent(),
  ["n|<Leader>cd"]            = map_cr('Lspsaga show_line_diagnostics'):with_noremap():with_silent(),
  -- ["n|<Leader>ct"]     = map_args("Template"),
  -- ["n|<Leader>tf"]     = map_cu('DashboardNewFile'):with_noremap():with_silent(),
  -- Plugin nvim-tree
  -- ["n|<Leader>e"]      = map_cr('NvimTreeToggle'):with_noremap():with_silent(),
  -- ["n|<Leader>F"]      = map_cr('NvimTreeFindFile'):with_noremap():with_silent(),
  -- Plugin MarkdownPreview
  -- ["n|<Leader>om"]     = map_cu('MarkdownPreview'):with_noremap():with_silent(),
  -- Plugin DadbodUI
  -- ["n|<Leader>od"]     = map_cr('DBUIToggle'):with_noremap():with_silent(),
  -- Plugin Floaterm
  -- ["n|<Leader>t"]          = map_cu('Lspsaga open_floaterm'):with_noremap():with_silent(),
  -- ["t|<Leader>t"]          = map_cu([[<C-\><C-n>:Lspsaga close_floaterm<CR>]]):with_noremap():with_silent(),
  -- ["n|<Leader>g"]      = map_cu("Lspsaga open_floaterm lazygit"):with_noremap():with_silent(),
  -- Far.vim
  -- ["n|<Leader>fz"]     = map_cr('Farf'):with_noremap():with_silent();
  -- ["v|<Leader>fz"]     = map_cr('Farf'):with_noremap():with_silent();
  -- Plugin Lua FZF
  -- ["n|<C-p>"]                 = map_cu('FzfLua git_files'):with_noremap():with_silent(),
  -- ["n|<Leader><C-p>"]         = map_cu('execute "FzfLua files cwd=" . expand("%:h")'):with_noremap(),
  ["n|<Leader>t"]             = map_cu('FzfLua tabs'):with_noremap():with_silent(),
  ["n|<Leader><Leader><C-p>"] = map_cu('FzfLua files'):with_noremap():with_silent(),
  ["n|<Leader>h"]             = map_cu('FzfLua oldfiles'):with_noremap():with_silent(),
  -- ["n|<Leader><Leader>s"]     = map_cu('FzfLua grep'):with_noremap():with_silent(),
  -- Plugin Telescope
  -- ["n|<Leader>bb"]     = map_cu('Telescope buffers'):with_noremap():with_silent(),
  -- ["n|<Leader>fa"]     = map_cu('DashboardFindWord'):with_noremap():with_silent(),
  -- ["n|<Leader>fb"]     = map_cu('Telescope file_browser'):with_noremap():with_silent(),
  -- ["n|<Leader>ff"]     = map_cu('DashboardFindFile'):with_noremap():with_silent(),
  -- ["n|<Leader>fg"]     = map_cu('Telescope git_files'):with_noremap():with_silent(),
  -- ["n|<Leader>fw"]     = map_cu('Telescope grep_string'):with_noremap():with_silent(),
  -- ["n|<Leader>fh"]     = map_cu('DashboardFindHistory'):with_noremap():with_silent(),
  -- ["n|<Leader>fl"]     = map_cu('Telescope loclist'):with_noremap():with_silent(),
  -- ["n|<Leader>fc"]     = map_cu('Telescope git_commits'):with_noremap():with_silent(),
  -- ["n|<Leader>ft"]     = map_cu('Telescope help_tags'):with_noremap():with_silent(),
  -- ["n|<Leader>fd"]     = map_cu('Telescope dotfiles path='..os.getenv("HOME")..'/.dotfiles'):with_noremap():with_silent(),
  -- ["n|<Leader>fs"]     = map_cu('Telescope gosource'):with_noremap():with_silent(),
  -- prodoc
  -- ["n|gcc"]            = map_cu('ProComment'):with_noremap():with_silent(),
  -- ["x|gcc"]            = map_cr('ProComment'),
  -- ["n|gcj"]            = map_cu('ProDoc'):with_silent():with_silent(),
  -- Plugin acceleratedjk
  -- ["n|j"]              = map_cmd('v:lua.enhance_jk_move("j")'):with_silent():with_expr(),
  -- ["n|k"]              = map_cmd('v:lua.enhance_jk_move("k")'):with_silent():with_expr(),
  -- Plugin QuickRun
  -- ["n|<Leader>r"]     = map_cr("<cmd> lua require'internal.quickrun'.run_command()"):with_noremap():with_silent(),
  -- Plugin Vista
  -- ["n|<Leader>v"]      = map_cu('Vista'):with_noremap():with_silent(),
  -- Plugin hrsh7th/vim-eft
  -- ["n|;"]              = map_cmd("v:lua.enhance_ft_move(';')"):with_expr(),
  -- ["x|;"]              = map_cmd("v:lua.enhance_ft_move(';')"):with_expr(),
  -- ["n|f"]              = map_cmd("v:lua.enhance_ft_move('f')"):with_expr(),
  -- ["x|f"]              = map_cmd("v:lua.enhance_ft_move('f')"):with_expr(),
  -- ["o|f"]              = map_cmd("v:lua.enhance_ft_move('f')"):with_expr(),
  -- ["n|F"]              = map_cmd("v:lua.enhance_ft_move('F')"):with_expr(),
  -- ["x|F"]              = map_cmd("v:lua.enhance_ft_move('F')"):with_expr(),
  -- ["o|F"]              = map_cmd("v:lua.enhance_ft_move('F')"):with_expr(),
  -- Plugin vimspector
  ["n|<leader>dd"]            = map_cr("call vimspector#Launch()"):with_noremap():with_silent(),
  ["n|<leader>dr"]            = map_cr("VimspectorReset"):with_noremap():with_silent(),
  ["n|<leader>dc"]            = map_cmd("<Plug>VimspectorContinue"):with_noremap():with_silent(),
  ["n|<leader>dC"]            = map_cmd("<Plug>VimspectorRunToCursor"):with_noremap():with_silent(),
  ["n|<leader>ds"]            = map_cmd("<Plug>VimspectorStop"):with_noremap():with_silent(),
  ["n|<leader>dt"]            = map_cmd("<Plug>VimspectorToggleBreakpoint"):with_noremap():with_silent(),
  ["n|<leader>do"]            = map_cmd("<Plug>VimspectorStepOver"):with_noremap():with_silent(),
  ["n|<leader>di"]            = map_cmd("<Plug>VimspectorStepInto"):with_noremap():with_silent(),
  ["n|<leader>dO"]            = map_cmd("<Plug>VimspectorStepOut"):with_noremap():with_silent(),
  ["n|<leader><leader>dt"]    = map_cmd("<Plug>VimspectorToggleConditionalBreakpoint"):with_noremap():with_silent(),
  ["n|<leader>de"]            = map_cmd("<Plug>VimspectorBalloonEval"):with_noremap():with_silent(),
  -- Plugin copilot
  ["i|<C-n>"]                 = map_cmd("<Plug>(copilot-previous)"):with_noremap():with_silent(),
  ["i|<C-m>]"]                = map_cmd("<Plug>(copilot-next)"):with_noremap():with_silent(),
  -- Plugin symbol outline
  -- ["n|<leader>so"]            = map_cu('SymbolsOutline'):with_noremap():with_silent(),
}

bind.nvim_load_mapping(plug_map)
