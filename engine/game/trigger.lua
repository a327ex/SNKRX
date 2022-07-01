-- The base Trigger class.
-- A global instance of this called "trigger" is available by default.
Trigger = Object:extend()
function Trigger:init()
  self.triggers = {}
  self.time = love.timer.getTime()
end


-- Calls the action every frame until it's cancelled via trigger:cancel.
-- The tag must be passed in otherwise there will be no way to stop this from running.
-- If after is passed in then it is called after the run is cancelled.
function Trigger:run(action, after, tag)
  local tag = tag or random:uid()
  local after = after or function() end
  self.triggers[tag] = {type = "run", timer = 0, after = after, action = action}
end


-- Calls the action after delay seconds.
-- Or calls the action after the condition is true.
-- If tag is passed in then any other trigger actions with the same tag are automatically cancelled.
-- trigger:after(2, function() print(1) end) -> prints 1 after 2 seconds
-- trigger:after(function() return self.should_print_1 end, function() print(1) end) -> prints 1 after self.should_print_1 is set to true
function Trigger:after(delay, action, tag)
  local tag = tag or random:uid()
  if type(delay) == "number" or type(delay) == "table" then
    self.triggers[tag] = {type = "after", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action}
  else
    self.triggers[tag] = {type = "conditional_after", condition = delay, action = action}
  end
end


-- Calls the action every delay seconds if the condition is true.
-- If the condition isn't true when delay seconds are up then it waits and only performs the action and resets the timer when that happens.
-- If times is passed in then it only calls action for that amount of times.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other trigger actions with the same tag are automatically cancelled.
-- trigger:cooldown(2, function() return #self:get_objects_in_shape(self.attack_sensor, enemies) > 0 end, function() self:attack() end) -> only attacks when 2 seconds have passed and there are more than 0 enemies around
function Trigger:cooldown(delay, condition, action, times, after, tag)
  local times = times or 0
  local after = after or function() end
  local tag = tag or random:uid()
  self.triggers[tag] = {type = "cooldown", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), condition = condition, action = action, times = times, max_times = times, after = after, multiplier = 1}
end


-- Calls the action every delay seconds.
-- Or calls the action once every time the condition becomes true.
-- If times is passed in then it only calls action for that amount of times.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other trigger actions with the same tag are automatically cancelled.
-- trigger:every(2, function() print(1) end) -> prints 1 every 2 seconds
-- trigger:every(2, function() print(1) end, 5, function() print(2) end) -> prints 1 every 2 seconds 5 times, and then prints 2
-- trigger:every(function() return player.hit end, function() print(1) end) -> prints 1 every time the player is hit
-- trigger:every(function() return player.grounded end, function() print(1), 5, function() print(2) end) -> prints 1 every time the player becomes grounded 5 times, and then prints 2
-- Note that if using this as a condition, the action will only be triggered when the condition jumps from being false to true.
-- If the condition remains true for multiple frames then the action won't be triggered further, unless it becomes false and then becomes true again.
function Trigger:every(delay, action, times, after, tag)
  local times = times or 0
  local after = after or function() end
  local tag = tag or random:uid()
  if type(delay) == "number" or type(delay) == "table" then
    self.triggers[tag] = {type = "every", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, times = times, max_times = times, after = after, multiplier = 1}
  else
    self.triggers[tag] = {type = "conditional_every", condition = delay, last_condition = false, action = action, times = times, max_times = times, after = after}
  end
end


-- Same as every except the action is called immediately when this function is called, and then every delay seconds.
function Trigger:every_immediate(delay, action, times, after, tag)
  local times = times or 0
  local after = after or function() end
  local tag = tag or random:uid()
  self.triggers[tag] = {type = "every", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, times = times, max_times = times, after = after, multiplier = 1}
  action()
end


-- Calls the action every frame for delay seconds.
-- Or calls the action every frame the condition is true.
-- If after is passed in then it is called after the duration ends or after the condition becomes false.
-- If tag is passed in then any other trigger actions with the same tag are automatically cancelled.
-- trigger:during(5, function() print(random:float(0, 100)) end)
-- trigger:during(function() return self.should_print_random_float end, function() print(random:float(0, 100)) end) -> prints the random float as long as self.should_print_random_float is true
function Trigger:during(delay, action, after, tag)
  local after = after or function() end
  local tag = tag or random:uid()
  if type(delay) == "number" or type(delay) == "table" then
    self.triggers[tag] = {type = "during", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, after = after}
  elseif type(delay) == "function" then
    self.triggers[tag] = {type = "conditional_during", condition = delay, last_condition = false, action = action, after = after}
  end
end


-- Tweens the target's values specified by the source table for delay seconds using the given tweening method.
-- All tween methods can be found in the math/math file.
-- If after is passed in then it is called after the duration ends.
-- If tag is passed in then any other trigger actions with the same tag are automatically cancelled.
-- trigger:tween(0.2, self, {sx = 0, sy = 0}, math.linear) -> tweens this object's scale variables to 0 linearly over 0.2 seconds
-- trigger:tween(0.2, self, {sx = 0, sy = 0}, math.linear, function() self.dead = true end) -> tweens this object's scale variables to 0 linearly over 0.2 seconds and then kills it
function Trigger:tween(delay, target, source, method, after, tag)
  local method = method or math.linear
  local after = after or function() end
  local tag = tag or random:uid()
  local initial_values = {}
  for k, _ in pairs(source) do initial_values[k] = target[k] end
  self.triggers[tag] = {type = "tween", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), target = target, initial_values = initial_values, source = source, method = method, after = after}
end


-- Cancels a trigger action based on its tag.
-- This is automatically called if repeated tags are given to trigger actions.
function Trigger:cancel(tag)
  if self.triggers[tag] and self.triggers[tag].type == "run" then
    self.triggers[tag].after()
  end
  self.triggers[tag] = nil
end


-- Resets the timer for a tag.
-- Useful when you need to start counting that tag from 0 after an event happens.
function Trigger:reset(tag)
  self.triggers[tag].timer = 0
end


-- Returns the delay of a given tag.
-- This is useful when delays are set randomly (trigger:every({2, 4}, ...) would set the delay at a random number between 2 and 4) and you need to know what the value chosen was.
function Trigger:get_delay(tag)
  return self.triggers[tag].delay
end


-- Returns the current iteration of an every trigger action with the given tag.
-- Useful if you need to know that its the nth time an every action has been called.
function Trigger:get_every_iteration(tag)
  return self.triggers[tag].max_times - self.triggers[tag].times 
end


-- Sets a multiplier for an every tag.
-- This is useful when you need the event to happen in a varying interval, like based on the player's attack speed, which might change every frame based on buffs.
-- Call this on the update function with the appropriate multiplier.
function Trigger:set_every_multiplier(tag, multiplier)
  if not self.triggers[tag] then return end
  self.triggers[tag].multiplier = multiplier or 1
end


function Trigger:get_every_multiplier(tag)
  if not self.triggers[tag] then return end
  return self.triggers[tag].multiplier
end


-- Returns the elapsed time of a given trigger as a number between 0 and 1.
-- Useful if you need to know where you currently are in the duration of a during call.
function Trigger:get_during_elapsed_time(tag)
  if not self.triggers[tag] then return end
  return self.triggers[tag].timer/self.triggers[tag].delay
end


function Trigger:get_timer_and_delay(tag)
  if not self.triggers[tag] then return end
  return self.triggers[tag].timer, self.triggers[tag].delay
end


function Trigger:get_time()
  self.time = love.timer.getTime()
  return self.time
end


function Trigger:resolve_delay(delay)
  if type(delay) == "table" then
    return random:float(delay[1], delay[2])
  else
    return delay
  end
end


function Trigger:destroy()
  self.triggers = nil
end


function Trigger:update(dt)
  self.time = self.time + dt

  for tag, trigger in pairs(self.triggers) do
    if trigger.timer then
      trigger.timer = trigger.timer + dt
    end

    if trigger.type == "run" then
      trigger.action()

    elseif trigger.type == "cooldown" then
      if trigger.timer > trigger.delay*trigger.multiplier and trigger.condition() then
        trigger.action()
        trigger.timer = 0
        trigger.delay = self:resolve_delay(trigger.unresolved_delay)
        if trigger.times > 0 then
          trigger.times = trigger.times - 1
          if trigger.times <= 0 then
            trigger.after()
            self.triggers[tag] = nil
          end
        end
      end

    elseif trigger.type == "after" then
      if trigger.timer > trigger.delay then
        trigger.action()
        self.triggers[tag] = nil
      end

    elseif trigger.type == "conditional_after" then
      if trigger.condition() then
        trigger.action()
        self.triggers[tag] = nil
      end

    elseif trigger.type == "every" then
      if trigger.timer > trigger.delay*trigger.multiplier then
        trigger.action()
        trigger.timer = trigger.timer - trigger.delay*trigger.multiplier
        trigger.delay = self:resolve_delay(trigger.unresolved_delay)
        if trigger.times > 0 then
          trigger.times = trigger.times - 1
          if trigger.times <= 0 then
            trigger.after()
            self.triggers[tag] = nil
          end
        end
      end

    elseif trigger.type == "conditional_every" then
      local condition = trigger.condition()
      if condition and not trigger.last_condition then
        trigger.action()
        if trigger.times > 0 then
          trigger.times = trigger.times - 1
          if trigger.times <= 0 then
            trigger.after()
            self.triggers[tag] = nil
          end
        end
      end
      trigger.last_condition = condition

    elseif trigger.type == "during" then
      trigger.action(dt)
      if trigger.timer > trigger.delay then
        trigger.after()
        self.triggers[tag] = nil
      end

    elseif trigger.type == "conditional_during" then
      local condition = trigger.condition()
      if condition then
        trigger.action()
      end
      if trigger.last_condition and not condition then
        trigger.after()
      end
      trigger.last_condition = condition

    elseif trigger.type == "tween" then
      local t = trigger.method(trigger.timer/trigger.delay)
      for k, v in pairs(trigger.source) do
        trigger.target[k] = math.lerp(t, trigger.initial_values[k], v)
      end
      if trigger.timer > trigger.delay then
        trigger.after()
        self.triggers[tag] = nil
      end
    end
  end
end
