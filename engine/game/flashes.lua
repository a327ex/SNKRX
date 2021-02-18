-- The base Flashes class.
-- This class is used to manage all flashes in an object.
-- Add a new flash:
-- self.flashes:add('hit', 0.15)
-- Use it:
-- self.flashes.hit:flash(0.1)
-- self.flashes.hit.f -- a boolean that says if it's currently flashing or not
-- Every GameObject has a .flashes attribute with a Flashes instance attached to it.
Flashes = Object:extend()
function Flashes:init()
  self.trigger = Trigger()
end


function Flashes:update(dt)
  self.trigger:update(dt)
end


-- Adds a new flash to the object. The name must be unique and the second argument is the default duration for the flash.
-- self.flashes:add('hit', 0.15)
function Flashes:add(name, default_duration)
  if name == 'parent' or name == 'names' or name == 'trigger' or name == 'add' or name == 'use' or name == 'update' or name == 'init' or name == 'pull' or name == 'flash' then
    error("Invalid name to be added to the Flashes object. 'add', 'flash', 'init', 'names', 'parent', 'pull', 'trigger', 'update' and 'use' are reserved names, choose another.")
  end
  self[name] = {f = false, default_duration = default_duration or 0.15, flash = function(_, duration)
    self[name].f = true
    self.trigger:after(duration or self[name].default_duration, function() self[name].f = false end, name)
  end}
end
