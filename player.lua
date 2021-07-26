Player = Object:extend()
Player:implement(GameObject)
Player:implement(Physics)
Player:implement(Unit)
function Player:init(args)
  self:init_game_object(args)
  self:init_unit()

  if self.passives then for k, v in pairs(self.passives) do self[v.passive] = v.level end end

  self.color = character_colors[self.character]
  self:set_as_rectangle(9, 9, 'dynamic', 'player')
  self.visual_shape = 'rectangle'
  self.classes = character_classes[self.character]
  self.damage_dealt = 0

  if self.character == 'vagrant' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'swordsman' then
    self.attack_sensor = Circle(self.x, self.y, 48)
    self.t:cooldown(3, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      self:attack(96)
    end, nil, nil, 'attack')

  elseif self.character == 'wizard' then
    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {chain = (self.level == 3 and 2 or 0)})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'magician' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      if self.magician_invulnerable then return end
      local enemy = self:get_random_object_in_shape(self.attack_sensor, main.current.enemies)
      if enemy then
        self:attack(32, {x = enemy.x, y = enemy.y})
      end
    end, nil, nil, 'attack')
    if self.level == 3 then
      self.t:every(12, function()
        self.magician_aspd_m = 1.5
        self.t:after(6, function() self.magician_aspd_m = 1 end, 'magician_aspd_m')
      end)
    end

  elseif self.character == 'gambler' then
    self.sorcerer_count = 0
    local cast = function(pitch_a)
      local enemy = table.shuffle(main.current.main:get_objects_by_classes(main.current.enemies))[1]
      if enemy then
        gambler1:play{pitch = pitch_a, volume = math.clamp(math.remap(gold, 0, 50, 0, 0.5), 0, 0.75)}
        enemy:hit(2*gold)
        if main.current.sorcerer_level > 0 then
          self.sorcerer_count = self.sorcerer_count + 1
          if self.sorcerer_count >= ((main.current.sorcerer_level == 3 and 2) or (main.current.sorcerer_level == 2 and 3) or (main.current.sorcerer_level == 1 and 4)) then
            self:sorcerer_repeat()
            self.sorcerer_count = 0
            self.t:after(0.25, function()
              local enemy = table.shuffle(main.current.main:get_objects_by_classes(main.current.enemies))[1]
              if enemy then
                gambler1:play{pitch = pitch_a + 0.05, volume = math.clamp(math.remap(gold, 0, 50, 0, 0.5), 0, 0.75)}
                enemy:hit(2*gold)
              end
            end)
          end
        end
      end
    end
    self.t:every(2, function()
      cast(1)
      if self.level == 3 then
        if random:bool(60) then
          if random:bool(40) then
            if random:bool(20) then
              self.t:after(0.25, function()
                cast(1.1)
                self.t:after(0.25, function()
                  cast(1.2)
                  self.t:after(0.25, function()
                    cast(1.3)
                  end)
                end)
              end)
            else
              self.t:after(0.25, function()
                cast(1.1)
                self.t:after(0.25, function()
                  cast(1.2)
                end)
              end)
            end
          else
            self.t:after(0.25, function()
              cast(1.1)
            end)
          end
        end
      end
    end, nil, nil, 'attack')

  elseif self.character == 'archer' then
    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {pierce = 1000, ricochet = (self.level == 3 and 3 or 0)})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'scout' then
    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {chain = (self.level == 3 and 6 or 3)})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'thief' then
    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {chain = (self.level == 3 and 10 or 5)})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'cleric' then
    self.t:every(8, function()
      if self.level == 3 then
        for i = 1, 4 do
          local check_circle = Circle(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16), 2)
          local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
          while #objects > 0 do
            check_circle:move_to(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16))
            objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
          end
          SpawnEffect{group = main.current.effects, x = check_circle.x, y = check_circle.y, color = green[0], action = function(x, y)
            local check_circle = Circle(x, y, 2)
            local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
            if #objects == 0 then
              HealingOrb{group = main.current.main, x = x, y = y}
            end
          end}
        end
      else
        local check_circle = Circle(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16), 2)
        local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
        while #objects > 0 do
          check_circle:move_to(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16))
          objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
        end
        SpawnEffect{group = main.current.effects, x = check_circle.x, y = check_circle.y, color = green[0], action = function(x, y)
          local check_circle = Circle(x, y, 2)
          local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
          if #objects == 0 then
            HealingOrb{group = main.current.main, x = x, y = y}
          end
        end}
      end
      --[[
      local all_units = self:get_all_units()
      local unit_index = table.contains(all_units, function(v) return v.hp <= 0.5*v.max_hp end)
      if unit_index then
        local unit = all_units[unit_index]
        self.last_heal_time = love.timer.getTime()
        if self.level == 3 then
          for _, unit in ipairs(all_units) do unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1)) end
        else
          unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1))
        end
        heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      end
      ]]--
    end, nil, nil, 'heal')

  elseif self.character == 'arcanist' then
    self.sorcerer_count = 0
    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(4, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {pierce = 10000, v = 40})
        if main.current.sorcerer_level > 0 then
          self.sorcerer_count = self.sorcerer_count + 1
          if self.sorcerer_count >= ((main.current.sorcerer_level == 3 and 2) or (main.current.sorcerer_level == 2 and 3) or (main.current.sorcerer_level == 1 and 4)) then
            self:sorcerer_repeat()
            self.sorcerer_count = 0
            self.t:after(0.25, function()
              self:shoot(self:angle_to_object(closest_enemy), {pierce = 10000, v = 40})
            end)
          end
        end
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'artificer' then
    self.sorcerer_count = 0
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:every(6, function()
      SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = self.color, action = function(x, y)
        artificer1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        local check_circle = Circle(self.x, self.y, 2)
        local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Pet, Turret, Sentry, Bomb})
        if #objects == 0 then Automaton{group = main.current.main, x = x, y = y, parent = self, level = self.level, conjurer_buff_m = self.conjurer_buff_m or 1} end
      end}
      if main.current.sorcerer_level > 0 then
        self.sorcerer_count = self.sorcerer_count + 1
        if self.sorcerer_count >= ((main.current.sorcerer_level == 3 and 2) or (main.current.sorcerer_level == 2 and 3) or (main.current.sorcerer_level == 1 and 4)) then
          self:sorcerer_repeat()
          self.sorcerer_count = 0
          self.t:after(0.25, function()
            SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = self.color, action = function(x, y)
              artificer1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
              local check_circle = Circle(self.x, self.y, 2)
              local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Pet, Turret, Sentry, Bomb})
              if #objects == 0 then Automaton{group = main.current.main, x = x, y = y, parent = self, level = self.level, conjurer_buff_m = self.conjurer_buff_m or 1} end
            end}
          end)
        end
      end
    end, nil, nil, 'spawn')

  elseif self.character == 'outlaw' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(3, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {homing = (self.level == 3)})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'blade' then
    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:cooldown(4, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      self:shoot()
    end, nil, nil, 'shoot')

  elseif self.character == 'elementor' then
    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(7, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local enemy = self:get_random_object_in_shape(self.attack_sensor, main.current.enemies)
      if enemy then
        self:attack(128, {x = enemy.x, y = enemy.y})
      end
    end, nil, nil, 'attack')

  elseif self.character == 'psychic' then
    self.sorcerer_count = 0
    self.attack_sensor = Circle(self.x, self.y, self.level == 3 and 512 or 64)
    self.t:cooldown(3, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local strike = function()
        local enemy = self:get_random_object_in_shape(self.attack_sensor, main.current.enemies)
        if enemy then
          if self.level == 3 then
            self:attack(32, {x = enemy.x, y = enemy.y})
            self.t:after(0.5, function()
              local enemy = self:get_random_object_in_shape(self.attack_sensor, main.current.enemies)
              if enemy then
                self:attack(32, {x = enemy.x, y = enemy.y})
              end
            end)
          else
            self:attack(32, {x = enemy.x, y = enemy.y})
          end
        end
      end
      strike()
      if main.current.sorcerer_level > 0 then
        self.sorcerer_count = self.sorcerer_count + 1
        if self.sorcerer_count >= ((main.current.sorcerer_level == 3 and 2) or (main.current.sorcerer_level == 2 and 3) or (main.current.sorcerer_level == 1 and 4)) then
          self.sorcerer_count = 0
          self:sorcerer_repeat()
          self.t:after(0.1, function()
            strike()
          end)
        end
      end
    end, nil, nil, 'attack')

  elseif self.character == 'saboteur' then
    self.t:every(8, function()
      self.t:every(0.25, function()
        SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = self.color, action = function(x, y)
          Saboteur{group = main.current.main, x = x, y = y, parent = self, level = self.level, conjurer_buff_m = self.conjurer_buff_m or 1, crit = (self.level == 3) and random:bool(50)}
        end}
      end, 2)
    end, nil, nil, 'spawn')

  elseif self.character == 'bomber' then
    self.t:every(8, function()
      SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = self.color, action = function(x, y)
        Bomb{group = main.current.main, x = x, y = y, parent = self, level = self.level, conjurer_buff_m = self.conjurer_buff_m or 1}
      end}
    end, nil, nil, 'spawn')

  elseif self.character == 'stormweaver' then
    self.t:every(8, function()
      stormweaver1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      local units = self:get_all_units()
      for _, unit in ipairs(units) do
        unit:chain_infuse(4)
      end
    end, nil, nil, 'buff')

  elseif self.character == 'sage' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(9, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'cannoneer' then
    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(6, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'vulcanist' then
    self.sorcerer_count = 0
    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:every(12, function()
      local volcano = function()
        local enemies = main.current.main:get_objects_by_classes(main.current.enemies)
        local x, y = 0, 0
        if enemies and #enemies > 0 then
          for _, enemy in ipairs(enemies) do
            x = x + enemy.x
            y = y + enemy.y
          end
          x = x/#enemies
          y = y/#enemies
        end
        if x == 0 and y == 0 then x, y = gw/2, gh/2 end
        x, y = x + self.x, y + self.y
        x, y = x/2, y/2
        main.current.t:every_immediate(0.1, function()
          local check_circle = Circle(x, y, 2)
          local objects = main.current.main:get_objects_in_shape(check_circle, {Player, Seeker, EnemyCritter, Critter, Saboteur, Pet, Turret, Sentry, Bomb})
          if #objects == 0 then
            Volcano{group = main.current.main, x = x, y = y, color = self.color, parent = self, rs = 24, level = self.level}
            main.current.t:cancel('volcano_spawn')
          end
        end, nil, nil, 'volcano_spawn')
      end
      volcano()
      if main.current.sorcerer_level > 0 then
        self.sorcerer_count = self.sorcerer_count + 1
        if self.sorcerer_count >= ((main.current.sorcerer_level == 3 and 2) or (main.current.sorcerer_level == 2 and 3) or (main.current.sorcerer_level == 1 and 4)) then
          self.sorcerer_count = 0
          self:sorcerer_repeat()
          self.t:after(0.5, function()
            volcano()
          end)
        end
      end
    end, nil, nil, 'attack')

  elseif self.character == 'dual_gunner' then
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
    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy))
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'chronomancer' then
    if self.level == 3 then
      main.current.chronomancer_dot = 0.5
    end

  elseif self.character == 'spellblade' then
    self.t:every(2, function()
      self:shoot(random:float(0, 2*math.pi))
    end, nil, nil, 'shoot')

  elseif self.character == 'psykeeper' then
    self.stored_heal = 0
    self.last_heal_time = love.timer.getTime()

  elseif self.character == 'engineer' then
    self.t:every(8, function()
      SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = orange[0], action = function(x, y)
        Turret{group = main.current.main, x = x, y = y, parent = self}
      end}
    end, nil, nil, 'spawn')

    if self.level == 3 then
      self.t:every(24, function()
        SpawnEffect{group = main.current.effects, x = self.x - 16, y = self.y + 16, color = orange[0], action = function(x, y) Turret{group = main.current.main, x = x, y = y, parent = self} end}
        SpawnEffect{group = main.current.effects, x = self.x + 16, y = self.y + 16, color = orange[0], action = function(x, y) Turret{group = main.current.main, x = x, y = y, parent = self} end}

        self.t:after(0.5, function()
          local turrets = main.current.main:get_objects_by_class(Turret)
          buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          for _, turret in ipairs(turrets) do
            HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = orange[0], duration = 0.1}
            LightningLine{group = main.current.effects, src = self, dst = turret, color = orange[0]}
            turret:upgrade()
          end
        end)
      end)
    end

  elseif self.character == 'plague_doctor' then
    self.t:every(5, function()
      self:dot_attack(24, {duration = 12, plague_doctor_unmovable = true})
    end, nil, nil, 'attack')

    if self.level == 3 then
      self.t:after(0.01, function()
        self.dot_area = DotArea{group = main.current.effects, x = self.x, y = self.y, rs = self.area_size_m*48, color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self}
      end)
    end

  elseif self.character == 'witch' then
    self.sorcerer_count = 0
    self.t:every(4, function()
      self:dot_attack(42, {duration = random:float(12, 16)})
      if main.current.sorcerer_level > 0 then
        self.sorcerer_count = self.sorcerer_count + 1
        if self.sorcerer_count >= ((main.current.sorcerer_level == 3 and 2) or (main.current.sorcerer_level == 2 and 3) or (main.current.sorcerer_level == 1 and 4)) then
          self.sorcerer_count = 0
          self:sorcerer_repeat()
          self.t:after(0.25, function()
            self:dot_attack(42, {duration = random:float(12, 16)})
          end)
        end
      end
    end, nil, nil, 'attack')

  elseif self.character == 'barbarian' then
    self.attack_sensor = Circle(self.x, self.y, 48)
    self.t:cooldown(8, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      self:attack(96, {stun = 4})
    end, nil, nil, 'attack')

  elseif self.character == 'juggernaut' then
    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:cooldown(8, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      self:attack(128, {juggernaut_push = true})
    end, nil, nil, 'attack')

  elseif self.character == 'lich' then
    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(4, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {chain = (self.level == 3 and 14 or 7), v = 140})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'cryomancer' then
    self.t:after(0.01, function()
      self.dot_area = DotArea{group = main.current.effects, x = self.x, y = self.y, rs = self.area_size_m*72, color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self}
    end)

  elseif self.character == 'pyromancer' then
    self.t:after(0.01, function()
      self.dot_area = DotArea{group = main.current.effects, x = self.x, y = self.y, rs = self.area_size_m*48, color = self.color, dmg = self.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self}
    end)

  elseif self.character == 'corruptor' then
    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {spawn_critters_on_kill = 3, spawn_critters_on_hit = (self.level == 3 and 2 or nil)})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'beastmaster' then
    self.attack_sensor = Circle(self.x, self.y, 160)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {spawn_critters_on_crit = 2})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'launcher' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.t:cooldown(6, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      buff1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
      local enemies = main.current.main:get_objects_by_classes(main.current.enemies)
      for _, enemy in ipairs(enemies) do
        if self:distance_to_object(enemy) < 128 then
          local resonance_dmg = 0
          if self.resonance then resonance_dmg = (self.level == 3 and 6*self.dmg*0.05*#enemies or 2*self.dmg*0.05*#enemies) end
          enemy:curse('launcher', 4*(self.hex_duration_m or 1), (self.level == 3 and 6*self.dmg or 2*self.dmg) + resonance_dmg, self)
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = yellow[0], duration = 0.1}
          LightningLine{group = main.current.effects, src = self, dst = enemy, color = yellow[0]}
        end
      end
    end, nil, nil, 'attack')

  elseif self.character == 'jester' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.wide_attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(6, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      buff1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
      local enemies = table.first2(table.shuffle(self:get_objects_in_shape(self.wide_attack_sensor, main.current.enemies)),
        6 + ((self.malediction == 1 and 1) or (self.malediction == 2 and 3) or (self.malediction == 3 and 5) or 0) + ((main.current.curser_level == 2 and 3) or (main.current.curser_level == 1 and 1) or 0))
      for _, enemy in ipairs(enemies) do
        if self:distance_to_object(enemy) < 128 then
          enemy:curse('jester', 6*(self.hex_duration_m or 1), self.level == 3, self)
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = red[0], duration = 0.1}
          LightningLine{group = main.current.effects, src = self, dst = enemy, color = red[0]}
        end
      end
    end, nil, nil, 'attack')

  elseif self.character == 'usurer' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.wide_attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(6, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      buff1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
      local enemies = table.first2(table.shuffle(self:get_objects_in_shape(self.wide_attack_sensor, main.current.enemies)),
        3 + ((self.malediction == 1 and 1) or (self.malediction == 2 and 3) or (self.malediction == 3 and 5) or 0) + ((main.current.curser_level == 2 and 3) or (main.current.curser_level == 1 and 1) or 0))
      for _, enemy in ipairs(enemies) do
        enemy:curse('usurer', 10000, self.level == 3, self)
        enemy:apply_dot(self.dmg*(self.dot_dmg_m or 1)*(main.current.chronomancer_dot or 1), 10000)
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = purple[0], duration = 0.1}
        LightningLine{group = main.current.effects, src = self, dst = enemy, color = purple[0]}
      end
    end, nil, nil, 'attack')

  elseif self.character == 'silencer' then
    self.sorcerer_count = 0
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.wide_attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(6, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local curse = function()
        buff1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
        local enemies = table.first2(table.shuffle(self:get_objects_in_shape(self.wide_attack_sensor, main.current.enemies)),
          6 + ((self.malediction == 1 and 1) or (self.malediction == 2 and 3) or (self.malediction == 3 and 5) or 0) + ((main.current.curser_level == 2 and 3) or (main.current.curser_level == 1 and 1) or 0))
        for _, enemy in ipairs(enemies) do
          enemy:curse('silencer', 6*(self.hex_duration_m or 1), self.level == 3, self)
          if self.level == 3 then
            enemy:apply_dot(self.dmg*(self.dot_dmg_m or 1)*(main.current.chronomancer_dot or 1), 6*(self.hex_duration_m or 1))
          end
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = blue2[0], duration = 0.1}
          LightningLine{group = main.current.effects, src = self, dst = enemy, color = blue2[0]}
        end
      end
      curse()
      if main.current.sorcerer_level > 0 then
        self.sorcerer_count = self.sorcerer_count + 1
        if self.sorcerer_count >= ((main.current.sorcerer_level == 3 and 2) or (main.current.sorcerer_level == 2 and 3) or (main.current.sorcerer_level == 1 and 4)) then
          self.sorcerer_count = 0
          self:sorcerer_repeat()
          self.t:after(0.5, function()
            curse()
          end)
        end
      end
    end, nil, nil, 'attack')

  elseif self.character == 'assassin' then
    self.attack_sensor = Circle(self.x, self.y, 64)
    self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      if closest_enemy then
        self:shoot(self:angle_to_object(closest_enemy), {pierce = 1000})
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'host' then
    if self.level == 3 then
      self.t:every(1, function()
        critter1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
        for i = 1, 2 do
          Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 10, dmg = self.dmg, parent = self}
        end
      end, nil, nil, 'spawn')
    else
      self.t:every(2, function()
        critter1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
        Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 10, dmg = self.dmg, parent = self}
      end, nil, nil, 'spawn')
    end

  elseif self.character == 'carver' then
    self.t:every(16, function()
      Tree{group = main.current.main, x = self.x, y = self.y, color = self.color, parent = self, level = self.level}
    end, nil, nil, 'spawn')

  elseif self.character == 'sentry' then
    self.t:every(7, function()
      Sentry{group = main.current.main, x = self.x, y = self.y, color = self.color, parent = self, level = self.level}
    end, nil, nil, 'spawn')

  elseif self.character == 'bane' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.wide_attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(6, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      buff1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
      local enemies = table.first2(table.shuffle(self:get_objects_in_shape(self.wide_attack_sensor, main.current.enemies)),
        6 + ((self.malediction == 1 and 1) or (self.malediction == 2 and 3) or (self.malediction == 3 and 5) or 0) + ((main.current.curser_level == 2 and 3) or (main.current.curser_level == 1 and 1) or 0))
      for _, enemy in ipairs(enemies) do
        enemy:curse('bane', 6*(self.hex_duration_m or 1), self.level == 3, self)
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = purple[0], duration = 0.1}
        LightningLine{group = main.current.effects, src = self, dst = enemy, color = purple[0]}
      end
    end, nil, nil, 'attack')

  elseif self.character == 'psykino' then
    self.t:every(4, function()
      local center_enemy = self:get_random_object_in_shape(Circle(self.x, self.y, 160), main.current.enemies)
      if center_enemy then
        ForceArea{group = main.current.effects, x = center_enemy.x, y = center_enemy.y, rs = self.area_size_m*64, color = self.color, character = self.character, level = self.level, parent = self}
      end
    end, nil, nil, 'attack')

  elseif self.character == 'barrager' then
    self.barrager_counter = 0
    self.attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(4, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
      local r = self:angle_to_object(closest_enemy)
      self.barrager_counter = self.barrager_counter + 1
      if self.barrager_counter == 3 and self.level == 3 then
        self.barrager_counter = 0
        for i = 1, 15 do
          self.t:after((i-1)*0.05, function()
            self:shoot(r + random:float(-math.pi/32, math.pi/32), {knockback = (self.level == 3 and 14 or 7)})
          end)
        end
      else
        for i = 1, 3 do
          self.t:after((i-1)*0.075, function()
            self:shoot(r + random:float(-math.pi/32, math.pi/32), {knockback = (self.level == 3 and 14 or 7)})
          end)
        end
      end
    end, nil, nil, 'shoot')

  elseif self.character == 'highlander' then
    self.attack_sensor = Circle(self.x, self.y, 36)
    self.t:cooldown(4, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      if self.level == 3 then
        self.t:every(0.25, function()
          self:attack(72)
        end, 3)
      else
        self:attack(72)
      end
    end, nil, nil, 'attack')

  elseif self.character == 'fairy' then
    self.t:every(6, function()
      if self.level == 3 then
        local units = self:get_all_units()
        local unit_1 = random:table(units)
        local runs = 0
        if unit_1 then
          while table.any(non_attacking_characters, function(v) return v == unit_1.character end) and runs < 1000 do unit_1 = random:table(units); runs = runs + 1 end
        end
        local unit_2 = random:table(units)
        local runs = 0
        if unit_2 then
          while table.any(non_attacking_characters, function(v) return v == unit_2.character end) and runs < 1000 do unit_2 = random:table(units); runs = runs + 1 end
        end
        if unit_1 then
          unit_1.fairy_aspd_m = 3
          unit_1.fairyd = true
          unit_1.t:after(5.98, function() unit_1.fairy_aspd_m = 1; unit_1.fairyd = false end)
        end
        if unit_2 then
          unit_2.fairy_aspd_m = 3
          unit_2.fairyd = true
          unit_2.t:after(5.98, function() unit_2.fairy_aspd_m = 1; unit_2.fairyd = false end)
        end
        heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        for i = 1, 2 do
          local check_circle = Circle(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16), 2)
          local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Bomb, Pet, Turret, Sentry})
          while #objects > 0 do
            check_circle:move_to(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16))
            objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Pet, Turret, Sentry, Bomb})
          end
          SpawnEffect{group = main.current.effects, x = check_circle.x, y = check_circle.y, color = green[0], action = function(x, y)
            local check_circle = Circle(x, y, 2)
            local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Bomb, Pet, Turret, Sentry})
            if #objects == 0 then
              HealingOrb{group = main.current.main, x = x, y = y}
            end
          end}
        end

      else
        local unit = random:table(self:get_all_units())
        local runs = 0
        while table.any(non_attacking_characters, function(v) return v == unit.character end) and runs < 1000 do unit = random:table(self:get_all_units()); runs = runs + 1 end
        if unit then
          unit.fairyd = true
          unit.fairy_aspd_m = 2
          unit.t:after(5.98, function() unit.fairy_aspd_m = 1; unit.fairyd = false end)
        end
        heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        local check_circle = Circle(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16), 2)
        local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Bomb, Pet, Turret, Sentry})
        while #objects > 0 do
          check_circle:move_to(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16))
          objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Bomb, Pet, Turret, Sentry})
        end
        SpawnEffect{group = main.current.effects, x = check_circle.x, y = check_circle.y, color = green[0], action = function(x, y)
          local check_circle = Circle(x, y, 2)
          local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Pet, Turret, Sentry, Bomb})
          if #objects == 0 then
            HealingOrb{group = main.current.main, x = x, y = y}
          end
        end}
      end
    end, nil, nil, 'heal')

  elseif self.character == 'warden' then
    self.sorcerer_count = 0
    self.t:every(12, function()
      local ward = function()
        if self.level == 3 then
          local units = self:get_all_units()
          local unit_1 = random:table_remove(units)
          local unit_2 = random:table_remove(units)
          if unit_1 then
            illusion1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            main.current.t:every_immediate(0.1, function()
              local check_circle = Circle(unit_1.x, unit_1.y, 6)
              local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter})
              if #objects == 0 then
                ForceField{group = main.current.main, x = unit_1.x, y = unit_1.y, parent = unit_1}
                main.current.t:cancel('warden_force_field_1')
              end
            end, nil, nil, 'warden_force_field_1')
          end
          if unit_2 then
            illusion1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            ForceField{group = main.current.main, x = unit_2.x, y = unit_2.y, parent = unit_2}
            main.current.t:every_immediate(0.1, function()
              local check_circle = Circle(unit_2.x, unit_2.y, 6)
              local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter})
              if #objects == 0 then
                ForceField{group = main.current.main, x = unit_2.x, y = unit_2.y, parent = unit_2}
                main.current.t:cancel('warden_force_field_2')
              end
            end, nil, nil, 'warden_force_field_2')
          end
        else
          local unit = random:table(self:get_all_units())
          if unit then
            illusion1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
            main.current.t:every_immediate(0.1, function()
              local check_circle = Circle(unit.x, unit.y, 6)
              local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter})
              if #objects == 0 then
                ForceField{group = main.current.main, x = unit.x, y = unit.y, parent = unit}
                main.current.t:cancel('warden_force_field_0')
              end
            end, nil, nil, 'warden_force_field_0')
          end
        end
      end
      ward()
      if main.current.sorcerer_level > 0 then
        self.sorcerer_count = self.sorcerer_count + 1
        if self.sorcerer_count >= ((main.current.sorcerer_level == 3 and 2) or (main.current.sorcerer_level == 2 and 3) or (main.current.sorcerer_level == 1 and 4)) then
          self.sorcerer_count = 0
          self:sorcerer_repeat()
          self.t:after(0.5, function()
            ward()
          end)
        end
      end
    end, nil, nil, 'buff')

  elseif self.character == 'priest' then
    if self.level == 3 then
      self.t:after(0.01, function()
        local all_units = self:get_all_units()
        local unit_1 = random:table_remove(all_units)
        local unit_2 = random:table_remove(all_units)
        local unit_3 = random:table_remove(all_units)
        if unit_1 then unit_1.divined = true end
        if unit_2 then unit_2.divined = true end
        if unit_3 then unit_3.divined = true end
      end)
    end

    self.t:every(12, function()
      local x, y = random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16)
      for i = 1, 3 do
        SpawnEffect{group = main.current.effects, x = x, y = y, color = green[0], action = function(x, y)
          local check_circle = Circle(x, y, 2)
          local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Bomb, Pet, Turret, Sentry, Automaton})
          if #objects == 0 then HealingOrb{group = main.current.main, x = x, y = y} end
        end}
      end
      --[[
      local all_units = self:get_all_units()
      for _, unit in ipairs(all_units) do unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1)) end
      heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      ]]--
    end, nil, nil, 'heal')

  elseif self.character == 'infestor' then
    self.attack_sensor = Circle(self.x, self.y, 96)
    self.wide_attack_sensor = Circle(self.x, self.y, 128)
    self.t:cooldown(6, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
      buff1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
      local enemies = table.first2(table.shuffle(self:get_objects_in_shape(self.wide_attack_sensor, main.current.enemies)),
        8 + ((self.malediction == 1 and 1) or (self.malediction == 2 and 3) or (self.malediction == 3 and 5) or 0) + ((main.current.curser_level == 2 and 3) or (main.current.curser_level == 1 and 1) or 0))
      for _, enemy in ipairs(enemies) do
        enemy:curse('infestor', 6*(self.hex_duration_m or 1), (self.level == 3 and 6 or 2), self.dmg, self)
        HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = orange[0], duration = 0.1}
        LightningLine{group = main.current.effects, src = self, dst = enemy, color = orange[0]}
      end
    end, nil, nil, 'attack')

  elseif self.character == 'flagellant' then
    self.t:every(8, function()
      buff1:play{pitch = random:float(0.95, 1.05), volume = 0.3}
      flagellant1:play{pitch = random:float(0.95, 1.05), volume = 0.4}
      local all_units = self:get_all_units()
      for _, unit in ipairs(all_units) do
        if unit.character == 'flagellant' then
          hit2:play{pitch = random:float(0.95, 1.05), volume = 0.4}
          unit:hit(self.level == unit.dmg or 2*unit.dmg)
        end
        if not unit.flagellant_dmg_m then
          unit.flagellant_dmg_m = 1
        end
        if self.level == 3 then
          unit.flagellant_dmg_m = unit.flagellant_dmg_m + 0.12
        else
          unit.flagellant_dmg_m = unit.flagellant_dmg_m + 0.04
        end
      end
    end, nil, nil, 'buff')
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

  if self.ouroboros_technique_r then
    self.t:after(0.01, function()
      self.t:every((self.ouroboros_technique_r == 1 and 0.5) or (self.ouroboros_technique_r == 2 and 0.33) or (self.ouroboros_technique_r == 3 and 0.25), function()
        if self.leader and (state.mouse_control and table.all(self.mouse_control_v_buffer, function(v) return v >= 0.5 end)) or (self.move_right_pressed and love.timer.getTime() - self.move_right_pressed > 1) then
          local target = self:get_closest_object_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
          if target then
            local units = self:get_all_units()
            local unit = random:table(units)
            unit:barrage(unit:angle_to_object(target), 1)
          else
            local units = self:get_all_units()
            local cx, cy = 0, 0
            for _, unit in ipairs(units) do
              cx = cx + unit.x
              cy = cy + unit.y
            end
            cx = cx/#units
            cy = cy/#units
            local unit = random:table(units)
            unit:barrage(unit:angle_from_point(cx, cy), 1)
          end
        end
      end)
    end)
  end

  if self.centipede then self.centipede_mvspd_m = (self.centipede == 1 and 1.1) or (self.centipede == 2 and 1.2) or (self.centipede == 3 and 1.3) end
  if self.amplify then self.amplify_area_dmg_m = (self.amplify == 1 and 1.2) or (self.amplify == 2 and 1.35) or (self.amplify == 3 and 1.5) end

  if self.ballista and launches_projectiles(self.character) then
    self.ballista_dmg_m = (self.ballista == 1 and 1.2) or (self.ballista == 2 and 1.35) or (self.ballista == 3 and 1.5)
  end

  if self.chronomancy then
    if table.any(self.classes, function(v) return v == 'mage' end) then
      self.chronomancy_aspd_m = (self.chronomancy == 1 and 1.15) or (self.chronomancy == 2 and 1.25) or (self.chronomancy == 3 and 1.35)
    end
  end

  if self.leader and self.awakening then
    main.current.t:after(0.1, function()
      local units = self:get_all_units()
      local mages = {}
      for _, unit in ipairs(units) do
        if table.any(unit.classes, function(v) return v == 'mage' end) then
          table.insert(mages, unit)
        end
      end
      local mage = random:table(mages)
      if mage then
        local runs = 0
        while table.any(non_attacking_characters, function(v) return v == mage.character end) and runs < 1000 do mage = random:table(mages); runs = runs + 1 end
        mage.awakening_aspd_m = (self.awakening == 1 and 1.5) or (self.awakening == 2 and 1.75) or (self.awakening == 3 and 2)
        mage.awakening_dmg_m = (self.awakening == 1 and 1.5) or (self.awakening == 2 and 1.75) or (self.awakening == 3 and 2)
      end
    end)
  end

  if self.leader and self.divine_punishment then
    main.current.t:every(5, function()
      local units = self:get_all_units()
      local mages = {}
      for _, unit in ipairs(units) do
        if table.any(unit.classes, function(v) return v == 'mage' end) then
          table.insert(mages, unit)
        end
      end
      local leader = main.current.player:get_leader()
      local enemies = main.current.main:get_objects_by_classes(main.current.enemies)
      if #enemies > 0 then
        thunder1:play{volume = 0.3}
        camera:shake(4, 0.5)
      end
      for _, enemy in ipairs(enemies) do
        enemy:hit(10*#mages)
        LightningLine{group = main.current.effects, src = {x = enemy.x, y = enemy.y - 32}, dst = enemy, color = blue[0], duration = 0.2}
        _G[random:table{'spark1', 'spark2', 'spark3'}]:play{pitch = random:float(0.9, 1.1), volume = 0.3}
      end
    end, nil, nil, 'divine_punishment')
  end

  if self.unwavering_stance and table.any(self.classes, function(v) return v == 'warrior' end) then
    self.unwavering_stance_def_m = 1
    self.t:every(5, function()
      self.unwavering_stance_def_m = self.unwavering_stance_def_m + ((self.unwavering_stance == 1 and 0.04) or (self.unwavering_stance == 2 and 0.08) or (self.unwavering_stance == 3 and 0.12))
    end)
  end

  if self.magnify then
    self.magnify_area_size_m = (self.magnify == 1 and 1.2) or (self.magnify == 2 and 1.35) or (self.magnify == 3 and 1.5)
  end

  if self.unleash and table.any(self.classes, function(v) return v == 'nuker' end) then
    self.unleash_area_dmg_m = 1
    self.unleash_area_size_m = 1
    self.t:every(1, function()
      self.unleash_area_dmg_m = self.unleash_area_dmg_m + 0.01
      self.unleash_area_size_m = self.unleash_area_size_m + 0.01
      if self.dot_area then
        self.dot_area:scale(self.unleash_area_size_m)
      end
    end)
  end

  if self.reinforce then
    main.current.t:after(0.1, function()
      local units = self:get_all_units()
      local any_enchanter = false
      for _, unit in ipairs(units) do
        if table.any(unit.classes, function(v) return v == 'enchanter' end) then
          any_enchanter = true
          break
        end
      end
      if any_enchanter then
        local v = (self.reinforce == 1 and 1.1) or (self.reinforce == 2 and 1.2) or (self.reinforce == 3 and 1.3) or 1
        self.reinforce_dmg_m = v
        self.reinforce_def_m = v
        self.reinforce_aspd_m = v
      end
    end)
  end

  if self.enchanted then
    main.current.t:after(0.1, function()
      local units = self:get_all_units()
      local enchanter_amount = 0
      for _, unit in ipairs(units) do
        if table.any(unit.classes, function(v) return v == 'enchanter' end) then
          enchanter_amount = enchanter_amount + 1
        end
      end
      
      if enchanter_amount >= 2 then
        local unit = random:table(units)
        local runs = 0
        if unit then
          while table.any(non_attacking_characters, function(v) return v == unit.character end) and runs < 1000 do unit = random:table(units); runs = runs + 1 end
          unit.enchanted_aspd_m = (self.enchanted == 1 and 1.33) or (self.enchanted == 2 and 1.66) or (self.enchanted == 3 and 1.99)
        end
      end
    end)
  end

  if self.payback then
    self.payback_dmg_m = 1
  end

  if self.hex_master then
    self.hex_duration_m = 1.25
  end

  if self.unrelenting_stance then
    self.unrelenting_stance_def_m = 1
  end

  if self.leader and self.immolation then
    main.current.t:after(0.1, function()
      local units = self:get_all_units()
      local unit_1 = random:table_remove(units)
      local unit_2 = random:table_remove(units)
      local unit_3 = random:table_remove(units)
      if unit_1 then unit_1.t:every(2, function() unit_1:hit(0.05*unit_1.max_hp) end) end
      if unit_2 then unit_2.t:every(2, function() unit_2:hit(0.05*unit_2.max_hp) end) end
      if unit_3 then unit_3.t:every(2, function() unit_3:hit(0.05*unit_3.max_hp) end) end
      local units = self:get_all_units()
      for _, unit in ipairs(units) do
        unit.immolation_dmg_m = 1
        unit.t:every(2, function() unit.immolation_dmg_m = unit.immolation_dmg_m + 0.08 end)
      end
    end)
  end

  if self.leader and self.shoot_5 then
    main.current.t:after(0.1, function()
      main.current.t:every(0.33, function()
        local units = main.current.player:get_all_units()
        local unit = units[5]
        if unit then
          local target = unit:get_closest_object_in_shape(Circle(unit.x, unit.y, 96), main.current.enemies)
          if target then
            unit:barrage(unit:angle_to_object(target), 1, nil, nil, true)
          else
            unit:barrage(random:float(0, 2*math.pi), 1, nil, nil, true)
          end
        end
      end)
    end)
  end

  if self.leader and self.death_6 then
    main.current.t:after(0.1, function()
      main.current.t:every(3, function()
        flagellant1:play{pitch = random:float(0.95, 1.05), volume = 0.4}
        local units = main.current.player:get_all_units()
        local unit = units[6]
        if unit then
          hit2:play{pitch = random:float(0.95, 1.05), volume = 0.4}
          unit:hit(0.1*unit.max_hp)
        end
      end)
    end)
  end

  if self.character == 'flagellant' and self.level == 3 then
    self.hp = 2*self.max_hp
  end

  if self.leader then
    self.t:after(1, function()
      local units = self:get_all_units()
      for _, unit in ipairs(units) do
        if table.any(unit.classes, function(v) return v == 'psyker' end) then
          Projectile{group = main.current.main, x = unit.x + 24*math.cos(unit.r), y = unit.y + 24*math.sin(unit.r), color = fg[0], v = 200, dmg = unit.dmg, character = 'psyker', parent = unit}
        end
      end

      local psykers = {}
      for _, unit in ipairs(units) do
        if table.any(unit.classes, function(v) return v == 'psyker' end) then
          table.insert(psykers, unit)
        end
      end

      for i = 1, ((main.current.psyker_level == 2 and 4) or (main.current.psyker_level == 1 and 2) or (main.current.psyker_level == 0 and 0) or 0) do
        local unit = random:table(#psykers > 0 and psykers or units)
        Projectile{group = main.current.main, x = unit.x + 24*math.cos(unit.r), y = unit.y + 24*math.sin(unit.r), color = fg[0], v = 200, dmg = unit.dmg, character = 'psyker', parent = unit}
      end

      if self.psyker_orbs then
        for i = 1, ((self.psyker_orbs == 1 and 1) or (self.psyker_orbs == 2 and 2) or (self.psyker_orbs == 3 and 4) or 0) do
          local unit = random:table(#psykers > 0 and psykers or units)
          Projectile{group = main.current.main, x = unit.x + 24*math.cos(unit.r), y = unit.y + 24*math.sin(unit.r), color = fg[0], v = 200, dmg = unit.dmg, character = 'psyker', parent = unit}
        end
      end
    end)
  end

  if self.leader and self.psycholeak then
    main.current.t:every(10, function()
      local unit = main.current.player
      Projectile{group = main.current.main, x = unit.x + 24*math.cos(unit.r), y = unit.y + 24*math.sin(unit.r), color = fg[0], v = 200, dmg = unit.dmg, character = 'psyker', parent = unit}
    end)
  end

  if self.leader and self.divine_blessing then
    main.current.t:every(8, function()
      local x, y = random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16)
      SpawnEffect{group = main.current.effects, x = x, y = y, color = green[0], action = function(x, y)
        local check_circle = Circle(x, y, 2)
        local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Bomb, Pet, Turret, Sentry, Automaton})
        if #objects == 0 then HealingOrb{group = main.current.main, x = x, y = y} end
      end}
    end)
  end

  self.mouse_control_v_buffer = {}

  if main.current:is(MainMenu) then
    self.r = random:table{-math.pi/4, math.pi/4, 3*math.pi/4, -3*math.pi/4}
    self:set_angle(self.r)
  end
end


function Player:update(dt)
  self:update_game_object(dt)

  if self.character == 'squire' then
    local all_units = self:get_all_units()
    for _, unit in ipairs(all_units) do
      unit.squire_dmg_m = 1.2
      unit.squire_def_m = 1.2
      if self.level == 3 then
        unit.squire_dmg_m = 1.5
        unit.squire_def_m = 1.5
        unit.squire_aspd_m = 1.3
        unit.squire_mvspd_m = 1.3
      end
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
    if class_levels.nuker >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.curser >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.forcer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.swarmer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.voider >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.sorcerer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.mercenary >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.explorer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    self.vagrant_dmg_m = 1 + 0.1*number_of_active_sets
    self.vagrant_aspd_m = 1 + 0.1*number_of_active_sets
  end

  if self.character == 'swordsman' and self.level == 3 then
    self.swordsman_dmg_m = 2
  end

  if self.character == 'outlaw' and self.level == 3 then
    self.outlaw_aspd_m = 1.5
  end

  if table.any(self.classes, function(v) return v == 'ranger' end) then
    if main.current.ranger_level == 2 then self.chance_to_barrage = 16
    elseif main.current.ranger_level == 1 then self.chance_to_barrage = 8
    elseif main.current.ranger_level == 0 then self.chance_to_barrage = 0 end
  end

  if table.any(self.classes, function(v) return v == 'warrior' end) then
    if main.current.warrior_level == 2 then self.warrior_def_a = 50
    elseif main.current.warrior_level == 1 then self.warrior_def_a = 25
    elseif main.current.warrior_level == 0 then self.warrior_def_a = 0 end
  end

  self.heal_effect_m = 1
  if self.blessing then self.heal_effect_m = self.heal_effect_m*((self.blessing == 1 and 1.1) or (self.blessing == 2 and 1.2) or (self.blessing == 3 and 1.3)) end

  if table.any(self.classes, function(v) return v == 'nuker' end) then
    if main.current.nuker_level == 2 then self.nuker_area_size_m = 1.25; self.nuker_area_dmg_m = 1.25
    elseif main.current.nuker_level == 1 then self.nuker_area_size_m = 1.15; self.nuker_area_dmg_m = 1.15
    elseif main.current.nuker_level == 0 then self.nuker_area_size_m = 1; self.nuker_area_dmg_m = 1 end
  end

  if main.current.conjurer_level == 2 then self.conjurer_buff_m = 1.5
  elseif main.current.conjurer_level == 1 then self.conjurer_buff_m = 1.25
  else self.conjurer_buff_m = 1 end

  if table.any(self.classes, function(v) return v == 'rogue' end) then
    if main.current.rogue_level == 2 then self.chance_to_crit = 30
    elseif main.current.rogue_level == 1 then self.chance_to_crit = 15
    elseif main.current.rogue_level == 0 then self.chance_to_crit = 0 end
  end

  if main.current.enchanter_level == 2 then self.enchanter_dmg_m = 1.25
  elseif main.current.enchanter_level == 1 then self.enchanter_dmg_m = 1.15
  else self.enchanter_dmg_m = 1 end

  if table.any(self.classes, function(v) return v == 'explorer' end) then
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
    if class_levels.nuker >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.curser >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.forcer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.swarmer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.voider >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.sorcerer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.mercenary >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    if class_levels.explorer >= 1 then number_of_active_sets = number_of_active_sets + 1 end
    self.explorer_dmg_m = 1 + 0.15*number_of_active_sets
    self.explorer_aspd_m = 1 + 0.15*number_of_active_sets
  end

  if main.current.forcer_level == 2 then self.knockback_m = 1.5
  elseif main.current.forcer_level == 1 then self.knockback_m = 1.25
  else self.knockback_m = 1 end
  if self.force_push then self.knockback_m = self.knockback_m*1.25 end

  self.dot_dmg_m = 1
  if table.any(self.classes, function(v) return v == 'voider' end) then
    if main.current.voider_level == 2 then self.dot_dmg_m = 1.4
    elseif main.current.voider_level == 1 then self.dot_dmg_m = 1.2
    else self.dot_dmg_m = 1 end
  end
  if self.call_of_the_void then self.dot_dmg_m = (self.dot_dmg_m or 1)*((self.call_of_the_void == 1 and 1.3) or (self.call_of_the_void == 2 and 1.6) or (self.call_of_the_void == 3 and 1.9) or 1) end

  if self.ouroboros_technique_l and self.leader then
    local units = self:get_all_units()
    if (state.mouse_control and table.all(self.mouse_control_v_buffer, function(v) return v <= -0.5 end)) or (self.move_left_pressed and love.timer.getTime() - self.move_left_pressed > 1) then
      for _, unit in ipairs(units) do
        unit.ouroboros_def_m = (self.ouroboros_technique_l == 1 and 1.15) or (self.ouroboros_technique_l == 2 and 1.25) or (self.ouroboros_technique_l == 3 and 1.35)
      end
    else
      for _, unit in ipairs(units) do
        unit.ouroboros_def_m = 1
      end
    end
  end

  if self.berserking and table.any(self.classes, function(v) return v == 'warrior' end) then
    self.berserking_aspd_m = math.remap(self.hp/self.max_hp, 0, 1, (self.berserking == 1 and 1.5) or (self.berserking == 2 and 1.75) or (self.berserking == 3 and 2), 1)
  end

  if self.speed_3 and self.follower_index == 2 then
    self.speed_3_aspd_m = 1.5
  end

  if self.damage_4 and self.follower_index == 3 then
    self.damage_4_dmg_m = 1.3
  end

  if self.defensive_stance and self.leader then
    self.defensive_stance_def_m = (self.defensive_stance == 1 and 1.1) or (self.defensive_stance == 2 and 1.2) or (self.defensive_stance == 3 and 1.3)
  end

  if self.defensive_stance and not self.leader and self.follower_index == #self.parent.followers then
    self.defensive_stance_def_m = (self.defensive_stance == 1 and 1.1) or (self.defensive_stance == 2 and 1.2) or (self.defensive_stance == 3 and 1.3)
  end

  if self.offensive_stance and self.leader then
    self.offensive_stance_dmg_m = (self.offensive_stance == 1 and 1.1) or (self.offensive_stance == 2 and 1.2) or (self.offensive_stance == 3 and 1.3)
  end

  if self.offensive_stance and not self.leader and self.follower_index == #self.parent.followers then
    self.offensive_stance_dmg_m = (self.offensive_stance == 1 and 1.1) or (self.offensive_stance == 2 and 1.2) or (self.offensive_stance == 3 and 1.3)
  end

  if self.leader and #self.followers == 0 and self.last_stand then
    self.last_stand_dmg_m = 1.2
    self.last_stand_def_m = 1.2
    self.last_stand_aspd_m = 1.2
    self.last_stand_area_size_m = 1.2
    self.last_stand_area_dmg_m = 1.2
    self.last_stand_mvspd_m = 1.2
  end

  if self.dividends and table.any(self.classes, function(v) return v == 'mercenary' end) then
    self.dividends_dmg_m = (1 + gold/100)
  end

  if self.character == 'flagellant' and self.level == 3 then
    self.flagellant_hp_m = 2
  end

  if self.haste then
    if self.hasted then
      self.haste_mvspd_m = math.clamp(math.remap(love.timer.getTime() - self.hasted, 0, 4, 1.5, 1), 1, 1.5)
    else self.haste_mvspd_m = 1 end
  end

  self.buff_def_a = (self.warrior_def_a or 0)
  self.buff_aspd_m = (self.chronomancer_aspd_m or 1)*(self.vagrant_aspd_m or 1)*(self.outlaw_aspd_m or 1)*(self.fairy_aspd_m or 1)*(self.psyker_aspd_m or 1)*(self.chronomancy_aspd_m or 1)*(self.awakening_aspd_m or 1)*(self.berserking_aspd_m or 1)*(self.reinforce_aspd_m or 1)*(self.squire_aspd_m or 1)*(self.speed_3_aspd_m or 1)*(self.last_stand_aspd_m or 1)*(self.enchanted_aspd_m or 1)*(self.explorer_aspd_m or 1)*(self.magician_aspd_m or 1)
  self.buff_dmg_m = (self.squire_dmg_m or 1)*(self.vagrant_dmg_m or 1)*(self.enchanter_dmg_m or 1)*(self.swordsman_dmg_m or 1)*(self.flagellant_dmg_m or 1)*(self.psyker_dmg_m or 1)*(self.ballista_dmg_m or 1)*(self.awakening_dmg_m or 1)*(self.reinforce_dmg_m or 1)*(self.payback_dmg_m or 1)*(self.immolation_dmg_m or 1)*(self.damage_4_dmg_m or 1)*(self.offensive_stance_dmg_m or 1)*(self.last_stand_dmg_m or 1)*(self.dividends_dmg_m or 1)*(self.explorer_dmg_m or 1)
  self.buff_def_m = (self.squire_def_m or 1)*(self.ouroboros_def_m or 1)*(self.unwavering_stance_def_m or 1)*(self.reinforce_def_m or 1)*(self.defensive_stance_def_m or 1)*(self.last_stand_def_m or 1)*(self.unrelenting_stance_def_m or 1)*(self.hardening_def_m or 1)
  self.buff_area_size_m = (self.nuker_area_size_m or 1)*(self.magnify_area_size_m or 1)*(self.unleash_area_size_m or 1)*(self.last_stand_area_size_m or 1)
  self.buff_area_dmg_m = (self.nuker_area_dmg_m or 1)*(self.amplify_area_dmg_m or 1)*(self.unleash_area_dmg_m or 1)*(self.last_stand_area_dmg_m or 1)
  self.buff_mvspd_m = (self.wall_rider_mvspd_m or 1)*(self.centipede_mvspd_m or 1)*(self.squire_mvspd_m or 1)*(self.last_stand_mvspd_m or 1)*(self.haste_mvspd_m or 1)
  self.buff_hp_m = (self.flagellant_hp_m or 1)
  self:calculate_stats()

  if self.attack_sensor then self.attack_sensor:move_to(self.x, self.y) end
  if self.wide_attack_sensor then self.wide_attack_sensor:move_to(self.x, self.y) end
  if self.gun_kata_sensor then self.gun_kata_sensor:move_to(self.x, self.y) end
  self.t:set_every_multiplier('shoot', self.aspd_m)
  self.t:set_every_multiplier('attack', self.aspd_m)

  if self.leader then
    if not main.current:is(MainMenu) then
      if input.move_left.pressed and not self.move_right_pressed then self.move_left_pressed = love.timer.getTime() end
      if input.move_right.pressed and not self.move_left_pressed then self.move_right_pressed = love.timer.getTime() end
      if input.move_left.released then self.move_left_pressed = nil end
      if input.move_right.released then self.move_right_pressed = nil end

      if state.mouse_control then
        self.mouse_control_v = Vector(math.cos(self.r), math.sin(self.r)):perpendicular():dot(Vector(math.cos(self:angle_to_mouse()), math.sin(self:angle_to_mouse())))
        self.r = self.r + math.sign(self.mouse_control_v)*1.66*math.pi*dt
        table.insert(self.mouse_control_v_buffer, 1, self.mouse_control_v)
        if #self.mouse_control_v_buffer > 64 then self.mouse_control_v_buffer[65] = nil end
      else
        if input.move_left.down then self.r = self.r - 1.66*math.pi*dt end
        if input.move_right.down then self.r = self.r + 1.66*math.pi*dt end
      end
    end

    local total_v = 0
    local units = self:get_all_units()
    for _, unit in ipairs(units) do
      total_v = total_v + unit.max_v
    end
    total_v = math.floor(total_v/#units)
    self.total_v = total_v

    self:set_velocity(total_v*math.cos(self.r), total_v*math.sin(self.r))

    if not main.current.won and not main.current.choosing_passives then
      if not state.no_screen_movement then
        local vx, vy = self:get_velocity()
        local hd = math.remap(math.abs(self.x - gw/2), 0, 192, 1, 0)
        local vd = math.remap(math.abs(self.y - gh/2), 0, 108, 1, 0)
        camera.x = camera.x + math.remap(vx, -100, 100, -24*hd, 24*hd)*dt
        camera.y = camera.y + math.remap(vy, -100, 100, -8*vd, 8*vd)*dt
        if input.move_right.down then camera.r = math.lerp_angle_dt(0.01, dt, camera.r, math.pi/256)
        elseif input.move_left.down then camera.r = math.lerp_angle_dt(0.01, dt, camera.r, -math.pi/256)
          --[[
        elseif input.move_down.down then camera.r = math.lerp_angle_dt(0.01, dt, camera.r, math.pi/256)
        elseif input.move_up.down then camera.r = math.lerp_angle_dt(0.01, dt, camera.r, -math.pi/256)
        ]]--
        else camera.r = math.lerp_angle_dt(0.005, dt, camera.r, 0) end
      end
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
        p = self.parent.previous_positions[i-1]
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
    if self.magician_invulnerable then
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, blue_transparent)
    elseif self.undead then
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.color, 1)
    else
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, (self.hfx.hit.f or self.hfx.shoot.f) and fg[0] or self.color)
    end

    if self.leader and state.arrow_snake then
      local x, y = self.x + 0.9*self.shape.w, self.y
      graphics.line(x + 3, y, x, y - 3, character_colors[self.character], 1)
      graphics.line(x + 3, y, x, y + 3, character_colors[self.character], 1)
    end

    if self.ouroboros_def_m and self.ouroboros_def_m > 1 then
      graphics.rectangle(self.x, self.y, 1.25*self.shape.w, 1.25*self.shape.h, 3, 3, yellow_transparent)
    end

    if self.divined then
      graphics.rectangle(self.x, self.y, 1.25*self.shape.w, 1.25*self.shape.h, 3, 3, green_transparent)
    end

    if self.fairyd then
      graphics.rectangle(self.x, self.y, 1.25*self.shape.w, 1.25*self.shape.h, 3, 3, blue_transparent)
    end
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

      if self.wall_echo then
        if random:bool(34) then
          local target = self:get_closest_object_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
          if target then
            self:barrage(self:angle_to_object(target), 2)
          else
            local r = Vector(contact:getNormal()):angle()
            self:barrage(r, 2)
          end
        end
      end

      if self.wall_rider then
        local units = self:get_all_units()
        for _, unit in ipairs(units) do unit.wall_rider_mvspd_m = 1.25 end
        trigger:after(1, function()
          for _, unit in ipairs(units) do unit.wall_rider_mvspd_m = 1 end
        end, 'wall_rider')
      end
    end

  elseif table.any(main.current.enemies, function(v) return other:is(v) end) then
    other:push(random:float(25, 35)*(self.knockback_m or 1), self:angle_to_object(other))
    if self.character == 'vagrant' or self.character == 'psykeeper' then other:hit(2*self.dmg)
    else other:hit(self.dmg) end
    if other.headbutting then
      self:hit((4 + math.floor(other.level/3))*other.dmg)
      other.headbutting = false
    else self:hit(other.dmg) end
    HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = self.color} end
    for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = other.color} end
  end
end


function Player:hit(damage, from_undead)
  if self.dead then return end
  if self.magician_invulnerable then return end
  if self.undead and not from_undead then return end
  self.hfx:use('hit', 0.25, 200, 10)
  self:show_hp()

  local actual_damage = math.max(self:calculate_damage(damage), 0)
  self.hp = self.hp - actual_damage
  _G[random:table{'player_hit1', 'player_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  camera:shake(4, 0.5)
  main.current.damage_taken = main.current.damage_taken + actual_damage

  if self.payback and table.any(self.classes, function(v) return v == 'enchanter' end) then
    local units = self:get_all_units()
    for _, unit in ipairs(units) do
      if not unit.payback_dmg_m then unit.payback_dmg_m = 1 end
      unit.payback_dmg_m = unit.payback_dmg_m + ((self.payback == 1 and 0.02) or (self.payback == 2 and 0.05) or (self.payback == 3 and 0.08) or 0)
    end
  end

  if self.unrelenting_stance and table.any(self.classes, function(v) return v == 'warrior' end) then
    local units = self:get_all_units()
    for _, unit in ipairs(units) do
      if not unit.unrelenting_stance_def_m then unit.unrelenting_stance_def_m = 1 end
      unit.unrelenting_stance_def_m = unit.unrelenting_stance_def_m + ((self.unrelenting_stance == 1 and 0.02) or (self.unrelenting_stance == 2 and 0.05) or (self.unrelenting_stance == 3 and 0.08) or 0)
    end
  end

  if self.character == 'beastmaster' and self.level == 3 then
    critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    trigger:after(0.01, function()
      for i = 1, 4 do
        Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 20, dmg = self.dmg, parent = self}
      end
    end)
  end

  if self.crucio then
    local enemies = main.current.main:get_objects_by_classes(main.current.enemies)
    for _, enemy in ipairs(enemies) do
      enemy:hit(((self.crucio == 1 and 0.2) or (self.crucio == 2 and 0.3) or (self.crucio == 3 and 0.4))*actual_damage)
      HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = fg[0], duration = 0.1}
    end
  end

  if self.character == 'psykeeper' then
    self.stored_heal = self.stored_heal + actual_damage
    if self.stored_heal > (0.25*self.max_hp) then
      self.stored_heal = 0
      local check_circle = Circle(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16), 2)
      local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Bomb, Pet, Turret, Sentry, Automaton})
      while #objects > 0 do
        check_circle:move_to(random:float(main.current.x1 + 16, main.current.x2 - 16), random:float(main.current.y1 + 16, main.current.y2 - 16))
        objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Volcano, Saboteur, Bomb, Pet, Turret, Sentry, Automaton})
      end
      for i = 1, 3 do
        SpawnEffect{group = main.current.effects, x = check_circle.x, y = check_circle.y, color = green[0], action = function(x, y)
          local check_circle = Circle(x, y, 2)
          local objects = main.current.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Sentry, Volcano, Saboteur, Bomb, Pet, Turret, Automaton})
          if #objects == 0 then
            HealingOrb{group = main.current.main, x = x, y = y}
          end
        end}
      end
    end

    if self.level == 3 then
      local enemies = main.current.main:get_objects_by_classes(main.current.enemies)
      for _, enemy in ipairs(enemies) do
        enemy:hit(2*actual_damage/#enemies)
      end
    end
  end

  self.character_hp:change_hp()

  if self.hp <= 0 then
    if self.divined then
      self:heal(self.max_hp)
      heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      for i = 1, random:int(4, 6) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
      HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 12}:scale_down(0.3):change_color(0.5, self.color)
      self.divined = false

    elseif self.lasting_7 and self.follower_index == 6 and not self.undead then
      self.undead = true
      self.t:after(10, function() self:hit(10000, true) end)

    else
      hit4:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      slow(0.25, 1)
      for i = 1, random:int(4, 6) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
      HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 12}:scale_down(0.3):change_color(0.5, self.color)
      if self.leader and #self.followers == 0 then
        if main.current:die() then
          self.dead = true
        else
          self.hp = 1
        end
      else
        self.dead = true
        if self.leader then self:recalculate_followers()
        else self.parent:recalculate_followers() end
        if #main.current.player.followers == 0 and main.current.player.last_stand then
          heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          buff1:play{pitch == random:float(0.9, 1.1), volume = 0.5}
          main.current.player:heal(10000)
        end
      end

      if self.kinetic_bomb then
        elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
        local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
        for _, enemy in ipairs(enemies) do
          enemy:push(random:float(30, 50)*(self.knockback_m or 1), self:angle_to_object(enemy))
        end
      end

      if self.porcupine_technique then
        main.current.t:after(0.01, function()
          local r = 0
          for i = 1, 8 do
            archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
            HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
            local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.color, dmg = self.dmg,
            parent = self, character = 'barrage', level = self.level, pierce = 1000, ricochet = 2}
            Projectile(table.merge(t, mods or {}))
            r = r + math.pi/4
          end
        end)
      end

      if self.hardening then
        local units = self:get_all_units()
        for _, unit in ipairs(units) do
          unit.hardening_def_m = 2.5
          unit.t:after(3, function() unit.hardening_def_m = 1 end)
        end
      end

      if self.annihilation and table.any(self.classes, function(v) return v == 'voider' end) then
        local enemies = self.group:get_objects_by_classes({Seeker, EnemyCritter})
        for _, enemy in ipairs(enemies) do
          enemy:apply_dot(self.dmg*(self.dot_dmg_m or 1)*(main.current.chronomancer_dot or 1), 3)
        end
      end

      if self.insurance then
        if random:bool(4*((main.current.mercenary_level == 2 and 16) or (main.current.mercenary_level == 1 and 8) or 0)) then
          main.current.t:after(0.01, function()
            Gold{group = main.current.main, x = self.x, y = self.y}
            Gold{group = main.current.main, x = self.x, y = self.y}
          end)
        end
      end

      if self.dot_area then self.dot_area.dead = true; self.dot_area = nil end
    end
  end
end


function Player:sorcerer_repeat()
  local enemies = self.group:get_objects_by_classes(main.current.enemies)
  if not enemies then return end
  local enemy = random:table(enemies)
  if enemy then
    if self.gravity_field then
      ForceArea{group = main.current.effects, x = enemy.x, y = enemy.y, rs = self.area_size_m*24, color = fg[0], character = 'gravity_field', parent = self}
    end
  end

  local enemy = random:table(enemies)
  if enemy then
    if self.burning_field then
      fire1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
      DotArea{group = main.current.effects, x = enemy.x, y = enemy.y, rs = self.area_size_m*24, color = red[0], dmg = 30*self.area_dmg_m*(self.dot_dmg_m or 1), duration = 2, character = 'burning_field'}
    end
  end

  local enemy = random:table(enemies)
  if enemy then
    if self.freezing_field then
      frost1:play{pitch = random:float(0.8, 1.2), volume = 0.3}
      elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.3}
      Area{group = main.current.effects, x = enemy.x, y = enemy.y, w = self.area_size_m*36, color = blue[0], character = 'freezing_field', parent = self}
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

  self.character_hp:change_hp()
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


function Player:get_leader()
  return (self.leader and self) or self.parent
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
  if self.character == 'beastmaster' then crit = random:bool(10) end
  if self.chance_to_crit and random:bool(self.chance_to_crit) then dmg_m = ((self.assassination == 1 and 8) or (self.assassination == 2 and 10) or (self.assassination == 3 and 12) or 4); crit = true end
  if self.assassination and table.any(self.classes, function(v) return v == 'rogue' end) then
    if not crit then
      dmg_m = 0.5
    end
  end

  if self.character == 'thief' then
    dmg_m = dmg_m*2
    if self.level == 3 and crit then
      dmg_m = dmg_m*10
      main.current.gold_picked_up = main.current.gold_picked_up + 1
    end
  end

  if crit and mods.spawn_critters_on_crit then
    critter1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    trigger:after(0.01, function()
      for i = 1, mods.spawn_critters_on_crit do
        Critter{group = main.current.main, x = self.x, y = self.y, color = orange[0], r = random:float(0, 2*math.pi), v = 10, dmg = self.dmg, parent = self}
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
    if self.dg_counter == 5 and self.level == 3 then
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

  if self.character == 'vagrant' or self.character == 'artificer' then
    shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.2}
  elseif self.character == 'dual_gunner' then
    dual_gunner1:play{pitch = random:float(0.95, 1.05), volume = 0.3}
    dual_gunner2:play{pitch = random:float(0.95, 1.05), volume = 0.3}
  elseif self.character == 'archer' or self.character == 'hunter' or self.character == 'barrager' or self.character == 'corruptor' then
    archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
  elseif self.character == 'wizard' or self.character == 'lich' or self.character == 'arcanist' then
    wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
  elseif self.character == 'scout' or self.character == 'outlaw' or self.character == 'blade' or self.character == 'spellblade' or self.character == 'jester' or self.character == 'assassin' or self.character == 'beastmaster' or
         self.character == 'thief' then
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

  if self.character == 'arcanist' then
    arcane1:play{pitch = random:float(0.95, 1.05), volume = 0.3}
  end

  if self.chance_to_barrage and random:bool(self.chance_to_barrage) then
    self:barrage(r, 3)
  end
end


function Player:attack(area, mods)
  mods = mods or {}
  camera:shake(2, 0.5)
  self.hfx:use('shoot', 0.25)
  local t = {group = main.current.effects, x = mods.x or self.x, y = mods.y or self.y, r = self.r, w = self.area_size_m*(area or 64), color = self.color, dmg = self.area_dmg_m*self.dmg,
    character = self.character, level = self.level, parent = self}
  Area(table.merge(t, mods))

  if self.character == 'swordsman' or self.character == 'barbarian' or self.character == 'juggernaut' or self.character == 'highlander' then
    _G[random:table{'swordsman1', 'swordsman2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.75}
  elseif self.character == 'elementor' then
    elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
  elseif self.character == 'psychic' then
    psychic1:play{pitch = random:float(0.9, 1.1), volume = 0.4}
  elseif self.character == 'launcher' then
    buff1:play{pitch == random:float(0.9, 1.1), volume = 0.5}
  end

  if self.character == 'juggernaut' then
    elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
  end
end


function Player:dot_attack(area, mods)
  mods = mods or {}
  camera:shake(2, 0.5)
  self.hfx:use('shoot', 0.25)
  local t = {group = main.current.effects, x = mods.x or self.x, y = mods.y or self.y, r = self.r, rs = self.area_size_m*(area or 64), color = self.color, dmg = self.area_dmg_m*self.dmg*(self.dot_dmg_m or 1),
    character = self.character, level = self.level, parent = self}
  DotArea(table.merge(t, mods))

  dot1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
end


function Player:barrage(r, n, pierce, ricochet, shoot_5, homing)
  n = n or 8
  for i = 1, n do
    self.t:after((i-1)*0.075, function()
      if shoot_5 then archer1:play{pitch = random:float(0.95, 1.05), volume = 0.2}
      else archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35} end
      HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
      local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r + random:float(-math.pi/16, math.pi/16), color = self.color, dmg = self.dmg,
      parent = self, character = 'barrage', level = self.level, pierce = pierce or 0, ricochet = ricochet or 0, shoot_5 = shoot_5, homing = homing}
      Projectile(table.merge(t, mods or {}))
    end)
  end
end




Projectile = Object:extend()
Projectile:implement(GameObject)
Projectile:implement(Physics)
function Projectile:init(args)
  self:init_game_object(args)
  if not self.group.world then self.dead = true; return end
  if tostring(self.x) == tostring(0/0) or tostring(self.y) == tostring(0/0) then self.dead = true; return end
  self.hfx:add('hit', 1)
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

  elseif self.character == 'psyker' then
    self.pierce = 10000
    self.orbit_distance = random:float(56, 64)
    self.orbit_speed = random:float(2, 4)*((self.parent.orbitism == 1 and 1.25) or (self.parent.orbitism == 2 and 1.50) or (self.parent.orbitism == 3 and 1.75) or 1)*(1/self.parent.aspd_m)
    self.orbit_offset = random:float(0, 2*math.pi)
    self.dmg = self.dmg*((self.parent.psychosink == 1 and 1.4) or (self.parent.psychosink == 2 and 1.8) or (self.parent.psychosink == 3 and 2.2) or 1)

  elseif self.character == 'lich' then
    self.spring:pull(0.15)
    self.t:every(0.08, function()
      HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color}
    end)

  elseif self.character == 'arcanist' then
    self.dmg = 0.2*self.dmg
    self.t:every(0.08, function() HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color, r = self.r + math.pi + random:float(-math.pi/6, math.pi/6), v = random:float(10, 25), parent = self} end)
    self.t:every(self.parent.level == 3 and 0.54 or 0.8, function()
      local enemies = table.head(self:get_objects_in_shape(Circle(self.x, self.y, 128), main.current.enemies), self.level == 3 and 2 or 1)
      for _, enemy in ipairs(enemies) do
        arcane2:play{pitch = random:float(0.7, 1.3), volume = 0.15}
        self.hfx:use('hit', 0.5)
        local r = self:angle_to_object(enemy)
        local t = {group = main.current.main, x = self.x + 8*math.cos(r), y = self.y + 8*math.sin(r), v = 250, r = r, color = self.parent.color, dmg = self.parent.dmg, pierce = 2, character = 'arcanist_projectile',
        parent = self.parent, level = self.parent.level}
        local check_circle = Circle(t.x, t.y, 2)
        local objects = main.current.main:get_objects_in_shape(check_circle, {Player, Seeker, EnemyCritter, Critter, Sentry, Volcano, Saboteur, Bomb, Pet, Turret, Automaton})
        if #objects == 0 then Projectile(table.merge(t, mods or {})) end
      end
    end)

  elseif self.character == 'witch' and self.level == 3 then
    self.chain = 1

  elseif self.character == 'miner' then
    self.homing = true
    if self.level == 3 then
      self.pierce = 2
    end
  end

  if self.parent.divine_machine_arrow and table.any(self.parent.classes, function(v) return v == 'ranger' end) then
    if random:bool((self.parent.divine_machine_arrow == 1 and 10) or (self.parent.divine_machine_arrow == 2 and 20) or (self.parent.divine_machine_arrow == 3 and 30)) then
      self.homing = true
      self.pierce = self.parent.divine_machine_arrow or 0
    end
  end

  if self.homing then
    self.homing = false
    self.t:after(0.1, function()
      self.homing = true
      self.closest_sensor = Circle(self.x, self.y, 64)
    end)
  end

  self.distance_travelled = 0
  self.distance_dmg_m = 1

  if self.parent.blunt_arrow and table.any(self.parent.classes, function(v) return v == 'ranger' end) then
    if random:bool((self.parent.blunt_arrow == 1 and 10) or (self.parent.blunt_arrow == 2 and 20) or (self.parent.blunt_arrow == 3 and 30)) then
      self.knockback = 10
    end
  end

  if self.parent.flying_daggers and table.any(self.parent.classes, function(v) return v == 'rogue' end) then
    self.chain = self.chain + ((self.parent.flying_daggers == 1 and 2) or (self.parent.flying_daggers == 2 and 3) or (self.parent.flying_daggers == 3 and 4))
  end
end


function Projectile:update(dt)
  self:update_game_object(dt)

  if self.character == 'psyker' then
    if self.parent.dead then self.dead = true; self.parent = nil; return end
    self:set_position(self.parent.x + self.orbit_distance*math.cos(self.orbit_speed*main.current.t.time + self.orbit_offset),
      self.parent.y + self.orbit_distance*math.sin(self.orbit_speed*main.current.t.time + self.orbit_offset))
    local dx, dy = self.x - (self.previous_x or 0), self.y - (self.previous_y or 0)
    self.r = Vector(dx, dy):angle()
    self:set_angle(self.r)
    self.previous_x, self.previous_y = self.x, self.y
    return
  end

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

  --[[
  if self.parent.point_blank or self.parent.longshot then
    self.distance_travelled = self.distance_travelled + math.length(self:get_velocity())
    if self.parent.point_blank and self.parent.longshot then
      self.distance_dmg_m = 1
    elseif self.parent.point_blank then
      self.distance_dmg_m = math.remap(self.distance_travelled, 0, 15000, 2, 0.75)
    elseif self.parent.longshot then
      self.distance_dmg_m = math.remap(self.distance_travelled, 0, 15000, 0.75, 2)
    end
  end
  ]]--
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
      graphics.circle(self.x, self.y, 3 + random:float(-1, 1), self.color)
    graphics.pop()

  elseif self.character == 'arcanist' then
    graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
      graphics.circle(self.x, self.y, 4, self.hfx.hit.f and fg[0] or self.color)
    graphics.pop()

  elseif self.character == 'psyker' then
    graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
      graphics.circle(self.x, self.y, 2.5, self.hfx.hit.f and fg[0] or self.color)
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
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*24, color = self.color, dmg = self.parent.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self,
      void_rift = self.parent.void_rift, echo_barrage = self.parent.echo_barrage}
  elseif self.character == 'blade' then
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*64, color = self.color, dmg = self.parent.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self,
      void_rift = self.parent.void_rift, echo_barrage = self.parent.echo_barrage}
  elseif self.character == 'cannoneer' then
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*96, color = self.color, dmg = 2*self.parent.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self,
      void_rift = self.parent.void_rift, echo_barrage = self.parent.echo_barrage}
    if self.level == 3 then
      self.parent.t:every(0.3, function()
        _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        Area{group = main.current.effects, x = self.x + random:float(-32, 32), y = self.y + random:float(-32, 32), r = self.r + random:float(0, 2*math.pi), w = self.parent.area_size_m*48, color = self.color, 
          dmg = 0.5*self.parent.area_dmg_m*self.dmg, character = self.character, level = self.level, parent = self, void_rift = self.parent.void_rift, echo_barrage = self.parent.echo_barrage}
      end, 7)
    end
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
    if self.character == 'archer' or self.character == 'hunter' or self.character == 'barrage' or self.character == 'barrager' or self.character == 'sentry' then
      if self.ricochet <= 0 then
        self:die(x, y, r, 0)
        WallArrow{group = main.current.main, x = x, y = y, r = self.r, color = self.color}
      else
        local r = Unit.bounce(self, nx, ny)
        self.r = r
        self.ricochet = self.ricochet - 1
      end
      _G[random:table{'arrow_hit_wall1', 'arrow_hit_wall2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.2}
    elseif self.character == 'scout' or self.character == 'outlaw' or self.character == 'blade' or self.character == 'spellblade' or self.character == 'jester' or self.character == 'beastmaster' or self.character == 'witch' or
           self.character == 'thief' then
      self:die(x, y, r, 0)
      knife_hit_wall1:play{pitch = random:float(0.9, 1.1), volume = 0.2}
      local r = Unit.bounce(self, nx, ny)
      self.parent.t:after(0.01, function()
        WallKnife{group = main.current.main, x = x, y = y, r = r, v = self.v*0.1, color = self.color}
      end)
      if self.character == 'spellblade' then
        magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
      end
    elseif self.character == 'artificer_death' then
      if self.ricochet <= 0 then
        self:die(x, y, r, random:int(2, 3))
        magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
      else
        local r = Unit.bounce(self, nx, ny)
        self.r = r
        self.ricochet = self.ricochet - 1
      end
    elseif self.character == 'wizard' or self.character == 'lich' or self.character == 'arcanist' or self.character == 'arcanist_projectile' or self.character == 'witch' then
      self:die(x, y, r, random:int(2, 3))
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
    elseif self.character == 'cannoneer' then
      self:die(x, y, r, random:int(2, 3))
      cannon_hit_wall1:play{pitch = random:float(0.95, 1.05), volume = 0.1}
    elseif self.character == 'engineer' or self.character == 'dual_gunner' or self.character == 'miner' then
      self:die(x, y, r, random:int(2, 3))
      _G[random:table{'turret_hit_wall1', 'turret_hit_wall2'}]:play{pitch = random:float(0.9, 1.1), volume = 0.2}
    elseif self.character == 'psyker' then
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
          if self.parent.ultimatum then
            self.dmg = self.dmg*((self.parent.ultimatum == 1 and 1.1) or (self.parent.ultimatum == 2 and 1.2) or (self.parent.ultimatum == 3 and 1.3))
          end
        end
      end
      HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = fg[0], duration = 0.1}
      HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color}
      HitParticle{group = main.current.effects, x = self.x, y = self.y, color = other.color}
    end

    if self.character == 'archer' or self.character == 'scout' or self.character == 'outlaw' or self.character == 'blade' or self.character == 'hunter' or self.character == 'spellblade' or self.character == 'engineer' or
    self.character == 'jester' or self.character == 'assassin' or self.character == 'barrager' or self.character == 'beastmaster' or self.character == 'witch' or self.character == 'miner' or self.character == 'thief' or 
    self.character == 'psyker' or self.character == 'sentry' then
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      if self.character == 'spellblade' or self.character == 'psyker' then
        magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
      end
    elseif self.character == 'wizard' or self.character == 'lich' or self.character == 'arcanist' then
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
    elseif self.character == 'arcanist_projectile' then
      magic_area1:play{pitch = random:float(0.95, 1.05), volume = 0.075}
    else
      hit3:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end

    other:hit(self.dmg*(self.distance_dmg_m or 1), self)

    if self.character == 'wizard' and self.level == 3 then
      Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*32, color = self.color, dmg = self.parent.area_dmg_m*self.dmg, character = self.character, parent = self,
        void_rift = self.parent.void_rift, echo_barrage = self.parent.echo_barrage}
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

    if self.character == 'assassin' then
      other:apply_dot((self.crit and 4*self.dmg or self.dmg/2)*(self.dot_dmg_m or 1)*(main.current.chronomancer_dot or 1), 3)
    end

    if self.parent and self.parent.chain_infused then
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
          dst:hit(0.2*self.dmg*(self.distance_dmg_m or 1))
          LightningLine{group = main.current.effects, src = src, dst = dst}
          src = dst 
        end
      end
    end

    if self.parent and self.parent.lightning_strike then
      if random:bool((self.parent.lightning_strike == 1 and 5) or (self.parent.lightning_strike == 2 and 10) or (self.parent.lightning_strike == 3 and 15)) then
        local src = other
        for j = 1, 3 do
          main.current.t:after((j-1)*0.1, function()
            if not self.parent then return end
            _G[random:table{'spark1', 'spark2', 'spark3'}]:play{pitch = random:float(0.9, 1.1), volume = 0.3}
            for i = 1, 3 do
              table.insert(self.infused_enemies_hit, src)
              local dst = src:get_random_object_in_shape(Circle(src.x, src.y, 64), main.current.enemies, self.infused_enemies_hit)
              if dst then
                dst:hit(0.33*((self.parent.lightning_strike == 1 and 0.6) or (self.parent.lightning_strike == 2 and 0.8) or (self.parent.lightning_strike == 3 and 1))*self.dmg*(self.distance_dmg_m or 1))
                LightningLine{group = main.current.effects, src = src, dst = dst}
                src = dst 
              end
            end
          end)
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

    if self.knockback then
      other:push(self.knockback*(self.knockback_m or 1), self.r)
    end

    if self.parent and self.parent.explosive_arrow and table.any(self.parent.classes, function(v) return v == 'ranger' end) then
      if random:bool((self.parent.explosive_arrow == 1 and 10) or (self.parent.explosive_arrow == 2 and 20) or (self.parent.explosive_arrow == 3 and 30)) then
        _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        Area{group = main.current.effects, x = self.x, y = self.y, r = self.r + random:float(0, 2*math.pi), w = self.parent.area_size_m*32, color = self.color, 
          dmg = ((self.parent.explosive_arrow == 1 and 0.1) or (self.parent.explosive_arrow == 2 and 0.2) or (self.parent.explosive_arrow == 3 and 0.3))*self.parent.area_dmg_m*self.dmg, character = self.character,
          level = self.level, parent = self, void_rift = self.parent.void_rift, echo_barrage = self.parent.echo_barrage}
      end
    end

    if self.parent and self.parent.void_rift and table.any(self.parent.classes, function(v) return v == 'mage' or v == 'nuker' or v == 'voider' end) then
      if random:bool(20) then
        DotArea{group = main.current.effects, x = self.x, y = self.y, rs = self.parent.area_size_m*24, color = self.color, dmg = self.parent.area_dmg_m*self.dmg*(self.parent.dot_dmg_m or 1), void_rift = true, duration = 1}
      end
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
    local resonance_dmg = 0
    local resonance_m = (self.parent.resonance == 1 and 0.03) or (self.parent.resonance == 2 and 0.05) or (self.parent.resonance == 3 and 0.07) or 0
    if self.character == 'elementor' then
      if self.parent.resonance then resonance_dmg = 2*self.dmg*resonance_m*#enemies end
      enemy:hit(2*self.dmg + resonance_dmg, self)
      if self.level == 3 then
        enemy:slow(0.4, 6)
      end
    elseif self.character == 'swordsman' then
      if self.parent.resonance then resonance_dmg = (self.dmg + self.dmg*0.15*#enemies)*resonance_m*#enemies end
      enemy:hit(self.dmg + self.dmg*0.15*#enemies + resonance_dmg, self)
    elseif self.character == 'blade' and self.level == 3 then
      if self.parent.resonance then resonance_dmg = (self.dmg + self.dmg*0.33*#enemies)*resonance_m*#enemies end
      enemy:hit(self.dmg + self.dmg*0.33*#enemies + resonance_dmg, self)
    elseif self.character == 'highlander' then
      if self.parent.resonance then resonance_dmg = 6*self.dmg*resonance_m*#enemies end
      enemy:hit(6*self.dmg + resonance_dmg, self)
    elseif self.character == 'launcher' then
      if self.parent.resonance then resonance_dmg = (self.level == 3 and 6*self.dmg*0.05*#enemies or 2*self.dmg*0.05*#enemies) end
      enemy:curse('launcher', 4*(self.hex_duration_m or 1), (self.level == 3 and 6*self.dmg or 2*self.dmg) + resonance_dmg, self.parent)
    elseif self.character == 'freezing_field' then
      enemy:slow(0.5, 2)
    else
      if self.parent.resonance then resonance_dmg = self.dmg*resonance_m*#enemies end
      enemy:hit(self.dmg + resonance_dmg, self)
    end
    HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
    for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
    if self.character == 'wizard' or self.character == 'magician' or self.character == 'elementor' or self.character == 'psychic' then
      magic_hit1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    elseif self.character == 'swordsman' or self.character == 'barbarian' or self.character == 'juggernaut' or self.character == 'highlander' then
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    elseif self.character == 'blade' then
      blade_hit1:play{pitch = random:float(0.9, 1.1), volume = 0.35}
      hit2:play{pitch = random:float(0.95, 1.05), volume = 0.2}
    elseif self.character == 'saboteur' or self.character == 'pyromancer' or self.character == 'bomber' then
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
      enemy:push(random:float(75, 100)*(self.knockback_m or 1), r)
      enemy.juggernaut_push = 3*self.dmg
    end
  end

  if self.parent:is(Projectile) then
    local p = self.parent.parent
    if p.void_rift and table.any(p.classes, function(v) return v == 'mage' or v == 'nuker' or v == 'voider' end) then
      if random:bool(20) then
        DotArea{group = main.current.effects, x = self.x, y = self.y, rs = p.area_size_m*24, color = self.color, dmg = p.area_dmg_m*self.dmg*(p.dot_dmg_m or 1),
          void_rift = true, duration = 1, parent = p}
      end
    end
    if p.echo_barrage and not self.echo_barrage_area then
      if random:bool((p.echo_barrage == 1 and 10) or (p.echo_barrage == 2 and 20) or (p.echo_barrage == 3 and 30)) then
        p.t:every(0.3, function()
          _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          Area{group = main.current.effects, x = self.x + random:float(-32, 32), y = self.y + random:float(-32, 32), r = self.r + random:float(0, 2*math.pi), w = p.area_size_m*48, color = p.color, 
            dmg = 0.5*p.area_dmg_m*self.dmg, character = self.character, level = p.level, parent = p, echo_barrage_area = true}
        end, p.echo_barrage)
      end
    end
  else
    if self.parent.void_rift and table.any(self.parent.classes, function(v) return v == 'mage' or v == 'nuker' or v == 'voider' end) then
      if random:bool(20) then
        DotArea{group = main.current.effects, x = self.x, y = self.y, rs = self.parent.area_size_m*24, color = self.color, dmg = self.parent.area_dmg_m*self.dmg*(self.parent.dot_dmg_m or 1),
          void_rift = true, duration = 1, parent = self.parent}
      end
    end
    if self.parent.echo_barrage and not self.echo_barrage_area then
      if random:bool((self.parent.echo_barrage == 1 and 10) or (self.parent.echo_barrage == 2 and 20) or (self.parent.echo_barrage == 3 and 30)) then
        self.parent.t:every(0.3, function()
          _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          Area{group = main.current.effects, x = self.x + random:float(-32, 32), y = self.y + random:float(-32, 32), r = self.r + random:float(0, 2*math.pi), w = self.parent.area_size_m*48, color = self.parent.color, 
            dmg = 0.5*self.parent.area_dmg_m*(self.dmg or self.parent.dmg), character = self.character, level = self.parent.level, parent = self.parent, echo_barrage_area = true}
        end, self.parent.echo_barrage)
      end
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
DotArea:implement(Physics)
function DotArea:init(args)
  self:init_game_object(args)
  self.shape = Circle(self.x, self.y, self.rs)
  self.closest_sensor = Circle(self.x, self.y, 128)

  if self.character == 'plague_doctor' or self.character == 'pyromancer' or self.character == 'witch' or self.character == 'burning_field' then
    self.t:every(0.2, function()
      local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
      if #enemies > 0 then self.spring:pull(0.05, 200, 10) end
      for _, enemy in ipairs(enemies) do
        hit2:play{pitch = random:float(0.8, 1.2), volume = 0.2}
        if self.character == 'pyromancer' then
          pyro1:play{pitch = random:float(1.5, 1.8), volume = 0.1}
          if self.level == 3 then
            enemy.pyrod = self
          end
        end
        enemy:hit((self.dot_dmg_m or 1)*self.dmg/5, self, true)
        HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
      end
    end, nil, nil, 'dot')

  elseif self.character == 'cryomancer' then
    self.t:every(1, function()
      local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
      if #enemies > 0 then
        self.spring:pull(0.15, 200, 10)
        frost1:play{pitch = random:float(0.8, 1.2), volume = 0.4}
      end
      for _, enemy in ipairs(enemies) do
        if self.level == 3 then
          enemy:slow(0.4, 4)
        end
        enemy:hit((self.dot_dmg_m or 1)*2*self.dmg, self, true)
        HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
      end
    end, nil, nil, 'dot')

  --[[
  elseif self.character == 'bane' then
    if self.level == 3 then
      self.t:every(0.5, function()
        local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
        if #enemies > 0 then
          self.spring:pull(0.05, 200, 10)
          buff1:play{pitch = random:float(0.8, 1.2), volume = 0.1}
        end
        for _, enemy in ipairs(enemies) do
          enemy:curse('bane', 0.5*(self.hex_duration_m or 1), self.level == 3, self)
          if self.level == 3 then
            enemy:slow(0.5, 0.5)
            enemy:hit((self.dot_dmg_m or 1)*self.dmg/2)
            HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
            for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
            for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
          end
        end
      end, nil, nil, 'dot')
    end
    ]]--

  elseif self.void_rift then
    self.t:every(0.2, function()
      local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
      if #enemies > 0 then self.spring:pull(0.05, 200, 10) end
      for _, enemy in ipairs(enemies) do
        hit2:play{pitch = random:float(0.8, 1.2), volume = 0.2}
        enemy:hit((self.dot_dmg_m or 1)*self.dmg/5, self, true)
        HitCircle{group = main.current.effects, x = enemy.x, y = enemy.y, rs = 6, color = fg[0], duration = 0.1}
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = self.color} end
        for i = 1, 1 do HitParticle{group = main.current.effects, x = enemy.x, y = enemy.y, color = enemy.color} end
      end
    end, nil, nil, 'dot')
  end

  if self.character == 'witch' then
    self.v = random:float(40, 80)
    self.r = random:table{math.pi/4, 3*math.pi/4, -math.pi/4, -3*math.pi/4}
    if self.level == 3 then
      self.t:every(1, function()
        local enemies = main.current.main:get_objects_in_shape(self.closest_sensor, main.current.enemies)
        if enemies and #enemies > 0 then
          local r = self:angle_to_object(enemies[1])
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6}
          local t = {group = main.current.main, x = self.x, y = self.y, v = 250, r = r, color = self.parent.color, dmg = self.parent.dmg, character = 'witch', parent = self.parent, level = self.parent.level}
          Projectile(table.merge(t, mods or {}))
          _G[random:table{'scout1', 'scout2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
          wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.15}
        end
      end)
    end
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

  if self.void_rift then
    self.dvr = random:table{random:float(-4*math.pi, -2*math.pi), random:float(2*math.pi, 4*math.pi)}
  end
end


function DotArea:update(dt)
  self:update_game_object(dt)
  self.t:set_every_multiplier('dot', (main.current.chronomancer_dot or 1))
  self.vr = self.vr + self.dvr*dt

  if self.parent then
    if (self.character == 'plague_doctor' and self.level == 3 and not self.plague_doctor_unmovable) or self.character == 'cryomancer' or self.character == 'pyromancer' then
      self.x, self.y = self.parent.x, self.parent.y
      self.shape:move_to(self.x, self.y)
    end
  end

  if self.character == 'witch' then
    self.x, self.y = self.x + self.v*math.cos(self.r)*dt, self.y + self.v*math.sin(self.r)*dt
    if self.x >= main.current.x2 - self.shape.rs/2 or self.x <= main.current.x1 + self.shape.rs/2 then
      self.r = math.pi - self.r
    end
    if self.y >= main.current.y2 - self.shape.rs/2 or self.y <= main.current.y1 + self.shape.rs/2 then
      self.r = 2*math.pi - self.r
    end
    self.shape:move_to(self.x, self.y)
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


function DotArea:scale(v)
  self.shape = Circle(self.x, self.y, (v or 1)*self.rs)
end




ForceArea = Object:extend()
ForceArea:implement(GameObject)
ForceArea:implement(Physics)
function ForceArea:init(args)
  self:init_game_object(args)
  self.shape = Circle(self.x, self.y, self.rs)
  
  self.color = fg[0]
  self.color_transparent = Color(args.color.r, args.color.g, args.color.b, 0.08)
  self.rs = 0
  self.hidden = false
  self.t:tween(0.05, self, {rs = args.rs}, math.cubic_in_out, function() self.spring:pull(0.15) end)
  self.t:after(0.2, function() self.color = args.color end)

  self.vr = 0
  self.dvr = random:table{random:float(-6*math.pi, -4*math.pi), random:float(4*math.pi, 6*math.pi)}

  if self.character == 'psykino' then
    elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
    self.t:tween(2, self, {dvr = 0}, math.linear)

    self.t:during(2, function()
      local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
      local t = self.t:get_during_elapsed_time('psykino')
      for _, enemy in ipairs(enemies) do
        enemy:apply_steering_force(600*(1-t), enemy:angle_to_point(self.x, self.y))
      end
    end, nil, 'psykino')
    self.t:after(2 - 0.35, function()
      self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self.dead = true end)
      if self.level == 3 then
        elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.5}
        local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
        for _, enemy in ipairs(enemies) do
          enemy:hit(4*self.parent.dmg)
          enemy:push(50*(self.knockback_m or 1), self:angle_to_object(enemy))
        end
      end
    end)

  elseif self.character == 'gravity_field' then
    elementor1:play{pitch = random:float(0.9, 1.1), volume = 0.4}
    self.t:tween(1, self, {dvr = 0}, math.linear)

    self.t:during(1, function()
      local enemies = main.current.main:get_objects_in_shape(self.shape, main.current.enemies)
      local t = self.t:get_during_elapsed_time('gravity_field')
      for _, enemy in ipairs(enemies) do
        enemy:apply_steering_force(400*(1-t), enemy:angle_to_point(self.x, self.y))
      end
    end, nil, 'gravity_field')
    self.t:after(1 - 0.35, function()
      self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self.dead = true end)
    end)
  end
end


function ForceArea:update(dt)
  self:update_game_object(dt)
  self.vr = self.vr + self.dvr*dt
end


function ForceArea:draw()
  if self.hidden then return end

  graphics.push(self.x, self.y, self.r + self.vr, self.spring.x, self.spring.x)
    graphics.circle(self.x, self.y, self.shape.rs, self.color_transparent)
    local lw = math.remap(self.shape.rs, 32, 256, 2, 4)
    for i = 1, 4 do graphics.arc('open', self.x, self.y, self.shape.rs, (i-1)*math.pi/2 + math.pi/4 - math.pi/8, (i-1)*math.pi/2 + math.pi/4 + math.pi/8, self.color, lw) end
  graphics.pop()
end



Tree = Object:extend()
Tree:implement(GameObject)
Tree:implement(Physics)
function Tree:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(9, 9, 'static', 'player')
  self:set_restitution(0.5)
  self.hfx:add('hit', 1)
  self.color = orange[0]
  self.heal_sensor = Circle(self.x, self.y, 48)

  self.vr = 0
  self.dvr = random:float(-math.pi/4, math.pi/4)

  buff1:play{pitch = random:float(0.95, 1.05), volume = 0.5}

  self.color = fg[0]
  self.color_transparent = Color(args.color.r, args.color.g, args.color.b, 0.08)
  self.rs = 0
  self.hidden = false
  self.t:tween(0.05, self, {rs = args.rs}, math.cubic_in_out, function() self.spring:pull(0.15) end)
  self.t:after(0.2, function() self.color = args.color end)

  self.t:every(self.parent.level == 3 and 3 or 6, function()
    self.hfx:use('hit', 0.2)
    HealingOrb{group = main.current.main, x = self.x, y = self.y}
    if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
      local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)

      if #enemies > 0 then
        for _, enemy in ipairs(enemies) do
          enemy.taunted = self
          enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
        end
      end
    end

    if self.parent.rearm then
      self.t:after(0.25, function()
        self.hfx:use('hit', 0.2)
        HealingOrb{group = main.current.main, x = self.x, y = self.y}

        if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
          if #enemies > 0 then
            for _, enemy in ipairs(enemies) do
              enemy.taunted = self
              enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
            end
          end
        end
      end)
    end
  end)

  --[[
  self.t:cooldown(3.33/(self.level == 3 and 2 or 1), function() return #self:get_objects_in_shape(self.heal_sensor, {Player}) > 0 end, function()
    local n = n or random:int(3, 4)
    for i = 1, n do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
    heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    local units = self:get_objects_in_shape(self.heal_sensor, {Player})
    if self.level == 3 then
      local unit_1 = random:table_remove(units)
      local unit_2 = random:table_remove(units)
      if unit_1 then
        unit_1:heal(0.2*unit_1.max_hp*(self.heal_effect_m or 1))
        LightningLine{group = main.current.effects, src = self, dst = unit_1, color = green[0]}
      end
      if unit_2 then
        unit_2:heal(0.2*unit_2.max_hp*(self.heal_effect_m or 1))
        LightningLine{group = main.current.effects, src = self, dst = unit_2, color = green[0]}
      end
      HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}

      if self.parent.rearm then
        self.t:after(1, function()
          heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          local unit_1 = random:table_remove(units)
          local unit_2 = random:table_remove(units)
          if unit_1 then
            unit_1:heal(0.2*unit_1.max_hp*(self.heal_effect_m or 1))
            LightningLine{group = main.current.effects, src = self, dst = unit_1, color = green[0]}
          end
          if unit_2 then
            unit_2:heal(0.2*unit_2.max_hp*(self.heal_effect_m or 1))
            LightningLine{group = main.current.effects, src = self, dst = unit_2, color = green[0]}
          end
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
        end)
      end

      if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
        local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
        if #enemies > 0 then
          for _, enemy in ipairs(enemies) do
            enemy.taunted = self
            enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
          end
        end
      end

    else
      local unit = random:table(units)
      unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1))
      HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
      LightningLine{group = main.current.effects, src = self, dst = unit, color = green[0]}

      if self.parent.rearm then
        self.t:after(1, function()
          heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
          local unit = random:table(units)
          unit:heal(0.2*unit.max_hp*(self.heal_effect_m or 1))
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
          LightningLine{group = main.current.effects, src = self, dst = unit, color = green[0]}
        end)
      end

      if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
        local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
        if #enemies > 0 then
          for _, enemy in ipairs(enemies) do
            enemy.taunted = self
            enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
          end
        end
      end
    end
  end)
  ]]--

  self.t:after(12*(self.parent.conjurer_buff_m or 1), function()
    self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function()
      self.dead = true

      if self.parent.construct_instability then
        camera:shake(2, 0.5)
        local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
        Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*48, color = self.color, dmg = n*self.parent.dmg*self.parent.area_dmg_m, parent = self.parent}
        _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      end
    end)
  end)
end


function Tree:update(dt)
  self:update_game_object(dt)
  self.vr = self.vr + self.dvr*dt
end


function Tree:draw()
  if self.hidden then return end

  graphics.push(self.x, self.y, math.pi/4, self.spring.x, self.spring.x)
    graphics.rectangle(self.x, self.y, 1.5*self.shape.w, 4, 2, 2, self.hfx.hit.f and fg[0] or self.color)
    graphics.rectangle(self.x, self.y, 4, 1.5*self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()

  graphics.push(self.x, self.y, self.r + self.vr, self.spring.x, self.spring.x)
    -- graphics.circle(self.x, self.y, self.shape.rs + random:float(-1, 1), self.color, 2)
    graphics.circle(self.x, self.y, self.heal_sensor.rs, self.color_transparent)
    local lw = math.remap(self.heal_sensor.rs, 32, 256, 2, 4)
    for i = 1, 4 do graphics.arc('open', self.x, self.y, self.heal_sensor.rs, (i-1)*math.pi/2 + math.pi/4 - math.pi/8, (i-1)*math.pi/2 + math.pi/4 + math.pi/8, self.color, lw) end
  graphics.pop()
end



ForceField = Object:extend()
ForceField:implement(GameObject)
ForceField:implement(Physics)
function ForceField:init(args)
  self:init_game_object(args)
  self:set_as_circle((self.parent and self.parent.magnify and (self.parent.magnify == 1 and 14) or (self.parent.magnify == 2 and 17) or (self.parent.magnify == 3 and 20)) or 12, 'static', 'force_field')
  self.hfx:add('hit', 1)
  
  self.color = fg[0]
  self.color_transparent = Color(yellow[0].r, yellow[0].g, yellow[0].b, 0.08)
  self.rs = 0
  self.hidden = false
  self.t:tween(0.05, self, {rs = args.rs}, math.cubic_in_out, function() self.spring:pull(0.15) end)
  self.t:after(0.2, function() self.color = yellow[0] end)

  self.t:after(6, function()
    self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self.dead = true end)
    dot1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  end)
end


function ForceField:update(dt)
  self:update_game_object(dt)
  if not self.parent then self.dead = true; return end
  if self.parent and self.parent.dead then self.dead = true; return end
  self:set_position(self.parent.x, self.parent.y)
end


function ForceField:draw()
  if self.hidden then return end
  graphics.push(self.x, self.y, 0, self.spring.x*self.hfx.hit.x, self.spring.x*self.hfx.hit.x)
    graphics.circle(self.x, self.y, self.shape.rs, self.hfx.hit.f and fg[0] or self.color, 2)
    graphics.circle(self.x, self.y, self.shape.rs, self.hfx.hit.f and fg_transparent[0] or self.color_transparent)
  graphics.pop()
end


function ForceField:on_collision_enter(other, contact)
  local x, y = contact:getPositions()
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    other:push(random:float(15, 20)*(self.parent.knockback_m or 1), self.parent:angle_to_object(other))
    other:hit(0)
    HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
    for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = self.color} end
    for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = other.color} end
    self.hfx:use('hit', 0.2)
    dot1:play{pitch = random:float(0.95, 1.05), volume = 0.3}
  end
end



Volcano = Object:extend()
Volcano:implement(GameObject)
Volcano:implement(Physics)
function Volcano:init(args)
  self:init_game_object(args)
  if not self.group.world then self.dead = true; return end
  if tostring(self.x) == tostring(0/0) or tostring(self.y) == tostring(0/0) then self.dead = true; return end
  self:set_as_rectangle(9, 9, 'static', 'player')
  self:set_restitution(0.5)
  self.hfx:add('hit', 1)
  self.color = orange[0]
  self.attack_sensor = Circle(self.x, self.y, 256)

  self.vr = 0
  self.dvr = random:float(-math.pi/4, math.pi/4)

  self.color = fg[0]
  self.color_transparent = Color(args.color.r, args.color.g, args.color.b, 0.08)
  self.rs = 0
  self.hidden = false
  self.t:tween(0.05, self, {rs = args.rs}, math.cubic_in_out, function() self.spring:pull(0.15) end)
  self.t:after(0.2, function() self.color = args.color end)

  camera:shake(6, 1)
  earth1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  fire1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.t:every(self.level == 3 and 0.5 or 1, function()
    camera:shake(4, 0.5)
    _G[random:table{'earth1', 'earth2', 'earth3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.25}
    _G[random:table{'fire1', 'fire2', 'fire3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.25}
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*72, r = random:float(0, 2*math.pi), color = self.color, dmg = (self.parent.area_dmg_m or 1)*self.parent.dmg,
      character = self.parent.character, level = self.parent.level, parent = self, void_rift = self.parent.void_rift, echo_barrage = self.parent.echo_barrage}
  end, self.level == 3 and 8 or 4)

  self.t:after(4, function()
    self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self.dead = true end)
  end)
end


function Volcano:update(dt)
  self:update_game_object(dt)
  if self.dvr then self.vr = self.vr + self.dvr*dt end
end


function Volcano:draw()
  if self.hidden then return end
  if not self.hfx.hit then return end

  graphics.push(self.x, self.y, -math.pi/2, self.spring.x, self.spring.x)
    graphics.triangle_equilateral(self.x, self.y, 1.5*self.shape.w, self.hfx.hit.f and fg[0] or self.color, 3)
  graphics.pop()

  graphics.push(self.x, self.y, self.r + (self.vr or 0), self.spring.x, self.spring.x)
    -- graphics.circle(self.x, self.y, self.shape.rs + random:float(-1, 1), self.color, 2)
    graphics.circle(self.x, self.y, 24, self.color_transparent)
    local lw = 2
    for i = 1, 4 do graphics.arc('open', self.x, self.y, 24, (i-1)*math.pi/2 + math.pi/4 - math.pi/8, (i-1)*math.pi/2 + math.pi/4 + math.pi/8, self.color, lw) end
  graphics.pop()
end




Sentry = Object:extend()
Sentry:implement(GameObject)
Sentry:implement(Physics)
function Sentry:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(6, 6, 'static', 'player')
  self:set_restitution(0.5)
  self.hfx:add('hit', 1)

  self.t:after(15*(self.parent.conjurer_buff_m or 1), function()
    local n = n or random:int(3, 4)
    for i = 1, n do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y}:scale_down()
    self.dead = true

    if self.parent.construct_instability then
      camera:shake(2, 0.5)
      local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
      Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*48, color = self.color, dmg = n*self.parent.dmg*self.parent.area_dmg_m, parent = self.parent}
      _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    end
  end)

  self.t:every({2.75, 3.5}, function()
    self.hfx:use('hit', 0.25, 200, 10)
    local r = self.r
    local n = random:bool((main.current.ranger_level == 2 and 16) or (main.current.ranger_level == 1 and 8) or 0) and 4 or 1
    for j = 1, n do
      self.t:after((j-1)*0.1, function()
        for i = 1, 4 do
          archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
          HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
          local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 200, r = r, color = self.color,
          dmg = self.parent.dmg*(self.parent.conjurer_buff_m or 1), character = 'sentry', parent = self.parent, ricochet = self.parent.level == 3 and 2 or 0}
          Projectile(table.merge(t, mods or {}))
          r = r + math.pi/2
        end
      end)
    end

    if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
      local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
      if #enemies > 0 then
        for _, enemy in ipairs(enemies) do
          enemy.taunted = self
          enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
        end
      end
    end

    if self.parent.rearm then
      self.t:after(0.25, function()
        self.hfx:use('hit', 0.25, 200, 10)
        local r = self.r
        for i = 1, 4 do
          archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
          HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
          local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 200, r = r, color = self.color,
          dmg = self.parent.dmg*(self.parent.conjurer_buff_m or 1), character = 'sentry', parent = self.parent, ricochet = self.parent.level == 3 and 2 or 0}
          Projectile(table.merge(t, mods or {}))
          r = r + math.pi/2
        end

        if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
          if #enemies > 0 then
            for _, enemy in ipairs(enemies) do
              enemy.taunted = self
              enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
            end
          end
        end
      end)
    end
  end, nil, nil, 'attack')
end


function Sentry:update(dt)
  self:update_game_object(dt)
  self.r = self.r + math.pi*dt
  self:set_angle(self.r)
  self.t:set_every_multiplier('attack', self.parent.level == 3 and 0.75 or 1)
end


function Sentry:draw()
  if self.hidden then return end
  graphics.push(self.x, self.y, self.r, self.spring.x, self.spring.x)
    graphics.rectangle(self.x, self.y, 2*self.shape.w, 4, 2, 2, self.hfx.hit.f and fg[0] or self.color)
    graphics.rectangle(self.x, self.y, 4, 2*self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
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
  
  self.t:every({2.75, 3.5}, function()
    self.t:every({0.1, 0.2}, function()
      self.hfx:use('hit', 0.25, 200, 10)
      HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(self.r), y = self.y + 0.8*self.shape.w*math.sin(self.r), rs = 6}
      local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(self.r), y = self.y + 1.6*self.shape.w*math.sin(self.r), v = 200, r = self.r, color = self.color,
      dmg = self.parent.dmg*(self.parent.conjurer_buff_m or 1)*self.upgrade_dmg_m, character = self.parent.character, parent = self.parent}
      Projectile(table.merge(t, mods or {}))
      turret1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
      turret2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end, 3)

    if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
      local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
      if #enemies > 0 then
        for _, enemy in ipairs(enemies) do
          enemy.taunted = self
          enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
        end
      end
    end

    if self.parent.rearm then
      self.t:after(1, function()
        self.t:every({0.1, 0.2}, function()
          self.hfx:use('hit', 0.25, 200, 10)
          HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(self.r), y = self.y + 0.8*self.shape.w*math.sin(self.r), rs = 6}
          local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(self.r), y = self.y + 1.6*self.shape.w*math.sin(self.r), v = 200, r = self.r, color = self.color,
          dmg = self.parent.dmg*(self.parent.conjurer_buff_m or 1)*self.upgrade_dmg_m, character = self.parent.character, parent = self.parent}
          Projectile(table.merge(t, mods or {}))
          turret1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
          turret2:play{pitch = random:float(0.95, 1.05), volume = 0.35}
        end, 3)

        if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
          local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
          if #enemies > 0 then
            for _, enemy in ipairs(enemies) do
              enemy.taunted = self
              enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
            end
          end
        end
      end)
    end
  end, nil, nil, 'shoot')

  self.t:after(24*(self.parent.conjurer_buff_m or 1), function()
    local n = n or random:int(3, 4)
    for i = 1, n do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y}:scale_down()
    self.dead = true

    if self.parent.construct_instability then
      camera:shake(2, 0.5)
      local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
      Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*48, color = self.color, dmg = n*self.parent.dmg*self.parent.area_dmg_m, parent = self.parent}
      _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    end
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
  self.upgrade_dmg_m = self.upgrade_dmg_m + 0.5
  self.upgrade_aspd_m = self.upgrade_aspd_m + 0.5
  for i = 1, 6 do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
  HitCircle{group = main.current.effects, x = self.x, y = self.y}:scale_down()
end




Pet = Object:extend()
Pet:implement(GameObject)
Pet:implement(Physics)
function Pet:init(args)
  self:init_game_object(args)
  if tostring(self.x) == tostring(0/0) or tostring(self.y) == tostring(0/0) then self.dead = true; return end
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
  if not self.hfx.hit then return end
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

      if self.parent.construct_instability then
        camera:shake(2, 0.5)
        local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
        Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*48, color = self.color, dmg = n*self.parent.dmg*self.parent.area_dmg_m, parent = self.parent}
        _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      end
    end
  end
end


function Pet:on_trigger_enter(other)
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    if self.pierce <= 0 then
      camera:shake(2, 0.5)
      other:hit(self.parent.dmg*(self.conjurer_buff_m or 1))
      other:push(35*(self.knockback_m or 1), self:angle_to_object(other))
      self.dead = true
      local n = random:int(3, 4)
      for i = 1, n do HitParticle{group = main.current.effects, x = x, y = y, r = random:float(0, 2*math.pi), color = self.color} end
      HitCircle{group = main.current.effects, x = x, y = y}:scale_down()
    else
      camera:shake(2, 0.5)
      other:hit(self.parent.dmg*(self.conjurer_buff_m or 1))
      other:push(35*(self.knockback_m or 1), self:angle_to_object(other))
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



Bomb = Object:extend()
Bomb:implement(GameObject)
Bomb:implement(Physics)
function Bomb:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(8, 8, 'static', 'player')
  self:set_restitution(0.5)
  self.hfx:add('hit', 1)
  
  mine1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.color = orange[0]
  self.dmg = 2*get_character_stat('bomber', self.level, 'dmg')
  self.t:after(8, function() self:explode() end)
end


function Bomb:update(dt)
  self:update_game_object(dt)
end


function Bomb:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function Bomb:explode()
  camera:shake(4, 0.5)
  local t = {group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*64*(self.level == 3 and 2 or 1), color = self.color, 
    dmg = self.parent.area_dmg_m*self.dmg*(self.parent.conjurer_buff_m or 1)*(self.level == 3 and 2 or 1), character = self.character, parent = self.parent}
  Area(table.merge(t, mods or {}))
  if not self.parent.construct_instability and not self.parent.rearm then self.dead = true end
  _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  _G[random:table{'saboteur_hit1', 'saboteur_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  explosion1:play{pitch = random:float(0.95, 1.05), volume = 0.5}

  self.t:after(0.25, function()
    if self.parent.construct_instability then
      camera:shake(2, 0.5)
      local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
      Area{group = main.current.effects, x = self.x, y = self.y, r = self.r + random:float(-math.pi/16, math.pi/16), w = self.parent.area_size_m*48*(self.level == 3 and 2 or 1), color = self.color, 
        dmg = n*self.parent.dmg*self.parent.area_dmg_m*(self.level == 3 and 2 or 1), parent = self.parent}
      _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.dead = true
    end

    if self.parent.rearm then
      camera:shake(2, 0.5)
      local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
      Area{group = main.current.effects, x = self.x, y = self.y, r = self.r + random:float(-math.pi/16, math.pi/16), w = self.parent.area_size_m*48*(self.level == 3 and 2 or 1), color = self.color,
        dmg = n*self.parent.dmg*self.parent.area_dmg_m*(self.level == 3 and 2 or 1), parent = self.parent}
      _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.dead = true
    end
  end)
end


function Bomb:on_collision_enter(other, contact)
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    self:explode()
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

  self.actual_dmg = 2*get_character_stat('saboteur', self.level, 'dmg')
end


function Saboteur:update(dt)
  self:update_game_object(dt)

  self.buff_area_size_m = self.parent.buff_area_size_m
  self.buff_area_dmg_m = self.parent.buff_area_dmg_m
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
      dmg = (self.crit and 2 or 1)*self.area_dmg_m*self.actual_dmg*(self.conjurer_buff_m or 1), character = self.character, parent = self.parent}
    Area(table.merge(t, mods or {}))

    if self.parent.construct_instability then
      self.t:after(0.25, function()
        camera:shake(2, 0.5)
        local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
        Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*48, color = self.color, dmg = n*self.parent.dmg*self.parent.area_dmg_m, parent = self.parent}
        _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        self.dead = true
      end)
    else
      self.dead = true
    end
  end
end



Automaton = Object:extend()
Automaton:implement(GameObject)
Automaton:implement(Physics)
Automaton:implement(Unit)
function Automaton:init(args)
  self:init_game_object(args)
  self:init_unit()
  self:set_as_rectangle(8, 8, 'dynamic', 'player')
  self:set_restitution(0.5)
  
  self.color = character_colors.artificer
  self.character = 'artificer'
  self.classes = {'sorcerer', 'conjurer'}
  self:calculate_stats(true)
  self:set_as_steerable(self.v, 2000, 4*math.pi, 4)

  self.attack_sensor = Circle(self.x, self.y, 96)
  self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
    local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
    if closest_enemy then
      turret1:play{pitch = random:float(0.95, 1.05), volume = 0.10}
      turret2:play{pitch = random:float(0.95, 1.05), volume = 0.10}
      wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.10}
      local r = self:angle_to_object(closest_enemy)
      HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
      local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.parent.color, dmg = self.parent.dmg, character = 'artificer',
      parent = self.parent, level = self.parent.level}
      Projectile(table.merge(t, mods or {}))
    end

    if self.parent.rearm then
      self.t:after(0.25, function()
        local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
        if closest_enemy then
          turret1:play{pitch = random:float(0.95, 1.05), volume = 0.10}
          turret2:play{pitch = random:float(0.95, 1.05), volume = 0.10}
          wizard1:play{pitch = random:float(0.95, 1.05), volume = 0.10}
          local r = self:angle_to_object(closest_enemy)
          HitCircle{group = main.current.effects, x = self.x + 0.8*self.shape.w*math.cos(r), y = self.y + 0.8*self.shape.w*math.sin(r), rs = 6}
          local t = {group = main.current.main, x = self.x + 1.6*self.shape.w*math.cos(r), y = self.y + 1.6*self.shape.w*math.sin(r), v = 250, r = r, color = self.parent.color, dmg = self.parent.dmg, character = 'artificer',
          parent = self.parent, level = self.parent.level}
          Projectile(table.merge(t, mods or {}))
        end
      end)
    end

    if self.parent.taunt and random:bool((self.parent.taunt == 1 and 10) or (self.parent.taunt == 2 and 20) or (self.parent.taunt == 3 and 30)) then
      local enemies = self:get_objects_in_shape(Circle(self.x, self.y, 96), main.current.enemies)
      if #enemies > 0 then
        for _, enemy in ipairs(enemies) do
          enemy.taunted = self
          enemy.t:after(4, function() enemy.taunted = false end, 'taunt')
        end
      end
    end
  end, nil, nil, 'shoot')

  self.t:after(18*(self.parent.conjurer_buff_m or 1), function()
    local n = n or random:int(3, 4)
    for i = 1, n do HitParticle{group = main.current.effects, x = self.x, y = self.y, r = random:float(0, 2*math.pi), color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y}:scale_down()
    self.dead = true

    if self.parent.level == 3 then
      shoot1:play{pitch = random:float(0.95, 1.05), volume = 0.2}
      for i = 1, 12 do
        Projectile{group = main.current.main, x = self.x, y = self.y, color = self.color, r = (i-1)*math.pi/6, v = 200, dmg = self.parent.dmg, character = 'artificer_death',
          parent = self.parent, level = self.parent.level, pierce = 1, ricochet = 1}
      end
    end

    if self.parent.construct_instability then
      camera:shake(2, 0.5)
      local n = (self.parent.construct_instability == 1 and 1) or (self.parent.construct_instability == 2 and 1.5) or (self.parent.construct_instability == 3 and 2) or 1
      Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*48, color = self.color, dmg = n*self.parent.dmg*self.parent.area_dmg_m, parent = self.parent}
      _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    end
  end)
end


function Automaton:update(dt)
  self:update_game_object(dt)

  self:calculate_stats()

  if not self.target then self.target = random:table(self.group:get_objects_by_classes(main.current.enemies)) end
  if self.target and self.target.dead then self.target = random:table(self.group:get_objects_by_classes(main.current.enemies)) end
  if not self.seek_f then return end
  if not self.target then
    self:seek_point(gw/2, gh/2)
    self:wander(50, 200, 50)
    self:rotate_towards_velocity(1)
    self:steering_separate(32, {Seeker})
  else
    self:seek_point(self.target.x, self.target.y)
    self:wander(50, 200, 50)
    self:rotate_towards_velocity(1)
    self:steering_separate(32, {Seeker})
  end
  self.r = self:get_angle()

  self.t:set_every_multiplier('shoot', self.parent.level == 3 and 0.75 or 1)
  self.attack_sensor:move_to(self.x, self.y)
end


function Automaton:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


Gold = Object:extend()
Gold:implement(GameObject)
Gold:implement(Physics)
function Gold:init(args)
  self:init_game_object(args)
  if not self.group.world then self.dead = true; return end
  if tostring(self.x) == tostring(0/0) or tostring(self.y) == tostring(0/0) then self.dead = true; return end
  if #self.group:get_objects_by_class(Gold) > 30 then self.dead = true; return end
  self:set_as_rectangle(3, 3, 'dynamic', 'ghost')
  self:set_restitution(0.5)
  local r = random:float(0, 2*math.pi)
  local f = random:float(2, 4)
  self:apply_impulse(f*math.cos(r), f*math.sin(r))
  self:apply_angular_impulse(random:table{random:float(-6*math.pi, -2*math.pi), random:float(2*math.pi, 6*math.pi)})
  self:set_damping(2.5)
  self:set_angular_damping(5)
  self.color = yellow2[0]
  self.hfx:add('hit', 1)
  self.cant_be_picked_up = true
  self.t:after(0.5, function() self.cant_be_picked_up = false end)
  gold1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.weak_magnet_sensor = Circle(self.x, self.y, 16)
  self.magnet_sensor = Circle(self.x, self.y, 56)
end


function Gold:update(dt)
  self:update_game_object(dt)
  self.r = self:get_angle()
  if not self.magnet_sensor then return end
  if not self.weak_magnet_sensor then return end

  local players = self:get_objects_in_shape(main.current.player.magnetism and self.magnet_sensor or self.weak_magnet_sensor, {Player})
  if players and #players > 0 then
    local x, y = 0, 0
    for _, p in ipairs(players) do
      x = x + p.x
      y = y + p.y
    end
    x = x/#players
    y = y/#players
    local r = self:angle_to_point(x, y)
    self:apply_force(20*math.cos(r), 20*math.sin(r))
  end
  if self.magnet_sensor then self.magnet_sensor:move_to(self.x, self.y) end
  if self.weak_magnet_sensor then self.weak_magnet_sensor:move_to(self.x, self.y) end
end


function Gold:draw()
  if not self.hfx.hit then return end
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 1, 1, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function Gold:on_trigger_enter(other, contact)
  if self.cant_be_picked_up then return end

  if other:is(Player) then
    main.current.gold_picked_up = main.current.gold_picked_up + 1
    self.dead = true
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 4, color = fg[0], duration = 0.1}
    for i = 1, 2 do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    _G[random:table{'gold2', 'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.9, 1.1), volume = 0.3}

    local units = other:get_all_units()
    local th
    for _, unit in ipairs(units) do
      if unit.character == 'miner' then
        th = unit
      end
    end
    if th then
      if th.level == 3 then
        trigger:after(0.01, function()
          if not main.current.main.world then return end
          _G[random:table{'scout1', 'scout2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6}
          local r = random:float(0, 2*math.pi)
          for i = 1, 8 do
            local t = {group = main.current.main, x = self.x + 8*math.cos(r), y = self.y + 8*math.sin(r), v = 250, r = r, color = yellow2[0], dmg = th.dmg, character = th.character, parent = th, level = th.level}
            Projectile(table.merge(t, mods or {}))
            r = r + math.pi/4
          end
        end)
      else
        trigger:after(0.01, function()
          if not main.current.main.world then return end
          _G[random:table{'scout1', 'scout2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.35}
          HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6}
          local r = random:float(0, 2*math.pi)
          for i = 1, 4 do
            local t = {group = main.current.main, x = self.x + 8*math.cos(r), y = self.y + 8*math.sin(r), v = 250, r = r, color = yellow2[0], dmg = th.dmg, character = th.character, parent = th, level = th.level}
            Projectile(table.merge(t, mods or {}))
            r = r + 2*math.pi/4
          end
        end)
      end
    end
  end
end




HealingOrb = Object:extend()
HealingOrb:implement(GameObject)
HealingOrb:implement(Physics)
function HealingOrb:init(args)
  self:init_game_object(args)
  if not self.group.world then self.dead = true; return end
  if tostring(self.x) == tostring(0/0) or tostring(self.y) == tostring(0/0) then self.dead = true; return end
  if #self.group:get_objects_by_class(HealingOrb) > 30 then self.dead = true; return end
  self:set_as_rectangle(4, 4, 'dynamic', 'ghost')
  self:set_restitution(0.5)
  local r = random:float(0, 2*math.pi)
  local f = random:float(2, 4)
  self:apply_impulse(f*math.cos(r), f*math.sin(r))
  self:apply_angular_impulse(random:table{random:float(-6*math.pi, -2*math.pi), random:float(2*math.pi, 6*math.pi)})
  self:set_damping(2.5)
  self:set_angular_damping(5)
  self.color = yellow2[0]
  self.hfx:add('hit', 1)
  self.cant_be_picked_up = true
  self.t:after(0.5, function() self.cant_be_picked_up = false end)
  illusion1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.weak_magnet_sensor = Circle(self.x, self.y, 16)
  self.magnet_sensor = Circle(self.x, self.y, 56)

  if main.current.healer_level > 0 and not self.healer_effect_orb then
    if random:bool((main.current.healer_level == 1 and 15) or (main.current.healer_level == 2 and 30)) then
      SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = green[0], action = function(x, y)
        HealingOrb{group = main.current.main, x = x, y = y, healer_effect_orb = true}
      end}
    end
  end
end


function HealingOrb:update(dt)
  self:update_game_object(dt)
  self.r = self:get_angle()
  if not self.magnet_sensor then return end
  if not self.weak_magnet_sensor then return end

  local players = self:get_objects_in_shape(main.current.player.magnetism and self.magnet_sensor or self.weak_magnet_sensor, {Player})
  if players and #players > 0 then
    local x, y = 0, 0
    for _, p in ipairs(players) do
      x = x + p.x
      y = y + p.y
    end
    x = x/#players
    y = y/#players
    local r = self:angle_to_point(x, y)
    self:apply_force(20*math.cos(r), 20*math.sin(r))
  end
  if self.magnet_sensor then self.magnet_sensor:move_to(self.x, self.y) end
  if self.weak_magnet_sensor then self.weak_magnet_sensor:move_to(self.x, self.y) end
end


function HealingOrb:draw()
  if not self.hfx.hit then return end
  local sr = random:float(-0.1, 0.1)
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x + sr, self.hfx.hit.x + sr)
    graphics.circle(self.x, self.y, 1.2*self.shape.w, self.hfx.hit.f and fg[0] or green_transparent_weak)
    graphics.circle(self.x, self.y, 0.5*self.shape.w, self.hfx.hit.f and fg[0] or green[0])
  graphics.pop()
end


function HealingOrb:on_trigger_enter(other, contact)
  if self.cant_be_picked_up then return end

  if other:is(Player) then
    self.dead = true
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 4, color = fg[0], duration = 0.1}
    for i = 1, 2 do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = green[0]} end
    orb1:play{pitch = random:float(0.95, 1.05), volume = 1}
    heal1:play{pitch = random:float(0.95, 1.05), volume = 0.5}

    local units = other:get_all_units()
    local lowest_hp = 10
    local lowest_unit
    for _, unit in ipairs(units) do
      local r = unit.hp/unit.max_hp
      if r < lowest_hp then
        lowest_hp = r
        lowest_unit = unit
      end
    end
    if lowest_unit then
      lowest_unit:heal(0.2*lowest_unit.max_hp*(lowest_unit.heal_effect_m or 1))
    end

    if main.current.player.haste then
      local units = other:get_all_units()
      for _, unit in ipairs(units) do
        unit.hasted = love.timer.getTime()
        unit.t:after(4, function() unit.hasted = false end, 'haste')
      end
    end

    if main.current.player.divine_barrage and random:bool((main.current.player.divine_barrage == 1 and 20) or (main.current.player.divine_barrage == 2 and 40) or (main.current.player.divine_barrage == 3 and 60)) then
      trigger:after(0.01, function()
        if not main.current.main.world then return end
        main.current.player:barrage(main.current.player.r, 5, nil, 3)
      end)
    end
  end
end




Critter = Object:extend()
Critter:implement(GameObject)
Critter:implement(Physics)
Critter:implement(Unit)
function Critter:init(args)
  self:init_game_object(args)
  if tostring(self.x) == tostring(0/0) or tostring(self.y) == tostring(0/0) then self.dead = true; return end
  if #self.group:get_objects_by_class(Critter) > 100 then self.dead = true; return end
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

  self.dmg = args.dmg or self.parent.dmg
  self.hp = 1 + ((main.current.swarmer_level == 2 and 3) or (main.current.swarmer_level == 1 and 1) or 0) + (self.parent.hive or 0)
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
    if not self.seek_f then return end
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
  if not self.hfx.hit then return end
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end


function Critter:hit(damage)
  if self.dead or self.invulnerable then return end
  self.hfx:use('hit', 0.25, 200, 10)
  self.hp = self.hp - 1
  -- self:show_hp()
  if main.current.player.baneling_burst then
    self:die()
  else
    if self.hp <= 0 then self:die() end
  end
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

  if main.current.player.baneling_burst then
    camera:shake(2, 0.5)
    Area{group = main.current.effects, x = self.x, y = self.y, r = self.r, w = self.parent.area_size_m*24, color = self.color,
      dmg = (main.current.player.baneling_burst == 1 and 50) or (main.current.player.baneling_burst == 2 and 100) or (main.current.player.baneling_burst == 3 and 150) or 0, parent = self.parent}
    _G[random:table{'cannoneer1', 'cannoneer2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  end
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
    critter2:play{pitch = random:float(0.65, 0.85), volume = 0.1}
    self:hit(1)
    other:hit(self.dmg, self)
  end
end
