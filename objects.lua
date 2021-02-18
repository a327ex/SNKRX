Unit = Object:extend()
Unit:implement(GameObject)
Unit:implement(Physics)
function Unit:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(9, 9, 'dynamic', (self.player and 'player') or (self.enemy and 'enemy'))

  if self.character == 'vagrant' then
    self.color = fg[0]
    self.visual_shape = 'rectangle'
    self.classes = {'ranger', 'warrior', 'mage'}
  elseif self.character == 'seeker' then
    self.color = red[0]
    self.visual_shape = 'capsule'
    self.classes = {'seeker'}
    if self.enemy then
      self.enemy_behavior = 'seek'
      self:calculate_stats()
      self:set_as_steerable(self.v)
    end
  end

  self:calculate_stats()

  self.r = 0
  self.hfx:add('hit', 1)
  self.hp = self.max_hp

  if self.leader then
    self.previous_positions = {}
    self.followers = {}
    self.t:every(0.01, function()
      table.insert(self.previous_positions, 1, {x = self.x, y = self.y, r = self.r})
      if #self.previous_positions > 256 then self.previous_positions[257] = nil end
    end)
  end
end


function Unit:update(dt)
  self:update_game_object(dt)
  self:calculate_stats()

  if self.player and self.leader then
    if input.move_left.down then self.r = self.r - 1.66*math.pi*dt end
    if input.move_right.down then self.r = self.r + 1.66*math.pi*dt end
    self:set_velocity(self.v*math.cos(self.r), self.v*math.sin(self.r))

    local vx, vy = self:get_velocity()
    local hd = math.remap(math.abs(self.x - gw/2), 0, 192, 1, 0)
    local vd = math.remap(math.abs(self.y - gh/2), 0, 108, 1, 0)
    camera.x = camera.x + math.remap(vx, -100, 100, -24*hd, 24*hd)*dt
    camera.y = camera.y + math.remap(vy, -100, 100, -8*vd, 8*vd)*dt
    if input.move_right.down then camera.r = math.lerp_angle_dt(0.01, dt, camera.r, math.pi/256)
    elseif input.move_left.down then camera.r = math.lerp_angle_dt(0.01, dt, camera.r, -math.pi/256)
    elseif input.move_down.down then camera.r = math.lerp_angle_dt(0.01, dt, camera.r, math.pi/256)
    elseif input.move_up.down then camera.r = math.lerp_angle_dt(0.01, dt, camera.r, -math.pi/256)
    else camera.r = math.lerp_angle_dt(0.005, dt, camera.r, 0) end
  end

  if not self.player and self.leader then
    local player = main.current.player
    if self.enemy_behavior == 'seek' then
      if self.being_pushed then
        local v = math.length(self:get_velocity())
        if v < 25 then
          self.being_pushed = false
          self.steering_enabled = true
          self:set_damping(0)
          self:set_angular_damping(0)
        end
        self.r = self:get_angle()
      else
        self:seek_point(player.x, player.y)
        self:wander(25, 100, 20)
        self:rotate_towards_velocity(0.5)
        self.r = self:get_angle()
      end
    end
  end

  if not self.leader then
    local ds
    if self.parent.v >= 80 and self.parent.v <= 90 then ds = 8 end
    if self.parent.v >= 20 and self.parent.v <= 30 then ds = 12 end
    if not ds then error('undefined unit distance for parent velocity: ' .. self.parent.v) end

    local d = ds*self.follower_index
    local p = self.parent.previous_positions[d]
    if p then
      self:set_position(p.x, p.y)
      self.r = p.r
    end
  end

  self:set_angle(self.r)
end


function Unit:on_trigger_enter(other)
  if other:is(Unit) and other.enemy then
    other:push(math.length(self:get_velocity())/3.5, self:angle_to_object(other))
  end
end


function Unit:push(f, r)
  self.being_pushed = true
  self.steering_enabled = false
  self:apply_impulse(f*math.cos(r), f*math.sin(r))
  self:apply_angular_impulse(random:float(-12*math.pi, 12*math.pi))
  self:set_damping(1.5)
  self:set_angular_damping(1.5)
end


function Unit:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    if self.visual_shape == 'triangle' then
      graphics.triangle(self.x, self.y, self.shape.w, self.shape.h, self.hfx.hit.f and fg[0] or self.color)
    elseif self.visual_shape == 'rectangle' then
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
    elseif self.visual_shape == 'capsule' then
      graphics.rectangle(self.x, self.y, self.shape.w, 0.525*self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
    end
  graphics.pop()

  graphics.push(self.x, self.y, 0, self.hfx.hit.x, self.hfx.hit.x)
    if self.show_hp then
      graphics.line(self.x - 0.5*self.shape.w, self.y - self.shape.h, self.x + 0.5*self.shape.w, self.y - self.shape.h, bg[-3], 2)
      local n = math.remap(self.hp, 0, self.max_hp, 0, 1)
      graphics.line(self.x - 0.5*self.shape.w, self.y - self.shape.h, self.x - 0.5*self.shape.w + n*self.shape.w, self.y - self.shape.h, self.hfx.hit.f and fg[0] or ((self.player and green[0]) or (self.enemy and red[0])), 2)
    end
  graphics.pop()
end


function Unit:on_collision_enter(other, contact)
  if other:is(Wall) and self.leader then
    self.hfx:use('hit', 0.5, 200, 10, 0.1)
    camera:spring_shake(2, math.pi - self.r)

    for i, unit in ipairs(self.followers) do
      self.t:after((i-1)*self.v*0.00185, function()
        unit.hfx:use('hit', 0.25, 200, 10, 0.1)
      end)
    end

    local nx, ny = contact:getNormal()
    local vx, vy = self:get_velocity()
    if nx == 0 then
      self:set_velocity(vx, -vy)
      self.r = 2*math.pi - self.r
    end
    if ny == 0 then
      self:set_velocity(-vx, vy)
      self.r = math.pi - self.r
    end
  end
end


function Unit:add_follower(unit)
  table.insert(self.followers, unit)
  unit.parent = self
  unit.follower_index = #self.followers
end


function Unit:calculate_damage(dmg)
  if self.def >= 0 then dmg = dmg*(100/(100+self.def))
  else dmg = dmg*(2 - 100/(100+self.def)) end
  return dmg
end


function Unit:calculate_stats()
  self.base_hp = 100
  self.base_dmg = 10
  self.base_aspd = 1
  self.base_cycle = 2
  self.base_def = 0
  self.base_mvspd = 75
  self.class_hp_a = 0
  self.class_dmg_a = 0
  self.class_aspd_a = 0
  self.class_cycle_a = 0
  self.class_def_a = 0
  self.class_mvspd_a = 0
  self.class_hp_m = 1
  self.class_dmg_m = 1
  self.class_aspd_m = 1
  self.class_cycle_m = 1
  self.class_def_m = 1
  self.class_mvspd_m = 1
  self.buff_hp_a = 0
  self.buff_dmg_a = 0
  self.buff_aspd_a = 0
  self.buff_cycle_a = 0
  self.buff_def_a = 0
  self.buff_mvspd_a = 0
  self.buff_hp_m = 1
  self.buff_dmg_m = 1
  self.buff_aspd_m = 1
  self.buff_cycle_m = 1
  self.buff_def_m = 1
  self.buff_mvspd_m = 1

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_hp_m = self.class_hp_m*1.4
    elseif class == 'mage' then self.class_hp_m = self.class_hp_m*0.6
    elseif class == 'healer' then self.class_hp_m = self.class_hp_m*1.1
    elseif class == 'cycler' then self.class_hp_m = self.class_hp_m*0.9
    elseif class == 'seeker' then self.class_hp_m = self.class_hp_m*0.5 end
  end
  self.max_hp = (self.base_hp + self.class_hp_a + self.buff_hp_a)*self.class_hp_m*self.buff_hp_m

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_dmg_m = self.class_dmg_m*1.1
    elseif class == 'ranger' then self.class_dmg_m = self.class_dmg_m*1.2
    elseif class == 'mage' then self.class_dmg_m = self.class_dmg_m*1.4 end
  end
  self.dmg = (self.base_dmg + self.class_dmg_a + self.buff_dmg_a)*self.class_dmg_m*self.buff_dmg_m

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_aspd_m = self.class_aspd_m*0.9
    elseif class == 'ranger' then self.class_aspd_m = self.class_aspd_m*1.4
    elseif class == 'healer' then self.class_aspd_m = self.class_aspd_m*0.5 end
  end
  self.aspd = 1/((self.base_aspd + self.class_aspd_a + self.buff_aspd_a)*self.class_aspd_m*self.buff_aspd_m)

  for _, class in ipairs(self.classes) do
    if class == 'mage' then self.class_cycle_m = self.class_cycle_m*1.25
    elseif class == 'healer' then self.class_cycle_m = self.class_cycle_m*1.1
    elseif class == 'cycler' then self.class_cycle_m = self.class_cycle_m*1.5 end
  end
  self.cycle = (self.base_cycle + self.class_cycle_a + self.buff_cycle_a)*self.class_cycle_m*self.buff_cycle_m

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_def_m = self.class_def_m*1.25
    elseif class == 'ranger' then self.class_def_m = self.class_def_m*1.1
    elseif class == 'mage' then self.class_def_m = self.class_def_m*1.5
    elseif class == 'healer' then self.class_def_m = self.class_def_m*1.2 end
  end
  self.def = (self.base_def + self.class_def_a + self.buff_def_a)*self.class_def_m*self.buff_def_m

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_mvspd_m = self.class_mvspd_m*0.9
    elseif class == 'ranger' then self.class_mvspd_m = self.class_mvspd_m*1.2
    elseif class == 'seeker' then self.class_mvspd_m = self.class_mvspd_m*0.3 end
  end
  self.v = (self.base_mvspd + self.class_mvspd_a + self.buff_mvspd_a)*self.class_mvspd_m*self.buff_mvspd_m
end
