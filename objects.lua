Unit = Object:extend()
function Unit:init_unit()
  self.hfx:add('hit', 1)
  self.hfx:add('shoot', 1)
  self.hp_bar = HPBar{group = main.current.effects, parent = self}
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
end


function Unit:show_hp(n)
  self.hp_bar.hidden = false
  self.t:after(n or 2, function() self.hp_bar.hidden = true end, 'hp_bar')
end


function Unit:hit(damage)
  if self.dead then return end

  self.hfx:use('hit', 0.25, 200, 10)
  self:show_hp()
  
  local actual_damage = self:calculate_damage(damage)
  self.hp = self.hp - actual_damage
  if self:is(Player) then
    if actual_damage >= 20 then
      camera:shake(2, 1)
      slow(0.25, 1)
    else
      camera:shake(2, 0.5)
    end
  end

  if self.hp <= 0 then
    self.dead = true
    for i = 1, random:int(4, 6) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.color} end
    HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 12}:scale_down(0.3):change_color(0.5, self.color)
  end
end


function Unit:calculate_damage(dmg)
  if self.def >= 0 then dmg = dmg*(100/(100+self.def))
  else dmg = dmg*(2 - 100/(100+self.def)) end
  return dmg
end


function Unit:calculate_stats(first_run)
  self.base_hp = 100
  self.base_dmg = 10
  self.base_aspd_m = 1
  self.base_area_dmg_m = 1
  self.base_area_size_m = 1
  self.base_def = 0
  self.base_mvspd = 75
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

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_hp_m = self.class_hp_m*1.4
    elseif class == 'mage' then self.class_hp_m = self.class_hp_m*0.6
    elseif class == 'healer' then self.class_hp_m = self.class_hp_m*1.1
    elseif class == 'void' then self.class_hp_m = self.class_hp_m*0.9
    elseif class == 'seeker' then self.class_hp_m = self.class_hp_m*0.5 end
  end
  self.max_hp = (self.base_hp + self.class_hp_a + self.buff_hp_a)*self.class_hp_m*self.buff_hp_m
  if first_run then self.hp = self.max_hp end

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_dmg_m = self.class_dmg_m*1.1
    elseif class == 'ranger' then self.class_dmg_m = self.class_dmg_m*1.2
    elseif class == 'mage' then self.class_dmg_m = self.class_dmg_m*1.4 end
  end
  self.dmg = (self.base_dmg + self.class_dmg_a + self.buff_dmg_a)*self.class_dmg_m*self.buff_dmg_m

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_aspd_m = self.class_aspd_m*0.9
    elseif class == 'ranger' then self.class_aspd_m = self.class_aspd_m*1.4
    elseif class == 'healer' then self.class_aspd_m = self.class_aspd_m*0.5
    elseif class == 'void' then self.class_aspd_m = self.class_aspd_m*0.75 end
  end
  self.aspd_m = 1/(self.base_aspd_m*self.class_aspd_m*self.buff_aspd_m)

  for _, class in ipairs(self.classes) do
    if class == 'mage' then self.class_area_dmg_m = self.class_area_dmg_m*1.25
    elseif class == 'void' then self.class_area_dmg_m = self.class_area_m*1.5 end
  end
  self.area_dmg_m = self.base_area_dmg_m*self.class_area_dmg_m*self.buff_area_dmg_m

  for _, class in ipairs(self.classes) do
    if class == 'mage' then self.class_area_size_m = self.class_area_size_m*1.2
    elseif class == 'void' then self.class_area_size_m = self.class_area_m*1.3 end
  end
  self.area_size_m = self.base_area_size_m*self.class_area_size_m*self.buff_area_size_m

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_def_m = self.class_def_m*1.25
    elseif class == 'ranger' then self.class_def_m = self.class_def_m*1.1
    elseif class == 'mage' then self.class_def_m = self.class_def_m*0.8
    elseif class == 'healer' then self.class_def_m = self.class_def_m*1.2 end
  end
  self.def = (self.base_def + self.class_def_a + self.buff_def_a)*self.class_def_m*self.buff_def_m

  for _, class in ipairs(self.classes) do
    if class == 'warrior' then self.class_mvspd_m = self.class_mvspd_m*0.9
    elseif class == 'ranger' then self.class_mvspd_m = self.class_mvspd_m*1.2
    elseif class == 'seeker' then self.class_mvspd_m = self.class_mvspd_m*0.3 end
  end
  self.v = (self.base_mvspd + self.class_mvspd_a + self.buff_mvspd_a)*self.class_mvspd_m*self.buff_mvspd_m
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
