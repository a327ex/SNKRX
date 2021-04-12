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
        self:shoot(self:angle_to_object(closest_enemy), {chain = (self.level == 3 and 5 or 0)})
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
        self:shoot(self:angle_to_object(closest_enemy), {pierce = 1000, ricochet = (self.level == 3 and 3 or 0)})
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
        self:shoot(self:angle_to_object(closest_enemy), {chain = (self.level == 3 and 6 or 3)})
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
      local unit_index = table.contains(all_units, function(v) return v.hp <= 0.5*v.max_hp end)
      if unit_index and love.timer.getTime() - self.last_heal_time > 6 then
        local unit = all_units[unit_index]
        self.last_heal_time = love.timer.getTime()
        if self.level == 3 then
          for _, unit in ipairs(all_units) do unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1)) end
        else
          unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1))
        end
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
        self:shoot(self:angle_to_object(closest_enemy), {homing = (self.level == 3)})
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
          Saboteur{group = main.current.main, x = x, y = y, parent = self, level = self.level, conjurer_buff_m = self.conjurer_buff_m or 1, crit = (self.level == 3) and random:bool(50)}
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
      local units = self:get_all_units()
      for _, unit in ipairs(units) do
        unit:chain_infuse(4)
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

    self.dg_counter = 0
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.gun_kata_sensor = Circle(self.x, self.y, 160)
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

    if self.level == 3 then
      main.current.chronomancer_dot = 0.5
    end

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
    self.stored_heal = 0
    self.last_heal_time = love.timer.getTime()

  elseif self.character == 'engineer' then
    self.color = character_colors.engineer
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.engineer

    self.turret_counter = 0
    self.t:every(8, function()
      SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = orange[0], action = function(x, y)
        Turret{group = main.current.main, x = x, y = y, parent = self}
      end}
      self.turret_counter = self.turret_counter + 1
      if self.turret_counter == 3 then
        self.turret_counter = 0
        local turrets = main.current.main:get_objects_by_class(Turret)
        buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        for _, turret in ipairs(turrets) do
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = orange[0], duration = 0.1}
          LightningLine{group = main.current.effects, src = self, dst = turret, color = orange[0]}
          turret:upgrade()
        end
      end
    end)

  elseif self.character == 'plague_doctor' then
    self.color = character_colors.plague_doctor
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.plague_doctor
    
    self.t:every(5, function()
      self:dot_attack(24, {duration = 12})
    end)

    if self.level == 3 then
      self.t:after(0.01, function()
        self.dot_area = DotArea{group = main.current.effects, x = self.x, y = self.y, rs = self.area_size_m*48, color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self}
      end)
    end

  elseif self.character == 'barbarian' then
    self.color = character_colors.barbarian
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.barbarian

    self.t:every(8, function()
      self:attack(96, {stun = 4})
    end)

  elseif self.character == 'juggernaut' then
    self.color = character_colors.juggernaut
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.juggernaut

    self.t:every(8, function()
      self:attack(64, {juggernaut_push = true})
    end)

  elseif self.character == 'lich' then
    self.color = character_colors.lich
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.lich

    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(4, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {chain = (self.level == 3 and 14 or 7), v = 70})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'cryomancer' then
    self.color = character_colors.cryomancer
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.cryomancer
    
    self.t:after(0.01, function()
      self.dot_area = DotArea{group = main.current.effects, x = self.x, y = self.y, rs = self.area_size_m*48, color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self}
    end)

  elseif self.character == 'pyromancer' then
    self.color = character_colors.pyromancer
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.pyromancer
    
    self.t:after(0.01, function()
      self.dot_area = DotArea{group = main.current.effects, x = self.x, y = self.y, rs = self.area_size_m*48, color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self}
    end)

  elseif self.character == 'corruptor' then
    self.color = character_colors.corruptor
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.corruptor

    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {spawn_critters_on_kill = 3, spawn_critters_on_hit = (self.level == 3 and 3 or 0)})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'beastmaster' then
    self.color = character_colors.beastmaster
    self:set_as_rectangle(9, 9, 'dynamic', 'player')
    self.visual_shape = 'rectangle'
    self.classes = character_classes.beastmaster

    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {spawn_critters_on_crit = 2})
      end
    end, nil, nil, 'shoot')
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
      unit.squire_dmg_m = 1.15
      unit.squire_def_m = 1.15
    end
  elseif self.character == 'chronomancer' then
    local all_units = self:get_all_units()
    for _, unit in ipairs(all_units) do
      unit.chronomancer_aspd_m = 1.2
    end
  end

  if self.character == 'vagrant' and self.level == 3 then
    local class_levels = get_class_levels(self:get_all_units())
    local number_of_active_sets = 0
    if class_levels.ranger >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.warrior >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.mage >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.rogue >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.healer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.conjurer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.enchanter >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.psyker >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.curser >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.forcer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.swarmer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.voider >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    self.vagrant_dmg_m = 1 + 0.1*number_of_active_sets
    self.vagrant_aspd_m = 1 + 0.05*number_of_active_sets
  end

  if self.character == 'swordsman' and self.level == 3 then
    self.swordsman_dmg_m = 2
  end

  if self.character == 'outlaw' and self.level == 3 then
    self.outlaw_aspd_m = 1.5
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
  self.buff_aspd_m = (self.chronomancer_aspd_m or 1)*(self.vagrant_aspd_m or 1)*(self.outlaw_aspd_m or 1)
  self.buff_dmg_m = (self.squire_dmg_m or 1)*(self.vagrant_dmg_m or 1)*(main.current.enchanter_dmg_m or 1)*(self.swordsman_dmg_m or 1)
  self.buff_def_m = (self.squire_def_m or 1)
  self.buff_area_size_m = (self.nuker_area_size_m or 1)
  self.buff_area_dmg_m = (self.nuker_area_dmg_m or 1)
  self:calculate_stats()

  if self.attack_sensor then self.attack_sensor:move_to(self.x, self.y) end
  if self.gun_kata_sensor then self.gun_kata_sensor:move_to(self.x, self.y) end
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

  if self.character == 'beastmaster' and self.level == 3 then
    critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    trigger:after(0.01, function()
      for i = 1, 2 do
        Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 20, dmg = self.dmg}
      end
    end)
  end

  local psykeeper = self:get_unit'psykeeper'
  if psykeeper then
    psykeeper.stored_heal = psykeeper.stored_heal + actual_damage
    if psykeeper.stored_heal > (0.5*psykeeper.max_hp) and love.timer.getTime() - self.last_heal_time > 6 then
      self.last_heal_time = love.timer.getTime()
      local all_units = self:get_all_units()
      for _, unit in ipairs(all_units) do
        unit:heal(psykeeper.stored_heal*(self.heal_effect_m or 1)/#all_units)
      end
      if self.level == 3 then
        buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        local enemies = main.current.main:get_objects_by_classes(main.current.enemies)
        for _, enemy in ipairs(enemies) do
          enemy:hit(2*psykeeper.stored_heal/#enemies)
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = fg[0], duration = 0.1}
          LightningLine{group = main.current.effects, src = self, dst = enemy, color = fg[0]}
        end
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

    if self.dot_area then self.dot_area.dead = true; self.dot_area = nil end
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
  print(crit, mods.spawn_critters_on_crit, self.chance_to_crit)

  if crit and mods.spawn_critters_on_crit then
    critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    trigger:after(0.01, function()
      for i = 1, mods.spawn_critters_on_crit do
        Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 10, dmg = self.dmg}
      end
    end)
  end

  if self.character == 'outlaw' then
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
    r = r - 2*math.pi/8
    for i = 1, 5 do
      local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character,
        parent = self, level = self.level}
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
          parent = self, level = self.level}
        Projectile(table.merge(t, mods or {}))
      end
    end

  elseif self.character == 'sage' then
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
    local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 25, r = r, color = self.color, dmg = self.dmg, pierce = 1000, character = 'sage',
      parent = self, level = self.level}
    Projectile(table.merge(t, mods or {}))

  elseif self.character == 'dual_gunner' then
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r) + 4*math.cos(r - math.pi/2), y = self.y + 0.8*self.shape.w*math.sin(r) + 4*math.sin(r - math.pi/2), rs = 6}
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r) + 4*math.cos(r + math.pi/2), y = self.y + 0.8*self.shape.w*math.sin(r) + 4*math.sin(r + math.pi/2), rs = 6}
    local t1 = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r) + 4*math.cos(r - math.pi/2) , y = self.y + 1.6*self.shape.w*math.sin(r) + 4*math.sin(r - math.pi/2),
    v = 300, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character, parent = self, level = self.level}
    local t2 = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r) + 4*math.cos(r + math.pi/2) , y = self.y + 1.6*self.shape.w*math.sin(r) + 4*math.sin(r + math.pi/2),
    v = 300, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character, parent = self, level = self.level}
    Projectile(table.merge(t1, mods or {}))
    Projectile(table.merge(t2, mods or {}))
    self.dg_counter = self.dg_counter + 1
    if self.dg_counter == 5 then
      self.dg_counter = 0
      self.t:every(0.1, function()
        local random_enemy = self:get_random_object_in_shape(self.attack_sensor, main.current.enemies)
        if random_enemy then
          _G[random:table{'gun_kata1', 'gun_kata2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
          camera:spring_shake(2, r)
          self.hfx:use('shoot', 0.25)
          local r = self:angle_to_object(random_enemy)
          HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r) + 4*math.cos(r - math.pi/2), y = self.y + 0.8*self.shape.w*math.sin(r) + 4*math.sin(r - math.pi/2), rs = 6}
          local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 300, r = r, color = self.color, dmg = self.dmg, character = self.character,
            parent = self, level = self.level}
          Projectile(table.merge(t, mods or {}))
        end
      end, 20)
    end
  else
    HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
    local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.color, dmg = self.dmg*dmg_m, crit = crit, character = self.character,
    parent = self, level = self.level}
    Projectile(table.merge(t, mods or {}))
  end

  if self.character == 'vagrant' then
    shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.2}
  elseif self.character == 'dual_gunner' then
    dual_gunner1:play{pitch = random:float(0.95, 1.05), volume = 0.3}
    dual_gunner2:play{pitch = random:float(0.95, 1.05), volume = 0.3}
  elseif self.character == 'archer' or self.character == 'hunter' then
    archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
  elseif self.character == 'wizard' or self.character == 'lich' then
    wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
  elseif self.character == 'scout' or self.character == 'outlaw' or self.character == 'blade' or self.character == 'spellblade' then
    _G[random:table{'scout1', 'scout2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    if self.character == 'spellblade' then
      wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
    end
  elseif self.character == 'cannoneer' then
    _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  end

  if self.character == 'lich' then
    frost1:play{pitch = random:float(0.95, 1.05), volume = 0.3}
  end

  if self.chance_to_barrage and random:bool(self.chance_to_barrage) then
    self:barrage(r, 4)
  end
end


function Player:attack(area, mods)
  mods = mods or {}
  camera:shake(2, 0.5)
  self.hfx:use('shoot', 0.25)
  local t = {group = main.current.effects, x = mods.x or self.x, y = mods.y or self.y, r = self.r, w = self.area_size_m*(area or 64), color = self.color, dmg = self.area_dmg_m*self.dmg,
    character = self.character, level = self.level, parent = self}
  Area(table.merge(t, mods))

  if self.character == 'swordsman' or self.character == 'barbarian' or self.character == 'juggernaut' then
    _G[random:table{'swordsman1', 'swordsman2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.75}
  elseif self.character == 'elementor' then
    elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
  end

  if self.character == 'juggernaut' then
    elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
  end
end


function Player:dot_attack(area, mods)
  mods = mods or {}
  camera:shake(2, 0.5)
  self.hfx:use('shoot', 0.25)
  local t = {group = main.current.effects, x = mods.x or self.x, y = mods.y or self.y, r = self.r, rs = self.area_size_m*(area or 64), color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character, level = self.level}
  DotArea(table.merge(t, mods))

  dot1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
end


function Player:barrage(r, n)
  n = n or 8
  for i = 1, n do
    self.t:after((i-1)*0.075, function()
      archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
      local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r + random:float(-math.pi/16, math.pi/16), color = self.color, dmg = self.dmg,
      parent = self, character = 'barrage', level = self.level}
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
  self.ricochet = args.ricochet or 0
  self.chain_enemies_hit = {}
  self.infused_enemies_hit = {}

  if self.character == 'sage' then
    elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
    self.compression_dmg = self.dmg
    self.dmg = 0
    self.pull_sensor = Circle(self.x, self.y, 64*self.parent.area_size_m)
    self.rs = 0
    self.t:tween(0.05, self, {rs = self.shape.w/2.5}, math.cubic_in_out, function() self.spring:pull(0.15) end)
    self.t:after(4, function()
      self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function()
        self:die()
        if self.level == 3 then
          _G[random:table{'saboteur_hit1', 'saboteur_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.2}
          magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
          local enemies = self:get_objects_in_shape(self.pull_sensor, main.current.enemies)
          for _, enemy in ipairs(enemies) do
            enemy:hit(3*self.compression_dmg)
          end
        end
      end)
    end)

    self.color_transparent = Color(args.color.r, args.color.g, args.color.b, 0.08)
    self.t:every(0.08, function()
      HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color}
    end)
    self.vr = 0
    self.dvr = random:float(-math.pi/4, math.pi/4)

  elseif self.character == 'spellblade' then
    if self.level == 3 then
      self.v = 1.5*self.v
      self.pierce = 1000
      self.orbit_r = 0
      self.orbit_vr = 12*math.pi
      self.t:tween(6.25, self, {orbit_vr = 4*math.pi}, math.expo_out, function()
        self.t:tween(12.25, self, {orbit_vr = 0}, math.linear)
      end)
    else
      self.pierce = 1000
      self.orbit_r = 0
      self.orbit_vr = 8*math.pi
      self.t:tween(6.25, self, {orbit_vr = math.pi}, math.expo_out, function()
        self.t:tween(12.25, self, {orbit_vr = 0}, math.linear)
      end)
    end

  elseif self.character == 'lich' then
    self.spring:pull(0.15)
    self.t:every(0.08, function()
      HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color}
    end)
  end

  if self.homing then
    self.homing = false
    self.t:after(0.1, function()
      self.homing = true
      self.closest_sensor = Circle(self.x, self.y, 64)
    end)
  end
end


function Projectile:update(dt)
  self:update_game_object(dt)

  if self.character == 'spellblade' then
    self.orbit_r = self.orbit_r + self.orbit_vr*dt
  end

  if self.homing then
    self.closest_sensor:move_to(self.x, self.y)
    local target = self:get_closest_object_in_shape(self.closest_sensor, main.current.enemies)
    if target then
      self:rotate_towards_object(target, 0.1)
      self.r = self:get_angle()
      self:move_along_angle(self.v, self.r + (self.orbit_r or 0))
    else
      self:set_angle(self.r)
      self:move_along_angle(self.v, self.r + (self.orbit_r or 0))
    end
  else
    self:set_angle(self.r)
    self:move_along_angle(self.v, self.r + (self.orbit_r or 0))
  end


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

  elseif self.character == 'lich' then
    graphics.push(self.x, self.y, self.r, self.spring.x, self.spring.x)
      graphics.circle(self.x, self.y, 4 + random:float(-1, 1), self.color)
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
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*32, color = self.color, dmg = self.parent.area_dmg_m*self.dmg, character = self.character, level = self.level}
  elseif self.character == 'blade' then
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*64, color = self.color, dmg = self.parent.area_dmg_m*self.dmg, character = self.character, level = self.level}
  elseif self.character == 'cannoneer' then
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*96, color = self.color, dmg = 2*self.parent.area_dmg_m*self.dmg, character = self.character, level = self.level}
    self.parent.t:every(0.2, function()
      _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      Area{group = main.current.effects, x = self.x + random:float(-32, 32), y = self.y + random:float(-32, 32), r = self.r + random:float(0, 2*math.pi), w = self.parent.area_size_m*48, color = self.color, 
        dmg = 0.5*self.parent.area_dmg_m*self.dmg, character = self.character, level = self.level}
    end, 5)
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
      if self.ricochet <= 0 then
        self:die(x, y, r, 0)
        WallArrow{group = main.current.main, x = x, y = y, r = self.r, color = self.color}
      else
        local r = Unit.bounce(self, nx, ny)
        self.r = r
        self.ricochet = self.ricochet - 1
      end
      _G[random:table{'arrow_hit_wall1', 'arrow_hit_wall2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.2}
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
    elseif self.character == 'wizard' or self.character == 'lich' then
      self:die(x, y, r, random:int(2, 3))
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
    elseif self.character == 'cannoneer' then
      self:die(x, y, r, random:int(2, 3))
      cannon_hit_wall1:play{pitch = random:float(0.95, 1.05), volume = 0.1}
    elseif self.character == 'engineer' or self.character == 'dual_gunner' then
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
        local object = self:get_random_object_in_shape(Circle(self.x, self.y, 48), main.current.enemies, self.chain_enemies_hit)
        if object then
          self.r = self:angle_to_object(object)
          if self.character == 'lich' then
            self.v = self.v*1.1
            if self.level == 3 then
              object:slow(0.2, 2)
            end
          else
            self.v = self.v*1.25
          end
          if self.level == 3 and self.character == 'scout' then
            self.dmg = self.dmg*1.25
          end
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
    elseif self.character == 'wizard' or self.character == 'lich' then
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
    else
      hit3:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end

    other:hit(self.dmg, self)

    if self.character == 'wizard' and self.level == 3 then
      Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*32, color = self.color, dmg = self.parent.area_dmg_m*self.dmg, character = self.character}
    end

    if self.character == 'hunter' and random:bool(40) then
      trigger:after(0.01, function()
        if self.level == 3 then
          local r = self.parent:angle_to_object(other)
          SpawnEffect{group = main.current.effects, x = self.parent.x, y = self.parent.y, color = green[0], action = function(x, y)
            Pet{group = main.current.main, x = x, y = y, r = r, v = 150, parent = self.parent, conjurer_buff_m = self.conjurer_buff_m or 1}
            Pet{group = main.current.main, x = x + 12*math.cos(r + math.pi/2), y = y + 12*math.sin(r + math.pi/2), r = r, v = 150, parent = self.parent, conjurer_buff_m = self.conjurer_buff_m or 1}
            Pet{group = main.current.main, x = x + 12*math.cos(r - math.pi/2), y = y + 12*math.sin(r - math.pi/2), r = r, v = 150, parent = self.parent, conjurer_buff_m = self.conjurer_buff_m or 1}
          end}
        else
          SpawnEffect{group = main.current.effects, x = self.parent.x, y = self.parent.y, color = orange[0], action = function(x, y)
            Pet{group = main.current.main, x = x, y = y, r = self.parent:angle_to_object(other), v = 150, parent = self.parent, conjurer_buff_m = self.conjurer_buff_m or 1}
          end}
        end
      end)
    end

    if self.parent.chain_infused then
      local units = self.parent:get_all_units()
      local stormweaver_level = 0
      for _, unit in ipairs(units) do
        if unit.character == 'stormweaver' then
          stormweaver_level = unit.level
          break
        end
      end
      local src = other
      for i = 1, 2 + (stormweaver_level == 3 and 2 or 0) do
        _G[random:table{'spark1', 'spark2', 'spark3'}]:play{pitch = random:float(0.9, 1.1), volume = 0.3}
        table.insert(self.infused_enemies_hit, src)
        local dst = src:get_random_object_in_shape(Circle(src.x, src.y, (stormweaver_level == 3 and 128 or 64)), main.current.enemies, self.infused_enemies_hit)
        if dst then
          dst:hit(0.2*self.dmg)
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
      if self.level == 3 then
        enemy:slow(0.4, 6)
      end
    elseif self.character == 'swordsman' then
      enemy:hit(self.dmg + self.dmg*0.33*#enemies)
    elseif self.character == 'blade' and self.level == 3 then
      enemy:hit(self.dmg + self.dmg*0.5*#enemies)
    else
      enemy:hit(self.dmg)
    end
    HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
    for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
    if self.character == 'wizard' or self.character == 'elementor' then
      magic_hit1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    elseif self.character == 'swordsman' or self.character == 'barbarian' or self.character == 'juggernaut' then
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    elseif self.character == 'blade' then
      blade_hit1:play{pitch = random:float(0.9, 1.1), volume = 0.35}
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.2}
    elseif self.character == 'saboteur' or self.character == 'pyromancer' then
      if self.character == 'pyromancer' then pyro2:play{pitch = random:float(0.95, 1.05), volume = 0.4} end
      _G[random:table{'saboteur_hit1', 'saboteur_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.2}
    elseif self.character == 'cannoneer' then
      _G[random:table{'saboteur_hit1', 'saboteur_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.075}
    end

    if self.stun then
      enemy:slow(0.1, self.stun)
      enemy.barbarian_stunned = true
      enemy.t:after(self.stun, function() enemy.barbarian_stunned = false end)
    end

    if self.juggernaut_push then
      local r = self.parent:angle_to_object(enemy)
      enemy:push(random:float(75, 100), r)
      enemy.juggernaut_push = 3*self.dmg
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




DotArea = Object:extend()
DotArea:implement(GameObject)
function DotArea:init(args)
  self:init_game_object(args)
  self.shape = Circle(self.x, self.y, self.rs)

  if self.character == 'plague_doctor' or self.character == 'pyromancer' then
    self.t:every(0.2, function()
      local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
      if #enemies > 0 then self.spring:pull(0.05, 200, 10) end
      for _, enemy in ipairs(enemies) do
        hit2:play{pitch = random:float(0.8, 1.2), volume = 0.2}
        if self.character == 'pyromancer' then
          pyro1:play{pitch = random:float(1.5, 1.8), volume = 0.1}
          enemy.pyrod = self
        end
        enemy:hit(self.dmg/5)
        HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
      end
    end, nil, nil, 'dot')
  elseif self.character == 'cryomancer' then
    self.t:every(2, function()
      local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
      if #enemies > 0 then
        self.spring:pull(0.15, 200, 10)
        frost1:play{pitch = random:float(0.8, 1.2), volume = 0.4}
      end
      for _, enemy in ipairs(enemies) do
        if self.level == 3 then
          enemy:slow(0.4, 4)
        end
        enemy:hit(2*self.dmg)
        HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
      end
    end, nil, nil, 'dot')
  end

  self.color = fg[0]
  self.color_transparent = Color(args.color.r, args.color.g, args.color.b, 0.08)
  self.rs = 0
  self.hidden = false
  self.t:tween(0.05, self, {rs = args.rs}, math.cubic_in_out, function() self.spring:pull(0.15) end)
  self.t:after(0.2, function() self.color = args.color end)
  if self.duration and self.duration > 0.5 then
    self.t:after(self.duration - 0.35, function()
      self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self.dead = true end)
    end)
  end

  self.vr = 0
  self.dvr = random:float(-math.pi/4, math.pi/4)
end


function DotArea:update(dt)
  self:update_game_object(dt)
  self.t:set_every_multiplier('dot', (main.current.chronomancer_dot or 1))
  self.vr = self.vr + self.dvr*dt

  if self.parent then
    if (self.character == 'plague_doctor' and self.level == 3) or self.character == 'cryomancer' or self.character == 'pyromancer' then
      self.x, self.y = self.parent.x, self.parent.y
      self.shape:move_to(self.x, self.y)
    end
  end
end


function DotArea:draw()
  if self.hidden then return end

  graphics.push(self.x, self.y, self.r + self.vr, self.spring.x, self.spring.x)
    -- graphics.circle(self.x, self.y, self.shape.rs + random:float(-1, 1), self.color, 2)
    graphics.circle(self.x, self.y, self.shape.rs, self.color_transparent)
    local lw = math.remap(self.shape.rs, 32, 256, 2, 4)
    for i = 1, 4 do graphics.arc('open', self.x, self.y, self.shape.rs, (i-1)*math.pi/2 + math.pi/4 - math.pi/8, (i-1)*math.pi/2 + math.pi/4 + math.pi/8, self.color, lw) end
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
      dmg = self.parent.dmg*(self.parent.conjurer_buff_m or 1)*self.upgrade_dmg_m, character = self.parent.character, parent = self.parent}
      Projectile(table.merge(t, mods or {}))
      turret1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      turret2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end, 3)
  end, nil, nil, 'shoot')

  self.t:after(24*(self.parent.conjurer_buff_m or 1), function()
    local n = n or random:int(3, 4)
    for i = 1, n do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y}:scale_down()
    self.dead = true
  end)
  
  self.upgrade_dmg_m = 1
  self.upgrade_aspd_m = 1
end


function Turret:update(dt)
  self:update_game_object(dt)

  self.t:set_every_multiplier('shoot', 1/self.upgrade_aspd_m)

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


function Turret:upgrade()
  self.upgrade_dmg_m = self.upgrade_dmg_m + 1
  self.upgrade_aspd_m = self.upgrade_aspd_m + 1
  for i = 1, 6 do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
  HitCircle{group = main.current.effects, x = self.x, y = self.y}:scale_down()
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
  self.ricochet = 1
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
    hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}

    if self.parent.level == 3 and self.ricochet > 0 then
      local r = Unit.bounce(self, nx, ny)
      self.r = r
      self.ricochet = self.ricochet - 1
    else
      self.dead = true
    end
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
    hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    elseif self.character == 'blade' then
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

  self.actual_dmg = get_character_stat('saboteur', self.level, 'dmg')
end


function Saboteur:update(dt)
  self:update_game_object(dt)
  self:calculate_stats()

  if not self.target then self.target = random:table(self.group:get_objects_by_classes(main.current.enemies)) end
  if self.target and self.target.dead then self.target = random:table(self.group:get_objects_by_classes(main.current.enemies)) end
  if not self.target then
    self:seek_point(gw/2, gh/2)
    self:rotate_towards_velocity(0.5)
    self.r = self:get_angle()
  else
    self:seek_point(self.target.x, self.target.y)
    self:rotate_towards_velocity(0.5)
    self.r = self:get_angle()
  end
end


function Saboteur:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function Saboteur:on_collision_enter(other, contact)
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    camera:shake(4, 0.5)
    local t = {group = main.current.effects, x = self.x, y = self.y, r = self.r, w = (self.crit and 1.5 or 1)*self.area_size_m*64, color = self.color, 
      dmg = (self.crit and 2 or 1)*self.area_dmg_m*self.actual_dmg*(self.conjurer_buff_m or 1), character = self.character}
    Area(table.merge(t, mods or {}))
    self.dead = true
  end
end




Critter = Object:extend()
Critter:implement(GameObject)
Critter:implement(Physics)
Critter:implement(Unit)
function Critter:init(args)
  self:init_game_object(args)
  self:init_unit()
  self:set_as_rectangle(7, 4, 'dynamic', 'player')
  self:set_restitution(0.5)

  self.classes = {'enemy_critter'}
  self.color = orange[0]
  self:calculate_stats(true)
  self:set_as_steerable(self.v, 400, math.pi, 1)
  self:push(args.v, args.r)
  self.invulnerable = true
  self.t:after(0.5, function() self.invulnerable = false end)

  self.hp = 1
end


function Critter:update(dt)
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
    if not self.target then self.target = random:table(self.group:get_objects_by_classes(main.current.enemies)) end
    if self.target and self.target.dead then self.target = random:table(self.group:get_objects_by_classes(main.current.enemies)) end
    if not self.target then
      self:seek_point(gw/2, gh/2)
      self:wander(50, 200, 50)
      self:rotate_towards_velocity(1)
      self:steering_separate(8, {Critter})
    else
      self:seek_point(self.target.x, self.target.y)
      self:wander(50, 200, 50)
      self:rotate_towards_velocity(1)
      self:steering_separate(8, {Critter})
    end
  end
  self.r = self:get_angle()
end


function Critter:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function Critter:hit(damage)
  if self.dead or self.invulnerable then return end
  self.hfx:use('hit', 0.25, 200, 10)
  self.hp = self.hp - damage
  -- self:show_hp()
  if self.hp <= 0 then self:die() end
end


function Critter:push(f, r)
  self.push_force = f
  self.being_pushed = true
  self.steering_enabled = false
  self:apply_impulse(f*math.cos(r), f*math.sin(r))
  self:apply_angular_impulse(random:table{random:float(-12*math.pi, -4*math.pi), random:float(4*math.pi, 12*math.pi)})
  self:set_damping(1.5)
  self:set_angular_damping(1.5)
end


function Critter:die(x, y, r, n)
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


function Critter:on_collision_enter(other, contact)
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


function Critter:on_trigger_enter(other, contact)
  if other:is(Seeker) then
    self:hit(1)
    other:hit(self.dmg)
  end
end
