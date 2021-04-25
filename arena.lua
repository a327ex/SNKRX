Arena = Object:extend()
Arena:implement(State)
Arena:implement(GameObject)
function Arena:init(name)
  self:init_state(name)
  self:init_game_object()
end


function Arena:on_enter(from, level, units, passives)
  self.hfx:add('condition1', 1)
  self.hfx:add('condition2', 1)
  self.level = level or 1
  self.units = units
  self.passives = passives

  steam.friends.setRichPresence('steam_display', '#StatusFull')
  steam.friends.setRichPresence('text', 'Arena - Level ' .. self.level)

  self.floor = Group()
  self.main = Group():set_as_physics_world(32, 0, 0, {'player', 'enemy', 'projectile', 'enemy_projectile'})
  self.post_main = Group()
  self.effects = Group()
  self.ui = Group()
  self.main:disable_collision_between('player', 'player')
  self.main:disable_collision_between('player', 'projectile')
  self.main:disable_collision_between('player', 'enemy_projectile')
  self.main:disable_collision_between('projectile', 'projectile')
  self.main:disable_collision_between('projectile', 'enemy_projectile')
  self.main:disable_collision_between('projectile', 'enemy')
  self.main:disable_collision_between('enemy_projectile', 'enemy')
  self.main:disable_collision_between('enemy_projectile', 'enemy_projectile')
  self.main:enable_trigger_between('projectile', 'enemy')
  self.main:enable_trigger_between('enemy_projectile', 'player')
  self.main:enable_trigger_between('player', 'enemy_projectile')

  self.damage_dealt = 0
  self.damage_taken = 0
  self.main_slow_amount = 1
  self.enemies = {Seeker, EnemyCritter}
  self.color = self.color or fg[0]

  -- Spawn solids and player
  self.x1, self.y1 = gw/2 - 0.8*gw/2, gh/2 - 0.8*gh/2
  self.x2, self.y2 = gw/2 + 0.8*gw/2, gh/2 + 0.8*gh/2
  self.w, self.h = self.x2 - self.x1, self.y2 - self.y1
  self.spawn_points = {
    {x = self.x1 + 32, y = self.y1 + 32, r = math.pi/4},
    {x = self.x1 + 32, y = self.y2 - 32, r = -math.pi/4},
    {x = self.x2 - 32, y = self.y1 + 32, r = 3*math.pi/4},
    {x = self.x2 - 32, y = self.y2 - 32, r = -3*math.pi/4},
    {x = gw/2, y = gh/2, r = random:float(0, 2*math.pi)}
  }
  self.spawn_offsets = {{x = -12, y = -12}, {x = 12, y = -12}, {x = 12, y = 12}, {x = -12, y = 12}, {x = 0, y = 0}}
  self.last_spawn_enemy_time = love.timer.getTime()

  Wall{group = self.main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}

  for i, unit in ipairs(units) do
    if i == 1 then
      self.player = Player{group = self.main, x = gw/2, y = gh/2 + 16, leader = true, character = unit.character, level = unit.level, passives = self.passives}
    else
      self.player:add_follower(Player{group = self.main, character = unit.character, level = unit.level, passives = self.passives})
    end
  end

  if self.level == 1000 then
    self.level_1000_text = Text2{group = self.ui, x = gw/2, y = gh/2, lines = {{text = '[fg, wavy_mid]SNKRX', font = fat_font, alignment = 'center'}}}
    -- self.level_1000_text2 = Text2{group = self.ui, x = gw/2, y = gh/2 + 64, lines = {{text = '[fg, wavy_mid]SNKRX', font = pixul_font, alignment = 'center'}}}
    -- Wall{group = self.main, vertices = math.to_rectangle_vertices(gw/2 - 0.45*self.level_1000_text.w, gh/2 - 0.3*self.level_1000_text.h, gw/2 + 0.45*self.level_1000_text.w, gh/2 - 3), snkrx = true, color = bg[-1]}
  
  elseif self.level == 6 or self.level == 12 or self.level == 18 or self.level == 24 or self.level == 25 then
    self.boss_level = true
    self.start_time = 3
    self.t:after(1, function()
      self.t:every(1, function()
        if self.start_time > 1 then alert1:play{volume = 0.5} end
        self.start_time = self.start_time - 1
        self.hfx:use('condition1', 0.25, 200, 10)
      end, 3, function()
        alert1:play{pitch = 1.2, volume = 0.5}
        camera:shake(4, 0.25)
        SpawnEffect{group = self.effects, x = gw/2, y = gh/2 - 48}
        SpawnEffect{group = self.effects, x = gw/2, y = gh/2, action = function(x, y)
          spawn1:play{pitch = random:float(0.8, 1.2), volume = 0.15}
          self.boss = Seeker{group = self.main, x = x, y = y, character = 'seeker', level = self.level, boss = level_to_boss[self.level]}
        end}
        self.t:every(function() return #self.main:get_objects_by_classes(self.enemies) <= 1 end, function()
          self.hfx:use('condition1', 0.25, 200, 10)
          self.hfx:pull('condition2', 0.0625)
          self.t:after(0.5, function()
            local spawn_type = random:table{'left', 'middle', 'right'}
            local spawn_points = {left = {x = self.x1 + 32, y = gh/2}, middle = {x = gw/2, y = gh/2}, right = {x = self.x2 - 32, y = gh/2}}
            local p = spawn_points[spawn_type]
            SpawnMarker{group = self.effects, x = p.x, y = p.y}
            self.t:after(0.75, function() self:spawn_n_enemies(p, nil, 8 + math.floor(self.level/2)) end)
          end)
        end)
      end)
      self.t:every(function() return self.start_time <= 0 and #self.main:get_objects_by_classes(self.enemies) <= 0 end, function() self.can_quit = true end)
    end)
  else
    -- Set win condition and enemy spawns
    self.win_condition = random:table{'time', 'enemy_kill', 'wave'}
    if self.level == 18 and self.trailer then self.win_condition = 'wave' end
    if self.win_condition == 'wave' then
      self.level_to_max_waves = {
        1, 2, random:int(2, 3),
        3, 3, 3, random:int(3, 4),
        4, 4, 4, 4, random:int(4, 5),
        5, 5, 5, 5, 5, random:int(5, 6),
        6, 7, 8, 9, 9, 10, 12
      }
      self.max_waves = self.level_to_max_waves[self.level]
      self.wave = 0
      self.start_time = 3
      self.t:after(1, function()
        self.t:every(1, function()
          if self.start_time > 1 then alert1:play{volume = 0.5} end
          self.start_time = self.start_time - 1
          self.hfx:use('condition1', 0.25, 200, 10)
        end, 3, function()
          alert1:play{pitch = 1.2, volume = 0.5}
          camera:shake(4, 0.25)
          SpawnEffect{group = self.effects, x = gw/2, y = gh/2 - 48}
          self.t:every(function() return #self.main:get_objects_by_classes(self.enemies) <= 0 end, function()
            self.wave = self.wave + 1
            if self.wave > self.max_waves then return end
            self.hfx:use('condition1', 0.25, 200, 10)
            self.hfx:pull('condition2', 0.0625)
            self.t:after(0.5, function()
              local spawn_type = random:table{'left', 'middle', 'right'}
              local spawn_points = {left = {x = self.x1 + 32, y = gh/2}, middle = {x = gw/2, y = gh/2}, right = {x = self.x2 - 32, y = gh/2}}
              local p = spawn_points[spawn_type]
              SpawnMarker{group = self.effects, x = p.x, y = p.y}
              self.t:after(0.75, function() self:spawn_n_enemies(p, nil, 8 + (self.wave-1)*2) end)
            end)
          end, self.max_waves+1)
        end)
        self.t:every(function() return #self.main:get_objects_by_classes(self.enemies) <= 0 and self.wave > self.max_waves end, function() self.can_quit = true end)
      end)

    elseif self.win_condition == 'time' then
      self.level_to_time_left = {
        20, 20, random:int(20, 25),
        25, 25, 25, random:int(25, 30),
        30, 30, 30, 30, random:int(30, 35),
        35, 35, 35, 35, 35, random:int(35, 40),
        40, 45, 50, 55, 55, 60, 80
      }
      self.time_left = self.level_to_time_left[self.level]
      self.start_time = 3
      self.t:after(1, function()
        self.t:every(1, function()
          if self.start_time > 1 then alert1:play{volume = 0.5} end
          self.start_time = self.start_time - 1
          self.hfx:use('condition1', 0.25, 200, 10)
        end, 3, function()
          alert1:play{pitch = 1.2, volume = 0.5}
          camera:shake(4, 0.25)
          SpawnEffect{group = self.effects, x = gw/2, y = gh/2 - 48}
          self.t:every(1, function()
            self.time_left = self.time_left - 1
            self.hfx:use('condition1', 0.25, 200, 10)
            self.hfx:pull('condition2', 0.0625)
          end, self.time_left)

          self.t:every_immediate(2, function()
            if #self.main:get_objects_by_classes(self.enemies) <= 0 or love.timer.getTime() - self.last_spawn_enemy_time >= 8 and not self.transitioning then
              self:spawn_distributed_enemies()
            end
          end, self.time_left/2)
        end)
      end)
      self.t:every(function() return #self.main:get_objects_by_classes(self.enemies) <= 0 and self.time_left <= 0 end, function() self.can_quit = true end)
    end

    if self.level == 18 and self.trailer then
      Text2{group = self.ui, x = gw/2, y = gh/2 - 24, lines = {{text = '[fg, wavy]SNKRX', font = fat_font, alignment = 'center'}}}
      Text2{group = self.ui, x = gw/2, y = gh/2, sx = 0.5, sy = 0.5, lines = {{text = '[fg, wavy_mid]wishlist now!', font = fat_font, alignment = 'center'}}}
      Text2{group = self.ui, x = gw/2, y = gh/2 + 24, sx = 0.5, sy = 0.5, lines = {{text = '[light_bg, wavy_mid]music: kubbi - ember', font = fat_font, alignment = 'center'}}}
    end
  end

  if self.level == 1 then
    local t1 = Text2{group = self.floor, x = gw/2, y = gh/2 + 2, sx = 0.6, sy = 0.6, lines = {{text = '[light_bg]<- or a         -> or d', font = fat_font, alignment = 'center'}}}
    local t2 = Text2{group = self.floor, x = gw/2, y = gh/2 + 18, lines = {{text = '[light_bg]turn left                                      turn right', font = pixul_font, alignment = 'center'}}}
    local t3 = Text2{group = self.floor, x = gw/2, y = gh/2 + 46, sx = 0.6, sy = 0.6, lines = {{text = '[light_bg]n - mute sfx', font = fat_font, alignment = 'center'}}}
    local t4 = Text2{group = self.floor, x = gw/2, y = gh/2 + 68, sx = 0.6, sy = 0.6, lines = {{text = '[light_bg]m - mute music', font = fat_font, alignment = 'center'}}}
    t1.t:after(8, function() t1.t:tween(0.2, t1, {sy = 0}, math.linear, function() t1.sy = 0 end) end)
    t2.t:after(8, function() t2.t:tween(0.2, t2, {sy = 0}, math.linear, function() t2.sy = 0 end) end)
    t3.t:after(8, function() t3.t:tween(0.2, t3, {sy = 0}, math.linear, function() t3.sy = 0 end) end)
    t4.t:after(8, function() t4.t:tween(0.2, t4, {sy = 0}, math.linear, function() t4.sy = 0 end) end)
  end

  -- Calculate class levels
  local units = {}
  table.insert(units, self.player)
  for _, f in ipairs(self.player.followers) do table.insert(units, f) end

  local class_levels = get_class_levels(units)
  self.ranger_level = class_levels.ranger
  self.warrior_level = class_levels.warrior
  self.mage_level = class_levels.mage
  self.rogue_level = class_levels.rogue
  self.nuker_level = class_levels.nuker
  self.curser_level = class_levels.curser
  self.forcer_level = class_levels.forcer
  self.swarmer_level = class_levels.swarmer
  self.voider_level = class_levels.voider
  self.enchanter_level = class_levels.enchanter
  self.healer_level = class_levels.healer
  self.psyker_level = class_levels.psyker
  self.conjurer_level = class_levels.conjurer
end


function Arena:update(dt)
  if input.k.pressed then
    SpawnEffect{group = self.effects, x = gw/2, y = gh/2, action = function(x, y)
      spawn1:play{pitch = random:float(0.8, 1.2), volume = 0.15}
      Seeker{group = self.main, x = x, y = y, character = 'seeker', level = self.level, boss = 'randomizer'}
    end}
  end

  if input.escape.pressed and not self.transitioning then
    if not self.paused then
      trigger:tween(0.25, _G, {slow_amount = 0}, math.linear, function()
        slow_amount = 0
        self.paused = true
        self.paused_t1 = Text2{group = self.ui, x = gw/2, y = gh/2 - 68, sx = 0.6, sy = 0.6, lines = {{text = '[bg10]<- or a         -> or d', font = fat_font, alignment = 'center'}}}
        self.paused_t2 = Text2{group = self.ui, x = gw/2, y = gh/2 - 52, lines = {{text = '[bg10]turn left                                      turn right', font = pixul_font, alignment = 'center'}}}
        self.paused_t3 = Text2{group = self.ui, x = gw/2, y = gh/2 - 22, sx = 0.6, sy = 0.6, lines = {{text = '[bg10]n - mute sfx', font = fat_font, alignment = 'center'}}}
        self.paused_t4 = Text2{group = self.ui, x = gw/2, y = gh/2 + 0, sx = 0.6, sy = 0.6, lines = {{text = '[bg10]m - mute music', font = fat_font, alignment = 'center'}}}
        self.paused_t5 = Text2{group = self.ui, x = gw/2, y = gh/2 + 22, sx = 0.6, sy = 0.6, lines = {{text = '[bg10]esc - resume game', font = fat_font, alignment = 'center'}}}
        self.paused_t6 = Text2{group = self.ui, x = gw/2, y = gh/2 + 44, sx = 0.6, sy = 0.6, lines = {{text = '[bg10]r - restart run', font = fat_font, alignment = 'center'}}}
        self.paused_t7 = Text2{group = self.ui, x = gw/2, y = gh/2 + 68, sx = 0.6, sy = 0.6, lines = {{text = '[bg10]w - wishlist on steam', font = fat_font, alignment = 'center'}}}
      end, 'pause')
    else
      trigger:tween(0.25, _G, {slow_amount = 1}, math.linear, function()
        slow_amount = 1
        self.paused = false
        self.paused_t1.dead = true
        self.paused_t2.dead = true
        self.paused_t3.dead = true
        self.paused_t4.dead = true
        self.paused_t5.dead = true
        self.paused_t6.dead = true
        self.paused_t7.dead = true
        self.paused_t1 = nil
        self.paused_t2 = nil
        self.paused_t3 = nil
        self.paused_t4 = nil
        self.paused_t5 = nil
        self.paused_t6 = nil
        self.paused_t7 = nil
      end, 'pause')
    end
  end

  if self.paused or self.died and not self.transitioning then
    if input.r.pressed then
      self.transitioning = true
      ui_transition2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      TransitionEffect{group = main.transitions, x = gw/2, y = gh/2, color = fg[0], transition_action = function()
        slow_amount = 1
        gold = 2
        passives = {}
        cascade_instance:stop()
        main:add(BuyScreen'buy_screen')
        main:go_to('buy_screen', 0, {}, passives)
      end, text = Text({{text = '[wavy, bg]restarting...', font = pixul_font, alignment = 'center'}}, global_text_tags)}
    end

    --[[
    if input.w.pressed then
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      system.open_url'https://store.steampowered.com/app/915310/SNKRX/'
    end
    ]]--
  end

  --[[
  if input.w.pressed and self.won then
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    system.open_url'https://store.steampowered.com/app/915310/SNKRX/'
  end
  ]]--

  self:update_game_object(dt*slow_amount)
  cascade_instance.pitch = math.clamp(slow_amount*self.main_slow_amount, 0.05, 1)

  self.floor:update(dt*slow_amount)
  self.main:update(dt*slow_amount*self.main_slow_amount)
  self.post_main:update(dt*slow_amount)
  self.effects:update(dt*slow_amount)
  self.ui:update(dt*slow_amount)

  if self.can_quit and #self.main:get_objects_by_classes(self.enemies) <= 0 and not self.transitioning then
    self.can_quit = false

    if self.level == 25 then
      if not self.win_text and not self.win_text2 then
        self.won = true
        camera.x, camera.y = gw/2, gh/2
        self.win_text = Text2{group = self.ui, x = gw/2, y = gh/2 - 66, lines = {{text = '[wavy_mid, cbyc2]congratulations!', font = fat_font, alignment = 'center'}}}
        self.t:after(2.5, function()
          self.win_text2 = Text2{group = self.ui, x = gw/2, y = gh/2 + 20, lines = {
            {text = "[fg]you've beaten the game!", font = pixul_font, alignment = 'center', height_multiplier = 1.2},
            {text = "[fg]i made this game in 2 months as a dev challenge", font = pixul_font, alignment = 'center', height_multiplier = 1.2},
            {text = "[fg]and i'm happy with how it turned out!", font = pixul_font, alignment = 'center', height_multiplier = 1.2},
            {text = "[fg]if you liked it too and want to play more games like this:", font = pixul_font, alignment = 'center', height_multiplier = 5},
            {text = "[fg]i will release more games this year, so stay tuned!", font = pixul_font, alignment = 'center', height_multiplier = 1.4},
            {text = "[wavy_mid, yellow]thanks for playing!", font = pixul_font, alignment = 'center'},
          }}
          SteamFollowButton{group = self.ui, x = gw/2, y = gh/2 + 37}
          RestartButton{group = self.ui, x = gw - 40, y = gh - 20}
        end)
      end

    else
      if not self.arena_clear_text then self.arena_clear_text = Text2{group = self.ui, x = gw/2, y = gh/2 - 48, lines = {{text = '[wavy_mid, cbyc]arena clear!', font = fat_font, alignment = 'center'}}} end
      self.t:after(3, function()
        if self.level % 3 == 0 then
          self.arena_clear_text.dead = true
          trigger:tween(1, _G, {slow_amount = 0}, math.linear, function() slow_amount = 0 end)
          trigger:tween(4, camera, {x = gw/2, y = gh/2, r = 0}, math.linear, function() camera.x, camera.y, camera.r = gw/2, gh/2, 0 end)
          local card_w, card_h = 100, 100
          local w = 3*card_w + 2*20
          self.choosing_passives = true
          self.cards = {}
          local passive_1 = random:table(tier_to_passives[random:weighted_pick(unpack(level_to_passive_tier_weights[level or self.level]))])
          local passive_2 = random:table(tier_to_passives[random:weighted_pick(unpack(level_to_passive_tier_weights[level or self.level]))])
          local passive_3 = random:table(tier_to_passives[random:weighted_pick(unpack(level_to_passive_tier_weights[level or self.level]))])
          table.insert(self.cards, PassiveCard{group = main.current.ui, x = gw/2 - w/2 + 0*(card_w + 20) + card_w/2, y = gh/2 - 6, w = card_w, h = card_h, arena = self, passive = passive_1, force_update = true})
          table.insert(self.cards, PassiveCard{group = main.current.ui, x = gw/2 - w/2 + 1*(card_w + 20) + card_w/2, y = gh/2 - 6, w = card_w, h = card_h, arena = self, passive = passive_2, force_update = true})
          table.insert(self.cards, PassiveCard{group = main.current.ui, x = gw/2 - w/2 + 2*(card_w + 20) + card_w/2, y = gh/2 - 6, w = card_w, h = card_h, arena = self, passive = passive_3, force_update = true})
          self.passive_text = Text2{group = self.ui, x = gw/2, y = gh/2 - 65, lines = {{text = '[fg, wavy]choose one', font = fat_font, alignment = 'center'}}}
        else
          self:transition()
        end
      end, 'transition')
    end
  end
end


function Arena:draw()
  self.floor:draw()
  self.main:draw()
  self.post_main:draw()
  self.effects:draw()
  if self.level == 18 and self.trailer then graphics.rectangle(gw/2, gh/2, 2*gw, 2*gh, nil, nil, modal_transparent) end
  if self.choosing_passives or self.won or self.paused then graphics.rectangle(gw/2, gh/2, 2*gw, 2*gh, nil, nil, modal_transparent) end
  self.ui:draw()

  graphics.draw_with_mask(function()
    star_canvas:draw(0, 0, 0, 1, 1)
  end, function()
    camera:attach()
    graphics.rectangle(gw/2, gh/2, self.w, self.h, nil, nil, fg[0])
    camera:detach()
  end, true)

  camera:attach()
  if self.start_time and self.start_time > 0 and not self.choosing_passives then
    graphics.push(gw/2, gh/2 - 48, 0, self.hfx.condition1.x, self.hfx.condition1.x)
      graphics.print_centered(tostring(self.start_time), fat_font, gw/2, gh/2 - 48, 0, 1, 1, nil, nil, self.hfx.condition1.f and fg[0] or red[0])
    graphics.pop()
  end

  if self.boss_level then
    if self.start_time <= 0 then
      graphics.push(self.x2 - 106, self.y1 - 10, 0, self.hfx.condition2.x, self.hfx.condition2.x)
        graphics.print_centered('kill the elite', fat_font, self.x2 - 106, self.y1 - 10, 0, 0.6, 0.6, nil, nil, fg[0])
      graphics.pop()
    end
  else
    if self.win_condition then
      if self.win_condition == 'time' then
        if self.start_time <= 0 then
          graphics.push(self.x2 - 66, self.y1 - 9, 0, self.hfx.condition2.x, self.hfx.condition2.x)
            graphics.print_centered('time left:', fat_font, self.x2 - 66, self.y1 - 9, 0, 0.6, 0.6, nil, nil, fg[0])
          graphics.pop()
          graphics.push(self.x2 - 18 + fat_font:get_text_width(tostring(self.time_left))/2, self.y1 - 8, 0, self.hfx.condition1.x, self.hfx.condition1.x)
            graphics.print(tostring(self.time_left), fat_font, self.x2 - 18, self.y1 - 8, 0, 0.75, 0.75, nil, fat_font.h/2, self.hfx.condition1.f and fg[0] or yellow[0])
          graphics.pop()
        end
      elseif self.win_condition == 'wave' then
        if self.start_time <= 0 then
          graphics.push(self.x2 - 50, self.y1 - 10, 0, self.hfx.condition2.x, self.hfx.condition2.x)
            graphics.print_centered('wave:', fat_font, self.x2 - 50, self.y1 - 10, 0, 0.6, 0.6, nil, nil, fg[0])
          graphics.pop()
          graphics.push(self.x2 - 25 + fat_font:get_text_width(self.wave .. '/' .. self.max_waves)/2, self.y1 - 8, 0, self.hfx.condition1.x, self.hfx.condition1.x)
            graphics.print(self.wave .. '/' .. self.max_waves, fat_font, self.x2 - 25, self.y1 - 8, 0, 0.75, 0.75, nil, fat_font.h/2, self.hfx.condition1.f and fg[0] or yellow[0])
          graphics.pop()
        end
      end
    end
  end
  camera:detach()
end


function Arena:die()
  if not self.died_text and not self.won then
    self.died = true
    self.t:tween(2, self, {main_slow_amount = 0}, math.linear, function() self.main_slow_amount = 0 end)
    self.died_text = Text2{group = self.ui, x = gw/2, y = gh/2 - 32, lines = {
      {text = '[wavy_mid, cbyc]you died...', font = fat_font, alignment = 'center', height_multiplier = 1.25},
    }}
    self.t:after(2, function()
      self.death_info_text = Text2{group = self.ui, x = gw/2, y = gh/2 + 24, sx = 0.7, sy = 0.7, lines = {
        {text = '[wavy_mid, light_bg]level reached: [wavy_mid, yellow]' .. self.level, font = fat_font, alignment = 'center'},
        {text = '[wavy_mid, light_bg]r - start new run', font = fat_font, alignment = 'center'},
      }}
    end)
  end
end


function Arena:transition()
  self.transitioning = true
  local gold_gained = random:int(level_to_gold_gained[self.level][1], level_to_gold_gained[self.level][2])
  gold = gold + gold_gained
  ui_transition2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  TransitionEffect{group = main.transitions, x = self.player.x, y = self.player.y, color = self.color, transition_action = function(t)
    main:add(BuyScreen'buy_screen')
    main:go_to('buy_screen', self.level, self.units, passives)
    t.t:after(0.1, function()
      t.text:set_text({
        {text = '[nudge_down, bg]gold gained: ' .. tostring(gold_gained), font = pixul_font, alignment = 'center', height_multiplier = 1.5},
        {text = '[wavy_lower, bg]damage taken: 0', font = pixul_font, alignment = 'center', height_multiplier = 1.5},
        {text = '[wavy_lower, bg]damage dealt: 0', font = pixul_font, alignment = 'center'}
      })
      _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      t.t:after(0.2, function()
        t.text:set_text({
          {text = '[wavy_lower, bg]gold gained: ' .. tostring(gold_gained), font = pixul_font, alignment = 'center', height_multiplier = 1.5},
          {text = '[nudge_down, bg]damage taken: ' .. tostring(math.round(self.damage_taken, 0)), font = pixul_font, alignment = 'center', height_multiplier = 1.5},
          {text = '[wavy_lower, bg]damage dealt: 0', font = pixul_font, alignment = 'center'}
        })
        _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        t.t:after(0.2, function()
          t.text:set_text({
            {text = '[wavy_lower, bg]gold gained: ' .. tostring(gold_gained), font = pixul_font, alignment = 'center', height_multiplier = 1.5},
            {text = '[wavy_lower, bg]damage taken: ' .. tostring(math.round(self.damage_taken, 0)), font = pixul_font, alignment = 'center', height_multiplier = 1.5},
            {text = '[nudge_down, bg]damage dealt: ' .. tostring(math.round(self.damage_dealt, 0)), font = pixul_font, alignment = 'center'}
          })
          _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        end)
      end)
    end)
  end, text = Text({
    {text = '[wavy_lower, bg]gold gained: 0', font = pixul_font, alignment = 'center', height_multiplier = 1.5},
    {text = '[wavy_lower, bg]damage taken: 0', font = pixul_font, alignment = 'center', height_multiplier = 1.5},
    {text = '[wavy_lower, bg]damage dealt: 0', font = pixul_font, alignment = 'center'}
  }, global_text_tags)}
end


function Arena:spawn_distributed_enemies()
  local t = {'4', '4+4', '4+4+4', '2x4', '3x4', '4x2'}
  local spawn_type = t[random:weighted_pick(40, 20, 5, 15, 5, 15)]
  local spawn_points = table.copy(self.spawn_points)
  if spawn_type == '4' then
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function()
      self:spawn_n_enemies(p)
    end)
  elseif spawn_type == '4+4' then
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function()
      self:spawn_n_enemies(p)
      self.t:after(2, function() self:spawn_n_enemies(p) end)
    end)
  elseif spawn_type == '4+4+4' then
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function()
      self:spawn_n_enemies(p)
      self.t:after(1, function()
        self:spawn_n_enemies(p)
        self.t:after(1, function()
          self:spawn_n_enemies(p)
        end)
      end)
    end)
  elseif spawn_type == '2x4' then
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 1) end)
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 2) end)
  elseif spawn_type == '3x4' then
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 1) end)
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 2) end)
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 3) end)
  elseif spawn_type == '4x2' then
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 1, 2) end)
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 2, 2) end)
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 3, 2) end)
    local p = random:table_remove(spawn_points)
    SpawnMarker{group = self.effects, x = p.x, y = p.y}
    self.t:after(0.75, function() self:spawn_n_enemies(p, 4, 2) end)
  end
end


function Arena:spawn_n_enemies(p, j, n)
  if self.died then return end
  j = j or 1
  n = n or 4
  self.last_spawn_enemy_time = love.timer.getTime()
  self.t:every(0.1, function()
    local o = self.spawn_offsets[(self.t:get_every_iteration('spawn_enemies_' .. j) % 5) + 1]
    SpawnEffect{group = self.effects, x = p.x + o.x, y = p.y + o.y, action = function(x, y)
      spawn1:play{pitch = random:float(0.8, 1.2), volume = 0.15}
      Seeker{group = self.main, x = x, y = y, character = 'seeker', level = self.level}
    end}
  end, n, nil, 'spawn_enemies_' .. j)
end
