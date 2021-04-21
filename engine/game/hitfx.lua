-- The base HitFX class.
-- Whenever an object is interacted with it's a good idea to either pull on a spring attached to its scale, or to flash it to signal that the interaction went through.
-- This is a combination of both Springs and Flashes put together to create that effect.
-- An instance of this called .hfx is added automatically to every game object.
-- Add a new effect:
-- self.hfx:add('hit')
-- Subsequent arguments are defaults for flashes and springs respectively, so:
-- self.hfx:add('hit', 0.15, 1, 200, 20)
-- Will add a flash with default duration of 0.15 and a spring with parameters 1, 200, 20.
-- Use the effect:
-- self.hfx:use('hit')
-- Subsequent arguments are the same as for the add function. This will call flash on the flash and pull on the spring.
-- Access its values:
-- self.hfx.hit.x -- the spring value
-- self.hfx.hit.f -- the flash boolean
HitFX = Object:extend()
function HitFX:init(parent)
  self.parent = parent
  self.names = {}
end


function HitFX:update(dt)
  if not self.parent then return end
  if self.parent and self.parent.dead then self.parent = nil; return end

  for _, name in ipairs(self.names) do
    self[name].x = self.parent.springs[name].x
    self[name].f = self.parent.flashes[name].f
  end
end


function HitFX:add(name, x, k, d, default_flash_duration)
  if name == 'parent' or name == 'names' or name == 'trigger' or name == 'add' or name == 'use' or name == 'update' or name == 'init' or name == 'pull' or name == 'flash' then
    error("Invalid name to be added to the HitFX object. 'add', 'flash', 'init', 'names', 'parent', 'pull', 'trigger', 'update' and 'use' are reserved names, choose another.")
  end
  self.parent.flashes:add(name, default_flash_duration)
  self.parent.springs:add(name, x, k, d)
  table.insert(self.names, name)
  self[name] = {x = self.parent.springs[name].x, f = self.parent.flashes[name].f}
end


function HitFX:use(name, x, k, d, flash_duration)
  if not self.parent then return end
  self.parent.flashes[name]:flash(flash_duration)
  self.parent.springs[name]:pull(x, k, d)
end


function HitFX:pull(name, ...)
  self.parent.springs[name]:pull(...)
end


function HitFX:flash(name, ...)
  self.parent.flashes[name]:flash(...)
end
