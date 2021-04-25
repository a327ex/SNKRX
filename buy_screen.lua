BuyScreen = Object:extend()
BuyScreen:implement(State)
BuyScreen:implement(GameObject)
function BuyScreen:init(name)
  self:init_state(name)
  self:init_game_object()
end


function BuyScreen:on_exit()
  self.main:destroy()
  self.effects:destroy()
  self.ui:destroy()
  self.main = nil
  self.effects = nil
  self.ui = nil
  self.shop_text = nil
  self.party_text = nil
  self.sets_text = nil
  self.items_text = nil
  self.characters = nil
  self.sets = nil
  self.cards = nil
  self.info_text = nil
end


function BuyScreen:on_enter(from, level, units, passives)
  self.level = level
  self.units = units
  self.passives = passives
  camera.x, camera.y = gw/2, gh/2

  if self.level == 0 then
    cascade_instance = cascade:play{volume = 0.5, loop = true}
    self.level = 1
    self.first_screen = true
  end

  steam.friends.setRichPresence('steam_display', '#StatusFull')
  steam.friends.setRichPresence('text', 'Shop - Level ' .. self.level)

  self.main = Group()
  self.effects = Group()
  self.ui = Group()

  self:set_cards()
  self:set_party_and_sets()
  self:set_items()

  self.shop_text = Text({{text = '[wavy_mid, fg]shop [fg]- gold: [yellow]' .. gold, font = pixul_font, alignment = 'center'}}, global_text_tags)
  self.party_text = Text({{text = '[wavy_mid, fg]party', font = pixul_font, alignment = 'center'}}, global_text_tags)
  self.sets_text = Text({{text = '[wavy_mid, fg]classes', font = pixul_font, alignment = 'center'}}, global_text_tags)
  self.items_text = Text({{text = '[wavy_mid, fg]items', font = pixul_font, alignment = 'center'}}, global_text_tags)

  if not self.first_screen then RerollButton{group = self.main, x = 150, y = 18, parent = self} end
  GoButton{group = self.main, x = gw - 135, y = gh - 20, parent = self}
  -- WishlistButton{group = self.main, x = gw - 147, y = gh - 20, parent = self}
end


function BuyScreen:update(dt)
  self:update_game_object(dt*slow_amount)
  cascade_instance.pitch = 1

  self.main:update(dt*slow_amount)
  self.effects:update(dt*slow_amount)
  self.ui:update(dt*slow_amount)

  if self.shop_text then self.shop_text:update(dt) end
  if self.sets_text then self.sets_text:update(dt) end
  if self.party_text then self.party_text:update(dt) end
  if self.items_text then self.items_text:update(dt) end
end


function BuyScreen:draw()
  self.main:draw()
  self.effects:draw()
  if self.items_text then self.items_text:draw(32, 150) end
  self.ui:draw()

  if self.shop_text then self.shop_text:draw(64, 20) end
  if self.sets_text then self.sets_text:draw(328, 20) end
  if self.party_text then self.party_text:draw(440, 20) end
end


function BuyScreen:buy(character, i)
  local bought
  if table.any(self.units, function(v) return v.character == character end) and gold >= character_tiers[character] then
    gold = gold - character_tiers[character]
    self.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = pixul_font, alignment = 'center'}}
    for _, unit in ipairs(self.units) do
      if unit.character == character then
        if unit.level == 1 then
          unit.reserve[1] = unit.reserve[1] + 1
          if unit.reserve[1] > 1 then
            unit.reserve[1] = 0
            unit.level = 2
            unit.spawn_effect = true
          end
        elseif unit.level == 2 then
          unit.reserve[1] = unit.reserve[1] + 1
          if unit.reserve[1] > 2 then
            if unit.reserve[2] == 1 then
              unit.reserve[2] = 0
              unit.reserve[1] = 0
              unit.level = 3
              unit.spawn_effect = true
            else
              unit.reserve[2] = unit.reserve[2] + 1
              unit.reserve[1] = 0
            end
          end
        end
      end
    end
    bought = true
  else
    if #self.units >= 10 then
      if not self.info_text then
        self.info_text = InfoText{group = main.current.ui}
        self.info_text:activate({
          {text = '[fg]maximum number of units [yellow](10) [fg]reached', font = pixul_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text.x, self.info_text.y = gw - 140, gh - 20
      end
      self.t:after(2, function() self.info_text:deactivate(); self.info_text.dead = true; self.info_text = nil end, 'info_text')
    else
      if gold >= character_tiers[character] then
        gold = gold - character_tiers[character]
        self.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = pixul_font, alignment = 'center'}}
        table.insert(self.units, {character = character, level = 1, reserve = {0, 0}})
        bought = true
      end
    end
  end
  self:set_party_and_sets()
  return bought
end


function BuyScreen:gain_gold(amount)
  gold = gold + amount or 0
  self.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = pixul_font, alignment = 'center'}}
end


function BuyScreen:set_cards(level, dont_spawn_effect)
  if self.cards then for i = 1, 3 do if self.cards[i] then self.cards[i]:die(dont_spawn_effect) end end end
  self.cards = {}
  local all_units = {}
  local unit_1
  local unit_2
  local unit_3
  repeat 
    unit_1 = random:table(tier_to_characters[random:weighted_pick(unpack(level_to_tier_weights[level or self.level]))])
    unit_2 = random:table(tier_to_characters[random:weighted_pick(unpack(level_to_tier_weights[level or self.level]))])
    unit_3 = random:table(tier_to_characters[random:weighted_pick(unpack(level_to_tier_weights[level or self.level]))])
    all_units = {unit_1, unit_2, unit_3}
  until not table.all(all_units, function(v) return table.any(non_attacking_characters, function(u) return v == u end) end)
  self.cards[1] = ShopCard{group = self.main, x = 60, y = 75, w = 80, h = 90, unit = unit_1, parent = self, i = 1}
  self.cards[2] = ShopCard{group = self.main, x = 140, y = 75, w = 80, h = 90, unit = unit_2, parent = self, i = 2}
  self.cards[3] = ShopCard{group = self.main, x = 220, y = 75, w = 80, h = 90, unit = unit_3, parent = self, i = 3}
end


function BuyScreen:set_party_and_sets()
  if self.characters then for _, part in ipairs(self.characters) do part:die() end end
  self.characters = {}
  local y = 40
  for i, unit in ipairs(self.units) do
    table.insert(self.characters, CharacterPart{group = self.main, x = gw - 30, y = y + (i-1)*19, character = unit.character, level = unit.level, reserve = unit.reserve, i = i, spawn_effect = unit.spawn_effect, parent = self})
    unit.spawn_effect = false
  end

  if self.sets then for _, icon in ipairs(self.sets) do icon:die(true) end end
  self.sets = {}
  local classes = get_classes(self.units)
  for i, class in ipairs(classes) do
    local x, y
    if #classes <= 6 then x, y = math.index_to_coordinates(i, 2)
    else x, y = math.index_to_coordinates(i, 3) end
    table.insert(self.sets, ClassIcon{group = self.main, x = (#classes <= 6 and 319 or 308) + (x-1)*20, y = 45 + (y-1)*56, class = class, units = self.units, parent = self})
  end
end


function BuyScreen:set_items()
  if self.items then for _, item in ipairs(self.items) do item:die() end end
  self.items = {}
  local y = 182
  for k, item in ipairs(self.passives) do
    local i, j = math.index_to_coordinates(k, 4)
    table.insert(self.items, ItemCard{group = self.main, x = 45 + (i-1)*60, y = y + (j-1)*50, w = 40, h = 50, passive = item})
  end
end




SteamFollowButton = Object:extend()
SteamFollowButton:implement(GameObject)
function SteamFollowButton:init(args)
  self:init_game_object(args)
  self.interact_with_mouse = true
  self.shape = Rectangle(self.x, self.y, fat_font:get_text_width('follow me on steam!'), fat_font.h)
  self.text = Text({{text = '[blue]follow me on steam!', font = fat_font, alignment = 'center'}}, global_text_tags)
end


function SteamFollowButton:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self.spring:pull(0.2, 200, 10)
    self.selected = true
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    system.open_url'https://store.steampowered.com/dev/a327ex/'
  end
end


function SteamFollowButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    self.text:draw(self.x, self.y)
    graphics.rectangle(self.x, self.y + self.text.h/5, self.text.w, 2, 2, 2, self.selected and blue[5] or blue[0])
  graphics.pop()
end


function SteamFollowButton:on_mouse_enter()
  love.mouse.setCursor(love.mouse.getSystemCursor'hand')
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[blue5]follow me on steam!', font = fat_font, alignment = 'center'}}
  self.spring:pull(0.05, 200, 10)
end


function SteamFollowButton:on_mouse_exit()
  love.mouse.setCursor()
  self.text:set_text{{text = '[blue]follow me on steam!', font = fat_font, alignment = 'center'}}
  self.selected = false
end




WishlistButton = Object:extend()
WishlistButton:implement(GameObject)
function WishlistButton:init(args)
  self:init_game_object(args)
  self.interact_with_mouse = true
  if self.w_to_wishlist then
    self.shape = Rectangle(self.x, self.y, 85, 18)
    self.text = Text({{text = '[bg10]w to wishlist', font = pixul_font, alignment = 'center'}}, global_text_tags)
  else
    self.shape = Rectangle(self.x, self.y, 110, 18)
    self.text = Text({{text = '[bg10]wishlist on steam', font = pixul_font, alignment = 'center'}}, global_text_tags)
  end
end


function WishlistButton:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self.spring:pull(0.2, 200, 10)
    self.selected = true
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    system.open_url'https://store.steampowered.com/app/915310/SNKRX/'
  end
end


function WishlistButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or bg[1])
    self.text:draw(self.x, self.y + 1)
  graphics.pop()
end


function WishlistButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  if self.w_to_wishlist then
    self.text:set_text{{text = '[fgm5]w to wishlist', font = pixul_font, alignment = 'center'}}
  else
    self.text:set_text{{text = '[fgm5]wishlist on steam', font = pixul_font, alignment = 'center'}}
  end
  self.spring:pull(0.2, 200, 10)
end


function WishlistButton:on_mouse_exit()
  if self.w_to_wishlist then
    self.text:set_text{{text = '[bg10]w to wishlist', font = pixul_font, alignment = 'center'}}
  else
    self.text:set_text{{text = '[bg10]wishlist on steam', font = pixul_font, alignment = 'center'}}
  end
  self.selected = false
end




RestartButton = Object:extend()
RestartButton:implement(GameObject)
function RestartButton:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, pixul_font:get_text_width('restart') + 4, pixul_font.h + 4)
  self.interact_with_mouse = true
  self.text = Text({{text = '[bg10]restart', font = pixul_font, alignment = 'center'}}, global_text_tags)
end


function RestartButton:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    main.current.transitioning = true
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
end


function RestartButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or bg[1])
    self.text:draw(self.x, self.y + 1, 0, 1, 1)
  graphics.pop()
end


function RestartButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]restart', font = pixul_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
end


function RestartButton:on_mouse_exit()
  self.text:set_text{{text = '[bg10]restart', font = pixul_font, alignment = 'center'}}
  self.selected = false
end




GoButton = Object:extend()
GoButton:implement(GameObject)
function GoButton:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 28, 18)
  self.interact_with_mouse = true
  self.text = Text({{text = '[greenm5]GO!', font = pixul_font, alignment = 'center'}}, global_text_tags)
end


function GoButton:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed and not self.transitioning then
    if #self.parent.units == 0 then
      if not self.info_text then
        error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        self.info_text = InfoText{group = main.current.ui}
        self.info_text:activate({
          {text = '[fg]cannot start the round with [yellow]0 [fg]units', font = pixul_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
      end
      self.t:after(2, function() self.info_text:deactivate(); self.info_text.dead = true; self.info_text = nil end, 'info_text')

    else
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.spring:pull(0.2, 200, 10)
      self.selected = true
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      ui_transition1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.transitioning = true
      TransitionEffect{group = main.transitions, x = self.x, y = self.y, color = character_colors[random:table(self.parent.units).character], transition_action = function()
        main:add(Arena'arena')
        main:go_to('arena', ((self.parent.first_screen and 1) or (self.parent.level + 1)), self.parent.units, self.parent.passives)
      end, text = Text({{text = '[wavy, bg]level ' .. ((self.parent.first_screen and 1) or (self.parent.level + 1)), font = pixul_font, alignment = 'center'}}, global_text_tags)}
    end
  end
end


function GoButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or green[0])
    self.text:draw(self.x, self.y + 1, 0, 1, 1)
  graphics.pop()
end


function GoButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]GO!', font = pixul_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
end


function GoButton:on_mouse_exit()
  self.text:set_text{{text = '[greenm5]GO!', font = pixul_font, alignment = 'center'}}
  self.selected = false
end



RerollButton = Object:extend()
RerollButton:implement(GameObject)
function RerollButton:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 54, 16)
  self.interact_with_mouse = true
  self.text = Text({{text = '[bg10]reroll: [yellow]2', font = pixul_font, alignment = 'center'}}, global_text_tags)
end


function RerollButton:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    if gold < 2 then
      self.spring:pull(0.2, 200, 10)
      self.selected = true
      error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      if not self.info_text then
        self.info_text = InfoText{group = main.current.ui}
        self.info_text:activate({
          {text = '[fg]not enough gold', font = pixul_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
      end
      self.t:after(2, function() self.info_text:deactivate(); self.info_text.dead = true; self.info_text = nil end, 'info_text')
    else
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.parent:set_cards(random:int(1, 25), true)
      self.selected = true
      self.spring:pull(0.2, 200, 10)
      gold = gold - 2
      self.parent.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = pixul_font, alignment = 'center'}}
    end
  end
end


function RerollButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or bg[1])
    self.text:draw(self.x, self.y + 1)
  graphics.pop()
end


function RerollButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]reroll: 2', font = pixul_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
end


function RerollButton:on_mouse_exit()
  self.text:set_text{{text = '[bg10]reroll: [yellow]2', font = pixul_font, alignment = 'center'}}
  self.selected = false
end




CharacterPart = Object:extend()
CharacterPart:implement(GameObject)
function CharacterPart:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.sx*20, self.sy*20)
  self.interact_with_mouse = true
  self.parts = {}
  local x = self.x - 20
  if self.reserve then
    if self.reserve[2] and self.reserve[2] == 1 then
      table.insert(self.parts, CharacterPart{group = main.current.main, x = x, y = self.y, character = self.character, level = 2, i = self.i, parent = self})
      x = x - 20
    end
    for i = 1, self.reserve and self.reserve[1] or 0 do
      table.insert(self.parts, CharacterPart{group = main.current.main, x = x, y = self.y, character = self.character, level = 1, sx = 0.9, sy = 0.9, i = self.i, parent = self})
      x = x - 20
    end
  end
  self.spring:pull(0.2, 200, 10)
  if self.spawn_effect then SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = character_colors[self.character]} end
  self.just_created = true
  self.t:after(0.1, function() self.just_created = false end)
end


function CharacterPart:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m2.pressed and not self.just_created then
    _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    if self.reserve then
      self.parent:gain_gold(self:get_sale_price())
      table.remove(self.parent.units, self.i)
      self:die()
      self.parent:set_party_and_sets()
    else
      self.parent.parent:gain_gold(self:get_sale_price())
      self.parent.parent.units[self.i].reserve[self.level] = self.parent.parent.units[self.i].reserve[self.level] - 1
      self:die()
      self.parent.parent:set_party_and_sets()
    end
  end
end


function CharacterPart:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    graphics.rectangle(self.x, self.y, 14, 14, 3, 3, character_colors[self.character])
    graphics.print_centered(self.level, pixul_font, self.x + 0.5, self.y + 2, 0, 1, 1, 0, 0, _G[character_color_strings[self.character]][-5])
  graphics.pop()
end


function CharacterPart:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.selected = true
  self.spring:pull(0.2, 200, 10)
  self.info_text = InfoText{group = main.current.ui}
  self.info_text:activate({
    {text = '[' .. character_color_strings[self.character] .. ']' .. self.character:capitalize() .. '[fg] - [yellow]Lv.' .. self.level .. '[fg] - sells for [yellow]' .. self:get_sale_price(),
    font = pixul_font, alignment = 'center', height_multiplier = 1.25},
    {text = '[fg]Classes: ' .. character_class_strings[self.character], font = pixul_font, alignment = 'center', height_multiplier = 1.25},
    {text = character_descriptions[self.character](self.level), font = pixul_font, alignment = 'center', height_multiplier = 2},
    {text = '[' .. (self.level == 3 and 'yellow' or 'light_bg') .. ']Lv.3 [' .. (self.level == 3 and 'fg' or 'light_bg') .. ']Effect - ' .. 
      (self.level == 3 and character_effect_names[self.character] or character_effect_names_gray[self.character]), font = pixul_font, alignment = 'center', height_multiplier = 1.25},
    {text = character_effect_descriptions[self.character](), font = pixul_font, alignment = 'center'},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
end


function CharacterPart:get_sale_price()
  local total = 0
  total = total + ((self.level == 1 and 1) or (self.level == 2 and 4) or (self.level == 3 and 8))
  if self.reserve then
    if self.reserve[2] then total = total + self.reserve[2]*4 end
    if self.reserve[1] then total = total + self.reserve[1] end
  end
  return total
end


function CharacterPart:on_mouse_exit()
  self.selected = false
  self.info_text:deactivate()
  self.info_text.dead = true
  self.info_text = nil
end


function CharacterPart:die()
  self.dead = true
  for _, part in ipairs(self.parts) do part:die() end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end




PassiveCard = Object:extend()
PassiveCard:implement(GameObject)
function PassiveCard:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.w, self.h)
  self.interact_with_mouse = true
  self.passive_name =  Text({{text = '[fg, wavy_mid]' .. passive_names[self.passive], font = pixul_font, alignment = 'center'}}, global_text_tags)
  self.passive_description = passive_descriptions[self.passive]
end


function PassiveCard:update(dt)
  self:update_game_object(dt)
  self.passive_name:update(dt)

  if self.selected and input.m1.pressed and self.arena.choosing_passives then
    self.arena.choosing_passives = false
    table.insert(passives, self.passive)
    trigger:tween(0.25, _G, {slow_amount = 1}, math.linear, function()
      slow_amount = 1
      self.arena:transition()
    end)
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self:die()
  end
end


function PassiveCard:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    self.passive_name:draw(self.x, self.y - 20)
    _G[self.passive]:draw(self.x, self.y + 24, 0, 1, 1, 0, 0, fg[0])
  graphics.pop()
end


function PassiveCard:on_mouse_enter()
  self.selected = true
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  self.info_text = InfoText{group = main.current.ui, force_update = true}
  self.info_text:activate({
    {text = self.passive_description, font = pixul_font, alignment = 'center', height_multiplier = 1.25},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + gh/4 + 12
end


function PassiveCard:on_mouse_exit()
  self.selected = false
  self.info_text:deactivate()
  self.info_text.dead = true
  self.info_text = nil
end


function PassiveCard:die()
  self.dead = true
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end




ItemCard = Object:extend()
ItemCard:implement(GameObject)
function ItemCard:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.w, self.h)
  self.interact_with_mouse = true
end


function ItemCard:update(dt)
  self:update_game_object(dt)
end


function ItemCard:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.x)
    if self.selected then
      graphics.rectangle(self.x, self.y, self.w, self.h, 6, 6, bg[-1])
    end
    _G[self.passive]:draw(self.x, self.y, 0, 0.8, 0.7, 0, 0, fg[0])
  graphics.pop()
end


function ItemCard:on_mouse_enter()
  self.selected = true
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  self.info_text = InfoText{group = main.current.ui, force_update = true}
  self.info_text:activate({
    {text = '[fg]' .. passive_names[self.passive], font = pixul_font, alignment = 'center', height_multiplier = 1.25},
    {text = passive_descriptions[self.passive], font = pixul_font, alignment = 'center', height_multiplier = 1.25},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
end


function ItemCard:on_mouse_exit()
  self.selected = false
  self.info_text:deactivate()
  self.info_text.dead = true
  self.info_text = nil
end


function ItemCard:die()
  self.dead = true
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end



ShopCard = Object:extend()
ShopCard:implement(GameObject)
function ShopCard:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.w, self.h)
  self.interact_with_mouse = true
  self.character_icon = CharacterIcon{group = main.current.effects, x = self.x, y = self.y - 26, character = self.unit, parent = self}
  self.class_icons = {}
  for i, class in ipairs(character_classes[self.unit]) do
    local x = self.x
    if #character_classes[self.unit] == 2 then x = self.x - 10
    elseif #character_classes[self.unit] == 3 then x = self.x - 20 end
    table.insert(self.class_icons, ClassIcon{group = main.current.effects, x = x + (i-1)*20, y = self.y + 6, class = class, character = self.unit, units = self.parent.units, parent = self})
  end
  self.cost = character_tiers[self.unit]
  self.spring:pull(0.2, 200, 10)
end


function ShopCard:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    if self.parent:buy(self.unit, self.i) then
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self:die()
      self.parent.cards[self.i] = nil
    else
      error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.spring:pull(0.2, 200, 10)
      self.character_icon.spring:pull(0.2, 200, 10)
      for _, ci in ipairs(self.class_icons) do ci.spring:pull(0.2, 200, 10) end
    end
  end
end


function ShopCard:select()
  self.selected = true
  self.spring:pull(0.2, 200, 10)
  self.t:every_immediate(1.4, function()
    if self.selected then
      self.t:tween(0.7, self, {sx = 0.97, sy = 0.97, plus_r = -math.pi/32}, math.linear, function()
        self.t:tween(0.7, self, {sx = 1.03, sy = 1.03, plus_r = math.pi/32}, math.linear, nil, 'pulse_1')
      end, 'pulse_2')
    end
  end, nil, nil, 'pulse')
end


function ShopCard:unselect()
  self.selected = false
  self.t:cancel'pulse'
  self.t:cancel'pulse_1'
  self.t:cancel'pulse_2'
  self.t:tween(0.1, self, {sx = 1, sy = 1, plus_r = 0}, math.linear, function() self.sx, self.sy, self.plus_r = 1, 1, 0 end, 'pulse')
end


function ShopCard:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    if self.selected then
      graphics.rectangle(self.x, self.y, self.w, self.h, 6, 6, bg[-1])
    end
  graphics.pop()
end


function ShopCard:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.spring:pull(0.1)
  self.character_icon.spring:pull(0.1, 200, 10)
  for _, class_icon in ipairs(self.class_icons) do
    class_icon.selected = true
    class_icon.spring:pull(0.1, 200, 10)
  end
end


function ShopCard:on_mouse_exit()
  self.selected = false
  for _, class_icon in ipairs(self.class_icons) do class_icon.selected = false end
end


function ShopCard:die(dont_spawn_effect)
  self.dead = true
  self.character_icon:die(dont_spawn_effect)
  for _, class_icon in ipairs(self.class_icons) do class_icon:die(dont_spawn_effect) end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end




CharacterIcon = Object:extend()
CharacterIcon:implement(GameObject)
function CharacterIcon:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 40, 20)
  self.interact_with_mouse = true
  self.character_text = Text({{text = '[' .. character_color_strings[self.character] .. ']' .. self.character, font = pixul_font, alignment = 'center'}}, global_text_tags)
end


function CharacterIcon:update(dt)
  self:update_game_object(dt)
  self.character_text:update(dt)
end


function CharacterIcon:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    graphics.rectangle(self.x, self.y - 7, 14, 14, 3, 3, character_colors[self.character])
    graphics.print_centered(self.parent.cost, pixul_font, self.x + 0.5, self.y - 5, 0, 1, 1, 0, 0, _G[character_color_strings[self.character]][-5])
    self.character_text:draw(self.x, self.y + 10)
  graphics.pop()
end


function CharacterIcon:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  self.info_text = InfoText{group = main.current.ui}
  self.info_text:activate({
    {text = '[' .. character_color_strings[self.character] .. ']' .. self.character:capitalize() .. '[fg] - cost: [yellow]' .. self.parent.cost, font = pixul_font, alignment = 'center', height_multiplier = 1.25},
    {text = '[fg]Classes: ' .. character_class_strings[self.character], font = pixul_font, alignment = 'center', height_multiplier = 1.25},
    {text = character_descriptions[self.character](1), font = pixul_font, alignment = 'center'},
    -- {text = character_stats[self.character](1), font = pixul_font, alignment = 'center'},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
end


function CharacterIcon:on_mouse_exit()
  self.info_text:deactivate()
  self.info_text.dead = true
  self.info_text = nil
end


function CharacterIcon:die(dont_spawn_effect)
  self.dead = true
  if not dont_spawn_effect then SpawnEffect{group = main.current.effects, x = self.x, y = self.y + 4, color = character_colors[self.character]} end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end




ClassIcon = Object:extend()
ClassIcon:implement(GameObject)
function ClassIcon:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y + 11, 20, 40)
  self.interact_with_mouse = true
  self.t:every(0.5, function() self.flash = not self.flash end)
  self.spring:pull(0.2, 200, 10)
end


function ClassIcon:update(dt)
  self:update_game_object(dt)
end


function ClassIcon:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    local i, j, n = class_set_numbers[self.class](self.units)
    local next_n
    if self.parent:is(ShopCard) then
      next_n = n+1
      if next_n > j then next_n = nil end
      if table.any(self.units, function(v) return v.character == self.character end) then next_n = nil end
    end

    graphics.rectangle(self.x, self.y, 16, 24, 4, 4, (n >= i) and class_colors[self.class] or bg[3])
    _G[self.class]:draw(self.x, self.y, 0, 0.3, 0.3, 0, 0, (n >= i) and _G[class_color_strings[self.class]][-5] or bg[10])
    graphics.rectangle(self.x, self.y + 26, 16, 16, 3, 3, bg[3])
    if i == 2 then
      graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, (n >= 1) and class_colors[self.class] or bg[10], 3)
      graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, (n >= 2) and class_colors[self.class] or bg[10], 3)
      graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, (n >= 3) and class_colors[self.class] or bg[10], 3)
      graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, (n >= 4) and class_colors[self.class] or bg[10], 3)
      if next_n then
        if next_n == 1 then
          graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 2 then
          graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 3 then
          graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 4 then
          graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        end
      end
    elseif i == 3 then
      graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, (n >= 1) and class_colors[self.class] or bg[10], 3)
      graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, (n >= 2) and class_colors[self.class] or bg[10], 3)
      graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, (n >= 3) and class_colors[self.class] or bg[10], 3)
      graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, (n >= 4) and class_colors[self.class] or bg[10], 3)
      graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, (n >= 5) and class_colors[self.class] or bg[10], 3)
      graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, (n >= 6) and class_colors[self.class] or bg[10], 3)
      --[[
      if next_n then
        if next_n == 1 then
          graphics.line(self.x - 4, self.y + 22, self.x - 4, self.y + 30, self.flash and class_colors[self.class] or bg[10], 2)
        elseif next_n == 2 then
          graphics.line(self.x, self.y + 22, self.x, self.y + 30, self.flash and class_colors[self.class] or bg[10], 2)
        elseif next_n == 3 then
          graphics.line(self.x + 4, self.y + 22, self.x + 4, self.y + 30, self.flash and class_colors[self.class] or bg[10], 2)
        end
      end
      ]]--
    end
  graphics.pop()
end


function ClassIcon:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  local i, j, owned = class_set_numbers[self.class](self.units)
  self.info_text = InfoText{group = main.current.ui}
  self.info_text:activate({
    {text = '[' .. class_color_strings[self.class] .. ']' .. self.class:capitalize() .. '[fg] - owned: [yellow]' .. owned, font = pixul_font, alignment = 'center', height_multiplier = 1.25},
    {text = class_descriptions[self.class]((owned >= j and 2) or (owned >= i and 1) or 0), font = pixul_font, alignment = 'center'},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
end


function ClassIcon:on_mouse_exit()
  self.info_text:deactivate()
  self.info_text.dead = true
  self.info_text = nil
end


function ClassIcon:die(dont_spawn_effect)
  self.dead = true
  local i, j, n = class_set_numbers[self.class](self.units)
  if not dont_spawn_effect then SpawnEffect{group = main.current.effects, x = self.x, y = self.y + 4, color = (n >= i) and class_colors[self.class] or bg[3]} end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end
