Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
Player:implement(Unit)
function Player:init(args)
  self:init_game_object(args)
  self:init_unit()

  if self.character == 'vagrant' then
    self.color = fg[0]
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = {'ranger', 'warrior', 'mage'}

    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:every(2, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'swordsman' then
    self.color = orange[0]
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = {'warrior'}

    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:every(3, function()
      local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies)
      if enemies and #enemies > 0 then
        self:attack(96)
      end
    end, nil, nil, 'attack')

  elseif self.character == 'wizard' then
    self.color = blue[0]
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = {'mage'}

    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:every(2, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {wizard = self})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'archer' then
    self.color = yellow[0]
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = {'ranger'}

    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:every(2, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {pierce = 1000})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'scout' then
    self.color = red[0]
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = {'rogue'}

    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:every(2, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {chain = 3})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'cleric' then
    self.color = green[0]
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = {'healer'}

    self.last_heal_time = love.timer.getTime()
    self.t:every(2, function()
      local followers
      local leader = (self.leader and self) or self.parent
      if self.leader then followers = self.followers else followers = self.parent.followers end
      if (table.any(followers, function(v) return v.hp <= 0.5*v.max_hp end) or (leader.hp <= 0.5*leader.max_hp)) and love.timer.getTime() - self.last_heal_time > 6 then
        self.last_heal_time = love.timer.getTime()
        if self.leader then self:heal(0.1*self.max_hp) else self.parent:heal(0.1*self.parent.max_hp) end
        for _, f in ipairs(followers) do f:heal(0.1*f.max_hp) end
        heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      end
    end)
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

  if self.attack_sensor then self.attack_sensor:move_to(self.x, self.y) end
  self.t:set_every_multiplier('shoot', self.aspd_m)
  self.t:set_every_multiplier('attack', self.aspd_m)

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
        spawn1:play{pitch = random:float(0.8, 1.2), volume = 0.15}
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
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x*self.hfx.shoot.x, self.hfx.hit.x*self.hfx.shoot.x)
  if self.visual_shape == 'rectangle' then
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, (self.hfx.hit.f or self.hfx.shoot.f) and fg[0] or self.color)
  end
  graphics.pop()
  -- self.attack_sensor:draw(self.color, 2)
end


function Player:on_collision_enter(other, contact)
  local x, y = contact:getPositions()

  if other:is(Wall) then
    if self.leader then
      self.hfx:use('hit', 0.5, 200, 10, 0.1)
      camera:spring_shake(2, math.pi - self.r)
      self:bounce(contact:getNormal())
      local r = random:float(0.9, 1.1)
      player_hit_wall1:play{pitch = r, volume = 0.1}
      pop1:play{pitch = r, volume = 0.2}

      for i, f in ipairs(self.followers) do
        trigger:after(i*0.002*self.v, function()
          f.hfx:use('hit', 0.5, 200, 10, 0.1)
          player_hit_wall1:play{pitch = r + 0.025*i, volume = 0.1}
          pop1:play{pitch = r + 0.05*i, volume = 0.2}
        end)
      end
    end

  elseif table.any(main.current.enemies, function(v) return other:is(v) end) then
    other:push(random:float(25, 35), self:angle_to_object(other))
    other:hit(20)
    self:hit(20)
    HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = self.color} end
    for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = other.color} end
  end
end


function Player:hit(damage)
  if self.dead then return end
  self.hfx:use('hit', 0.25, 200, 10)
  self:show_hp()
  
  local actual_damage = self:calculate_damage(damage)
  self.hp = self.hp - actual_damage
  _G[random:table{'player_hit1', 'player_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  camera:shake(4, 0.5)

  if self.hp <= 0 then
    slow(0.25, 1)
    self.dead = true
    for i = 1, random:int(4, 6) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 12}:scale_down(0.3):change_color(0.5, self.color)
  end
end


function Player:heal(amount)
  local hp = self.hp

  self.hfx:use('hit', 0.25, 200, 10)
  self:show_hp(1.5)
  self:show_heal(1.5)
  self.hp = self.hp + amount
  if self.hp > self.max_hp then self.hp = self.max_hp end
end


function Player:add_follower(unit)
  table.insert(self.followers, unit)
  unit.parent = self
  unit.follower_index = #self.followers
end


function Player:shoot(r, mods)
  camera:spring_shake(2, r)
  self.hfx:use('shoot', 0.25)
  HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
  local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.color, dmg = self.dmg, character = self.character}
  Projectile(table.merge(t, mods or {}))

  if self.character == 'vagrant' then
    shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.3}
  elseif self.character == 'archer' then
    archer1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  elseif self.character == 'wizard' then
    wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
  elseif self.character == 'scout' then
    _G[random:table{'scout1', 'scout2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  end
end


function Player:attack(area, mods)
  camera:shake(2, 0.5)
  self.hfx:use('shoot', 0.25)
  local t = {group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.area_size_m*(area or 64), color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character}
  Area(table.merge(t, mods or {}))

  if self.character == 'swordsman' then
    _G[random:table{'swordsman1', 'swordsman2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.75}
  end
end




Projectile = Object:extend()
Projectile:implement(GameObject)
Projectile:implement(Physics)
function Projectile:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(10, 4, 'dynamic', 'projectile')
  self.pierce = args.pierce or 0
  self.chain = args.chain or 0
  self.chain_enemies_hit = {}
end


function Projectile:update(dt)
  self:update_game_object(dt)

  self:set_angle(self.r)
  self:move_along_angle(self.v, self.r)
end


function Projectile:draw()
  graphics.push(self.x, self.y, self.r)
  graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.color)
  graphics.pop()
end


function Projectile:die(x, y, r, n)
  if self.dead then return end
  x = x or self.x
  y = y or self.y
  n = n or random:int(3, 4)
  for i = 1, n do HitParticle{group = main.current.effects, x = x, y = y, r = random:float(0, 2*math.pi), color = self.color} end
  HitCircle{group = main.current.effects, x = x, y = y}:scale_down()
  self.dead = true

  if self.character == 'wizard' then
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.wizard.area_size_m*32, color = self.color, dmg = self.wizard.area_dmg_m*self.dmg, character = self.character}
  end
end


function Projectile:on_collision_enter(other, contact)
  local x, y = contact:getPositions()
  local nx, ny = contact:getNormal()
  local r = 0
  if nx == 0 and ny == -1 then r = -math.pi/2
  elseif nx == 0 and ny == 1 then r = math.pi/2
  elseif nx == -1 and ny == 0 then r = math.pi
  else r = 0 end

  if other:is(Wall) then
    if self.character == 'archer' then
      self:die(x, y, r, 0)
      _G[random:table{'arrow_hit_wall1', 'arrow_hit_wall2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.2}
      WallArrow{group = main.current.main, x = x, y = y, r = self.r, color = self.color}
    elseif self.character == 'scout' then
      self:die(x, y, r, 0)
      knife_hit_wall1:play{pitch = random:float(0.9, 1.1), volume = 0.2}
      local r = Unit.bounce(self, nx, ny)
      trigger:after(0.01, function()
        WallKnife{group = main.current.main, x = x, y = y, r = r, v = self.v*0.1, color = self.color}
      end)
    elseif self.character == 'wizard' then
      self:die(x, y, r, random:int(2, 3))
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
    else
      self:die(x, y, r, random:int(2, 3))
      proj_hit_wall1:play{pitch = random:float(0.9, 1.1), volume = 0.2}
    end
  end
end


function Projectile:on_trigger_enter(other, contact)
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    if self.pierce <= 0 and self.chain <= 0 then
      self:die(self.x, self.y, nil, random:int(2, 3))
    else
      if self.pierce > 0 then
        self.pierce = self.pierce - 1
      end
      if self.chain > 0 then
        self.chain = self.chain - 1
        table.insert(self.chain_enemies_hit, other)
        local object = self:get_random_object_in_shape(Circle(self.x, self.y, 160), main.current.enemies, self.chain_enemies_hit)
        if object then
          self.r = self:angle_to_object(object)
          self.v = self.v*1.25
        end
      end
      HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = fg[0], duration = 0.1}
      HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color}
      HitParticle{group = main.current.effects, x = self.x, y = self.y, color = other.color}
    end

    if self.character == 'archer' or self.character == 'scout' then
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    elseif self.character == 'wizard' then
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
    else
      hit3:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end
    other:hit(self.dmg)
  end
end




Area = Object:extend()
Area:implement(GameObject)
function Area:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 1.5*self.w, 1.5*self.w, self.r)
  local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
  for _, enemy in ipairs(enemies) do
    enemy:hit(self.dmg)
    HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 2 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
    for i = 1, 2 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
    if self.character == 'wizard' then
      magic_hit1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    elseif self.character == 'swordsman' then
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end
  end

  self.color = fg[0]
  self.color_transparent = Color(args.color.r, args.color.g, args.color.b, 0.08)
  self.w = 0
  self.hidden = false
  self.t:tween(0.05, self, {w = args.w}, math.cubic_in_out, function() self.spring:pull(0.15) end)
  self.t:after(0.2, function()
    self.color = args.color
    self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self.dead = true end)
  end)
end


function Area:update(dt)
  self:update_game_object(dt)
end


function Area:draw()
  if self.hidden then return end
  graphics.push(self.x, self.y, self.r, self.spring.x, self.spring.x)
  local w = self.w/2
  local w10 = self.w/10
  local x1, y1 = self.x - w, self.y - w
  local x2, y2 = self.x + w, self.y + w
  graphics.polyline(self.color, 2, x1, y1 + w10, x1, y1, x1 + w10, y1)
  graphics.polyline(self.color, 2, x2 - w10, y1, x2, y1, x2, y1 + w10)
  graphics.polyline(self.color, 2, x2 - w10, y2, x2, y2, x2, y2 - w10)
  graphics.polyline(self.color, 2, x1, y2 - w10, x1, y2, x1 + w10, y2)
  graphics.rectangle((x1+x2)/2, (y1+y2)/2, x2-x1, y2-y1, nil, nil, self.color_transparent)
  graphics.pop()
end
