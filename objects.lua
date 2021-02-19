Unit = Object:extend()
function Unit:init_unit()
  self.hfx:add('hit', 1)
end


function Unit:draw_hp()
  graphics.push(self.x, self.y, 0, self.hfx.hit.x, self.hfx.hit.x)
    if self.show_hp_bar then
      graphics.line(self.x - 0.5*self.shape.w, self.y - self.shape.h, self.x + 0.5*self.shape.w, self.y - self.shape.h, bg[-3], 2)
      local n = math.remap(self.hp, 0, self.max_hp, 0, 1)
      graphics.line(self.x - 0.5*self.shape.w, self.y - self.shape.h, self.x - 0.5*self.shape.w + n*self.shape.w, self.y - self.shape.h,
      self.hfx.hit.f and fg[0] or ((self:is(Player) and green[0]) or (table.any(main.current.enemies, function(v) return self:is(v) end) and red[0])), 2)
    end
  graphics.pop()
end


function Unit:bounce(nx, ny)
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


function Unit:show_hp(n)
  self.show_hp_bar = true
  self.t:after(n or 2, function() self.show_hp_bar = false end, 'show_hp_bar')
end


function Unit:hit(damage)
  if self.dead then return end

  self.hfx:use('hit', 0.25, 200, 10)
  self:show_hp()
  
  local actual_damage = self:calculate_damage(damage)
  self.hp = self.hp - actual_damage
  if self:is(Player) then
    if actual_damage >= 20 then
      camera:shake(2, 1)
      slow(0.25, 1)
    else
      camera:shake(2, 0.5)
    end
  end

  if self.hp <= 0 then
    self.dead = true
    for i = 1, random:int(4, 6) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 12}:scale_down(0.3):change_color(0.5, self.color)
  end
end


function Unit:calculate_damage(dmg)
  if self.def >= 0 then dmg = dmg*(100/(100+self.def))
  else dmg = dmg*(2 - 100/(100+self.def)) end
  return dmg
end


function Unit:calculate_stats(first_run)
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
  if first_run then self.hp = self.max_hp end

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



Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
Player:implement(Unit)
function Player:init(args)
  self:init_game_object(args)
  self:init_unit()

  if self.character == 'vagrant' then
    self.color = blue[0]
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = {'ranger', 'warrior', 'mage'}
  end
  self:calculate_stats(true)

  if self.leader then
    self.previous_positions = {}
    self.followers = {}
    self.t:every(0.01, function()
      table.insert(self.previous_positions, 1, {x = self.x, y = self.y, r = self.r})
      if #self.previous_positions > 256 then self.previous_positions[257] = nil end
    end)
  end
end


function Player:update(dt)
  self:update_game_object(dt)
  self:calculate_stats()

  if self.leader then
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

    self:set_angle(self.r)

  else
    local target_distance = 10.6*self.follower_index
    local distance_sum = 0
    local p
    local previous = self.parent
    for i, point in ipairs(self.parent.previous_positions) do
      local distance_to_previous = math.distance(previous.x, previous.y, point.x, point.y)
      distance_sum = distance_sum + distance_to_previous
      if distance_sum >= target_distance then
        p = point
        break
      end
      previous = point
    end

    if p then
      self:set_position(p.x, p.y)
      self.r = p.r
      if not self.following then
        for i = 1, random:int(3, 4) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 10, color = fg[0]}:scale_down(0.3):change_color(0.5, self.color)
        self.following = true
      end
    else
      self.r = self:get_angle()
    end
  end
end


function Player:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
  if self.visual_shape == 'rectangle' then
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  end
  graphics.pop()
  self:draw_hp()
end


function Player:on_collision_enter(other, contact)
  local x, y = contact:getPositions()

  if other:is(Wall) then
    self.hfx:use('hit', 0.5, 200, 10, 0.1)
    camera:spring_shake(2, math.pi - self.r)
    self:bounce(contact:getNormal())

  elseif table.any(main.current.enemies, function(v) return other:is(v) end) then
    other:push(random:float(25, 35), self:angle_to_object(other))
    other:hit(20)
    self:hit(20)
    HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = self.color} end
    for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = other.color} end
  end
end


function Player:add_follower(unit)
  table.insert(self.followers, unit)
  unit.parent = self
  unit.follower_index = #self.followers
end


Seeker = Object:extend()
Seeker:implement(GameObject)
Seeker:implement(Physics)
Seeker:implement(Unit)
function Seeker:init(args)
  self:init_game_object(args)
  self:init_unit()
  self:set_as_rectangle(14, 6, 'dynamic', 'enemy')
  self:set_restitution(0.5)

  self.color = red[0]
  self.classes = {'seeker'}
  self:calculate_stats(true)
  self:set_as_steerable(self.v, 2000, 4*math.pi, 4)
end


function Seeker:update(dt)
  self:update_game_object(dt)
  self:calculate_stats()

  if self.being_pushed then
    local v = math.length(self:get_velocity())
    if v < 25 then
      self.being_pushed = false
      self.steering_enabled = true
      self:set_damping(0)
      self:set_angular_damping(0)
    end
  else
    local player = main.current.player
    self:seek_point(player.x, player.y)
    self:wander(50, 100, 20)
    self:separate(16, main.current.enemies)
    self:rotate_towards_velocity(0.5)
  end
  self.r = self:get_angle()
end


function Seeker:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
  self:draw_hp()
end


function Seeker:on_collision_enter(other, contact)
  local x, y = contact:getPositions()

  if other:is(Wall) then
    self.hfx:use('hit', 0.15, 200, 10, 0.1)
    self:bounce(contact:getNormal())

  elseif table.any(main.current.enemies, function(v) return other:is(v) end) then
    if self.being_pushed and math.length(self:get_velocity()) > 60 then
      other:hit(5)
      self:hit(10)
      other:push(random:float(10, 15), other:angle_to_object(self))
      HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
      for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = self.color} end
    end
  end
end


function Seeker:push(f, r)
  self.being_pushed = true
  self.steering_enabled = false
  self:apply_impulse(f*math.cos(r), f*math.sin(r))
  self:apply_angular_impulse(random:table{random:float(-12*math.pi, -4*math.pi), random:float(4*math.pi, 12*math.pi)})
  self:set_damping(1.5)
  self:set_angular_damping(1.5)
end
