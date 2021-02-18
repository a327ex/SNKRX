-- The class responsible for holding an animation's graphics.
-- It takes in an already loaded image, the width and height of each frames, and a list of frames in terms of indexed position on the image.
-- player_sheet = Image('player_sheet')
-- player_idle_frames = AnimationFrames(player_sheet, 32, 32, {{1, 1}, {2, 1}})
-- player_run_frames = AnimationFrames(player_sheet, 32, 32, {{1, 2}, {2, 2}, {3, 2}})
-- player_attack_frames = AnimationFrames(player_sheet, 32, 32, {{1, 3}, {2, 3}, {3, 3}, {4, 3}})
--
-- In the example above we first load an image, and then load 3 player animations.
-- Each animation comes from different rows in the same spritesheet, and that's reflected by the last argument in each call.
-- If your animation comes from a single spritesheet that doesn't have multiple animations, then you can omit the last argument and it will automatically go through it.
AnimationFrames = Object:extend()
function AnimationFrames:init(image, frame_w, frame_h, frames_list)
  self.source = image
  self.frame_w, self.frame_h = frame_w, frame_h
  self.frames_list = frames_list

  if type(self.frames_list) == 'number' then -- the source is a single row spritesheet and number of frames are specified
    local frames_list = {}
    for i = 1, self.frames_list do table.insert(frames_list, {i, 1}) end
    self.frames_list = frames_list
  elseif not self.frames_list then
    local frames_list = {}
    for i = 1, math.floor(self.source.w/self.frame_w) do table.insert(frames_list, {i, 1}) end
    self.frames_list = frames_list
  end

  self.frames = {}
  for i, frame in ipairs(self.frames_list) do
    self.frames[i] = {quad = love.graphics.newQuad((frame[1]-1)*self.frame_w, (frame[2]-1)*self.frame_h, self.frame_w, self.frame_h, self.source.w, self.source.h), w = self.frame_w, h = self.frame_h}
  end
  self.size = #self.frames
end


function AnimationFrames:draw(frame, x, y, r, sx, sy, ox, oy, color)
  local _r, g, b, a
  if color then
    _r, g, b, a = love.graphics.getColor()
    graphics.set_color(color)
  end
  love.graphics.draw(self.source.image, self.frames[frame].quad, x, y, r or 0, sx or 1, sy or sx or 1, self.frames[frame].w/2 + (ox or 0), self.frames[frame].h/2 + (oy or 0))
  if color then love.graphics.setColor(_r, g, b, a) end
end




-- The class that logically updates an animation.
-- This being separated from the visual part of an animation is useful whenever you need animation-like behavior unrelated to graphics, like making your own animations with code only. For instance:
--[[
self.animation = AnimationLogic(0.04, 6, 'loop', {
  [1] = function()
    if self.parent:is(Player) then
      for i = 1, random:int(1, 3) do DustParticle(game.current_state.floor, self.parent.x, self.parent.y)) end
    end
    self.z = 9
  end,
  [2] = function() self.parent.timer:tween(0.025, self, {z = 6}, math.linear, nil, 'move_2') end,
  [3] = function() self.parent.timer:tween(0.025, self, {z = 3}, math.linear, nil, 'move_3') end,
  [4] = function()
    self.parent.timer:tween(0.025, self, {z = 0}, math.linear, nil, 'move_4')
    self.sx = 0.1
    self.parent.timer:tween(0.05, self, {sx = 0}, math.linear, nil, 'move_5')
  end,
})
]]--
--
-- That was an example of a code-only movement animation for a game I'm making.
-- The arguments that this takes are the delay between each frame, how many frames there are, the loop mode ('loop', 'once' or 'bounce') and a table of actions.
-- The delay argument can either be a number or a table, if it's a table then the delay for each frame can be set individually:
-- animation = AnimationLogic({0.02, 0.04, 0.06, 0.04}, ...)
-- In the example above, it would take 0.02s to go from frame 1 to 2, 0.04s from 2 to 3, 0.06s from 3 to 4 and 0.04s from 4 to 5 (or 1 if there are only 4 frames).
-- Loop can be either: 'loop', the animation will start once from frame 1 once it reaches the end; 'once', it will stop once it reaches the end; 'bounce', it will reverse once it reaches the end or start
-- Finally, the actions table can contain a list of functions, as shown in the code-only animation example above, and each function will be performed when that frame is reached.
-- In that example, once the second frame is reached, this function would be executed:
-- function() self.parent.timer:tween(0.025, self, {z = 6}, math.linear, nil, 'move_2') end
-- The index 0 can be used to perform an action once the animation reaches its end:
-- self.animation = AnimationLogic(0.04, self.player_dead_frames.size, 'once', {[0] = function() self.dead = true end})
AnimationLogic = Object:extend()
function AnimationLogic:init(delay, frames, loop_mode, actions)
  self.delay = delay
  self.frames = frames
  self.loop_mode = loop_mode or "once"
  self.actions = actions
  self.timer = 0
  self.frame = 1
  self.direction = 1
end


function AnimationLogic:update(dt)
  if self.dead then return end

  self.timer = self.timer + dt
  local delay = self.delay
  if type(self.delay) == "table" then delay = self.delay[self.frame] end

  if self.timer > delay then
    self.timer = 0
    self.frame = self.frame + self.direction
    if self.frame > self.frames or self.frame < 1 then
      if self.loop_mode == "once" then
        self.frame = self.frames
        self.dead = true
      elseif self.loop_mode == "loop" then
        self.frame = 1
      elseif self.loop_mode == "bounce" then
        self.direction = -self.direction
        self.frame = self.frame + 2*self.direction
      end
      if self.actions and self.actions[0] then self.actions[0]() end
    end
    if self.actions and self.actions[self.frame] then self.actions[self.frame]() end
  end
end




-- The Animation class, a mix of AnimationFrames and AnimationLogic.
-- Takes in a delay, an AnimationFrames object, the loop mode and a table of actions.
-- Read more about the AnimationFrames and AnimationLogic classes as everything there applies here.
Animation = Object:extend()
function Animation:init(delay, animation_frames, loop_mode, actions)
  self.delay = delay
  self.animation_frames = animation_frames
  self.size = self.animation_frames.size
  self.loop_mode = loop_mode
  self.actions = actions
  self.animation_logic = AnimationLogic(self.delay, self.animation_frames.size, self.loop_mode, self.actions)
end


function Animation:update(dt)
  self.animation_logic:update(dt)
end


function Animation:draw(x, y, r, sx, sy, ox, oy, color)
  self.animation_frames:draw(self.animation_logic.frame, x, y, r, sx, sy, ox, oy, color)
end
