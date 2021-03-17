LightningLine = Object:extend()
LightningLine:implement(GameObject)
function LightningLine:init(args)
  self:init_game_object(args)
  self.lines = {}
  table.insert(self.lines, {x1 = self.src.x, y1 = self.src.y, x2 = self.dst.x, y2 = self.dst.y})
  self.w = 3
  self.generations = 3
  self.max_offset = 8
  self:generate()
  self.t:tween(0.1, self, {w = 1}, math.linear, function() self.dead = true end)
  self.color = blue[0]
  HitCircle{group = main.current.effects, x = self.src.x, y = self.src.y, rs = 6, color = fg[0], duration = 0.1}
  for i = 1, 2 do HitParticle{group = main.current.effects, x = self.src.x, y = self.src.y, color = blue[0]} end
  HitCircle{group = main.current.effects, x = self.dst.x, y = self.dst.y, rs = 6, color = fg[0], duration = 0.1}
  HitParticle{group = main.current.effects, x = self.dst.x, y = self.dst.y, color = blue[0]}
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
    table.insert(self.points, line.x1)
    table.insert(self.points, line.y1)
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


function Unit:show_squire(n)
  self.effect_bar.hidden = false
  self.effect_bar.color = purple[0]
  self.t:after(n or 4, function() self.effect_bar.hidden = false end, 'effect_bar')
end


function Unit:show_chronomancer(n)
  self.effect_bar.hidden = false
  self.effect_bar.color = purple[0]
  self.t:after(n or 2, function() self.effect_bar.hidden = false end, 'effect_bar')
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
    local x = self.level
    local y = {0, 1, 4, 2, 3, 6, 3, 5, 9, 4, 6, 11, 7, 9, 15, 8, 10, 18, 9, 11, 21, 14, 15, 24, 25}
    self.base_hp = 50 + 55*y[x]
    self.base_dmg = 10 + 3*y[x]
    self.base_mvspd = 70 + 3*y[x]
  elseif self:is(Saboteur) then
    self.base_hp = 100*math.pow(2, self.level-1)
    self.base_dmg = 10*math.pow(2, self.level-1)
    self.base_mvspd = 75
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
