Arena = Object:extend()
Arena:implement(State)
Arena:implement(GameObject)
function Arena:init(name)
  self:init_state(name)
  self:init_game_object()
end


function Arena:on_enter(from, level)
  self.hfx:add('condition1', 1)
  self.hfx:add('condition2', 1)
  self.level = level or 1

  self.main = Group():set_as_physics_world(32, 0, 0, {'player', 'enemy', 'projectile', 'enemy_projectile'})
  self.post_main = Group()
  self.effects = Group()
  self.ui = Group():no_camera()
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

  self.enemies = {Seeker}

  self.x1, self.y1 = gw/2 - 0.8*gw/2, gh/2 - 0.8*gh/2
  self.x2, self.y2 = gw/2 + 0.8*gw/2, gh/2 + 0.8*gh/2
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

  self.player = Player{group = self.main, x = gw/2, y = gh/2, leader = true, character = 'swordsman'}
  self.player:add_follower(Player{group = self.main, character = 'archer'})
  self.player:add_follower(Player{group = self.main, character = 'vagrant'})
  self.player:add_follower(Player{group = self.main, character = 'cleric'})
  self.player:add_follower(Player{group = self.main, character = 'scout'})
  self.player:add_follower(Player{group = self.main, character = 'wizard'})

  self.win_condition = random:table{'time', 'enemy_kill', 'wave'}
  if self.win_condition == 'wave' then
    self.level_to_max_waves = {
      2, 2, random:int(2, 3),
      3, 3, 3, random:int(3, 4),
      4, 4, 4, 4, random:int(4, 5),
      5, 5, 5, 5, 5, random:int(5, 6),
      6, 7, 8, 9, 9, 10
    }
    self.max_waves = self.level_to_max_waves[self.level]
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
        self.wave = 0
        self.t:every(function() return #self.main:get_objects_by_classes(self.enemies) <= 0 end, function()
          self.wave = self.wave + 1
          self.hfx:use('condition1', 0.25, 200, 10)
          self.hfx:pull('condition2', 0.0625)
          self.t:after(0.5, function()
            local spawn_type = random:table{'left', 'middle', 'right'}
            local spawn_points = {left = {x = self.x1 + 32, y = gh/2}, middle = {x = gw/2, y = gh/2}, right = {x = self.x2 - 32, y = gh/2}}
            self:spawn_n_enemies(spawn_points[spawn_type], nil, 8 + (self.wave-1)*2)
          end)
        end, self.max_waves, function() self.can_quit = true end)
      end)
    end)

  elseif self.win_condition == 'enemy_kill' then
    self.level_to_enemies_to_kill = {
      16, 16, random:int(16, 18),
      18, 18, 18, random:int(18, 20),
      20, 20, 20, 20, random:int(20, 22),
      22, 22, 22, 22, 22, random:int(22, 24),
      24, 26, 28, 30, 30, 32
    }
    self.enemies_killed = 0
    self.enemies_to_kill = self.level_to_enemies_to_kill[self.level]
    self.enemy_spawn_delay = 8
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
        self:spawn_distributed_enemies()
        self.t:every(2, function()
          if love.timer.getTime() - self.last_spawn_enemy_time >= self.enemy_spawn_delay then
            self:spawn_distributed_enemies()
          end
        end, nil, nil, 'spawn_enemies')
      end)
    end)

  elseif self.win_condition == 'time' then
    self.level_to_time_left = {
      20, 20, random:int(20, 25),
      25, 25, 25, random:int(25, 30),
      30, 30, 30, 30, random:int(30, 35),
      35, 35, 35, 35, 35, random:int(35, 40),
      40, 45, 50, 55, 55, 60
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
        end, self.time_left, function() self.can_quit = true end)

        self.t:every_immediate(2, function()
          if #self.main:get_objects_by_classes(self.enemies) <= 0 or love.timer.getTime() - self.last_spawn_enemy_time >= 8 then
            self:spawn_distributed_enemies()
          end
        end, self.time_left/2)
      end)
    end)
  end
end


function Arena:update(dt)
  self:update_game_object(dt*slow_amount)
  self.main:update(dt*slow_amount)
  self.post_main:update(dt*slow_amount)
  self.effects:update(dt*slow_amount)
  self.ui:update(dt*slow_amount)

  if self.win_condition == 'enemy_kill' then
    if self.can_quit then
      self.t:after(2, function()
        -- PostArenaScreen{group = self.ui, x = gw/2, y = gh/2}
      end)
    end

  else
    if self.can_quit and #self.main:get_objects_by_classes(self.enemies) <= 0 then
      self.can_quit = false
      self.t:after(2, function()
        if #self.main:get_objects_by_classes(self.enemies) > 0 then
          self.can_quit = true
        else
          -- PostArenaScreen{group = self.ui, x = gw/2, y = gh/2}
        end
      end)
    end
  end
end


function Arena:draw()
  self.main:draw()
  self.post_main:draw()
  self.effects:draw()
  self.ui:draw()

  camera:attach()
  if self.start_time and self.start_time > 0 then
    graphics.push(gw/2, gh/2 - 48, 0, self.hfx.condition1.x, self.hfx.condition1.x)
      graphics.print_centered(tostring(self.start_time), fat_font, gw/2, gh/2 - 48, 0, 1, 1, nil, nil, self.hfx.condition1.f and fg[0] or red[0])
    graphics.pop()
  end

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
    elseif self.win_condition == 'enemy_kill' then
      if self.start_time <= 0 then
        graphics.push(self.x2 - 106, self.y1 - 10, 0, self.hfx.condition2.x, self.hfx.condition2.x)
          graphics.print_centered('enemies killed:', fat_font, self.x2 - 106, self.y1 - 10, 0, 0.6, 0.6, nil, nil, fg[0])
        graphics.pop()
        graphics.push(self.x2 - 41 + fat_font:get_text_width(self.enemies_killed .. '/' .. self.enemies_to_kill)/2, self.y1 - 8, 0, self.hfx.condition1.x, self.hfx.condition1.x)
          graphics.print(self.enemies_killed .. '/' .. self.enemies_to_kill, fat_font, self.x2 - 41, self.y1 - 8, 0, 0.75, 0.75, nil, fat_font.h/2, self.hfx.condition1.f and fg[0] or yellow[0])
        graphics.pop()
      end
    end
  end
  camera:detach()
end


function Arena:enemy_killed()
  if self.win_condition == 'enemy_kill' then
    self.enemies_killed = self.enemies_killed + 1
    self.hfx:use('condition1', 0.25, 200, 10)
    self.hfx:pull('condition2', 0.0625)
    self.enemy_spawn_delay = self.enemy_spawn_delay*0.95
    if self.enemies_killed >= self.enemies_to_kill then
      self.can_quit = true
      self.t:cancel'spawn_enemies'
    end
  end
end


function Arena:spawn_distributed_enemies()
  local t = {'4', '4+4', '4+4+4', '2x4', '3x4', '4x2'}
  local spawn_type = t[random:weighted_pick(40, 20, 5, 15, 5, 15)]
  local spawn_points = table.copy(self.spawn_points)
  if spawn_type == '4' then
    self:spawn_n_enemies(random:table_remove(spawn_points))
  elseif spawn_type == '4+4' then
    local p = random:table_remove(spawn_points)
    self:spawn_n_enemies(p)
    self.t:after(2, function() self:spawn_n_enemies(p) end)
  elseif spawn_type == '4+4+4' then
    local p = random:table_remove(spawn_points)
    self:spawn_n_enemies(p)
    self.t:after(1, function()
      self:spawn_n_enemies(p)
      self.t:after(1, function()
        self:spawn_n_enemies(p)
      end)
    end)
  elseif spawn_type == '2x4' then
    self:spawn_n_enemies(random:table_remove(spawn_points), 1)
    self:spawn_n_enemies(random:table_remove(spawn_points), 2)
  elseif spawn_type == '3x4' then
    self:spawn_n_enemies(random:table_remove(spawn_points), 1)
    self:spawn_n_enemies(random:table_remove(spawn_points), 2)
    self:spawn_n_enemies(random:table_remove(spawn_points), 3)
  elseif spawn_type == '4x2' then
    self:spawn_n_enemies(random:table_remove(spawn_points), 1, 2)
    self:spawn_n_enemies(random:table_remove(spawn_points), 2, 2)
    self:spawn_n_enemies(random:table_remove(spawn_points), 3, 2)
    self:spawn_n_enemies(random:table_remove(spawn_points), 4, 2)
  end
end


function Arena:spawn_n_enemies(p, j, n)
  j = j or 1
  n = n or 4
  self.last_spawn_enemy_time = love.timer.getTime()
  self.t:every(0.1, function()
    local o = self.spawn_offsets[(self.t:get_every_iteration('spawn_enemies_' .. j) % 5) + 1]
    SpawnEffect{group = self.effects, x = p.x + o.x, y = p.y + o.y, action = function(x, y)
      spawn1:play{pitch = random:float(0.8, 1.2), volume = 0.15}
      if self.level == 1 then
        Seeker{group = self.main, x = x, y = y, character = 'seeker'}
      elseif self.level == 2 then
        Seeker{group = self.main, x = x, y = y, character = 'seeker'}
      elseif self.level == 3 then
      elseif self.level == 4 then
      elseif self.level == 5 then
      elseif self.level == 6 then
      elseif self.level == 7 then
      elseif self.level == 8 then
      elseif self.level == 9 then
      elseif self.level == 10 then
      elseif self.level == 11 then
      elseif self.level == 12 then
      elseif self.level == 13 then
      elseif self.level == 14 then
      elseif self.level == 15 then
      elseif self.level == 16 then
      elseif self.level == 17 then
      elseif self.level == 18 then
      elseif self.level == 19 then
      elseif self.level == 20 then
      elseif self.level == 21 then
      elseif self.level == 22 then
      elseif self.level == 23 then
      elseif self.level == 24 then
      elseif self.level == 25 then
      end
    end}
  end, n, nil, 'spawn_enemies_' .. j)
end
