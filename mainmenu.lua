MainMenu = Object:extend()
MainMenu:implement(State)
MainMenu:implement(GameObject)
function MainMenu:init(name)
  self:init_state(name)
  self:init_game_object()
end


function MainMenu:on_enter(from)
  slow_amount = 1
  trigger:tween(2, main_song_instance, {volume = 0.5, pitch = 1}, math.linear)

  steam.friends.setRichPresence('steam_display', '#StatusFull')
  steam.friends.setRichPresence('text', 'Main Menu')

  self.floor = Group()
  self.main = Group():set_as_physics_world(32, 0, 0, {'player', 'enemy', 'projectile', 'enemy_projectile', 'force_field', 'ghost'})
  self.post_main = Group()
  self.effects = Group()
  self.main_ui = Group():no_camera()
  self.ui = Group():no_camera()
  self.main:disable_collision_between('player', 'player')
  self.main:disable_collision_between('player', 'projectile')
  self.main:disable_collision_between('player', 'enemy_projectile')
  self.main:disable_collision_between('projectile', 'projectile')
  self.main:disable_collision_between('projectile', 'enemy_projectile')
  self.main:disable_collision_between('projectile', 'enemy')
  self.main:disable_collision_between('enemy_projectile', 'enemy')
  self.main:disable_collision_between('enemy_projectile', 'enemy_projectile')
  self.main:disable_collision_between('player', 'force_field')
  self.main:disable_collision_between('projectile', 'force_field')
  self.main:disable_collision_between('ghost', 'player')
  self.main:disable_collision_between('ghost', 'projectile')
  self.main:disable_collision_between('ghost', 'enemy')
  self.main:disable_collision_between('ghost', 'enemy_projectile')
  self.main:disable_collision_between('ghost', 'ghost')
  self.main:disable_collision_between('ghost', 'force_field')
  self.main:enable_trigger_between('projectile', 'enemy')
  self.main:enable_trigger_between('enemy_projectile', 'player')
  self.main:enable_trigger_between('player', 'enemy_projectile')
  self.main:enable_trigger_between('enemy_projectile', 'enemy')
  self.main:enable_trigger_between('player', 'ghost')

  self.enemies = {Seeker, EnemyCritter}

  -- Spawn solids and player
  self.x1, self.y1 = gw/2 - 0.8*gw/2, gh/2 - 0.8*gh/2
  self.x2, self.y2 = gw/2 + 0.8*gw/2, gh/2 + 0.8*gh/2
  self.w, self.h = self.x2 - self.x1, self.y2 - self.y1
  Wall{group = self.main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}

  self.t:every(0.375, function()
    local p = random:table(star_positions)
    Star{group = star_group, x = p.x, y = p.y}
  end)

  self.units = {
    {character = 'psykino', level = 1},
    {character = 'magician', level = 1},
    {character = 'bane', level = 1},
    {character = 'scout', level = 1},
    {character = 'cannoneer', level = 1},
    {character = 'swordsman', level = 1},
    {character = 'archer', level = 1},
  }

  for i, unit in ipairs(self.units) do
    if i == 1 then
      self.player = Player{group = self.main, x = gw/2 + random:float(-48, 48), y = gh/2 + 16 + random:float(-48, 48), leader = true, character = unit.character, level = unit.level, passives = self.passives, ii = i}
    else
      self.player:add_follower(Player{group = self.main, character = unit.character, level = unit.level, passives = self.passives, ii = i})
    end
  end

  self.title_text = Text({{text = '[wavy_mid, fg]SNKRX', font = fat_font, alignment = 'center'}}, global_text_tags)

  self.arena_run_button = Button{group = self.main_ui, x = 55, y = gh/2 - 10, force_update = true, button_text = 'arena run', fg_color = 'bg10', bg_color = 'bg', action = function(b)
    self:start_run(false)
  end}
  self.daily_run_button = Button{group = self.main_ui, x = 52, y = gh/2 + 12, force_update = true, button_text = 'daily run', fg_color = 'bg10', bg_color = 'bg', action = function(b)
    self:start_run(true)
  end}

  local start_modes = {'standard', 'draft', 'class pick', 'random'}
  self.start_mode_button = Button{group = self.main_ui, x = 160, y = gh/2 - 10, w = 110, force_update = true, button_text = 'start: ' .. (state.start_mode or 'standard'), fg_color = 'bg10', bg_color = 'bg', action = function(b)
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    local i = table.index(start_modes, state.start_mode or 'standard') or 1
    state.start_mode = start_modes[i % #start_modes + 1]
    b:set_text('start: ' .. state.start_mode)
    system.save_state()
  end}
  self.challenge_button = Button{group = self.main_ui, x = 160, y = gh/2 + 12, w = 110, force_update = true, button_text = 'challenge: ' .. (state.challenge_mode and 'yes' or 'no'), fg_color = 'bg10', bg_color = 'bg', action = function(b)
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    state.challenge_mode = not state.challenge_mode
    b:set_text('challenge: ' .. (state.challenge_mode and 'yes' or 'no'))
    system.save_state()
  end}
  self.self_collision_button = Button{group = self.main_ui, x = 160, y = gh/2 + 56, w = 110, force_update = true, button_text = 'self collision: ' .. (state.self_collision and 'yes' or 'no'), fg_color = 'bg10', bg_color = 'bg', action = function(b)
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    state.self_collision = not state.self_collision
    b:set_text('self collision: ' .. (state.self_collision and 'yes' or 'no'))
    system.save_state()
  end}
  self.history_button = Button{group = self.main_ui, x = 160, y = gh/2 + 34, w = 110, force_update = true, button_text = 'run history', fg_color = 'bg10', bg_color = 'bg', action = function(b)
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self:toggle_history()
  end}
  self.options_button = Button{group = self.main_ui, x = 47, y = gh/2 + 34, force_update = true, button_text = 'options', fg_color = 'bg10', bg_color = 'bg', action = function(b)
    if not self.paused then
      open_options(self)
    else
      close_options(self)
    end
  end}
  self.quit_button = Button{group = self.main_ui, x = 37, y = gh/2 + 56, force_update = true, button_text = 'quit', fg_color = 'bg10', bg_color = 'bg', action = function(b)
    system.save_state()
    steam.shutdown()
    love.event.quit()
  end}
  self.t:every(2, function() self.soundtrack_button.spring:pull(0.025, 200, 10) end)
  self.soundtrack_button = Button{group = self.main_ui, x = gw - 72, y = gh - 40, force_update = true, button_text = 'buy the soundtrack!', fg_color = 'bg10', bg_color = 'bg', action = function(b)
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    b.spring:pull(0.2, 200, 10)
    b.selected = true
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    system.open_url('https://kubbimusic.com/album/ember')
  end}
  self.discord_button = Button{group = self.main_ui, x = gw - 92, y = gh - 17, force_update = true, button_text = 'join the community discord!', fg_color = 'bg10', bg_color = 'bg', action = function(b)
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    b.spring:pull(0.2, 200, 10)
    b.selected = true
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    system.open_url('https://discord.gg/4d6GWmChKY')
  end}
end



function MainMenu:show_message(text)
  if self.message_text then self.message_text.dead = true end
  self.message_text = Text2{group = self.main_ui, x = gw/2 + 60, y = gh/2 + 80, force_update = true, lines = {{text = '[fg]' .. text, font = pixul_font, alignment = 'center'}}}
  local message_text = self.message_text
  self.t:after(2.5, function() message_text.dead = true end)
end


-- Starts or continues a run. New runs pick up the start/challenge settings; draft and class pick first open a chooser.
function MainMenu:start_run(daily)
  if self.transitioning then return end
  local run = system.load_run()
  if daily then
    if run.level then return self:show_message('finish or restart your current run first') end
    run_modes = {start = 'standard', daily = os.date('%Y%m%d')}
  elseif run.level then
    run_modes = run.modes or {}
  else
    run_modes = {start = state.start_mode or 'standard', challenge = state.challenge_mode or nil}
  end

  if not run.level and (run_modes.start == 'draft' or run_modes.start == 'class pick') then return self:open_start_chooser(run) end
  local starting_units = {}
  if not run.level and run_modes.start == 'random' then starting_units = {{character = random:table(self:get_starting_unit_pool()), level = 1}} end
  self:begin_run(run, starting_units)
end


-- Tier 1 and 2 units that attack, optionally filtered to one class
function MainMenu:get_starting_unit_pool(class)
  local pool = {}
  for _, tier in ipairs({1, 2}) do
    for _, character in ipairs(tier_to_characters[tier]) do
      local attacks = not table.any(non_attacking_characters, function(v) return v == character end)
      local has_class = not class or table.any(character_classes[character], function(v) return v == class end)
      if attacks and has_class then table.insert(pool, character) end
    end
  end
  return pool
end


function MainMenu:open_start_chooser(run)
  if self.chooser then return end
  self.chooser = {}
  local options, title = {}, ''
  if run_modes.start == 'draft' then
    title = 'draft your first unit'
    local pool = table.shuffle(self:get_starting_unit_pool())
    for i = 1, 3 do table.insert(options, {text = pool[i], character = pool[i]}) end
  else
    title = 'pick a starting class'
    local classes = {}
    for class, _ in pairs(class_colors) do
      if class ~= 'explorer' and #self:get_starting_unit_pool(class) > 0 then table.insert(classes, class) end
    end
    table.sort(classes)
    classes = table.shuffle(classes)
    for i = 1, 4 do table.insert(options, {text = (classes[i] == 'conjurer' and 'builder' or classes[i]), class = classes[i]}) end
  end

  table.insert(self.chooser, Text2{group = self.main_ui, x = gw/2 + 100, y = gh/2 - 50, force_update = true, lines = {{text = '[wavy_mid, fg]' .. title, font = pixul_font, alignment = 'center'}}})
  for i, option in ipairs(options) do
    table.insert(self.chooser, Button{group = self.main_ui, x = gw/2 + 100, y = gh/2 - 28 + (i-1)*22, force_update = true, button_text = option.text, fg_color = 'bg10', bg_color = 'bg', action = function(b)
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      local character = option.character or random:table(self:get_starting_unit_pool(option.class))
      for _, object in ipairs(self.chooser) do object.dead = true end
      self.chooser = nil
      self:begin_run(run, {{character = character, level = 1}})
    end})
  end
end


function MainMenu:begin_run(run, starting_units)
  ui_transition2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.transitioning = true
  TransitionEffect{group = main.transitions, x = gw/2, y = gh/2, color = state.dark_transitions and bg[-2] or fg[0], transition_action = function()
    slow_amount = 1
    run_passive_pool = run.run_passive_pool or new_run_passive_pool()
    run_time = run.time or 0
    gold = run.gold or 3
    passives = run.passives or {}
    locked_state = run.locked_state
    current_new_game_plus = run.current_new_game_plus or current_new_game_plus or 0
    system.save_state()
    main:add(BuyScreen'buy_screen')
    main:go_to('buy_screen', run.level or 1, run.loop or 0, run.units or starting_units or {}, passives, run.shop_level or 1, run.shop_xp or 0)
  end, text = Text({{text = '[wavy, ' .. tostring(state.dark_transitions and 'fg' or 'bg') .. ']starting...', font = pixul_font, alignment = 'center'}}, global_text_tags)}
end


function MainMenu:toggle_history()
  if self.history_texts then
    for _, text in ipairs(self.history_texts) do text.dead = true end
    self.history_texts = nil
    return
  end
  self.history_texts = {}
  local lines = {'[wavy_mid, fg]last runs'}
  for _, r in ipairs(state.run_history or {}) do
    local tags = (r.challenge and ' [yellow]chal.' or '') .. (r.daily and ' [blue]daily' or '')
    table.insert(lines, string.format('[fg]%s  [%s]%s lv.%d[fg]  NG+%d  %s%s', r.date:sub(6), r.won and 'green' or 'red', r.won and 'won' or 'died', r.level, r.ng, format_run_time(r.time), tags))
  end
  if #lines == 1 then table.insert(lines, '[fg]no finished runs yet') end
  for i, line in ipairs(lines) do
    table.insert(self.history_texts, Text2{group = self.main_ui, x = gw/2 + 112, y = gh/2 - 60 + (i-1)*13, force_update = true, lines = {{text = line, font = pixul_font, alignment = 'center'}}})
  end
end


function MainMenu:on_exit()
  self.floor:destroy()
  self.main:destroy()
  self.post_main:destroy()
  self.effects:destroy()
  self.ui:destroy()
  self.main_ui:destroy()
  self.t:destroy()
  self.floor = nil
  self.main = nil
  self.post_main = nil
  self.effects = nil
  self.ui = nil
  self.units = nil
  self.player = nil
  self.t = nil
  self.springs = nil
  self.flashes = nil
  self.hfx = nil
  self.title_text = nil
end


function MainMenu:update(dt)
  if main_song_instance:isStopped() then
    main_song_instance = _G[random:table{'song1', 'song2', 'song3', 'song4', 'song5'}]:play{volume = 0.5}
  end

  if input.escape.pressed then
    if not self.paused then
      open_options(self)
    else
      close_options(self)
    end
  end

  self:update_game_object(dt*slow_amount)

  if not self.paused and not self.transitioning then
    star_group:update(dt*slow_amount)
    self.floor:update(dt*slow_amount)
    self.main:update(dt*slow_amount)
    self.post_main:update(dt*slow_amount)
    self.effects:update(dt*slow_amount)
    self.main_ui:update(dt*slow_amount)
    if self.title_text then self.title_text:update(dt) end
    self.ui:update(dt*slow_amount)
  else
    self.ui:update(dt*slow_amount)
  end
end


function MainMenu:draw()
  self.floor:draw()
  self.main:draw()
  self.post_main:draw()
  self.effects:draw()
  graphics.draw_with_mask(function()
    star_canvas:draw(0, 0, 0, 1, 1)
  end, function()
    camera:attach()
    graphics.rectangle(gw/2, gh/2, self.w, self.h, nil, nil, fg[0])
    camera:detach()
  end, true)
  graphics.rectangle(gw/2, gh/2, 2*gw, 2*gh, nil, nil, modal_transparent)

  self.main_ui:draw()
  self.title_text:draw(60, gh/2 - 40)
  local best = state.best_runs and state.best_runs[current_new_game_plus]
  if best and best.level then
    local text = 'best (NG+' .. current_new_game_plus .. '): level ' .. best.level .. (best.win_time and (', win ' .. format_run_time(best.win_time)) or '')
    graphics.print(text, pixul_font, 22, gh/2 + 72, 0, 1, 1, 0, 0, bg[10])
  end
  if state.daily_best and state.daily_best.date == os.date('%Y%m%d') then
    graphics.print("today's daily: level " .. state.daily_best.level, pixul_font, 22, gh/2 + 85, 0, 1, 1, 0, 0, bg[10])
  end
  if self.paused then graphics.rectangle(gw/2, gh/2, 2*gw, 2*gh, nil, nil, modal_transparent) end
  self.ui:draw()
end
