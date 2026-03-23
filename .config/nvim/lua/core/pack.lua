local fn, uv, api = vim.fn, vim.loop, vim.api
local g = require('core.global')
local vim_path = g.vim_path
local data_dir = g.data_dir
local modules_dir = g.modules_dir
local packer_compiled = data_dir .. 'packer_compiled.vim'
local compile_to_lua = data_dir .. 'lua/_compiled.lua'
local packer = nil

local Packer = {}
Packer.__index = Packer

function Packer:load_plugins()
  self.repos = {}

  local get_plugins_list = function()
    local list = {}
    local tmp = vim.split(fn.globpath(modules_dir, '*/plugins.lua'), '\n')
    for _, f in ipairs(tmp) do
      -- Extract the require path starting from 'modules/'
      local module_path = f:match("(modules/.*%.lua)$")
      if module_path then
        list[#list + 1] = module_path
      end
    end
    return list
  end

  local plugins_file = get_plugins_list()
  for _, m in ipairs(plugins_file) do
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend('force', { repo }, conf)
    end
  end
end

function Packer:load_packer()
  if not packer then
    api.nvim_command('packadd packer.nvim')
    packer = require('packer')
  end
  packer.init({
    compile_path = packer_compiled,
    git = { clone_timeout = 120 },
    disable_commands = true
  })
  packer.reset()
  local use = packer.use
  self:load_plugins()
  use { "wbthomason/packer.nvim", opt = true }
  for _, repo in ipairs(self.repos) do
    use(repo)
  end
end

function Packer:init_ensure_plugins()
  local packer_dir = data_dir .. 'pack/packer/opt/packer.nvim'
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    vim.fn.mkdir(data_dir .. 'lua', 'p')
    self:load_packer()
    packer.install()
  end
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Packer:load_packer()
    end
    return packer[key]
  end
})

function plugins.ensure_plugins()
  Packer:init_ensure_plugins()
end

function plugins.convert_compile_file()
  local input = io.open(packer_compiled, "r")
  if not input then
    return
  end

  local lines = {}
  local lnum = 1
  lines[#lines + 1] = 'vim.cmd [[packadd packer.nvim]]\n'

  for line in io.lines(packer_compiled) do
    lnum = lnum + 1
    if lnum > 15 then
      lines[#lines + 1] = line .. '\n'
      if line == 'END' then
        break
      end
    end
  end
  input:close()
  table.remove(lines, #lines)

  if vim.fn.isdirectory(data_dir .. 'lua') ~= 1 then
    vim.fn.mkdir(data_dir .. 'lua', 'p')
  end

  if vim.fn.filereadable(compile_to_lua) == 1 then
    os.remove(compile_to_lua)
  end

  local file, err = io.open(compile_to_lua, "w")
  if not file then
    error("Failed to write compiled file: " .. (err or "unknown error"))
    return
  end

  for _, line in ipairs(lines) do
    file:write(line)
  end
  file:close()

  os.remove(packer_compiled)
end

function plugins.magic_compile()
  local current_file = vim.fn.expand("%:p")
  if current_file == "" or not vim.fn.resolve(current_file):match(vim.fn.resolve(vim_path)) then
    vim.notify("magic_compile: current file is not in nvim config directory", vim.log.levels.WARN)
    return
  end

  -- Only run dofile if editing a plugin definition file
  local should_dofile = current_file:match("plugins%.lua$")

  vim.notify("Compiling plugins...", vim.log.levels.INFO)

  -- Clear all config-related cached modules
  for k, _ in pairs(package.loaded) do
    if k:match("^modules") or k:match("^core") or k:match("^keymap") or k == "_compiled" then
      package.loaded[k] = nil
    end
  end

  if should_dofile then
    dofile(current_file)
  end

  plugins.compile()
  plugins.convert_compile_file()

  -- Clear _compiled cache again before requiring to ensure fresh load
  package.loaded['_compiled'] = nil
  require('_compiled')

  vim.notify("Plugin compilation complete!", vim.log.levels.INFO)
end

function plugins.auto_compile()
  local file = vim.fn.expand('%:p')
  if file:match(vim.fn.resolve(vim_path)) then
    -- plugins.clean()
    plugins.magic_compile()
  end
end

function plugins.load_compile()
  if vim.fn.filereadable(compile_to_lua) == 1 then
    require('_compiled')
  else
    assert('Missing packer compile file. Run PackerCompile or PackerInstall to fix.')
  end
  vim.cmd [[command! PackerCompile lua require('core.pack').magic_compile()]]
  vim.cmd [[command! PackerInstall lua require('core.pack').install()]]
  vim.cmd [[command! PackerUpdate lua require('core.pack').update()]]
  vim.cmd [[command! PackerSync lua require('core.pack').sync()]]
  vim.cmd [[command! PackerClean lua require('core.pack').clean()]]
  vim.cmd [[autocmd User PackerComplete lua require('core.pack').magic_compile()]]
  vim.cmd [[command! PackerStatus  lua require('packer').status()]]
end

return plugins
