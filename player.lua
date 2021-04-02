Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
Player:implement(Unit)
function Player:init(args)
  self:init_game_object(args)
  self:init_unit()

  if self.character == 'vagrant' then
    self.color = character_colors.vagrant
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.vagrant

    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'swordsman' then
    self.color = character_colors.swordsman
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.swordsman

    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:cooldown(3, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      self:attack(96)
    end, nil, nil, 'attack')

  elseif self.character == 'wizard' then
    self.color = character_colors.wizard
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.wizard

    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'archer' then
    self.color = character_colors.archer
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.archer

    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {pierce = 1000})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'scout' then
    self.color = character_colors.scout
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.scout

    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {chain = 3})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'cleric' then
    self.color = character_colors.cleric
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.cleric

    self.last_heal_time = love.timer.getTime()
    self.t:every(2, function()
      local all_units = self:get_all_units()
      if table.any(all_units, function(v) return v.hp <= 0.5*v.max_hp end) and love.timer.getTime() - self.last_heal_time > 6 then
        self.last_heal_time = love.timer.getTime()
        for _, unit in ipairs(all_units) do unit:heal(0.1*unit.max_hp*(self.heal_effect_m or 1)) end
        heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      end
    end)

  elseif self.character == 'outlaw' then
    self.color = character_colors.outlaw
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.outlaw

    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(3, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'blade' then
    self.color = character_colors.blade
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.blade

    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:cooldown(4, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      self:shoot()
    end, nil, nil, 'shoot')

  elseif self.character == 'elementor' then
    self.color = character_colors.elementor
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.elementor

    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(7, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local enemy = self:get_random_object_in_shape(self.attack_sensor, main.current.enemies)
      if enemy then
        self:attack(128, {x = enemy.x, y = enemy.y})
      end
    end, nil, nil, 'attack')

  elseif self.character == 'saboteur' then
    self.color = character_colors.saboteur
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.saboteur

    self.t:every(8, function()
      self.t:every(0.25, function()
        SpawnEffect{group = main.current.effects, x = self.x, y = self.y, action = function(x, y)
          Saboteur{group = main.current.main, x = x, y = y, parent = self, conjurer_buff_m = self.conjurer_buff_m or 1}
        end}
      end, 2)
    end)

  elseif self.character == 'stormweaver' then
    self.color = character_colors.stormweaver
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.stormweaver

    self.t:every(8, function()
      stormweaver1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      local followers
      local leader = (self.leader and self) or self.parent
      if self.leader then followers = self.followers else followers = self.parent.followers end
      for _, f in ipairs(followers) do
        if f.character ~= 'swordsman' and f.character ~= 'cleric' and f.character ~= 'elementor' and f.character ~= 'saboteur' then
          f:chain_infuse(4)
        end
      end
    end)

  elseif self.character == 'sage' then
    self.color = character_colors.sage
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.sage

    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(12, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end)

  elseif self.character == 'squire' then
    self.color = character_colors.squire
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.squire

  elseif self.character == 'cannoneer' then
    self.color = character_colors.cannoneer
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.cannoneer

    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(6, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'dual_gunner' then
    self.color = character_colors.dual_gunner
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.dual_gunner

    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'hunter' then
    self.color = character_colors.hunter
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.hunter

    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'chronomancer' then
    self.color = character_colors.chronomancer
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.chronomancer

  elseif self.character == 'spellblade' then
    self.color = character_colors.spellblade
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.spellblade

    self.t:every(2, function()
      self:shoot(random:float(0, 2*math.pi))
    end, nil, nil, 'shoot')

  elseif self.character == 'psykeeper' then
    self.color = character_colors.psykeeper
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.psykeeper

  elseif self.character == 'engineer' then
    self.color = character_colors.engineer
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.engineer

    self.t:every(8, function()
      SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = orange[0], action = function(x, y)
        Turret{group = main.current.main, x = x, y = y, parent = self}
      end}
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

  if self.character == 'squire' then
    local all_units = self:get_all_units()
    for _, unit in ipairs(all_units) do
      unit.squire_dmg_m = 1 + 0.05*self.level
      unit.squire_def_m = 1 + 0.05*self.level
    end
  elseif self.character == 'chronomancer' then
    local all_units = self:get_all_units()
    for _, unit in ipairs(all_units) do
      unit.chronomancer_aspd_m = 1 + 0.10*self.level
    end
  end

  if table.any(self.classes, function(v) return v == 'ranger' end) then
    if main.current.ranger_level == 2 then self.chance_to_barrage = 20
    elseif main.current.ranger_level == 1 then self.chance_to_barrage = 10
    elseif main.current.ranger_level == 0 then self.chance_to_barrage = 0 end
  end

  if table.any(self.classes, function(v) return v == 'warrior' end) then
    if main.current.warrior_level == 2 then self.warrior_def_a = 50
    elseif main.current.warrior_level == 1 then self.warrior_def_a = 25
    elseif main.current.warrior_level == 0 then self.warrior_def_a = 0 end
  end

  if table.any(self.classes, function(v) return v == 'healer' end) then
    if main.current.healer_level == 1 then self.heal_effect_m = 1.25
    else self.heal_effect_m = 1 end
  end

  if table.any(self.classes, function(v) return v == 'nuker' end) then
    if main.current.nuker_level == 2 then self.nuker_area_size_m = 1.25; self.nuker_area_dmg_m = 1.25
    elseif main.current.nuker_level == 1 then self.nuker_area_size_m = 1.15; self.nuker_area_dmg_m = 1.15
    elseif main.current.nuker_level == 0 then self.nuker_area_size_m = 1; self.nuker_area_dmg_m = 1 end
  end

  if table.any(self.classes, function(v) return v == 'conjurer' end) then
    if main.current.conjurer_level == 1 then self.conjurer_buff_m = 1.25
    else self.conjurer_buff_m = 1 end
  end

  if table.any(self.classes, function(v) return v == 'rogue' end) then
    if main.current.rogue_level == 2 then self.chance_to_crit = 20
    elseif main.current.rogue_level == 1 then self.chance_to_crit = 10
    elseif main.current.rogue_level == 0 then self.chance_to_crit = 0 end
  end

  if table.any(self.classes, function(v) return v == 'enchanter' end) then
    if main.current.enchanter_level == 1 then self.enchanter_dmg_m = 1.25
    else self.enchanter_dmg_m = 1 end
  end

  self.buff_def_a = (self.warrior_def_a or 0)
  self.buff_aspd_m = (self.chronomancer_aspd_m or 1)
  self.buff_dmg_m = (self.squire_dmg_m or 1)*(main.current.enchanter_dmg_m or 1)
  self.buff_def_m = (self.squire_def_m or 1)
  self.buff_area_size_m = (self.nuker_area_size_m or 1)
  self.buff_area_dmg_m = (self.nuker_area_dmg_m or 1)
  self:calculate_stats()

  if self.attack_sensor then self.attack_sensor:move_to(self.x, self.y) end
  self.t:set_every_multiplier('shoot', self.aspd_m)
  self.t:set_every_multiplier('attack', self.aspd_m)


  if self.leader then
    if input.move_left.down then self.r = self.r - 1.66*math.pi*dt end
    if input.move_right.down then self.r = self.r + 1.66*math.pi*dt end
    self:set_velocity(self.v*math.cos(self.r), self.v*math.sin(self.r))

    if not main.current.won then
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

    self:set_angle(self.r)

  else
    local target_distance = 10.4*(self.follower_index or 0)
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
end


function Player:on_collision_enter(other, contact)
  local x, y = contact:getPositions()

  if other:is(Wall) then
    if self.leader then
      if other.snkrx then
        main.current.level_1000_text:pull(0.2, 200, 10)
      end
      self.hfx:use('hit', 0.5, 200, 10, 0.1)
      camera:spring_shake(2, math.pi - self.r)
      self:bounce(contact:getNormal())
      local r = random:float(0.9, 1.1)
      player_hit_wall1:play{pitch = r, volume = 0.1}
      pop1:play{pitch = r, volume = 0.2}

      for i, f in ipairs(self.followers) do
        trigger:after(i*(10.6/self.v), function()
          f.hfx:use('hit', 0.5, 200, 10, 0.1)
          player_hit_wall1:play{pitch = r + 0.025*i, volume = 0.1}
          pop1:play{pitch = r + 0.05*i, volume = 0.2}
        end)
      end
    end

  elseif table.any(main.current.enemies, function(v) return other:is(v) end) then
    other:push(random:float(25, 35), self:angle_to_object(other))
    if self.character == 'vagrant' or self.character == 'psykeeper' then other:hit(2*self.dmg)
    else other:hit(self.dmg) end
    if other.headbutting then
      self:hit((4 + math.floor(other.level/3))*other.dmg)
    else self:hit(other.dmg) end
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
  main.current.damage_taken = main.current.damage_taken + actual_damage

  local psykeeper = self:get_unit'psykeeper'
  if psykeeper then
    psykeeper.stored_heal = psykeeper.stored_heal + actual_damage
    if psykeeper.stored_heal > (0.1*self.level*psykeeper.max_hp) then
      local all_units = self:get_all_units()
      for _, unit in ipairs(all_units) do
        unit:heal(psykeeper.stored_heal*(self.heal_effect_m or 1))
      end
      psykeeper.stored_heal = 0
      heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    end
  end

  if self.hp <= 0 then
    hit4:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    slow(0.25, 1)
    self.dead = true
    for i = 1, random:int(4, 6) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 12}:scale_down(0.3):change_color(0.5, self.color)
    if self.leader and #self.followers == 0 then
      main.current:die()
    else
      if self.leader then self:recalculate_followers()
      else self.parent:recalculate_followers() end
    end
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


function Player:chain_infuse(duration)
  self.chain_infused = true
  self.t:after(duration or 2, function() self.chain_infused = false end, 'chain_infuse')
end


function Player:get_all_units()
  local followers
  local leader = (self.leader and self) or self.parent
  if self.leader then followers = self.followers else followers = self.parent.followers end
  return {leader, unpack(followers)}
end


function Player:get_unit(character)
  local all_units = self:get_all_units()
  for _, unit in ipairs(all_units) do
    if unit.character == character then return unit end
  end
end


function Player:recalculate_followers()
  if self.dead then
    local new_leader = table.remove(self.followers, 1)
    new_leader.leader = true
    new_leader.previous_positions = {}
    new_leader.followers = self.followers
    new_leader.t:every(0.01, function()
      table.insert(new_leader.previous_positions, 1, {x = new_leader.x, y = new_leader.y, r = new_leader.r})
      if #new_leader.previous_positions > 256 then new_leader.previous_positions[257] = nil end
    end)
    main.current.player = new_leader
    for i, follower in ipairs(self.followers) do
      follower.parent = new_leader
      follower.follower_index = i
    end
  else
    for i = #self.followers, 1, -1 do
      if self.followers[i].dead then
        table.remove(self.followers, i)
        break
      end
    end
    for i, follower in ipairs(self.followers) do
      follower.follower_index = i
    end
  end
end


function Player:add_follower(unit)
  table.insert(self.followers, unit)
  unit.parent = self
  unit.follower_index = #self.followers
end


function Player:shoot(r, mods)
  mods = mods or {}
  camera:spring_shake(2, r)
  self.hfx:use('shoot', 0.25)

  local dmg_m = 1
  local crit = false
  if self.chance_to_crit and random:bool(self.chance_to_crit) then dmg_m = 4; crit = true end

  if self.character == 'outlaw' then
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
    r = r - 2*math.pi/8
    for i = 1, 5 do
      local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character,
      parent = self}
      Projectile(table.merge(t, mods or {}))
      r = r + math.pi/8
    end

  elseif self.character == 'blade' then
    local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies)
    if enemies and #enemies > 0 then
      for _, enemy in ipairs(enemies) do
        local r = self:angle_to_object(enemy)
        HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
        local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character,
        parent = self}
        Projectile(table.merge(t, mods or {}))
      end
    end

  elseif self.character == 'sage' then
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
    local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 25, r = r, color = self.color, dmg = self.dmg, pierce = 1000, character = 'sage', parent = self}
    Projectile(table.merge(t, mods or {}))

  elseif self.character == 'dual_gunner' then
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r) + 4*math.cos(r - math.pi/2), y = self.y + 0.8*self.shape.w*math.sin(r) + 4*math.sin(r - math.pi/2), rs = 6}
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r) + 4*math.cos(r + math.pi/2), y = self.y + 0.8*self.shape.w*math.sin(r) + 4*math.sin(r + math.pi/2), rs = 6}
    local t1 = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r) + 4*math.cos(r - math.pi/2) , y = self.y + 1.6*self.shape.w*math.sin(r) + 4*math.sin(r - math.pi/2),
    v = 250, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character, parent = self}
    local t2 = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r) + 4*math.cos(r + math.pi/2) , y = self.y + 1.6*self.shape.w*math.sin(r) + 4*math.sin(r + math.pi/2),
    v = 250, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character, parent = self}
    Projectile(table.merge(t1, mods or {}))
    Projectile(table.merge(t2, mods or {}))

  else
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
    local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character,
    parent = self}
    Projectile(table.merge(t, mods or {}))
  end

  if self.character == 'vagrant' or self.character == 'dual_gunner' then
    shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.2}
  elseif self.character == 'archer' or self.character == 'hunter' then
    archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
  elseif self.character == 'wizard' then
    wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
  elseif self.character == 'scout' or self.character == 'outlaw' or self.character == 'blade' or self.character == 'spellblade' then
    _G[random:table{'scout1', 'scout2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    if self.character == 'spellblade' then
      wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
    end
  elseif self.character == 'cannoneer' then
    _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  end

  if self.chance_to_barrage and random:bool(self.chance_to_barrage) then
    self:barrage(r, 4)
  end
end


function Player:attack(area, mods)
  mods = mods or {}
  camera:shake(2, 0.5)
  self.hfx:use('shoot', 0.25)
  local t = {group = main.current.effects, x = mods.x or self.x, y = mods.y or self.y, r = self.r, w = self.area_size_m*(area or 64), color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character}
  Area(table.merge(t, mods))

  if self.character == 'swordsman' then
    _G[random:table{'swordsman1', 'swordsman2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.75}
  elseif self.character == 'elementor' then
    elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
  end
end


function Player:barrage(r, n)
  n = n or 8
  for i = 1, n do
    self.t:after((i-1)*0.075, function()
      archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
      local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r + random:float(-math.pi/16, math.pi/16), color = self.color, dmg = self.dmg,
      parent = self, character = 'barrage'}
      Projectile(table.merge(t, mods or {}))
    end)
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
  self.infused_enemies_hit = {}

  if self.character == 'sage' then
    self.dmg = 0
    self.pull_sensor = Circle(self.x, self.y, 64*self.parent.area_size_m)
    self.rs = 0
    self.t:tween(0.05, self, {rs = self.shape.w/2.5}, math.cubic_in_out, function() self.spring:pull(0.15) end)
    self.t:after(4, function()
      self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self:die() end)
    end)

    self.color_transparent = Color(args.color.r, args.color.g, args.color.b, 0.08)
    self.t:every(0.08, function()
      HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color}
    end)
    self.vr = 0
    self.dvr = random:float(-math.pi/4, math.pi/4)

  elseif self.character == 'spellblade' then
    self.pierce = 1000
    self.orbit_r = 0
    self.orbit_vr = 8*math.pi
    self.t:tween(6.25, self, {orbit_vr = math.pi}, math.expo_out, function()
      self.t:tween(12.25, self, {orbit_vr = 0}, math.linear)
    end)
  end
end


function Projectile:update(dt)
  self:update_game_object(dt)

  if self.character == 'spellblade' then
    self.orbit_r = self.orbit_r + self.orbit_vr*dt
  end

  self:set_angle(self.r)
  self:move_along_angle(self.v, self.r + (self.orbit_r or 0))

  if self.character == 'sage' then
    self.pull_sensor:move_to(self.x, self.y)
    local enemies = self:get_objects_in_shape(self.pull_sensor, main.current.enemies)
    for _, enemy in ipairs(enemies) do
      enemy:apply_steering_force(math.remap(self:distance_to_object(enemy), 0, 100, 250, 50), enemy:angle_to_object(self))
    end
    self.vr = self.vr + self.dvr*dt
  end
end


function Projectile:draw()
  if self.character == 'sage' then
    if self.hidden then return end

    graphics.push(self.x, self.y, self.r + self.vr, self.spring.x, self.spring.x)
      graphics.circle(self.x, self.y, self.rs + random:float(-1, 1), self.color)
      graphics.circle(self.x, self.y, self.pull_sensor.rs, self.color_transparent)
      local lw = math.remap(self.pull_sensor.rs, 32, 256, 2, 4)
      for i = 1, 4 do graphics.arc('open', self.x, self.y, self.pull_sensor.rs, (i-1)*math.pi/2 + math.pi/4 - math.pi/8, (i-1)*math.pi/2 + math.pi/4 + math.pi/8, self.color, lw) end
    graphics.pop()

  else
    graphics.push(self.x, self.y, self.r + (self.orbit_r or 0))
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.color)
    graphics.pop()
  end
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
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*32, color = self.color, dmg = self.parent.area_dmg_m*self.dmg, character = self.character}
  elseif self.character == 'blade' then
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*64, color = self.color, dmg = self.parent.area_dmg_m*self.dmg, character = self.character}
  elseif self.character == 'cannoneer' then
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*96, color = self.color, dmg = 2*self.parent.area_dmg_m*self.dmg, character = self.character}
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
    if self.character == 'archer' or self.character == 'hunter' or self.character == 'barrage' then
      self:die(x, y, r, 0)
      _G[random:table{'arrow_hit_wall1', 'arrow_hit_wall2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.2}
      WallArrow{group = main.current.main, x = x, y = y, r = self.r, color = self.color}
    elseif self.character == 'scout' or self.character == 'outlaw' or self.character == 'blade' or self.character == 'spellblade' then
      self:die(x, y, r, 0)
      knife_hit_wall1:play{pitch = random:float(0.9, 1.1), volume = 0.2}
      local r = Unit.bounce(self, nx, ny)
      trigger:after(0.01, function()
        WallKnife{group = main.current.main, x = x, y = y, r = r, v = self.v*0.1, color = self.color}
      end)
      if self.character == 'spellblade' then
        magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
      end
    elseif self.character == 'wizard' then
      self:die(x, y, r, random:int(2, 3))
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
    elseif self.character == 'cannoneer' then
      self:die(x, y, r, random:int(2, 3))
      cannon_hit_wall1:play{pitch = random:float(0.95, 1.05), volume = 0.1}
    elseif self.character == 'engineer' then
      self:die(x, y, r, random:int(2, 3))
      _G[random:table{'turret_hit_wall1', 'turret_hit_wall2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.2}
    else
      self:die(x, y, r, random:int(2, 3))
      proj_hit_wall1:play{pitch = random:float(0.9, 1.1), volume = 0.2}
    end
  end
end


function Projectile:on_trigger_enter(other, contact)
  if self.character == 'sage' then return end

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

    if self.character == 'archer' or self.character == 'scout' or self.character == 'outlaw' or self.character == 'blade' or self.character == 'hunter' or self.character == 'spellblade' or self.character == 'engineer' then
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      if self.character == 'spellblade' then
        magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
      end
    elseif self.character == 'wizard' then
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
    else
      hit3:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end

    other:hit(self.dmg)

    if self.character == 'hunter' and random:bool(40) then
      trigger:after(0.01, function()
        SpawnEffect{group = main.current.effects, x = self.parent.x, y = self.parent.y, color = orange[0], action = function(x, y)
          Pet{group = main.current.main, x = x, y = y, r = self.parent:angle_to_object(other), v = 150, parent = self.parent, conjurer_buff_m = self.conjurer_buff_m or 1}
        end}
      end)
    end

    if self.parent.chain_infused then
      local src = other
      for i = 1, 2 do
        _G[random:table{'spark1', 'spark2', 'spark3'}]:play{pitch = random:float(0.9, 1.1), volume = 0.3}
        table.insert(self.infused_enemies_hit, src)
        local dst = src:get_random_object_in_shape(Circle(src.x, src.y, 64), main.current.enemies, self.infused_enemies_hit)
        if dst then
          dst:hit(self.dmg/(i+1))
          LightningLine{group = main.current.effects, src = src, dst = dst}
          src = dst 
        end
      end
    end

    if self.crit then
      camera:shake(5, 0.25)
      rogue_crit1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      rogue_crit2:play{pitch = random:float(0.95, 1.05), volume = 0.15}
      for i = 1, 3 do HitParticle{group = main.current.effects, x = other.x, y = other.y, color = self.color, v = random:float(100, 400)} end
      for i = 1, 3 do HitParticle{group = main.current.effects, x = other.x, y = other.y, color = other.color, v = random:float(100, 400)} end
      HitCircle{group = main.current.effects, x = other.x, y = other.y, rs = 12, color = fg[0], duration = 0.3}:scale_down():change_color(0.5, self.color)
    end
  end
end




Area = Object:extend()
Area:implement(GameObject)
function Area:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 1.5*self.w, 1.5*self.w, self.r)
  local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
  for _, enemy in ipairs(enemies) do
    if self.character == 'elementor' then
      enemy:hit(2*self.dmg)
    else
      enemy:hit(self.dmg)
    end
    HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 2 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
    for i = 1, 2 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
    if self.character == 'wizard' or self.character == 'elementor' then
      magic_hit1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    elseif self.character == 'swordsman' then
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    elseif self.character == 'blade' then
      blade_hit1:play{pitch = random:float(0.9, 1.1), volume = 0.35}
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.2}
    elseif self.character == 'saboteur' then
      _G[random:table{'saboteur_hit1', 'saboteur_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.2}
    elseif self.character == 'cannoneer' then
      _G[random:table{'saboteur_hit1', 'saboteur_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.075}
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
  local lw = math.remap(w, 32, 256, 2, 4)
  graphics.polyline(self.color, lw, x1, y1 + w10, x1, y1, x1 + w10, y1)
  graphics.polyline(self.color, lw, x2 - w10, y1, x2, y1, x2, y1 + w10)
  graphics.polyline(self.color, lw, x2 - w10, y2, x2, y2, x2, y2 - w10)
  graphics.polyline(self.color, lw, x1, y2 - w10, x1, y2, x1 + w10, y2)
  graphics.rectangle((x1+x2)/2, (y1+y2)/2, x2-x1, y2-y1, nil, nil, self.color_transparent)
  graphics.pop()
end




Turret = Object:extend()
Turret:implement(GameObject)
Turret:implement(Physics)
function Turret:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(14, 6, 'static', 'player')
  self:set_restitution(0.5)
  self.hfx:add('hit', 1)
  self.color = orange[0]
  self.attack_sensor = Circle(self.x, self.y, 256)
  turret_deploy:play{pitch = 1.2, volume = 0.2}
  
  self.t:every({3.5, 4.5}, function()
    self.t:every({0.1, 0.2}, function()
      self.hfx:use('hit', 0.25, 200, 10)
      HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(self.r), y = self.y + 0.8*self.shape.w*math.sin(self.r), rs = 6}
      local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(self.r), y = self.y + 1.6*self.shape.w*math.sin(self.r), v = 200, r = self.r, color = self.color,
      dmg = self.parent.dmg*(self.parent.conjurer_buff_m or 1), character = self.parent.character, parent = self.parent}
      Projectile(table.merge(t, mods or {}))
      turret1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      turret2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end, 3)
  end)

  self.t:after(24*(self.parent.conjurer_buff_m or 1), function()
    local n = n or random:int(3, 4)
    for i = 1, n do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y}:scale_down()
    self.dead = true
  end)
end


function Turret:update(dt)
  self:update_game_object(dt)

  local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
  if closest_enemy then
    self:rotate_towards_object(closest_enemy, 0.2)
    self.r = self:get_angle()
  end
end


function Turret:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end




Pet = Object:extend()
Pet:implement(GameObject)
Pet:implement(Physics)
function Pet:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(8, 8, 'dynamic', 'projectile')
  self:set_restitution(0.5)
  self.hfx:add('hit', 1)
  self.color = character_colors.hunter
  self.pierce = 6
  pet1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
end


function Pet:update(dt)
  self:update_game_object(dt)

  self:set_angle(self.r)
  self:move_along_angle(self.v, self.r)
end


function Pet:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function Pet:on_collision_enter(other, contact)
  local x, y = contact:getPositions()
  local nx, ny = contact:getNormal()
  local r = 0
  if nx == 0 and ny == -1 then r = -math.pi/2
  elseif nx == 0 and ny == 1 then r = math.pi/2
  elseif nx == -1 and ny == 0 then r = math.pi
  else r = 0 end

  if other:is(Wall) then
    local n = n or random:int(3, 4)
    for i = 1, n do HitParticle{group = main.current.effects, x = x, y = y, r = random:float(0, 2*math.pi), color = self.color} end
    HitCircle{group = main.current.effects, x = x, y = y}:scale_down()
    self.dead = true
    hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
  end
end


function Pet:on_trigger_enter(other)
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    if self.pierce <= 0 then
      camera:shake(2, 0.5)
      other:hit(self.parent.dmg*(self.conjurer_buff_m or 1))
      other:push(35, self:angle_to_object(other))
      self.dead = true
      local n = random:int(3, 4)
      for i = 1, n do HitParticle{group = main.current.effects, x = x, y = y, r = random:float(0, 2*math.pi), color = self.color} end
      HitCircle{group = main.current.effects, x = x, y = y}:scale_down()
    else
      camera:shake(2, 0.5)
      other:hit(self.parent.dmg*(self.conjurer_buff_m or 1))
      other:push(35, self:angle_to_object(other))
      self.pierce = self.pierce - 1
    end
    self.hfx:use('hit', 0.25)
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = fg[0], duration = 0.1}
    HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color}
    HitParticle{group = main.current.effects, x = self.x, y = self.y, color = other.color}
  end
end




Saboteur = Object:extend()
Saboteur:implement(GameObject)
Saboteur:implement(Physics)
Saboteur:implement(Unit)
function Saboteur:init(args)
  self:init_game_object(args)
  self:init_unit()
  self:set_as_rectangle(8, 8, 'dynamic', 'player')
  self:set_restitution(0.5)
  
  self.color = character_colors.saboteur
  self.character = 'saboteur'
  self.classes = character_classes.saboteur
  self:calculate_stats(true)
  self:set_as_steerable(self.v, 2000, 4*math.pi, 4)

  _G[random:table{'saboteur1', 'saboteur2', 'saboteur3'}]:play{pitch = random:float(0.8, 1.2), volume = 0.2}
  self.target = random:table(self.group:get_objects_by_classes(main.current.enemies))
end


function Saboteur:update(dt)
  self:update_game_object(dt)
  self:calculate_stats()

  if not self.target then self.target = random:table(self.group:get_objects_by_classes(main.current.enemies)) end
  if not self.target then return end
  if self.target.dead then self.target = random:table(self.group:get_objects_by_classes(main.current.enemies)) end
  if not self.target then return end

  self:seek_point(self.target.x, self.target.y)
  self:rotate_towards_velocity(0.5)
  self.r = self:get_angle()
end


function Saboteur:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function Saboteur:on_collision_enter(other, contact)
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    camera:shake(4, 0.5)
    local t = {group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.area_size_m*64, color = self.color, dmg = self.area_dmg_m*self.dmg*(self.conjurer_buff_m or 1), character = self.character}
    Area(table.merge(t, mods or {}))
    self.dead = true
  end
end
