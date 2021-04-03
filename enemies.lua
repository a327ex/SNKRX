Seeker = Object:extend()
Seeker:implement(GameObject)
Seeker:implement(Physics)
Seeker:implement(Unit)
function Seeker:init(args)
  self:init_game_object(args)
  self:init_unit()
  self:set_as_rectangle(14, 6, 'dynamic', 'enemy')
  self:set_restitution(0.5)

  self.color = red[0]:clone()
  self.classes = {'seeker'}
  self:calculate_stats(true)
  self:set_as_steerable(self.v, 2000, 4*math.pi, 4)

  self.spawner = random:bool(25)

  --[[
  if random:bool(35) then
    local n = random:int(1, 3)
    self.speed_booster = n == 1
    self.exploder = n == 2
    self.headbutter = n == 3
  end
  ]]--

  if self.speed_booster then
    self.color = green[0]:clone()
    self.area_sensor = Circle(self.x, self.y, 128)
  elseif self.exploder then
    self.color = blue[0]:clone()
  elseif self.headbutter then
    self.color = orange[0]:clone()
    self.last_headbutt_time = 0
    self.t:every(function() return math.distance(self.x, self.y, main.current.player.x, main.current.player.y) < 64 and love.timer.getTime() - self.last_headbutt_time > 10 end, function()
      if self.headbutt_charging or self.headbutting then return end
      self.headbutt_charging = true
      self.t:tween(2, self.color, {r = fg[0].r, b = fg[0].b, g = fg[0].g}, math.cubic_in_out, function()
        self.t:tween(0.25, self.color, {r = orange[0].r, b = orange[0].b, g = orange[0].g}, math.linear)
        self.headbutt_charging = false
        headbutt1:play{pitch = random:float(0.95, 1.05), volume = 0.2}
        self.headbutting = true
        self.last_headbutt_time = love.timer.getTime()
        self:set_damping(0)
        self:apply_steering_impulse(300, self:angle_to_object(main.current.player), 0.75)
        self.t:after(0.75, function()
          self.headbutting = false
        end)
      end)
    end)
  elseif self.tank then
    self.color = yellow[0]:clone()
    self.buff_hp_m = 1.5 + (0.05*self.level)
    self:calculate_stats()
    self.hp = self.max_hp
  elseif self.shooter then
    self.color = fg[0]:clone()
    self.t:after({2, 4}, function()
      self.shooting = true
      self.t:every({3, 5}, function()
        for i = 1, 3 do
          self.t:after((1 - self.level*0.01)*0.15*(i-1), function()
            shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.1}
            self.hfx:use('hit', 0.25, 200, 10, 0.1)
            local r = self.r
            HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
            EnemyProjectile{group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), color = fg[0], r = r, v = 150 + 5*self.level, dmg = 2*self.dmg}
          end)
        end
      end, nil, nil, 'shooter')
  end)
  elseif self.spawner then
    self.color = purple[0]:clone()
  end
end


function Seeker:update(dt)
  self:update_game_object(dt)

  if main.current.mage_level == 2 then self.buff_def_a = -30
  elseif main.current.mage_level == 1 then self.buff_def_a = -15
  else self.buff_def_a = 0 end
  if self.speed_boosting then
    local n = math.remap(love.timer.getTime() - self.speed_boosting, 0, 3, 1, 0.5)
    self.buff_mvspd_m = (3 + 0.1*self.level)*n
    if not self.speed_booster and not self.exploder and not self.headbutter and not self.tank and not self.shooter and not self.spawner then
      self.color.r = math.remap(n, 1, 0.5, green[0].r, red[0].r)
      self.color.g = math.remap(n, 1, 0.5, green[0].g, red[0].g)
      self.color.b = math.remap(n, 1, 0.5, green[0].b, red[0].b)
    end
  end
  self:calculate_stats()

  if self.shooter then
    self.t:set_every_multiplier('shooter', (1 - self.level*0.02))
  end

  if self.being_pushed then
    local v = math.length(self:get_velocity())
    if v < 25 then
      self.being_pushed = false
      self.steering_enabled = true
      self:set_damping(0)
      self:set_angular_damping(0)
    end
  else
    if self.headbutt_charging or self.shooting then
      self:set_damping(10)
      self:rotate_towards_object(main.current.player, 0.5)
    elseif not self.headbutting then
      local player = main.current.player
      self:seek_point(player.x, player.y)
      self:wander(50, 100, 20)
      self:steering_separate(16, main.current.enemies)
      self:rotate_towards_velocity(0.5)
    end
  end
  self.r = self:get_angle()

  if self.area_sensor then self.area_sensor:move_to(self.x, self.y) end
end


function Seeker:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function Seeker:on_collision_enter(other, contact)
  local x, y = contact:getPositions()

  if other:is(Wall) then
    self.hfx:use('hit', 0.15, 200, 10, 0.1)
    self:bounce(contact:getNormal())

  elseif table.any(main.current.enemies, function(v) return other:is(v) end) then
    if self.being_pushed and math.length(self:get_velocity()) > 60 then
      other:hit(math.floor(self.push_force/4))
      self:hit(math.floor(self.push_force/2))
      other:push(math.floor(self.push_force/2), other:angle_to_object(self))
      HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
      for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = self.color} end
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}

    elseif self.headbutting then
      other:push(math.length(self:get_velocity())/4, other:angle_to_object(self))
      HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
      for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = self.color} end
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end
  
  elseif other:is(Turret) then
    _G[random:table{'player_hit1', 'player_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    self:hit(0)
    self:push(random:float(2.5, 7), other:angle_to_object(self))
  end
end


function Seeker:hit(damage, projectile)
  if self.dead then return end
  self.hfx:use('hit', 0.25, 200, 10)
  self:show_hp()
  
  local actual_damage = self:calculate_damage(damage)
  self.hp = self.hp - actual_damage
  main.current.damage_dealt = main.current.damage_dealt + actual_damage
  if self.hp <= 0 then
    self.dead = true
    for i = 1, random:int(4, 6) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 12}:scale_down(0.3):change_color(0.5, self.color)
    main.current:enemy_killed()
    _G[random:table{'enemy_die1', 'enemy_die2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.5}

    if self.speed_booster then
      local enemies = self:get_objects_in_shape(self.area_sensor, main.current.enemies)
      if #enemies > 0 then
        buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
        for _, enemy in ipairs(enemies) do
          LightningLine{group = main.current.effects, src = self, dst = enemy, color = green[0]}
          enemy:speed_boost(3)
        end
      end
    end

    if self.exploder then
      shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.4}
      trigger:after(0.01, function()
        for i = 1, 16 do
          EnemyProjectile{group = main.current.main, x = self.x, y = self.y, color = blue[0], r = (i-1)*math.pi/8, v = 150 + 5*self.level, dmg = 2*self.dmg}
        end
      end)
    end

    if self.spawner then
      critter1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      trigger:after(0.01, function()
        for i = 1, random:int(3, 6) do
          EnemyCritter{group = main.current.main, x = self.x, y = self.y, color = purple[0], r = random:float(0, 2*math.pi), v = 5 + 0.1*self.level, dmg = self.dmg, projectile = projectile}
        end
      end)
    end
  end
end


function Seeker:push(f, r)
  local n = 1
  if self.tank then n = 0.4 - 0.01*self.level end
  self.push_force = n*f
  self.being_pushed = true
  self.steering_enabled = false
  self:apply_impulse(n*f*math.cos(r), n*f*math.sin(r))
  self:apply_angular_impulse(random:table{random:float(-12*math.pi, -4*math.pi), random:float(4*math.pi, 12*math.pi)})
  self:set_damping(1.5*(1/n))
  self:set_angular_damping(1.5*(1/n))
end


function Seeker:speed_boost(duration)
  self.speed_boosting = love.timer.getTime()
  self.t:after(duration, function() self.speed_boosting = false end, 'speed_boost')
end




EnemyCritter = Object:extend()
EnemyCritter:implement(GameObject)
EnemyCritter:implement(Physics)
EnemyCritter:implement(Unit)
function EnemyCritter:init(args)
  self:init_game_object(args)
  self:init_unit()
  self:set_as_rectangle(7, 4, 'dynamic', 'enemy_projectile')
  self:set_restitution(0.5)

  self.classes = {'enemy_critter'}
  self:calculate_stats(true)
  self:set_as_steerable(self.v, 400, math.pi, 1)
  self:push(args.v, args.r)
  self.invulnerable_to = args.projectile
  self.t:after(0.5, function() self.invulnerable_to = nil end)
end


function EnemyCritter:update(dt)
  self:update_game_object(dt)

  if self.being_pushed then
    local v = math.length(self:get_velocity())
    if v < 50 then
      self.being_pushed = false
      self.steering_enabled = true
      self:set_damping(0)
      self:set_angular_damping(0)
    end
  else
    local player = main.current.player
    self:seek_point(player.x, player.y)
    self:wander(50, 200, 50)
    self:steering_separate(8, main.current.enemies)
    self:rotate_towards_velocity(1)
  end
  self.r = self:get_angle()
end


function EnemyCritter:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function EnemyCritter:hit(damage, projectile)
  if self.dead then return end
  if projectile == self.invulnerable_to then return end
  self.hfx:use('hit', 0.25, 200, 10)
  self.hp = self.hp - damage
  self:show_hp()
  if self.hp <= 0 then self:die() end
end


function EnemyCritter:push(f, r)
  self.push_force = f
  self.being_pushed = true
  self.steering_enabled = false
  self:apply_impulse(f*math.cos(r), f*math.sin(r))
  self:apply_angular_impulse(random:table{random:float(-12*math.pi, -4*math.pi), random:float(4*math.pi, 12*math.pi)})
  self:set_damping(1.5)
  self:set_angular_damping(1.5)
end


function EnemyCritter:die(x, y, r, n)
  if self.dead then return end
  x = x or self.x
  y = y or self.y
  n = n or random:int(2, 3)
  for i = 1, n do HitParticle{group = main.current.effects, x = x, y = y, r = random:float(0, 2*math.pi), color = self.color} end
  HitCircle{group = main.current.effects, x = x, y = y}:scale_down()
  self.dead = true
  _G[random:table{'enemy_die1', 'enemy_die2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.5}
  critter2:play{pitch = random:float(0.95, 1.05), volume = 0.2}
end


function EnemyCritter:on_collision_enter(other, contact)
  local x, y = contact:getPositions()
  local nx, ny = contact:getNormal()
  local r = 0
  if nx == 0 and ny == -1 then r = -math.pi/2
  elseif nx == 0 and ny == 1 then r = math.pi/2
  elseif nx == -1 and ny == 0 then r = math.pi
  else r = 0 end

  if other:is(Wall) then
    self.hfx:use('hit', 0.15, 200, 10, 0.1)
    self:bounce(contact:getNormal())
  end
end


function EnemyCritter:on_trigger_enter(other, contact)
  if other:is(Player) then
    self:die(self.x, self.y, nil, random:int(2, 3))
    other:hit(self.dmg)
  end
end




EnemyProjectile = Object:extend()
EnemyProjectile:implement(GameObject)
EnemyProjectile:implement(Physics)
function EnemyProjectile:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(10, 4, 'dynamic', 'enemy_projectile')
end


function EnemyProjectile:update(dt)
  self:update_game_object(dt)

  self:set_angle(self.r)
  self:move_along_angle(self.v, self.r)
end


function EnemyProjectile:draw()
  graphics.push(self.x, self.y, self.r)
  graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.color)
  graphics.pop()
end


function EnemyProjectile:die(x, y, r, n)
  if self.dead then return end
  x = x or self.x
  y = y or self.y
  n = n or random:int(3, 4)
  for i = 1, n do HitParticle{group = main.current.effects, x = x, y = y, r = random:float(0, 2*math.pi), color = self.color} end
  HitCircle{group = main.current.effects, x = x, y = y}:scale_down()
  self.dead = true
  proj_hit_wall1:play{pitch = random:float(0.9, 1.1), volume = 0.05}
end


function EnemyProjectile:on_collision_enter(other, contact)
  local x, y = contact:getPositions()
  local nx, ny = contact:getNormal()
  local r = 0
  if nx == 0 and ny == -1 then r = -math.pi/2
  elseif nx == 0 and ny == 1 then r = math.pi/2
  elseif nx == -1 and ny == 0 then r = math.pi
  else r = 0 end

  if other:is(Wall) then
    self:die(x, y, r, random:int(2, 3))
  end
end


function EnemyProjectile:on_trigger_enter(other, contact)
  if other:is(Player) then
    self:die(self.x, self.y, nil, random:int(2, 3))
    other:hit(self.dmg)
  end
end
