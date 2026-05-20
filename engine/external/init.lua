local path = ...
if not path:find("init") then
  binser = require(path .. ".binser")
  mlib = require(path .. ".mlib")
  -- if not web then clipper = require(path .. ".clipper") end
  ripple = require(path .. ".ripple")
  local ok, luasteam = pcall(require, 'luasteam')
  steam = ok and luasteam or require(path .. ".steam_stub")
end
