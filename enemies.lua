Seeker = Object:extend()
Seeker:implement(GameObject)
Seeker:implement(Physics)
Seeker:implement(Unit)
function Seeker:init(args)
  self:init_game_object(args)
  self:init_unit()

  if self.boss then
    self:set_as_rectangle(18, 7, 'dynamic', 'enemy')
    self:set_restitution(0.5)
    self.classes = {'mini_boss'}
    self:calculate_stats(true)
    self:set_as_steerable(self.v, 1000, 2*math.pi, 2)

    if self.boss == 'speed_booster' then
      self.color = green[0]:clone()
      self.t:every(8, function()
        if self.silenced then return end
        local enemies = table.head(self:get_objects_in_shape(Circle(self.x, self.y, 128), main.current.enemies), 4)
        if #enemies > 0 then
          buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
          for _, enemy in ipairs(enemies) do
            LightningLine{group = main.current.effects, src = self, dst = enemy, color = green[0]}
            enemy:speed_boost(3 + self.level*0.025 + current_new_game_plus*0.1)
          end
        end
      end)

    elseif self.boss == 'forcer' then
      self.color = yellow[0]:clone()
      self.t:every(6, function()
        if self.silenced then return end
        local enemies = main.current.main:get_objects_by_classes(main.current.enemies)
        local x, y = 0, 0
        if #enemies > 0 then
          for _, enemy in ipairs(enemies) do
            x = x + enemy.x
            y = y + enemy.y
          end
          x = x/#enemies
          y = y/#enemies
        else
          x, y = player.x, player.y
        end
        self.px, self.py = x + random:float(-16, 16), y + random:float(-16, 16)
        self.pull_sensor = Circle(self.px, self.py, 160)
        self.prs = 0
        self.t:tween(0.05, self, {prs = 4}, math.cubic_in_out, function() self.spring:pull(0.15) end)
        self.t:after(2 - 0.05*7, function()
          self.t:every_immediate(0.05, function() self.phidden = not self.phidden end, 7)
        end)
        self.color_transparent = Color(yellow[0].r, yellow[0].g, yellow[0].b, 0.08)
        self.t:every(0.08, function() HitParticle{group = main.current.effects, x = self.px, y = self.py, color = yellow[0]} end, math.floor(2/0.08))
        self.vr = 0
        self.dvr = random:float(-math.pi/4, math.pi/4)

        force1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        self.t:during(2, function(dt)
          local enemies = self:get_objects_in_shape(self.pull_sensor, main.current.enemies)
          for _, enemy in ipairs(enemies) do
            enemy:apply_steering_force(math.remap(enemy:distance_to_point(self.px, self.py), 0, 160, 400, 200), enemy:angle_to_point(self.px, self.py))
          end
          self.vr = self.vr + self.dvr*dt
        end, function()
          wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          local enemies = self:get_objects_in_shape(self.pull_sensor, main.current.enemies)
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = yellow[0], duration = 0.1}
          for _, enemy in ipairs(enemies) do
            LightningLine{group = main.current.effects, src = self, dst = enemy, color = yellow[0]}
            enemy:push(random:float(40, 80), enemy:angle_to_object(main.current.player), true)
          end
          self.px, self.py = nil, nil
        end)
      end)

    elseif self.boss == 'swarmer' then
      self.color = purple[0]:clone()
      self.t:every(4, function()
        if self.silenced then return end
        local enemies = table.select(main.current.main:get_objects_by_classes(main.current.enemies), function(v) return v.id ~= self.id and v:is(Seeker) end)
        local enemy = random:table(enemies)
        if enemy then
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = purple[0], duration = 0.1}
          LightningLine{group = main.current.effects, src = self, dst = enemy, color = purple[0]}
          enemy:hit(10000)
          critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          critter3:play{pitch = random:float(0.95, 1.05), volume = 0.6}
          for i = 1, random:int(4, 6) do EnemyCritter{group = main.current.main, x = enemy.x, y = enemy.y, color = purple[0], r = random:float(0, 2*math.pi), v = 8 + 0.1*enemy.level, dmg = 2*enemy.dmg} end
        end
      end)

    elseif self.boss == 'exploder' then
      self.color = blue[0]:clone()
      self.t:every(4, function()
        if self.silenced then return end
        local enemies = table.select(main.current.main:get_objects_by_classes(main.current.enemies), function(v) return v.id ~= self.id and v:is(Seeker) end)
        local enemy = random:table(enemies)
        if enemy then
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = blue[0], duration = 0.1}
          LightningLine{group = main.current.effects, src = self, dst = enemy, color = blue[0]}
          enemy:hit(10000)
          shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.4}
          local n = math.floor(8 + current_new_game_plus*1.5)
          for i = 1, n do EnemyProjectile{group = main.current.main, x = enemy.x, y = enemy.y, color = blue[0], r = (i-1)*math.pi/(n/2), v = 120 + 5*enemy.level, dmg = (1 + 0.1*current_new_game_plus)*enemy.dmg} end
        end
      end)

    elseif self.boss == 'randomizer' then
      self.t:every_immediate(0.07, function() self.color = _G[random:table{'green', 'purple', 'yellow', 'blue'}][0]:clone() end)
      self.t:every(6, function()
        if self.silenced then return end
        local attack = random:table{'explode', 'swarm', 'force', 'speed_boost'}
        if attack == 'explode' then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 128), {Seeker})
          local enemy = random:table(enemies)
          if enemy then
            HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = blue[0], duration = 0.1}
            LightningLine{group = main.current.effects, src = self, dst = enemy, color = blue[0]}
            enemy:hit(10000)
            shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.4}
            local n = 8 + current_new_game_plus*2
            for i = 1, n do EnemyProjectile{group = main.current.main, x = enemy.x, y = enemy.y, color = blue[0], r = (i-1)*math.pi/(n/2), v = 125 + 5*enemy.level, dmg = (1 + 0.2*current_new_game_plus)*enemy.dmg} end
          end
        elseif attack == 'swarm' then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 128), {Seeker})
          local enemy = random:table(enemies)
          if enemy then
            HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = purple[0], duration = 0.1}
            LightningLine{group = main.current.effects, src = self, dst = enemy, color = purple[0]}
            enemy:hit(10000)
            critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            critter3:play{pitch = random:float(0.95, 1.05), volume = 0.6}
            for i = 1, random:int(4, 6) do EnemyCritter{group = main.current.main, x = enemy.x, y = enemy.y, color = purple[0], r = random:float(0, 2*math.pi), v = 8 + 0.1*enemy.level, dmg = 2*enemy.dmg} end
          end
        elseif attack == 'force' then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 64), {Seeker})
          if #enemies > 0 then
            wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = yellow[0], duration = 0.1}
            for _, enemy in ipairs(enemies) do
              LightningLine{group = main.current.effects, src = self, dst = enemy, color = yellow[0]}
              enemy:push(random:float(40, 80), enemy:angle_to_object(main.current.player), true)
            end
          end

        elseif attack == 'speed_boost' then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 128), {Seeker})
          if #enemies > 0 then
            buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
            for _, enemy in ipairs(enemies) do
              LightningLine{group = main.current.effects, src = self, dst = enemy, color = green[0]}
              enemy:speed_boost(3 + self.level*0.025 + current_new_game_plus*0.1)
            end
          end
        end
      end)
    end

  else
    self:set_as_rectangle(14, 6, 'dynamic', 'enemy')
    self:set_restitution(0.5)
    self.color = red[0]:clone()
    self.classes = {'seeker'}
    self:calculate_stats(true)
    self:set_as_steerable(self.v, 2000, 4*math.pi, 4)
  end

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
    self.t:after({16, 24}, function() self:hit(10000) end)
  elseif self.exploder then
    self.color = blue[0]:clone()
    self.t:after({16, 24}, function() self:hit(10000) end)
  elseif self.headbutter then
    self.color = orange[0]:clone()
    self.last_headbutt_time = 0
    local n = math.remap(current_new_game_plus, 0, 5, 1, 0.5)
    self.t:every(function() return math.distance(self.x, self.y, main.current.player.x, main.current.player.y) < 76 and love.timer.getTime() - self.last_headbutt_time > 10*n end, function()
      if self.silenced then return end
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
    self.buff_hp_m = 1.25 + (0.1*self.level) + (0.4*current_new_game_plus)
    self:calculate_stats()
    self.hp = self.max_hp
    local n = math.remap(current_new_game_plus, 0, 5, 1, 0.75)
    self.t:every({3*n, 5*n}, function()
      local enemy = self:get_closest_object_in_shape(Circle(self.x, self.y, 128), main.current.enemies)
      if enemy then
        wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = yellow[0], duration = 0.1}
        LightningLine{group = main.current.effects, src = self, dst = enemy, color = yellow[0]}
        enemy:push(random:float(40, 80), enemy:angle_to_object(main.current.player), true)
      end
    end)
  elseif self.shooter then
    self.color = fg[0]:clone()
    local n = math.remap(current_new_game_plus, 0, 5, 1, 0.5)
    self.t:after({2*n, 4*n}, function()
      self.shooting = true
      self.t:every({3, 5}, function()
        if self.silenced then return end
        for i = 1, 3 do
          self.t:after((1 - self.level*0.01)*0.15*(i-1), function()
            shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.1}
            self.hfx:use('hit', 0.25, 200, 10, 0.1)
            local r = self.r
            HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
            EnemyProjectile{group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), color = fg[0], r = r, v = 140 + 5*self.level + 4*current_new_game_plus,
              dmg = (current_new_game_plus*0.1 + 1)*self.dmg}
          end)
        end
      end, nil, nil, 'shooter')
    end)
  elseif self.spawner then
    self.color = purple[0]:clone()
  end

  local player = main.current.player
  if player and player.intimidation and not self.boss and not self.tank then
    self.buff_hp_m = 0.8
    self:calculate_stats()
    self.hp = self.max_hp
  end

  if player and player.vulnerability then
    self.vulnerable = true
  end

  if player and player.temporal_chains then
    self.temporal_chains_mvspd_m = 0.8
  end

  self.usurer_count = 0
end


function Seeker:update(dt)
  self:update_game_object(dt)

  if main.current.mage_level == 2 then self.buff_def_a = -30
  elseif main.current.mage_level == 1 then self.buff_def_a = -15
  else self.buff_def_a = 0 end
  if self.headbutt_charging or self.headbutting then self.buff_def_m = 3 end

  if self.speed_boosting then
    local n = math.remap(love.timer.getTime() - self.speed_boosting, 0, (3 + 0.025*self.level + current_new_game_plus*0.1), 1, 0.5)
    self.speed_boosting_mvspd_m = (3 + 0.025*self.level + 0.1*current_new_game_plus)*n
    if not self.speed_booster and not self.exploder and not self.headbutter and not self.tank and not self.shooter and not self.spawner then
      self.color.r = math.remap(n, 1, 0.5, green[0].r, red[0].r)
      self.color.g = math.remap(n, 1, 0.5, green[0].g, red[0].g)
      self.color.b = math.remap(n, 1, 0.5, green[0].b, red[0].b)
    end
  else self.speed_boosting_mvspd_m = 1 end

  if self.slowed then self.slow_mvspd_m = self.slowed
  else self.slow_mvspd_m = 1 end

  self.buff_mvspd_m = (self.speed_boosting_mvspd_m or 1)*(self.slow_mvspd_m or 1)*(self.temporal_chains_mvspd_m or 1)*(self.tank and 0.35 or 1)

  self:calculate_stats()

  self.stun_dmg_m = (self.barbarian_stunned and 2 or 1)

  if self.shooter then
    self.t:set_every_multiplier('shooter', (1 - self.level*0.02))
  end

  if self.being_pushed then
    local v = math.length(self:get_velocity())
    if v < 25 then
      if self.push_invulnerable then self.push_invulnerable = false end
      self.being_pushed = false
      self.steering_enabled = true
      self.juggernaut_push = false
      self.launcher_push = false
      self:set_damping(0)
      self:set_angular_damping(0)
    end
  else
    if self.headbutt_charging or self.shooting then
      self:set_damping(10)
      self:rotate_towards_object(main.current.player, 0.5)
    elseif not self.headbutting then
      local player = main.current.player
      if self.boss then
        local enemies = main.current.main:get_objects_by_classes(main.current.enemies)
        local x, y = 0, 0
        if #enemies > 1 then
          for _, enemy in ipairs(enemies) do
            x = x + enemy.x
            y = y + enemy.y
          end
          x = x/#enemies
          y = y/#enemies
        else
          x, y = player.x, player.y
        end
        self:seek_point(x, y)
        self:wander(10, 250, 3)
      else
        self:seek_point(player.x, player.y)
        self:wander(50, 100, 20)
      end
      self:steering_separate(16, main.current.enemies)
      self:rotate_towards_velocity(0.5)
    end
  end
  self.r = self:get_angle()

  if self.area_sensor then self.area_sensor:move_to(self.x, self.y) end
end


function Seeker:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    if self.boss then
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.hfx.hit.f and fg[0] or self.color)
    else
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
    end
  graphics.pop()

  if self.px and self.py then
    if self.phidden then return end
    graphics.push(self.px, self.py, self.vr, self.spring.x, self.spring.x)
      graphics.circle(self.px, self.py, self.prs + random:float(-1, 1), yellow[0])
      graphics.circle(self.px, self.py, self.pull_sensor.rs, self.color_transparent)
      local lw = math.remap(self.pull_sensor.rs, 32, 256, 2, 4)
      for i = 1, 4 do graphics.arc('open', self.px, self.py, self.pull_sensor.rs, (i-1)*math.pi/2 + math.pi/4 - math.pi/8, (i-1)*math.pi/2 + math.pi/4 + math.pi/8, yellow[0], lw) end
    graphics.pop()
  end
end


function Seeker:on_collision_enter(other, contact)
  local x, y = contact:getPositions()

  if other:is(Wall) then
    self.hfx:use('hit', 0.15, 200, 10, 0.1)
    self:bounce(contact:getNormal())
    if self.juggernaut_push then
      self:hit(self.juggernaut_push)
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end

    if self.launcher_push then
      self:hit(self.launcher_push)
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end

    if main.current.player.heavy_impact then
      if self.being_pushed then
        self:hit(self.push_force)
      end
    end

    if self.headbutter and self.headbutting then
      self.headbutting = false
    end

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
      if other:is(Seeker) or other:is(Player) then self.headbutting = false end
    end
  
  elseif other:is(Turret) then
    self.headbutting = false
    _G[random:table{'player_hit1', 'player_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    self:hit(0)
    self:push(random:float(2.5, 7), other:angle_to_object(self))
  end
end


function Seeker:hit(damage, projectile)
  local pyrod = self.pyrod
  self.pyrod = false
  if self.dead then return end
  self.hfx:use('hit', 0.25, 200, 10)
  if self.push_invulnerable then return end
  self:show_hp()
  
  local actual_damage = math.max(self:calculate_damage(damage)*(self.stun_dmg_m or 1), 0)
  if self.vulnerable then actual_damage = actual_damage*1.2 end
  self.hp = self.hp - actual_damage
  if self.hp > self.max_hp then self.hp = self.max_hp end
  main.current.damage_dealt = main.current.damage_dealt + actual_damage

  if projectile and projectile.spawn_critters_on_hit then
    critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    trigger:after(0.01, function()
      for i = 1, projectile.spawn_critters_on_hit do
        Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 10, dmg = projectile.parent.dmg, parent = projectile.parent}
      end
    end)
  end

  if self.hp <= 0 then
    self.dead = true
    for i = 1, random:int(4, 6) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 12}:scale_down(0.3):change_color(0.5, self.color)
    _G[random:table{'enemy_die1', 'enemy_die2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.5}

    if main.current.mercenary_level > 0 then
      if random:bool((main.current.mercenary_level == 2 and 20) or (main.current.mercenary_level == 1 and 10) or 0) then
        trigger:after(0.01, function()
          Gold{group = main.current.main, x = self.x, y = self.y}
        end)
      end
    end

    if self.boss then
      slow(0.25, 1)
      magic_die1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    end

    if self.speed_booster then
      if self.silenced then return end
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
      if self.silenced then return end
      shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.4}
      trigger:after(0.01, function()
        local n = math.floor(8 + current_new_game_plus*1.5)
        for i = 1, n do
          EnemyProjectile{group = main.current.main, x = self.x, y = self.y, color = blue[0], r = (i-1)*math.pi/(n/2), v = 120 + 5*self.level, dmg = 1.5*self.dmg}
        end
      end)
    end

    if self.spawner then
      if self.silenced then return end
      critter1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      trigger:after(0.01, function()
        for i = 1, random:int(5, 8) do
          EnemyCritter{group = main.current.main, x = self.x, y = self.y, color = purple[0], r = random:float(0, 2*math.pi), v = 10 + 0.1*self.level, dmg = 2*self.dmg, projectile = projectile}
        end
      end)
    end

    if pyrod then
      trigger:after(0.01, function()
        Area{group = main.current.main, x = self.x, y = self.y, color = red[0], w = 32*pyrod.parent.area_size_m, r = random:float(0, 2*math.pi), dmg = pyrod.parent.area_dmg_m*pyrod.dmg,
          character = pyrod.character, level = pyrod.level, parent = pyrod.parent}
      end)
    end

    if projectile and projectile.spawn_critters_on_kill then
      trigger:after(0.01, function()
        critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        for i = 1, projectile.spawn_critters_on_kill do
          Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 5, dmg = projectile.parent.dmg, parent = projectile.parent}
        end
      end)
    end

    if self.infested then
      critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      trigger:after(0.01, function()
        if type(self.infested) == 'number' then
          for i = 1, self.infested do
            Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 10, dmg = self.infested_dmg, parent = self.infested_ref}
          end
        end
      end)
    end

    if self.jester_cursed then
      trigger:after(0.01, function()
        _G[random:table{'scout1', 'scout2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6}
        local r = random:float(0, 2*math.pi)
        for i = 1, 4 do
          local t = {group = main.current.main, x = self.x + 8*math.cos(r), y = self.y + 8*math.sin(r), v = 250, r = r, color = red[0], dmg = self.jester_ref.dmg,
            pierce = self.jester_lvl3 and 2 or 0, homing = self.jester_lvl3, character = self.jester_ref.character, parent = self.jester_ref}
          Projectile(table.merge(t, mods or {}))
          r = r + math.pi/2
        end
      end)
    end

    if self.bane_cursed then
      trigger:after(0.01, function()
        DotArea{group = main.current.effects, x = self.x, y = self.y, rs = (self.bane_ref.level == 3 and 2 or 1)*self.bane_ref.area_size_m*18, color = purple[0],
          dmg = self.bane_ref.area_dmg_m*self.bane_ref.dmg*(self.bane_ref.dot_dmg_m or 1), void_rift = true, duration = 1}
      end)
    end
  end
end


function Seeker:push(f, r, push_invulnerable)
  local n = 1
  if self.tank then n = 0.4 - 0.01*self.level end
  if self.boss then n = 0.1 end
  self.push_invulnerable = push_invulnerable
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


function Seeker:slow(amount, duration)
  self.slowed = amount
  self.t:after(duration, function() self.slowed = false end, 'slow')
end


function Seeker:curse(curse, duration, arg1, arg2, arg3)
  local curse_m = 1
  if main.current.curser_level == 2 then curse_m = 1.5
  elseif main.current.curser_level == 1 then curse_m = 1.25
  else curse_m = 1 end

  if main.current.player.whispers_of_doom then
    if not self.doom then self.doom = 0 end
    self.doom = self.doom + 1
    if self.doom == 4 then
      self.doom = 0
      self:hit(200)
      buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    end
  end

  buff1:play{pitch = random:float(0.65, 0.75), volume = 0.25}
  if curse == 'launcher' then
    self.t:after(duration*curse_m, function()
      self.launcher_push = arg1
      self.launcher = arg2
      self:push(random:float(50, 75)*self.launcher.knockback_m, random:table{0, math.pi, math.pi/2, -math.pi/2})
    end, 'launcher_curse')
  elseif curse == 'jester' then
    self.jester_cursed = true
    self.jester_lvl3 = arg1
    self.jester_ref = arg2
    self.t:after(duration*curse_m, function() self.jester_cursed = false end, 'jester_curse')
  elseif curse == 'bane' then
    self.bane_cursed = true
    self.bane_lvl3 = arg1
    self.bane_ref = arg2
    self.t:after(duration*curse_m, function() self.bane_cursed = false end, 'bane_curse')
  elseif curse == 'infestor' then
    self.infested = arg1
    self.infested_dmg = arg2
    self.infested_ref = arg3
    self.t:after(duration*curse_m, function() self.infested = false end, 'infestor_curse')
  elseif curse == 'silencer' then
    self.silenced = true
    self.t:after(duration*curse_m, function() self.silenced = false end, 'silencer_curse')
  elseif curse == 'usurer' then
    if arg1 then
      self.usurer_count = self.usurer_count + 1
      if self.usurer_count == 3 then
        usurer1:play{pitch = random:float(0.95, 1.05), volume = 1}
        rogue_crit1:play{pitch = random:float(0.95, 1.05), volume = 1}
        camera:shake(4, 0.4)
        self.usurer_count = 0
        self:hit(50*arg2.dmg)
      end
    end
  end
end


function Seeker:apply_dot(dmg, duration)
  self.t:every(0.25, function()
    hit2:play{pitch = random:float(0.8, 1.2), volume = 0.2}
    self:hit(dmg/4)
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 1 do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    for i = 1, 1 do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = purple[0]} end
  end, math.floor(duration/0.2))
end




EnemyCritter = Object:extend()
EnemyCritter:implement(GameObject)
EnemyCritter:implement(Physics)
EnemyCritter:implement(Unit)
function EnemyCritter:init(args)
  self:init_game_object(args)
  if tostring(self.x) == tostring(0/0) or tostring(self.y) == tostring(0/0) then self.dead = true; return end
  self:init_unit()
  self:set_as_rectangle(7, 4, 'dynamic', 'enemy_projectile')
  self:set_restitution(0.5)

  self.classes = {'enemy_critter'}
  self:calculate_stats(true)
  self:set_as_steerable(self.v, 400, math.pi, 1)
  self:push(args.v, args.r)
  self.invulnerable_to = args.projectile
  self.t:after(0.5, function() self.invulnerable_to = false end)
  self.usurer_count = 0
end


function EnemyCritter:update(dt)
  self:update_game_object(dt)

  if self.slowed then self.slow_mvspd_m = self.slowed
  else self.slow_mvspd_m = 1 end
  self.buff_mvspd_m = (self.speed_boosting_mvspd_m or 1)*(self.slow_mvspd_m or 1)*(self.temporal_chains_mvspd_m or 1)
  if not self.classes then return end
  self:calculate_stats()

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
  -- print(projectile == self.invulnerable_to)
  if projectile == self.invulnerable_to then return end
  self.hfx:use('hit', 0.25, 200, 10)
  self.hp = self.hp - math.max(damage, 0)
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


function EnemyCritter:speed_boost(duration)
  self.speed_boosting = love.timer.getTime()
  self.t:after(duration, function() self.speed_boosting = false end, 'speed_boost')
end


function EnemyCritter:slow(amount, duration)
  self.slowed = amount
  self.t:after(duration, function() self.slowed = false end, 'slow')
end


function EnemyCritter:curse(curse, duration, arg1, arg2, arg3)
  local curse_m = 1
  if main.current.curser_level == 2 then curse_m = 1.5
  elseif main.current.curser_level == 1 then curse_m = 1.25
  else curse_m = 1 end

  if main.current.player.whispers_of_doom then
    if not self.doom then self.doom = 0 end
    self.doom = self.doom + 1
    if self.doom == 4 then
      self.doom = 0
      self:hit(200)
      buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    end
  end

  if curse == 'launcher' then
    self.t:after(duration*curse_m, function()
      self.launcher_push = arg1
      self.launcher = arg2
      self:push(random:float(50, 75)*self.launcher.knockback_m, random:table{0, math.pi, math.pi/2, -math.pi/2})
    end, 'launcher_curse')
  elseif curse == 'jester' then
    self.jester_cursed = true
    self.jester_lvl3 = arg1
    self.jester_ref = arg2
    self.t:after(duration*curse_m, function() self.jester_cursed = false end, 'jester_curse')
  elseif curse == 'bane' then
    self.bane_cursed = true
    self.bane_lvl3 = arg1
    self.bane_ref = arg2
    self.t:after(duration*curse_m, function() self.bane_cursed = false end, 'bane_curse')
  elseif curse == 'infestor' then
    self.infested = arg1
    self.infested_dmg = arg2
    self.infested_ref = arg3
    self.t:after(duration*curse_m, function() self.infested = false end, 'infestor_curse')
  elseif curse == 'silencer' then
    self.silenced = true
    self.t:after(duration*curse_m, function() self.silenced = false end, 'silencer_curse')
  elseif curse == 'usurer' then
    if arg1 then
      self.usurer_count = self.usurer_count + 1
      if self.usurer_count == 3 then
        self.usurer_count = 0
        self:hit(10*arg2.dmg)
      end
    end
  end
end


function EnemyCritter:apply_dot(dmg, duration)
  self.t:every(0.25, function()
    hit2:play{pitch = random:float(0.8, 1.2), volume = 0.2}
    self:hit(dmg/4)
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 1 do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    for i = 1, 1 do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = purple[0]} end
  end, math.floor(duration/0.2))
end





EnemyProjectile = Object:extend()
EnemyProjectile:implement(GameObject)
EnemyProjectile:implement(Physics)
function EnemyProjectile:init(args)
  self:init_game_object(args)
  if tostring(self.x) == tostring(0/0) or tostring(self.y) == tostring(0/0) then self.dead = true; return end
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
