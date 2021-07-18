SpawnMarker = Object:extend()
SpawnMarker:implement(GameObject)
function SpawnMarker:init(args)
  self:init_game_object(args)
  self.color = red[0]
  self.r = random:float(0, 2*math.pi)
  self.spring:pull(random:float(0.4, 0.6), 200, 10)
  self.t:after(1.125, function() self.dead = true end)
  self.m = 1
  self.n = 0
  pop3:play{pitch = 1, volume = 0.15}
  self.t:every({0.195, 0.24}, function()
    self.hidden = not self.hidden
    self.m = self.m*random:float(0.84, 0.87)
  end, nil, nil, 'blink')
end


function SpawnMarker:update(dt)
  self:update_game_object(dt)
  self.t:set_every_multiplier('blink', self.m)
end


function SpawnMarker:draw()
  if self.hidden then return end
  graphics.push(self.x, self.y, self.r, self.spring.x, self.spring.x)
    graphics.push(self.x, self.y, self.r + math.pi/4)
      graphics.rectangle(self.x, self.y, 24, 6, 4, 4, self.color)
    graphics.pop()
    graphics.push(self.x, self.y, self.r + 3*math.pi/4)
      graphics.rectangle(self.x, self.y, 24, 6, 4, 4, self.color)
    graphics.pop()
  graphics.pop()
end




LightningLine = Object:extend()
LightningLine:implement(GameObject)
function LightningLine:init(args)
  self:init_game_object(args)
  self.lines = {}
  table.insert(self.lines, {x1 = self.src.x, y1 = self.src.y, x2 = self.dst.x, y2 = self.dst.y})
  self.w = 3
  self.generations = args.generations or 3
  self.max_offset = args.max_offset or 8
  self:generate()
  self.t:tween(self.duration or 0.1, self, {w = 1}, math.linear, function() self.dead = true end)
  self.color = args.color or blue[0]
  HitCircle{group = main.current.effects, x = self.src.x, y = self.src.y, rs = 6, color = fg[0], duration = self.duration or 0.1}
  for i = 1, 2 do HitParticle{group = main.current.effects, x = self.src.x, y = self.src.y, color = self.color} end
  HitCircle{group = main.current.effects, x = self.dst.x, y = self.dst.y, rs = 6, color = fg[0], duration = self.duration or 0.1}
  HitParticle{group = main.current.effects, x = self.dst.x, y = self.dst.y, color = self.color}
end


function LightningLine:update(dt)
  self:update_game_object(dt)
end


function LightningLine:draw()
  graphics.polyline(self.color, self.w, unpack(self.points))
end


function LightningLine:generate()
  local offset_amount = self.max_offset
  local lines = self.lines

  for j = 1, self.generations do
    for i = #self.lines, 1, -1 do
      local x1, y1 = self.lines[i].x1, self.lines[i].y1
      local x2, y2 = self.lines[i].x2, self.lines[i].y2
      table.remove(self.lines, i)

      local x, y = (x1+x2)/2, (y1+y2)/2
      local p = Vector(x2-x1, y2-y1):normalize():perpendicular()
      x = x + p.x*random:float(-offset_amount, offset_amount)
      y = y + p.y*random:float(-offset_amount, offset_amount)
      table.insert(self.lines, {x1 = x1, y1 = y1, x2 = x, y2 = y})
      table.insert(self.lines, {x1 = x, y1 = y, x2 = x2, y2 = y2})
    end
    offset_amount = offset_amount/2
  end

  self.points = {}
  while #self.lines > 0 do
    local min_d, min_i = 1000000, 0
    for i, line in ipairs(self.lines) do
      local d = math.distance(self.src.x, self.src.y, line.x1, line.y1)
      if d < min_d then
        min_d = d
        min_i = i
      end
    end
    local line = table.remove(self.lines, min_i)
    if line then
      table.insert(self.points, line.x1)
      table.insert(self.points, line.y1)
    end
  end
end




WallKnife = Object:extend()
WallKnife:implement(GameObject)
WallKnife:implement(Physics)
function WallKnife:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(10, 4, 'dynamic', 'projectile')
  self.hfx:add('hit', 1)
  self.hfx:use('hit', 0.25)
  self.t:tween({0.8, 1.6}, self, {v = 0}, math.linear, function()
    self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self.dead = true end)
  end)

  self.vr = self.r
  self.dvr = random:table{random:float(-8*math.pi, -4*math.pi), random:float(4*math.pi, 8*math.pi)}
end


function WallKnife:update(dt)
  self:update_game_object(dt)

  self:set_angle(self.r)
  self:move_along_angle(self.v, self.r)
  self.vr = self.vr + self.dvr*dt
end


function WallKnife:draw()
  if self.hidden then return end
  graphics.push(self.x, self.y, self.vr, self.hfx.hit.x, self.hfx.hit.x)
  graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end




WallArrow = Object:extend()
WallArrow:implement(GameObject)
function WallArrow:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 10, 4)
  self.hfx:add('hit', 1)
  self.hfx:use('hit', 0.25)
  self.t:after({0.8, 2}, function()
    self.t:every_immediate(0.05, function() self.hidden = not self.hidden end, 7, function() self.dead = true end)
  end)
end


function WallArrow:update(dt)
  self:update_game_object(dt)
end


function WallArrow:draw()
  if self.hidden then return end
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
  graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.hfx.hit.f and fg[0] or self.color)
  graphics.pop()
end




Unit = Object:extend()
function Unit:init_unit()
  self.level = self.level or 1
  self.hfx:add('hit', 1)
  self.hfx:add('shoot', 1)
  self.hp_bar = HPBar{group = main.current.effects, parent = self}
  self.effect_bar = EffectBar{group = main.current.effects, parent = self}
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
  return self.r
end


function Unit:show_hp(n)
  self.hp_bar.hidden = false
  self.hp_bar.color = red[0]
  self.t:after(n or 2, function() self.hp_bar.hidden = true end, 'hp_bar')
end


function Unit:show_heal(n)
  self.effect_bar.hidden = false
  self.effect_bar.color = green[0]
  self.t:after(n or 4, function() self.effect_bar.hidden = true end, 'effect_bar')
end


function Unit:show_infused(n)
  self.effect_bar.hidden = false
  self.effect_bar.color = blue[0]
  self.t:after(n or 4, function() self.effect_bar.hidden = true end, 'effect_bar')
end


function Unit:calculate_damage(dmg)
  if self.def >= 0 then dmg = dmg*(100/(100+self.def))
  else dmg = dmg*(2 - 100/(100+self.def)) end
  return dmg
end


function Unit:calculate_stats(first_run)
  if self:is(Player) then
    self.base_hp = 100*math.pow(2, self.level-1)
    self.base_dmg = 10*math.pow(2, self.level-1)
    self.base_mvspd = 75
  elseif self:is(Seeker) then
    if current_new_game_plus == 0 then
      if self.boss then
        local x = self.level
        local y = {0, 0, 3, 0, 0, 6, 0, 0, 9, 0, 0, 12, 0, 0, 18, 0, 0, 40, 0, 0, 32, 0, 0, 64, 90}
        local y2 = {0, 0, 24, 0, 0, 28, 0, 0, 32, 0, 0, 36, 0, 0, 44, 0, 0, 64, 0, 0, 48, 0, 0, 80, 100}
        local k = 1.07
        for i = 26, 50 do y[i] = y2[i-25] end
        for i = 51, 5000 do
          local n = i % 25
          if n == 0 then
            n = 25
            k = k + 0.07
          end
          y[i] = y2[n]*k
        end
        self.base_hp = 100 + (current_new_game_plus*5) + (90 + current_new_game_plus*10)*y[x]
        self.base_dmg = (12 + current_new_game_plus*2) + (2 + current_new_game_plus)*y[x]
        self.base_mvspd = math.min(35 + 1.5*y[x], 35 + 1.5*y[150])
        if x % 25 == 0 then
          self.base_dmg = (12 + current_new_game_plus*2) + (1.25 + current_new_game_plus)*y[x]
          self.base_mvspd = math.min(35 + 1.1*y[x], 35 + 1.1*y[150])
        end
      else
        local x = self.level
        local y = {0, 1, 3, 3, 4, 6, 5, 6, 9, 7, 8, 12, 10, 11, 15, 12, 13, 18, 16, 17, 21, 17, 20, 24, 25}
        local k = 1.07
        for i = 26, 5000 do
          local n = i % 25
          if n == 0 then
            n = 25
            k = k + 0.07
          end
          y[i] = y[i-10]*k
        end
        self.base_hp = 25 + 16.5*y[x]
        self.base_dmg = 4.5 + 2.5*y[x]
        self.base_mvspd = math.min(70 + 3*y[x], 70 + 3*y[150])
      end
    else
      if self.boss then
        local x = self.level
        local y = {0, 0, 3, 0, 0, 6, 0, 0, 9, 0, 0, 12, 0, 0, 18, 0, 0, 40, 0, 0, 32, 0, 0, 64, 90}
        local y2 = {0, 0, 24, 0, 0, 28, 0, 0, 32, 0, 0, 36, 0, 0, 44, 0, 0, 64, 0, 0, 48, 0, 0, 80, 100}
        local k = 1.07
        for i = 26, 50 do y[i] = y2[i-25] end
        for i = 51, 5000 do
          local n = i % 25
          if n == 0 then
            n = 25
            k = k + 0.07
          end
          y[i] = y2[n]*k
        end
        self.base_hp = 100 + (current_new_game_plus*5) + (90 + current_new_game_plus*10)*y[x]
        self.base_dmg = (12 + current_new_game_plus*2) + (2 + current_new_game_plus)*y[x]
        self.base_mvspd = math.min(35 + 1.5*y[x], 35 + 1.5*y[150])
        if x % 25 == 0 then
          self.base_dmg = (12 + current_new_game_plus*2) + (1.75 + 0.5*current_new_game_plus)*y[x]
          self.base_mvspd = math.min(35 + 1.2*y[x], 35 + 1.2*y[150])
        end
      else
        local x = self.level
        local y = {0, 1, 3, 3, 4, 6, 5, 6, 9, 7, 8, 12, 10, 11, 15, 12, 13, 18, 16, 17, 21, 17, 20, 24, 25}
        local k = 1.07
        for i = 26, 5000 do
          local n = i % 25
          if n == 0 then
            n = 25
            k = k + 0.07
          end
          y[i] = y[i-10]*k
        end
        self.base_hp = 22 + (current_new_game_plus*3) + (15 + current_new_game_plus*2.7)*y[x]
        self.base_dmg = (4 + current_new_game_plus*1.15) + (2 + current_new_game_plus*0.83)*y[x]
        self.base_mvspd = math.min(70 + 3*y[x], 70 + 3*y[150])
      end
    end
  elseif self:is(Saboteur) then
    self.base_hp = 100*math.pow(2, self.level-1)
    self.base_dmg = 10*math.pow(2, self.level-1)
    self.base_mvspd = 75
  elseif self:is(Automaton) then
    self.base_hp = 100*math.pow(2, self.level-1)
    self.base_dmg = 10*math.pow(2, self.level-1)
    self.base_mvspd = 15
  elseif self:is(EnemyCritter) or self:is(Critter) then
    local x = self.level
    local y = {0, 1, 3, 3, 4, 6, 5, 6, 9, 7, 8, 12, 10, 11, 15, 12, 13, 18, 16, 17, 21, 17, 20, 24, 25}
    local k = 1.2
    for i = 26, 5000 do
      local n = i % 25
      if n == 0 then
        n = 25
        k = k + 0.2
      end
      y[i] = y[n]*k
    end
    self.base_hp = 25 + 30*(y[x] or 1)
    self.base_dmg = 10 + 3*(y[x] or 1)
    self.base_mvspd = 60 + 3*(y[x] or 1)
  elseif self:is(Overlord) then
    self.base_hp = 50*math.pow(2, self.level-1)
    self.base_dmg = 10*math.pow(2, self.level-1)
    self.base_mvspd = 40
  end
  self.base_aspd_m = 1
  self.base_area_dmg_m = 1
  self.base_area_size_m = 1
  self.base_def = 25
  self.class_hp_a = 0
  self.class_dmg_a = 0
  self.class_def_a = 0
  self.class_mvspd_a = 0
  self.class_hp_m = 1
  self.class_dmg_m = 1
  self.class_aspd_m = 1
  self.class_area_dmg_m = 1
  self.class_area_size_m = 1
  self.class_def_m = 1
  self.class_mvspd_m = 1
  if first_run then
    self.buff_hp_a = 0
    self.buff_dmg_a = 0
    self.buff_def_a = 0
    self.buff_mvspd_a = 0
    self.buff_hp_m = 1
    self.buff_dmg_m = 1
    self.buff_aspd_m = 1
    self.buff_area_dmg_m = 1
    self.buff_area_size_m = 1
    self.buff_def_m = 1
    self.buff_mvspd_m = 1
  end

  for _, class in ipairs(self.classes) do self.class_hp_m = self.class_hp_m*class_stat_multipliers[class].hp end
  self.max_hp = (self.base_hp + self.class_hp_a + self.buff_hp_a)*self.class_hp_m*self.buff_hp_m
  if first_run then self.hp = self.max_hp end

  for _, class in ipairs(self.classes) do self.class_dmg_m = self.class_dmg_m*class_stat_multipliers[class].dmg end
  self.dmg = (self.base_dmg + self.class_dmg_a + self.buff_dmg_a)*self.class_dmg_m*self.buff_dmg_m

  for _, class in ipairs(self.classes) do self.class_aspd_m = self.class_aspd_m*class_stat_multipliers[class].aspd end
  self.aspd_m = 1/(self.base_aspd_m*self.class_aspd_m*self.buff_aspd_m)

  for _, class in ipairs(self.classes) do self.class_area_dmg_m = self.class_area_dmg_m*class_stat_multipliers[class].area_dmg end
  self.area_dmg_m = self.base_area_dmg_m*self.class_area_dmg_m*self.buff_area_dmg_m

  for _, class in ipairs(self.classes) do self.class_area_size_m = self.class_area_size_m*class_stat_multipliers[class].area_size end
  self.area_size_m = self.base_area_size_m*self.class_area_size_m*self.buff_area_size_m

  for _, class in ipairs(self.classes) do self.class_def_m = self.class_def_m*class_stat_multipliers[class].def end
  self.def = (self.base_def + self.class_def_a + self.buff_def_a)*self.class_def_m*self.buff_def_m

  for _, class in ipairs(self.classes) do self.class_mvspd_m = self.class_mvspd_m*class_stat_multipliers[class].mvspd end
  self.max_v = (self.base_mvspd + self.class_mvspd_a + self.buff_mvspd_a)*self.class_mvspd_m*self.buff_mvspd_m
  self.v = (self.base_mvspd + self.class_mvspd_a + self.buff_mvspd_a)*self.class_mvspd_m*self.buff_mvspd_m
end




EffectBar = Object:extend()
EffectBar:implement(GameObject)
EffectBar:implement(Parent)
function EffectBar:init(args)
  self:init_game_object(args)
  self.hidden = true
  self.color = fg[0]
end


function EffectBar:update(dt)
  self:update_game_object(dt)
  self:follow_parent_exclusively()
end


function EffectBar:draw()
  if self.hidden then return end
  --[[
  local p = self.parent
  graphics.push(p.x, p.y, p.r, p.hfx.hit.x, p.hfx.hit.x)
    graphics.rectangle(p.x, p.y, 3, 3, 1, 1, self.color)
  graphics.pop()
  ]]--
end




HPBar = Object:extend()
HPBar:implement(GameObject)
HPBar:implement(Parent)
function HPBar:init(args)
  self:init_game_object(args)
  self.hidden = true
end


function HPBar:update(dt)
  self:update_game_object(dt)
  self:follow_parent_exclusively()
end


function HPBar:draw()
  if self.hidden then return end
  local p = self.parent
  graphics.push(p.x, p.y, 0, p.hfx.hit.x, p.hfx.hit.x)
    graphics.line(p.x - 0.5*p.shape.w, p.y - p.shape.h, p.x + 0.5*p.shape.w, p.y - p.shape.h, bg[-3], 2)
    local n = math.remap(p.hp, 0, p.max_hp, 0, 1)
    graphics.line(p.x - 0.5*p.shape.w, p.y - p.shape.h, p.x - 0.5*p.shape.w + n*p.shape.w, p.y - p.shape.h,
    p.hfx.hit.f and fg[0] or ((p:is(Player) and green[0]) or (table.any(main.current.enemies, function(v) return p:is(v) end) and red[0])), 2)
  graphics.pop()
end
