-- Shared functions and classes for projects using JUGGLRX's visual style.
function shared_init()
  local colors = {
    white = ColorRamp(Color(1, 1, 1, 1), 0.025),
    black = ColorRamp(Color(0, 0, 0, 1), 0.025),
    bg = ColorRamp(Color'#303030', 0.025),
    fg = ColorRamp(Color'#dadada', 0.025),
    fg_alt = ColorRamp(Color'#b0a89f', 0.025),
    yellow = ColorRamp(Color'#facf00', 0.025),
    orange = ColorRamp(Color'#f07021', 0.025),
    blue = ColorRamp(Color'#019bd6', 0.025),
    green = ColorRamp(Color'#8bbf40', 0.025),
    red = ColorRamp(Color'#e91d39', 0.025),
    purple = ColorRamp(Color'#8e559e', 0.025),
    blue2 = ColorRamp(Color'#4778ba', 0.025),
    yellow2 = ColorRamp(Color'#f59f10', 0.025),
  }
  for name, color in pairs(colors) do
    _G[name] = color
    _G[name .. '_transparent'] = Color(color[0].r, color[0].g, color[0].b, 0.5)
    _G[name .. '_transparent_weak'] = Color(color[0].r, color[0].g, color[0].b, 0.25)
  end
  modal_transparent = Color(0.1, 0.1, 0.1, 0.6)
  modal_transparent_2 = Color(0.1, 0.1, 0.1, 0.9)

  bg_off = Color(46, 46, 46)
  bg_gradient = GradientImage('vertical', Color(128, 128, 128, 0), Color(0, 0, 0, 0.3))

  graphics.set_background_color(bg[0])
  graphics.set_color(fg[0])
  slow_amount = 1
  music_slow_amount = 1

  sfx = SoundTag()
  sfx.volume = state.sfx_volume or 0.5
  music = SoundTag()
  music.volume = state.music_volume or 0.5

  if state.volume_muted then sfx.volume = 0 end
  if state.music_muted then music.volume = 0 end

  fat_font = Font('FatPixelFont', 8)
  pixul_font = Font('PixulBrush', 8)
  background_canvas = Canvas(gw, gh)
  main_canvas = Canvas(gw, gh, {stencil = true})
  shadow_canvas = Canvas(gw, gh)
  shadow_shader = Shader(nil, 'shadow.frag')
  star_canvas = Canvas(gw, gh, {stencil = true})
  star_group = Group()
  star_positions = {}
  for i = -30, gh + 30, 15 do table.insert(star_positions, {x = -40, y = i}) end
  for i = -30, gw, 15 do table.insert(star_positions, {x = i, y = gh + 40}) end
end


function shared_draw(draw_action)
  star_canvas:draw_to(function()
    star_group:draw()
  end)

  background_canvas:draw_to(function()
    camera:attach()
    for i = 1, 32 do
      for j = 1, 18 do
        if j % 2 == 0 then
          if i % 2 == 1 then
            graphics.rectangle2(0 + (i-1)*22, 0 + (j-1)*22, 22, 22, nil, nil, bg_off)
          end
        else
          if i % 2 == 0 then
            graphics.rectangle2(0 + (i-1)*22, 0 + (j-1)*22, 22, 22, nil, nil, bg_off)
          end
        end
      end
    end
    bg_gradient:draw(gw/2, gh/2, 480, 270)
    camera:detach()
  end)

  main_canvas:draw_to(function()
    draw_action()
    if flashing then graphics.rectangle(gw/2, gh/2, gw, gh, nil, nil, flash_color) end
  end)

  shadow_canvas:draw_to(function()
    graphics.set_color(white[0])
    shadow_shader:set()
    main_canvas:draw2(0, 0, 0, 1, 1)
    shadow_shader:unset()
  end)

  local x, y = 0, 0
  background_canvas:draw(x, y, 0, sx, sy)
  shadow_canvas:draw(x + 1.5*sx, y + 1.5*sy, 0, sx, sy)
  main_canvas:draw(x, y, 0, sx, sy)
end




Star = Object:extend()
Star:implement(GameObject)
Star:implement(Physics)
function Star:init(args)
  self:init_game_object(args)
  self.sx, self.sy = 0.35, 0.35
  self.vr = 0
  self.dvr = random:float(0, math.pi/4)
  self.v = random:float(30, 42)
end


function Star:update(dt)
  self:update_game_object(dt)
  self.x = self.x + self.v*math.cos(-math.pi/4)*dt
  self.y = self.y + self.v*math.sin(-math.pi/4)*dt
  self.vr = self.vr + self.dvr*dt
  if self.x > gw + 64 then self.dead = true end
end


function Star:draw()
  star:draw(self.x, self.y, self.vr, self.sx, self.sy, 0, 0, bg[1])
end




SpawnEffect = Object:extend()
SpawnEffect:implement(GameObject)
function SpawnEffect:init(args)
  self:init_game_object(args)
  self.target_color = self.color or red[0]
  self.color = fg[0]
  self.rs = 0
  self.t:tween(0.1, self, {rs = 6}, math.cubic_in_out, function()
    if self.action then self.action(self.x, self.y) end
    self.spring:pull(1)
    for i = 1, random:int(6, 8) do HitParticle{group = main.current.effects, self.x, self.y, color = self.target_color, duration = random:float(0.3, 0.5), w = random:float(5, 8), v = random:float(150, 200)} end
    self.t:tween(0.25, self, {rs = 0}, math.linear, function() self.dead = true end)
    self.t:after(0.15, function() self.color = self.target_color end)
  end)
end


function SpawnEffect:update(dt)
  self:update_game_object(dt)
end


function SpawnEffect:draw()
  graphics.circle(self.x, self.y, random:float(0.9, 1.1)*self.rs*self.spring.x, self.color)
end



-- Mixin to be added to a state so it can have nodemap creation, saving and manipulating capabilities.
Nodemap = Object:extend()
-- nodemap is a table that contains the definition of the skill tree or overmap.
-- Each node in it should have the following attributes defined:
-- .x, .y, .neighbors or .links. Optionally: .rs, .color, .visited, .can_be_visited, .on_visit, .on_draw, .data
-- An example would look like this:
-- nodemap = {
--  [1] = {x = x, y = y, visited = true, links = {2, 3, 4, 5}}
--  [2] = {x = x, y = y - 64, links = {1}}
--  [3] = {x = x + 64, y = y, links = {1}}
--  [4] = {x = x, y = y + 64, links = {1}}
--  [5] = {x = x - 64, y = y, links = {1}}
-- }
-- .data can be a table that contains other attributes. These will be automatically added to the Node object when it's created.
-- .on_visit should be defined if you want the button to do something when it's clicked. Example:
--  [2] = {x = x, y = y - 64, links = {1}, on_visit = function(visited_node) state.goto'level_2' end}
-- .on_draw should be used when you want to draw the node in some specific way rather than the default one.
-- color_mode can be nil or 'skill_tree', if it's the latter then nodes and edges will change colors according to if they were a part of a skill tree:
-- Unvisitable nodes are gray, visitable nodes are white, visited nodes are their default color
-- This is opposed to the default color mode, where all nodes and edges have their their default colors, and when they're visited they turn gray instead.
function Nodemap:generate_nodemap(group, nodemap, color_mode)
  for id, node in pairs(nodemap) do
    Node{group = group, x = node.x, y = node.y, node_id = id, neighbors = node.links, rs = node.rs, visited = node.visited, can_be_visited = node.can_be_visited, color = node.color, label = node.label, data = node.data,
    on_visit = node.on_visit, on_draw = node.on_draw, color_mode = color_mode}
  end

  for id, node in pairs(nodemap) do
    for _, node_id in ipairs(node.links) do
      if nodemap[node_id] then
        Edge{group = group, x = 0, y = 0, node1_id = id, node2_id = node_id, color_mode = color_mode}
      end
    end
  end
end


Node = Object:extend()
Node:implement(GameObject)
function Node:init(args)
  self:init_game_object(args)
  for k, v in pairs(self.data) do self[k] = v end
  self.data = nil
  self.rs = self.rs or 6
  self.shape = Circle(self.x, self.y, 1.5*self.rs)
  self.interact_with_mouse = true

  self.src_color = self.color
  if self.color_mode == 'skill_tree' then
    self.color = bg[5]
    if self.visited then self.color = fg[0] end
  end

  self.t:every_immediate(1.4, function()
    if self.can_be_visited then
      self.t:tween(0.7, self, {sx = 0.9, sy = 0.9}, math.linear, function()
        self.t:tween(0.7, self, {sx = 1.1, sy = 1.1}, math.linear, nil, 'visit_pulse_1')
      end, 'visit_pulse_2')
    end
  end, nil, nil, 'visit_pulse')

  if self.label then self.label_r = 0 end
  self.t:after(0.01, function()
    if self.label then
      local xs, ys = 0, 0
      for _, neighbor_id in ipairs(self.neighbors) do
        local neighbor = self.group:get_object_by_property('node_id', neighbor_id)
        local r = math.angle(self.x, self.y, neighbor.x, neighbor.y)
        x, y = math.cos(r), math.sin(r)
        xs = xs + x
        ys = ys + y
      end
      self.label_r = Vector(-xs, -ys):angle()
      self.label_color = self.color
    end

    self.edges = {}
    for _, neighbor_id in ipairs(self.neighbors) do
      local edge = nil
      edge = self.group:get_object_by_properties({'node1_id', 'node2_id'}, {self.node_id, neighbor_id})
      if not edge then edge = self.group:get_object_by_properties({'node1_id', 'node2_id'}, {neighbor_id, self.node_id}) end
      if edge then table.insert(self.edges, edge) end
    end
  end)
end


function Node:update(dt)
  self:update_game_object(dt)

  if not self.visited then
    for _, neighbor_id in ipairs(self.neighbors) do
      local neighbor = self.group:get_object_by_property('node_id', neighbor_id)
      if neighbor and neighbor.visited then
        self.can_be_visited = true
      end
    end
  end

  if self.color_mode == 'skill_tree' then
    if self.can_be_visited then
      self.color = bg[10]
      if self.label then self.label_color = bg[10] end
      if self.hot then
        self.color = fg[0]
        if self.label then self.label_color = fg[0] end
      end
    end
  end

  if self.hot and self.can_be_visited and not self.visited and input.m1.pressed then
    self.t:cancel'visit_pulse'
    self.t:cancel'visit_pulse_1'
    self.t:cancel'visit_pulse_2'
    self.sx, self.sy = 1, 1
    self.spring:pull(0.25)
    self.can_be_visited = false
    self.visited = true
    self.hot = false
    if self.color_mode == 'skill_tree' then
      self.color = self.src_color
      if self.label then self.label_color = self.src_color end
    else
      self.color = bg[5]
      if self.label then self.label_color = bg[5] end
    end
    if self.label then self.label_color = self.color end
    if self.on_visit then self:on_visit() end
  end
end


function Node:draw()
  if self.on_draw then
    self:on_draw()
  else
    graphics.push(self.x, self.y, 0, self.spring.x*self.sx, self.spring.x*self.sy)
    if self.hot and self.can_be_visited then graphics.circle(self.x, self.y, 1.15*self.shape.rs, self.color)
    else graphics.circle(self.x, self.y, self.shape.rs, self.color, 3) end
    graphics.pop()
  end

  if self.label then
    local w = pixul_font:get_text_width(self.label)
    local s = math.remap(self.rs, 6, 12, 3.5, 2.5)
    graphics.print_centered(self.label, pixul_font, self.x + (w/6)*math.cos(self.label_r) + s*self.rs*math.cos(self.label_r), self.y + s*self.rs*math.sin(self.label_r), 0, self.spring.x*self.sx, self.spring.x*self.sy, nil, nil, self.label_color)
  end
end


function Node:on_mouse_enter()
  self.hot = true
  self.spring:pull(0.2, 200, 10)
  for _, edge in ipairs(self.edges) do edge.spring:pull(0.15, 200, 10) end
end


function Node:on_mouse_exit()
  self.hot = false
  self.spring:pull(0.05, 200, 10)
  for _, edge in ipairs(self.edges) do edge.spring:pull(0.05, 200, 10) end
end




Edge = Object:extend()
Edge:implement(GameObject)
function Edge:init(args)
  self:init_game_object(args)
  self.node1 = self.group:get_object_by_property('node_id', self.node1_id)
  self.node2 = self.group:get_object_by_property('node_id', self.node2_id)
  local r = math.angle(self.node1.x, self.node1.y, self.node2.x, self.node2.y)
  self.x1, self.y1 = self.node1.x + 2.75*self.node1.rs*math.cos(r), self.node1.y + 2.75*self.node1.rs*math.sin(r)
  self.x2, self.y2 = self.node2.x + 2.75*self.node2.rs*math.cos(r - math.pi), self.node2.y + 2.75*self.node2.rs*math.sin(r - math.pi)

  if self.color_mode == 'skill_tree' then self.color = bg[5]
  else self.color = fg[0] end
end


function Edge:update(dt)
  self:update_game_object(dt)

  if self.color_mode == 'skill' then
    self.color = bg[5]
    if (self.node1.visited and self.node2.can_be_visited) or (self.node2.visited and self.node1.can_be_visited) then self.color = bg[10] end
    if (self.node1.visited and self.node2.visited) or (self.node1.visited and self.node2.hot) or (self.node2.visited and self.node1.hot) then self.color = fg[0] end
  else
    if self.node1.visited and self.node2.visited then self.color = bg[5] end
  end

  --[[
  self.color = bg[5]
  if (self.node1.visited and self.node2.can_be_visited) or (self.node2.visited and self.node1.can_be_visited) then self.color = bg[10] end
  if (self.node1.visited and self.node2.visited) or (self.node1.visited and self.node2.hot) or (self.node2.visited and self.node1.hot) then self.color = fg[0] end
  ]]--
end


function Edge:draw()
  graphics.push((self.x1+self.x2)/2, (self.y1+self.y2)/2, 0, self.spring.x, self.spring.x)
  graphics.line(self.x1, self.y1, self.x2, self.y2, self.color, 4)
  graphics.circle(self.x1, self.y1, 2, self.color)
  graphics.circle(self.x2, self.y2, 2, self.color)
  graphics.pop()
end




SpawnEffect = Object:extend()
SpawnEffect:implement(GameObject)
function SpawnEffect:init(args)
  self:init_game_object(args)
  self.target_color = self.color or red[0]
  self.color = fg[0]
  self.rs = 0
  self.t:tween(0.1, self, {rs = 6}, math.cubic_in_out, function()
    if self.action then self.action(self.x, self.y) end
    self.spring:pull(1)
    for i = 1, random:int(6, 8) do HitParticle{group = main.current.effects, x = self.x, y = self.y, color = self.target_color, duration = random:float(0.3, 0.5), w = random:float(5, 8), v = random:float(150, 200)} end
    self.t:tween(0.25, self, {rs = 0}, math.linear, function() self.dead = true end)
    self.t:after(0.15, function() self.color = self.target_color end)
  end)
end


function SpawnEffect:update(dt)
  self:update_game_object(dt)
end


function SpawnEffect:draw()
  graphics.circle(self.x, self.y, random:float(0.9, 1.1)*self.rs*self.spring.x, self.color)
end




HoverCrosshair = Object:extend()
HoverCrosshair:implement(GameObject)
function HoverCrosshair:init(args)
  self:init_game_object(args)
  self.ox, self.oy = 0, 0
  self.sx, self.sy = 0, 0
  self.line_width = 2
  self.w, self.h = 10, 10
end


function HoverCrosshair:update(dt)
  self:update_game_object(dt)
  if self.animation then self.animation:update(dt) end
end


function HoverCrosshair:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
  graphics.polyline(fg[0], self.line_width, self.x - self.ox, self.y - self.oy + 0.4*self.h, self.x - self.ox, self.y - self.oy, self.x - self.ox + 0.4*self.w, self.y - self.oy)
  graphics.polyline(fg[0], self.line_width, self.x - self.ox, self.y + self.oy - 0.4*self.h, self.x - self.ox, self.y + self.oy, self.x - self.ox + 0.4*self.w, self.y + self.oy)
  graphics.polyline(fg[0], self.line_width, self.x + self.ox - 0.4*self.w, self.y - self.oy, self.x + self.ox, self.y - self.oy, self.x + self.ox, self.y - self.oy + 0.4*self.h)
  graphics.polyline(fg[0], self.line_width, self.x + self.ox - 0.4*self.w, self.y + self.oy, self.x + self.ox, self.y + self.oy, self.x + self.ox, self.y + self.oy - 0.4*self.h)
  graphics.pop()
end


function HoverCrosshair:activate(x, y, w, h, line_width)
  w, h = 10, 10
  line_width = 2
  self.x, self.y = camera:get_local_coords(x, y)
  self.t:cancel'deactivate'
  self.t:tween(0.1, self, {sx = 1, sy = 1}, math.cubic_in_out, function() self.sx, self.sy = 1, 1 end, 'activate')
  if self.w <= 10 and self.h <= 10 then
    self.animation = AnimationLogic(0.075, 3, 'bounce', {
      function() self.ox, self.oy = 0.6*self.w, 0.6*self.h end,
      function() self.ox, self.oy = 0.8*self.w, 0.8*self.h end,
      function() self.ox, self.oy = self.w, self.h end,
    })
  else
    self.animation = AnimationLogic(0.075, 3, 'bounce', {
      function() self.ox, self.oy = 0.8*self.w, 0.8*self.h end,
      function() self.ox, self.oy = 0.9*self.w, 0.9*self.h end,
      function() self.ox, self.oy = self.w, self.h end,
    })
  end
end


function HoverCrosshair:deactivate()
  self.t:cancel'activate'
  self.t:tween(0.05, self, {sx = 0, sy = 0}, math.linear, function() self.sx, self.sy = 0, 0 end, 'deactivate')
end




TransitionEffect = Object:extend()
TransitionEffect:implement(GameObject)
function TransitionEffect:init(args)
  self:init_game_object(args)
  self.rs = 0
  self.text_sx, self.text_sy = 0, 0
  self.t:after(0.25, function()
    self.t:after(0.1, function()
      self.t:tween(0.1, self, {text_sx = 1, text_sy = 1}, math.cubic_in_out)
    end)
    self.t:tween(0.6, self, {rs = 1.2*gw}, math.linear, function()
      if self.transition_action then self:transition_action(unpack(self.transition_action_args or {})) end
      self.t:after(0.3, function()
        self.x, self.y = gw/2, gh/2
        self.t:after(0.6, function() self.t:tween(0.05, self, {text_sx = 0, text_sy = 0}, math.cubic_in_out) end)
        if not args.dont_tween_out then
          self.t:tween(0.6, self, {rs = 0}, math.linear, function() self.text = nil; self.dead = true end)
        else
          self.t:after(0.6, function() self.text = nil; self.dead = true end)
        end
      end)
    end)
  end)
end


function TransitionEffect:update(dt)
  self:update_game_object(dt)
  if self.text then self.text:update(dt) end
end


function TransitionEffect:draw()
  graphics.push(self.x, self.y, 0, self.sx, self.sy)
  graphics.circle(self.x, self.y, self.rs, self.color)
  graphics.pop()
  if self.text then self.text:draw(gw/2, gh/2, 0, self.text_sx, self.text_sy) end
end




local invisible = Color(1, 1, 1, 0)
global_text_tags = {
  red = TextTag{draw = function(c, i, text) graphics.set_color(red[0]) end},
  orange = TextTag{draw = function(c, i, text) graphics.set_color(orange[0]) end},
  yellow = TextTag{draw = function(c, i, text) graphics.set_color(yellow[0]) end},
  yellow2 = TextTag{draw = function(c, i, text) graphics.set_color(yellow2[0]) end},
  green = TextTag{draw = function(c, i, text) graphics.set_color(green[0]) end},
  purple = TextTag{draw = function(c, i, text) graphics.set_color(purple[0]) end},
  blue = TextTag{draw = function(c, i, text) graphics.set_color(blue[0]) end},
  blue2 = TextTag{draw = function(c, i, text) graphics.set_color(blue2[0]) end},
  bg = TextTag{draw = function(c, i, text) graphics.set_color(bg[0]) end},
  bg3 = TextTag{draw = function(c, i, text) graphics.set_color(bg[3]) end},
  bg10 = TextTag{draw = function(c, i, text) graphics.set_color(bg[10]) end},
  bgm2 = TextTag{draw = function(c, i, text) graphics.set_color(bg[-2]) end},
  light_bg = TextTag{draw = function(c, i, text) graphics.set_color(bg[5]) end},
  fg = TextTag{draw = function(c, i, text) graphics.set_color(fg[0]) end},
  fgm1 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-1]) end},
  fgm2 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-2]) end},
  fgm3 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-3]) end},
  fgm4 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-4]) end},
  fgm5 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-5]) end},
  fgm6 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-6]) end},
  fgm7 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-7]) end},
  fgm8 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-8]) end},
  fgm9 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-9]) end},
  fgm10 = TextTag{draw = function(c, i, text) graphics.set_color(fg[-10]) end},
  greenm5 = TextTag{draw = function(c, i, text) graphics.set_color(green[-5]) end},
  green5 = TextTag{draw = function(c, i, text) graphics.set_color(green[5]) end},
  blue5 = TextTag{draw = function(c, i, text) graphics.set_color(blue[5]) end},
  bluem5 = TextTag{draw = function(c, i, text) graphics.set_color(blue[-5]) end},
  blue25 = TextTag{draw = function(c, i, text) graphics.set_color(blue2[5]) end},
  blue2m5 = TextTag{draw = function(c, i, text) graphics.set_color(blue2[-5]) end},
  yellow25 = TextTag{draw = function(c, i, text) graphics.set_color(yellow2[5]) end},
  yellow2m5 = TextTag{draw = function(c, i, text) graphics.set_color(yellow2[-5]) end},
  redm5 = TextTag{draw = function(c, i, text) graphics.set_color(red[-5]) end},
  orangem5 = TextTag{draw = function(c, i, text) graphics.set_color(orange[-5]) end},
  purplem5 = TextTag{draw = function(c, i, text) graphics.set_color(purple[-5]) end},
  yellowm5 = TextTag{draw = function(c, i, text) graphics.set_color(yellow[-5]) end},
  wavy = TextTag{update = function(c, dt, i, text) c.oy = 2*math.sin(4*time + i) end},
  wavy_mid = TextTag{update = function(c, dt, i, text) c.oy = 0.75*math.sin(3*time + i) end},
  wavy_mid2 = TextTag{update = function(c, dt, i, text) c.oy = 0.5*math.sin(3*time + i) end},
  wavy_lower = TextTag{update = function(c, dt, i, text) c.oy = 0.25*math.sin(2*time + i) end},

  steam_link = TextTag{
    init = function(c, i, text)
      c.color = blue[0]
    end,

    draw = function(c, i, text)
      graphics.set_color(c.color)
      graphics.line(c.x - c.w/2, c.y + c.h/2 + c.h/10, c.x + c.w/2, c.y + c.h/2 + c.h/10)
    end
  },

  cbyc = TextTag{init = function(c, i, text)
    c.color = invisible
    text.t:after((i-1)*0.15, function()
      c.color = red[0]
      camera:shake(3, 0.075)
      pop1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end)
  end, draw = function(c, i, text)
    graphics.set_color(c.color)
  end},

  cbyc2 = TextTag{init = function(c, i, text)
    c.color = invisible
    text.t:after((i-1)*0.15, function()
      c.color = yellow[0]
      camera:shake(3, 0.075)
      pop1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end)
  end, draw = function(c, i, text)
    graphics.set_color(c.color)
  end},

  cbyc3 = TextTag{init = function(c, i, text)
    c.color = invisible
    text.t:after((i-1)*0.025, function()
      c.color = bg[10]
    end)
  end, draw = function(c, i, text)
    graphics.set_color(c.color)
  end},

  nudge_down = TextTag{init = function(c, i, text)
    c.oy = -4
    text.t:tween(0.1, c, {oy = 0}, math.linear)
  end},
}




Text2 = Object:extend()
Text2:implement(GameObject)
function Text2:init(args)
  self:init_game_object(args)
  self.text = Text(args.lines, global_text_tags)
  self.w, self.h = self.text.w, self.text.h
end


function Text2:update(dt)
  self:update_game_object(dt)
  self.text:update(dt)
end


function Text2:draw()
  self.text:draw(self.x, self.y, self.r, self.spring.x*self.sx, self.spring.x*self.sy)
end


function Text2:pull(...)
  self.spring:pull(...)
  self.r = random:table{-math.pi/24, math.pi/24}
  self.t:tween(0.2, self, {r = 0}, math.linear)
end




InfoText = Object:extend()
InfoText:implement(GameObject)
function InfoText:init(args)
  self:init_game_object(args)
  self.sx, self.sy = 0, 0
  self.ox, self.oy = 0, 0
  self.ow, self.oh = 0, 0
  self.tox, self.toy = 0, 0
  self.text = Text({}, global_text_tags)
  return self
end


function InfoText:update(dt)
  self:update_game_object(dt)
end


function InfoText:draw()
  graphics.push(self.x + self.ox, self.y + self.oy, 0, self.sx*self.spring.x, self.sy*self.spring.x)
  graphics.rectangle(self.x + self.ox, self.y + self.oy, self.text.w + self.ow, self.text.h + self.oh, self.text.h/12, self.text.h/12, bg[-2])
  self.text:draw(self.x + self.ox + self.tox, self.y + self.oy + self.toy)
  graphics.pop()
end


function InfoText:activate(text, ox, oy, sx, sy, ow, oh, tox, toy)
  self.ox, self.oy = ox or 0, oy or 0
  self.sx, self.sy = sx or 1, sy or 1
  self.ow, self.oh = ow or 0, oh or 0
  self.tox, self.toy = tox or 0, toy or 0
  self.text:set_text(text)
  self.t:cancel'deactivate'
  self.t:tween(0.1, self, {sx = sx or 1, sy = sy or 1}, math.cubic_in_out, function() self.sx, self.sy = sx or 1, sy or 1 end, 'activate')
  self.spring:pull(0.075)
end


function InfoText:deactivate()
  self.t:cancel'activate'
  self.t:tween(0.05, self, {sy = 0}, math.linear, function() self.sy = 0; self.dead = true end, 'deactivate')
end




ColorRamp = Object:extend()
function ColorRamp:init(color, step)
  self.color = color
  self.step = step
  for i = -10, 10 do
    if i < 0 then
      self[i] = self.color:clone():lighten(i*self.step)
    elseif i > 0 then
      self[i] = self.color:clone():lighten(i*self.step)
    else
      self[i] = self.color:clone()
    end
  end
end




RefreshEffect = Object:extend()
RefreshEffect:implement(GameObject)
RefreshEffect:implement(Parent)
function RefreshEffect:init(args)
  self:init_game_object(args)
  self.oy = self.h/3
  self.t:tween(0.15, self, {h = 0}, math.linear, function() self.dead = true end)
end


function RefreshEffect:update(dt)
  self:update_game_object(dt)
  self:follow_parent_exclusively()
end


function RefreshEffect:draw()
  graphics.push(self.x, self.y, self.r)
  graphics.rectangle2(self.x - self.w/2, self.y - self.oy, self.w, self.h, nil, nil, fg[0])
  graphics.pop()
end




function flash(duration, color)
  flashing = true
  flash_color = color or fg[0]
  trigger:after(duration, function() flashing = false end, 'flash')
end


function slow(amount, duration, tween_method)
  amount = amount or 0.5
  duration = duration or 0.5
  tween_method = tween_method or math.cubic_in_out
  slow_amount = amount
  trigger:tween(duration, _G, {slow_amount = 1}, tween_method, function() slow_amount = 1 end, 'slow')
end




HitCircle = Object:extend()
HitCircle:implement(GameObject)
function HitCircle:init(args)
  self:init_game_object(args)
  self.rs = self.rs or 8
  self.duration = self.duration or 0.05
  self.color = self.color or fg[0]
  self.t:after(self.duration, function() self.dead = true end, 'die')
  return self
end


function HitCircle:update(dt)
  self:update_game_object(dt)
end


function HitCircle:draw()
  graphics.circle(self.x, self.y, self.rs, self.color)
end


function HitCircle:scale_down(duration)
  duration = duration or 0.2
  self.t:cancel'die'
  self.t:tween(self.duration, self, {rs = 0}, math.cubic_in_out, function() self.dead = true end)
  return self
end


function HitCircle:change_color(delay_multiplier, target_color)
  delay_multiplier = delay_multiplier or 0.5
  self.t:after(delay_multiplier*self.duration, function() self.color = target_color end)
  return self
end




HitParticle = Object:extend()
HitParticle:implement(GameObject)
function HitParticle:init(args)
  self:init_game_object(args)
  self.v = self.v or random:float(50, 150)
  self.r = args.r or random:float(0, 2*math.pi)
  self.duration = self.duration or random:float(0.2, 0.6)
  self.w = self.w or random:float(3.5, 7)
  self.h = self.h or self.w/2
  self.color = self.color or fg[0]
  self.t:tween(self.duration, self, {w = 2, h = 2, v = 0}, math.cubic_in_out, function() self.dead = true end)
end


function HitParticle:update(dt)
  self:update_game_object(dt)
  self.x = self.x + self.v*math.cos(self.r)*dt
  self.y = self.y + self.v*math.sin(self.r)*dt
end


function HitParticle:draw()
  graphics.push(self.x, self.y, self.r)
  if self.parent and not self.parent.dead then
    graphics.rectangle(self.x, self.y, self.w, self.h, 2, 2, self.parent.hfx.hit.f and fg[0] or self.color)
  else
    graphics.rectangle(self.x, self.y, self.w, self.h, 2, 2, self.color)
  end
  graphics.pop()
end


function HitParticle:change_color(delay_multiplier, target_color)
  delay_multiplier = delay_multiplier or 0.5
  self.t:after(delay_multiplier*self.duration, function() self.color = target_color end)
  return self
end




AnimationEffect = Object:extend()
AnimationEffect:implement(GameObject)
function AnimationEffect:init(args)
  self:init_game_object(args)
  self.animation = Animation(self.delay, self.frames, 'once', {[0] = function() self.dead = true end})
  self.color = self.color or fg[0]
end


function AnimationEffect:update(dt)
  self:update_game_object(dt)
  self.animation:update(dt)
  if self.linear_movement then
    self.x = self.x + self.v*math.cos(self.r)*dt
    self.y = self.y + self.v*math.sin(self.r)*dt
  end
end


function AnimationEffect:draw()
  self.animation:draw(self.x + (self.ox or 0), self.y + (self.ox or 0), self.r + (self.oa or 0), (self.flip_sx or 1)*self.sx, (self.flip_sy or 1)*self.sy, nil, nil, self.color)
end


function AnimationEffect:set_linear_movement(v, r)
  self.v = v
  self.r = r
  self.linear_movement = true
  local duration = self.animation.size*self.delay
  self.t:after(2*duration/3, function() self.t:tween(duration/3, self, {v = 0}, math.cubic_in_out) end)
end




Wall = Object:extend()
Wall:implement(GameObject)
Wall:implement(Physics)
function Wall:init(args)
  self:init_game_object(args)
  self:set_as_chain(true, self.vertices, 'static', 'solid')
  self.color = self.color or fg[0]
end


function Wall:update(dt)
  self:update_game_object(dt)
end


function Wall:draw()
  self.shape:draw(self.color)
end




WallCover = Object:extend()
WallCover:implement(GameObject)
function WallCover:init(args)
  self:init_game_object(args)
  self.shape = Polygon(self.vertices)
  self.color = self.color or fg[0]
end


function WallCover:update(dt)
  self:update_game_object(dt)
end


function WallCover:draw()
  self.shape:draw(self.color)
end
