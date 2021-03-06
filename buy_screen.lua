BuyScreen = Object:extend()
BuyScreen:implement(State)
BuyScreen:implement(GameObject)
function BuyScreen:init(name)
  self:init_state(name)
  self:init_game_object()
end


function BuyScreen:on_enter(from, level)
  self.level = level

  self.main = Group()
  self.effects = Group()
  self.ui = Group()
  self.info_text = InfoText{group = self.ui}

  if self.level == 0 then
    self.cards = {}
    self.selected_card_index = 1
    local units = {'vagrant', 'swordsman', 'wizard', 'archer', 'scout', 'cleric'}
    self.cards[1] = PairCard{group = self.main, x = gw/2, y = 85, w = gw, h = gh/4, unit_1 = random:table_remove(units), unit_2 = random:table_remove(units), i = 1, parent = self}
    local units = {'vagrant', 'swordsman', 'wizard', 'archer', 'scout', 'cleric'}
    self.cards[2] = PairCard{group = self.main, x = gw/2, y = 155, w = gw, h = gh/4, unit_1 = random:table_remove(units), unit_2 = random:table_remove(units), i = 2, parent = self}
    local units = {'vagrant', 'swordsman', 'wizard', 'archer', 'scout', 'cleric'}
    self.cards[3] = PairCard{group = self.main, x = gw/2, y = 225, w = gw, h = gh/4, unit_1 = random:table_remove(units), unit_2 = random:table_remove(units), i = 3, parent = self}
    self.title = Text({{text = '[fg]choose your initial party', font = pixul_font, alignment = 'center'}}, global_text_tags)
  end
end


function BuyScreen:update(dt)
  self:update_game_object(dt*slow_amount)
  self.main:update(dt*slow_amount)
  self.effects:update(dt*slow_amount)
  self.ui:update(dt*slow_amount)

  if self.level == 0 then
    self.title:update(dt)
    if input.move_up.pressed then
      self.selected_card_index = self.selected_card_index - 1
      if self.selected_card_index == 0 then self.selected_card_index = 3 end
      for i = 1, 3 do self.cards[i]:unselect() end
      self.cards[self.selected_card_index]:select()
    end
    if input.move_down.pressed then
      self.selected_card_index = self.selected_card_index + 1
      if self.selected_card_index == 4 then self.selected_card_index = 1 end
      for i = 1, 3 do self.cards[i]:unselect() end
      self.cards[self.selected_card_index]:select()
    end
  end
end


function BuyScreen:draw()
  self.main:draw()
  self.effects:draw()
  self.ui:draw()

  if self.level == 0 then
    self.title:draw(3.25*gw/4, 25)
  end
end




PairCard = Object:extend()
PairCard:implement(GameObject)
function PairCard:init(args)
  self:init_game_object(args)

  self.plus_r = 0
  if self.i == 1 then self:select() end
end


function PairCard:update(dt)
  self:update_game_object(dt)
end


function PairCard:select()
  self.selected = true
  self.spring:pull(0.2, 200, 10)
  self.t:every_immediate(1.4, function()
    if self.selected then
      self.t:tween(0.7, self, {sx = 0.97, sy = 0.97, plus_r = -math.pi/32}, math.linear, function()
        self.t:tween(0.7, self, {sx = 1.03, sy = 1.03, plus_r = math.pi/32}, math.linear, nil, 'pulse_1')
      end, 'pulse_2')
    end
  end, nil, nil, 'pulse')


  self.parent.info_text:activate({
    {text = '[' .. character_color_strings[self.unit_1] .. ']' .. self.unit_1:upper() .. '[] - ' .. table.reduce(character_classes[self.unit_1],
    function(memo, v) return memo .. '[' .. class_color_strings[v] .. ']' .. v .. '[fg], ' end, ''):sub(1, -3), font = pixul_font, height_multiplier = 1.1},
    {text = character_descriptions[self.unit_1](10), font = pixul_font},
  }, nil, nil, nil, nil, 20, 10, nil, 3)
  self.parent.info_text.x = gw/2
  self.parent.info_text.y = gh/2
end


function PairCard:unselect()
  self.selected = false
  self.t:cancel'pulse'
  self.t:cancel'pulse_1'
  self.t:cancel'pulse_2'
  self.t:tween(0.1, self, {sx = 1, sy = 1, plus_r = 0}, math.linear, function() self.sx, self.sy, self.plus_r = 1, 1, 0 end, 'pulse')
end


function PairCard:draw()
  local x = self.x - self.w/3

  if self.selected then
    graphics.push(x + (fat_font:get_text_width(self.i) + 20)/2, self.y - 25 + 37/2, 0, self.spring.x*self.sx, self.spring.x*self.sy)
      graphics.rectangle2(x - 52, self.y - 25, fat_font:get_text_width(self.i) + 20, 37, 6, 6, bg[2])
    graphics.pop()
  end

  -- 1, 2, 3
  graphics.push(x - 40 + fat_font:get_text_width(self.i)/2, self.y - fat_font.h/8, 0, self.spring.x*self.sx, self.spring.x*self.sy)
    graphics.print(self.i, fat_font, x - 40, self.y, 0, self.sx, self.sy, nil, fat_font.h/2, fg[0])
  graphics.pop()

  -- Unit 1 + class symbols
  graphics.push(x + (fat_font:get_text_width(self.unit_1:capitalize() .. 'w') + table.reduce(character_classes[self.unit_1], function(memo, v) return memo + 0.5*_G[v].w end, 0))/2, self.y - fat_font.h/8, 0,
  self.spring.x*self.sx, self.spring.x*self.sy)
    graphics.print(self.unit_1:capitalize(), fat_font, x, self.y, 0, 1, 1, nil, fat_font.h/2, character_colors[self.unit_1])
    x = x + fat_font:get_text_width(self.unit_1 .. 'w')
    for i, class in ipairs(character_classes[self.unit_1]) do
      _G[class]:draw(x, self.y, 0, 0.4, 0.4, nil, 20, class_colors[class])
      x = x + 0.5*_G[class].w
    end
  graphics.pop()

  -- +
  graphics.push(x + fat_font:get_text_width('+')/2, self.y, self.plus_r, self.spring.x*self.sx, self.spring.x*self.sy)
    graphics.print('+', fat_font, x, self.y, 0, 1, 1, nil, fat_font.h/2, fg[0])
  graphics.pop()

  -- Unit 2 + class symbols
  x = x + fat_font:get_text_width('+l')
  graphics.push(x + (fat_font:get_text_width(self.unit_2:capitalize() .. 'w') + table.reduce(character_classes[self.unit_2], function(memo, v) return memo + 0.5*_G[v].w end, 0))/2, self.y - fat_font.h/8, 0,
  self.spring.x*self.sx, self.spring.x*self.sy)
    graphics.print(self.unit_2:capitalize(), fat_font, x, self.y, 0, 1, 1, nil, fat_font.h/2, character_colors[self.unit_2])
    x = x + fat_font:get_text_width(self.unit_2 .. 'w')
    for i, class in ipairs(character_classes[self.unit_2]) do
      _G[class]:draw(x, self.y, 0, 0.4, 0.4, nil, 20, class_colors[class])
      x = x + 0.5*_G[class].w
    end
  graphics.pop()
end
