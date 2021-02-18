-- The base GameObject class.  
-- The general way of creating an object that implements these functions goes like this:
--[[
MyGameObject = Object:extend()
MyGameObject:implement(GameObject)
function MyGameObject:init(args)
  self:init_game_object(args)
end

function MyGameObject:update(dt)
  self:update_game_object(dt)
end
]]--

-- This simply implements the GameObject class as a mixin into your own class, giving it the functions defined in this file as well as the attributes set from init_game_object.
-- In general you'd create your own game object like this, for instance:
-- group = Group()
-- MyGameObject{group = group, x = 100, y = 100, v = 100, r = math.pi/4}
-- And then this object would be automatically updated and drawn by the group.
-- Alternatively you could add the object to the group manually:
-- my_object = MyGameObject{x = 100, y = 100, v = 100, r = math.pi/4}
-- group:add(my_object)
-- One of the nice patterns I've found was a passing arguments as a key + value table.
-- So in the case above, the object would automatically have its .x, .y and .v attributes set to 100 and its .r attribute set to math.pi/4.
GameObject = Object:extend()
function GameObject:init_game_object(args)
  for k, v in pairs(args or {}) do self[k] = v end
  if self.group then self.group:add(self) end
  self.x, self.y = self.x or 0, self.y or 0
  self.r = self.r or 0
  self.sx, self.sy = self.sx or 1, self.sy or 1
  self.id = self.id or random:uid()
  self.t = Trigger()
  self.springs = Springs()
  self.flashes = Flashes()
  self.hfx = HitFX(self) 
  self.spring = Spring(1)
  return self
end


function GameObject:update_game_object(dt)
  self.t:update(dt)
  self.springs:update(dt)
  self.flashes:update(dt)
  self.hfx:update(dt)
  self.spring:update(dt)
  if self.body then self:update_physics(dt) end

  if self.shape then
    if self.shape.vertices and self.body then
      self.shape.vertices = {self.body:getWorldPoints(self.fixture:getShape():getPoints())}
      self.shape:get_centroid()
    end
    if self.body then
      self.shape:move_to(self:get_position())
    end

    if self.interact_with_mouse then
      local colliding_with_mouse = self.shape:is_colliding_with_point(self.group:get_mouse_position())
      if colliding_with_mouse and not self.colliding_with_mouse then
        self.colliding_with_mouse = true
        if self.on_mouse_enter then self:on_mouse_enter() end
      elseif not colliding_with_mouse and self.colliding_with_mouse then
        self.colliding_with_mouse = false
        if self.on_mouse_exit then self:on_mouse_exit() end
      end
      if self.colliding_with_mouse then
        if self.on_mouse_stay then self:on_mouse_stay() end
      end
    end
  end
end


function GameObject:draw_game_object()
  if self.body then self:draw_physics() end
end
