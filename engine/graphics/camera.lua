Shake = Object:extend()
function Shake:init(amplitude, duration, frequency)
  self.amplitude = amplitude or 0
  self.duration = duration or 0
  self.frequency = frequency or 60
  self.samples = {}
  for i = 1, (duration/1000)*frequency do self.samples[i] = 2*love.math.random()-1 end
  self.ti = love.timer.getTime()*1000
  self.t = 0
  self.shaking = true
end


function Shake:update(dt)
  self.t = love.timer.getTime()*1000 - self.ti
  if self.t > self.duration then
    self.shaking = false
  end
end


function Shake:get_noise(s)
  return self.samples[s] or 0
end


function Shake:get_decay(t)
  if t > self.duration then return end
  return (self.duration - t)/self.duration
end


function Shake:get_amplitude(t)
  if not t then
    if not self.shaking then return 0 end
    t = self.t
  end
  local s = (t/1000)*self.frequency
  local s0 = math.floor(s)
  local s1 = s0 + 1
  local k = self:get_decay(t)
  return self.amplitude*(self:get_noise(s0) + (s-s0)*(self:get_noise(s1) - self:get_noise(s0)))*k
end


-- The camera object. A global instance of this called "camera" is created automatically, and the Game class also contains its own instance of in the .camera attribute.
-- This class handles drawing of the game world through a viewport and the functions needed to make that happen.
-- A common setup looks like this:
--[[
function Arena:on_enter()
  game.camera.follow_style = 'lockon'
  game.camera.lerp.x = 0.1
  game.camera.lerp.y = 0.1
  
  self.main = Group(game.camera):set_as_physics_world(192, 0, 0, {'player', 'enemy', 'projectile', 'solid'})
  self.effects = Group(game.camera)
  self.floor = Group(game.camera)
  self.ui = Group()

  self.player = Player(gw/2, gh/2)
  self.main:add_object(self.player)
end

function Arena:update(dt)
  game.camera:follow_object(self.player)
  game.camera.x = math.floor(game.camera.x)
  game.camera.y = math.floor(game.camera.y)

  self.main:update(dt)
  self.floor:update(dt)
  self.effects:update(dt)
  self.ui:update(dt)
end

function Arena:draw()
  self.floor:draw()
  self.main:sort_by_y()
  self.main:draw()
  self.effects:draw()
  self.ui:draw()
end
]]--

-- Here we see 4 groups being created and for 3 of them the game's camera instance is attached.
-- If a group has a camera instance attached to it then whenever group:draw() is called it will draw all objects to the camera's canvas affected by the camera's translation, zoom and rotation.
-- Additionally, we also see some basic following functionality, as the camera is told to follow the player with the 'lockon' follow style and with some lerping going on.
-- Finally, the 4th group has no camera attached to it, because for UI elements we want them to be drawn in static screen positions.
--
-- The arguments passed in to create a camera area:
-- x, y - the camera's position in world coordinates, the camera is always centered around its x, y coordinates
-- w, h - the camera's size, generally this should be the same as game_width and game_height (or gw and gh) passed in engine_run
Camera = Object:extend()
function Camera:init(x, y, w, h)
  self.x, self.y = x, y
  self.w, self.h = w or gw, h or gh
  self.r, self.sx, self.sy = 0, 1, 1
  self.mouse = Vector(0, 0)
  self.last_mouse = Vector(0, 0)
  self.mouse_dt = Vector(0, 0)
  self.shakes = {x = {}, y = {}}
  self.spring = {x = Spring(), y = Spring()}
  self.lerp = Vector(1, 1)
  self.lead = Vector(1, 1)
  self.impulse = Vector(0, 0)
  self.follow_style = "no_deadzone"
  self.shake_amount = Vector(0, 0)
  self.last_shake_amount = Vector(0, 0)
  self.last_target = Vector(0, 0)
  self.scroll = Vector(0, 0)
end


-- Set ignore_scale to true when you want drawing of objects to be scaled when drawing the canvas rather than the objects themselves
-- That is useful for mipmapping a pixelated canvas, for instance, such that zooming out doesn't create lots of ugly artifacts
-- In that case you want to set ignore_scale to true, and then when drawing the main canvas multiply it by camera.sx*sx, camera.sy*sy instead of only sx, sy
-- You'll also want to create a canvas that is bigger than normal to account for the fact that you're zooming out of it
-- TODO: classify and unify all disparate methods of drawing in this class, also move "main canvas" here

-- Attaches the camera, meaning all further draw operations will be affected by its transform.
-- Accepts two values that go from 0 to 1 that represent how much parallaxing there should be for the next operations.
-- A value of 1 means no parallaxing, meaning the elements drawn will move at the same rate as all other elements, while a value of 0 means maximum parallaxing, which means the elements won't move at all.
-- Groups automatically call this function, but you can still pass these scroll factors to their draw calls.
-- In general if you have multiple layers of backgrounds and you want them to be parallaxed you'd do something like this:
--[[
function init()
  back_backgrounds = Group(game.camera)
  middle_backgrounds = Group(game.camera)
  front_backgrounds = Group(game.camera)
  main = Group(game.camera)
end

function draw()
  back_backgrounds:draw(0.5)
  middle_backgrounds:draw(0.75)
  front_backgrounds:draw(0.9)
  main:draw()
end
]]--
--
-- In this example we have 4 layers are all drawn with different levels of parallax: 0.5 (half speed), 0.75, 0.9 and 1 (normal speed = no parallax).
function Camera:attach(scroll_factor_x, scroll_factor_y)
  self.bx, self.by = self.x, self.y
  self.x = self.bx*(scroll_factor_x or 1)
  self.y = self.by*(scroll_factor_y or scroll_factor_x or 1)
  love.graphics.push()
  love.graphics.translate(self.w/2, self.h/2)
  if not self.ignore_scale then love.graphics.scale(self.sx, self.sy) end
  love.graphics.rotate(self.r)
  love.graphics.translate(-self.x*(scroll_factor_x or 1), -self.y*(scroll_factor_y or 1))
end


-- Detaches the camera, meaning all further draw operations won't be affected by its transform.
-- This is also called automatically by groups that have cameras attached to them.
function Camera:detach()
  love.graphics.pop()
  self.x, self.y = self.bx, self.by
end


-- Returns the values passed in in world coordinates. This is useful when transforming things from screen space to world space, like when the mouse clicks on something.
-- If you look at camera:get_mouse_position you'll see that it uses this function on the values returned by love.mouse.getPosition (which return values in screen coordinates).
-- camera:get_world_coords(love.mouse.getPosition())
function Camera:get_world_coords(x, y)
  local c, s = math.cos(-self.r), math.sin(-self.r)
  x, y = (x - sx*self.w/2)/(sx*self.sx), (y - sy*self.h/2)/(sy*self.sy)
  x, y = c*x - s*y, s*x + c*y
  return x + self.x*(v or 1), y + self.y*(v or 1)
end


-- Returns the values passed in in local coordinates. This is useful when transforming things from world space to screen space, like when displaying UI according to the position of game objects.
-- x, y = camera:get_local_coords(player.x, player.y)
function Camera:get_local_coords(x, y)
  local c, s = math.cos(self.r), math.sin(self.r)
  x, y = x - self.x*(v or 1), y - self.y*(v or 1)
  x, y = c*x - s*y, s*x + c*y
  return x*self.sx + self.w/2, y*self.sy + self.h/2
end


function Camera:update(dt)
  self.mouse.x, self.mouse.y = self:get_mouse_position()
  self.mouse_dt.x, self.mouse_dt.y = self.mouse.x - self.last_mouse.x, self.mouse.y - self.last_mouse.y
  self.shake_amount:set(0, 0)
  for _, z in ipairs({"x", "y"}) do
    for i = #self.shakes[z], 1, -1 do
      self.shakes[z][i]:update(dt)
      self.shake_amount[z] = self.shake_amount[z] + self.shakes[z][i]:get_amplitude()
      if not self.shakes[z][i].shaking then
        table.remove(self.shakes[z], i)
      end
    end
  end

  self.spring.x:update(dt)
  self.spring.y:update(dt)
  self.shake_amount:add(self.spring.x.x, self.spring.y.x)
  self.x, self.y = self.x - self.last_shake_amount.x, self.y - self.last_shake_amount.y
  self.x, self.y = self.x + self.shake_amount.x, self.y + self.shake_amount.y
  self.last_shake_amount:set(self.shake_amount)
  self.x = self.x + self.impulse.x*dt
  self.y = self.y + self.impulse.y*dt
  self.impulse:mul(0.9*refresh_rate*dt)

  if self.bound then
    self.x = math.min(math.max(self.x, self.bounds_min.x + self.w/2), self.bounds_max.x - self.w/2)
    self.y = math.min(math.max(self.y, self.bounds_min.y + self.h/2), self.bounds_max.y - self.h/2)
  end

  self.last_mouse.x, self.last_mouse.y = self.mouse.x, self.mouse.y
  if not self.target then return end

  if self.follow_style == "lockon" then
    local w, h = self.w/16, self.w/16
    self:set_deadzone((self.w - w)/2, (self.h - h)/2, w, h)
  elseif self.follow_style == "lockon_tight" then
    local w, h = self.w/64, self.w/64
    self:set_deadzone((self.w - w)/2, (self.h - h)/2, w, h)
  elseif self.follow_style == "lockon_loose" then
    local w, h = self.w/4, self.w/4
    self:set_deadzone((self.w - w)/2, (self.h - h)/2, w, h)
  elseif self.follow_style == "platformer" then
    local w, h = self.w/8, self.h/3
    self:set_deadzone((self.w - w)/2, (self.h - h)/2 - h*0.25, w, h)
  elseif self.follow_style == "topdown" then
    local s = math.max(self.w, self.h)/4
    self:set_deadzone((self.w - s)/2, (self.h - s)/2, s, s)
  elseif self.follow_style == "topdown_tight" then
    local s = math.max(self.w, self.h)/8
    self:set_deadzone((self.w - s)/2, (self.h - s)/2, s, s)
  elseif self.follow_style == "screen_by_screen" then
    self:set_deadzone(0, 0, 0, 0)
  elseif self.follow_style == "no_deadzone" then
    self.deadzone = nil
  end

  if not self.deadzone then
    self.x, self.y = self.target.x, self.target.y
    if self.bound then
      self.x = math.min(math.max(self.x, self.bounds_min.x + self.w/2), self.bounds_max.x - self.w/2)
      self.y = math.min(math.max(self.y, self.bounds_min.y + self.h/2), self.bounds_max.y - self.h/2)
    end
    return
  end

  local dx1, dy1, dx2, dy2 = self.deadzone.x, self.deadzone.y, self.deadzone.x + self.deadzone.w, self.deadzone.y + self.deadzone.h
  local scroll_x, scroll_y = 0, 0
  local target_x, target_y = self:get_local_coords(self.target.x, self.target.y)
  local x, y = self:get_local_coords(self.x, self.y)

  if self.follow_style == "screen_by_screen" then
    if self.bound then
      if self.x > self.bounds_min.x + self.w/2 and target_x < 0 then self.scroll.x = math.snap_center(self.scroll.x - self.w/self.sx, self.w/self.sx) end
      if self.x < self.bounds_max.x - self.w/2 and target_x >= self.w then self.scroll.x = math.snap_center(self.scroll.x + self.w/self.sx, self.w/self.sx) end
      if self.y > self.bounds_min.y + self.h/2 and target_y < 0 then self.scroll.y = math.snap_center(self.scroll.y - self.h/self.sy, self.h/self.sy) end
      if self.y < self.bounds_max.y - self.h/2 and target_y >= self.h then self.scroll.y = math.snap_center(self.scroll.y + self.h/self.sy, self.h/self.sy) end
    else
      if target_x < 0 then self.scroll.x = math.snap_center(self.scroll.x - self.w/self.sx, self.w/self.sx) end
      if target_x >= self.w then self.scroll.x = math.snap_center(self.scroll.x + self.w/self.sx, self.w/self.sx) end
      if target_y < 0 then self.scroll.y = math.snap_center(self.scroll.y - self.h/self.sy, self.h/self.sy) end
      if target_y >= self.h then self.scroll.y = math.snap_center(self.scroll.y + self.h/self.sy, self.h/self.sy) end
    end
    self.x = math.lerp(self.lerp.x, self.x, self.scroll.x)
    self.y = math.lerp(self.lerp.y, self.y, self.scroll.y)

    if self.bound then
      self.x = math.min(math.max(self.x, self.bounds_min.x + self.w/2), self.bounds_max.x - self.w/2)
      self.y = math.min(math.max(self.y, self.bounds_min.y + self.h/2), self.bounds_max.y - self.h/2)
    end

  else
    if target_x < x + (dx1 + dx2 - x) then
      local d = target_x - dx1
      if d < 0 then scroll_x = d end
    end
    if target_x > x - (dx1 + dx2 - x) then
      local d = target_x - dx2
      if d > 0 then scroll_x = d end
    end
    if target_y < y + (dy1 + dy2 - y) then
      local d = target_y - dy1
      if d < 0 then scroll_y = d end
    end
    if target_y > y - (dy1 + dy2 - y) then
      local d = target_y - dy2
      if d > 0 then scroll_y = d end
    end

    if not self.last_target.x and not self.last_target.y then self.last_target.x, self.last_target.y = self.target.x, self.target.y end
    scroll_x = scroll_x + (self.target.x - self.last_target.x)*self.lead.x
    scroll_y = scroll_y + (self.target.y - self.last_target.y)*self.lead.y
    self.last_target.x, self.last_target.y = self.target.x, self.target.y
    self.x = math.lerp(self.lerp.x, self.x, self.x + scroll_x)
    self.y = math.lerp(self.lerp.y, self.y, self.y + scroll_y)

    if self.bound then
      self.x = math.min(math.max(self.x, self.bounds_min.x + self.w/2), self.bounds_max.x - self.w/2)
      self.y = math.min(math.max(self.y, self.bounds_min.y + self.h/2), self.bounds_max.y - self.h/2)
    end
  end
end


-- Shakes the camera with a certain intensity for duration seconds and with the specified frequency
-- Higher frequency means jerkier movement, lower frequency means smoother movement
-- camera:shake(10, 1, 120) -> shakes the camera with 10 intensity for 1 second and 120 frequency
function Camera:shake(intensity, duration, frequency)
  if state.no_screen_shake then return end
  table.insert(self.shakes.x, Shake(intensity, 1000*(duration or 0), frequency or 60))
  table.insert(self.shakes.y, Shake(intensity, 1000*(duration or 0), frequency or 60))
end


-- Shakes the camera with a certain intensity towards angle r using a spring mechanism
-- k and d are stiffness and damping spring values (see spring file for more)
-- camera:shake(10, math.pi/4) -> shakes the camera with 10 intensity diagonally
function Camera:spring_shake(intensity, r, k, d)
  if state.no_screen_shake then return end
  self.spring.x:pull(-intensity*math.cos(r or 0), k, d)
  self.spring.y:pull(-intensity*math.sin(r or 0), k, d)
end


-- When following an object, this function sets a deadzone in which the camera can move freely in before having to go back to following the object
-- TODO: add STALKER-X documentation examples of all deadzones and lerping modes here
function Camera:set_deadzone(x, y, w, h)
  self.deadzone = {x = x, y = y, w = w, h = h}
end


-- Sets the boundaries of the camera as a rectangle.
-- The camera's center will not be allowed to move outside the boundaries of this rectangle.
-- TODO: this doesn't seem to work when zooming levels are different than 1, fix it
function Camera:set_bounds(x, y, w, h)
  self.bound = true
  self.bounds_min = {x = x - w/2, y = y - h/2}
  self.bounds_max = {x = x + w/2, y = y + h/2}
end


-- Tells the camera to follow the object
-- Previously set lerp, lead, follow styles and deadzone variables apply when following the object
function Camera:follow_object(obj)
  self.target = obj
end


-- Returns the mouse's position in world coordinates
-- x, y = camera:get_mouse_position()
function Camera:get_mouse_position()
  return self:get_world_coords(love.mouse.getPosition())
end


-- Returns the angle from a point to the mouse
-- x, y = camera:angle_to_mouse(point.x, point.y)
function Camera:angle_to_mouse(x, y)
  local mx, my = self:get_mouse_position()
  return math.angle(x, y, mx, my)
end


function Camera:apply_impulse(f, r)
  self.impulse:set(f*math.cos(r), f*math.sin(r))
end
