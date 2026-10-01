local path = ...
if not path:find("init") then
  binser = require(path .. ".binser")
  mlib = require(path .. ".mlib")
  -- if not web then clipper = require(path .. ".clipper") end
  ripple = require(path .. ".ripple")
  local ok, luasteam = pcall(require, 'luasteam')
  steam = ok and luasteam or nil
end

-- No-op stand-in for luasteam, used when Steam isn't available (e.g. running the game without the Steam client open).
-- Any field access returns another stub and any call does nothing, so calls like steam.userStats.setAchievement(...) are safe.
function steam_stub()
  return setmetatable({}, {
    __index = function(t, k) local v = steam_stub(); rawset(t, k, v); return v end,
    __call = function() end,
  })
end
