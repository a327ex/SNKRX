-- The base Springs class.
-- This class is used to manage all springs in an object.
-- Add a new spring:
-- self.springs:add('hit', 1)
-- Use it:
-- self.springs.hit:pull(0.2)
-- self.springs.hit.x
-- Every GameObject has a .springs attribute with a Springs instance attached to it.
-- See engine/game/hit
Springs = Object:extend()
function Springs:init()
  self.names = {}
end


function Springs:update(dt)
  for _, name in ipairs(self.names) do
    self[name]:update(dt)
  end
end


-- Adds a new spring to the object. The name must be unique and the next arguments are the same
-- as the arguments for creating a spring, see engine/math/spring.lua.
-- self.springs:add('hit', 1)
function Springs:add(name, x, k, d)
  if name == 'parent' or name == 'names' or name == 'trigger' or name == 'add' or name == 'use' or name == 'update' or name == 'init' or name == 'pull' or name == 'flash' then
    error("Invalid name to be added to the Springs object. 'add', 'flash', 'init', 'names', 'parent', 'pull', 'trigger', 'update' and 'use' are reserved names, choose another.")
  end
  self[name] = Spring(x, k, d)
  table.insert(self.names, name)
end
