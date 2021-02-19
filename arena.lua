Arena = Object:extend()
Arena:implement(State)
Arena:implement(GameObject)
function Arena:init(name)
  self:init_state(name)
  self:init_game_object()
  self.main = Group():set_as_physics_world(32, 0, 0, {'player', 'enemy', 'projectile', 'enemy_projectile'})
  self.effects = Group()
  self.ui = Group():no_camera()
  self.main:disable_collision_between('player', 'player')

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

  Wall{group = self.main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}

  self.player = Player{group = self.main, x = gw/2, y = gh/2, leader = true, character = 'vagrant'}
  self.player:add_follower(Player{group = self.main, character = 'vagrant'})
  self.player:add_follower(Player{group = self.main, character = 'vagrant'})
  self.player:add_follower(Player{group = self.main, character = 'vagrant'})
  self.player:add_follower(Player{group = self.main, character = 'vagrant'})
  self.player:add_follower(Player{group = self.main, character = 'vagrant'})
  self.player:add_follower(Player{group = self.main, character = 'vagrant'})
end


function Arena:on_enter(from)
  
end


function Arena:update(dt)
  self:update_game_object(dt*slow_amount)
  self.main:update(dt*slow_amount)
  self.effects:update(dt*slow_amount)
  self.ui:update(dt*slow_amount)

  if input.k.pressed then
    self:spawn_enemy(4)
  end
end


function Arena:draw()
  self.main:draw()
  self.effects:draw()
  self.ui:draw()
end


function Arena:spawn_enemy(n)
  n = n or 1
  local p = table.random(self.spawn_points)
  for i = 1, n do
    self.t:after((i-1)*0.1, function()
      local o = table.random(self.spawn_offsets)
      SpawnEffect{group = self.effects, x = p.x + o.x, y = p.y + o.y, action = function(x, y) Seeker{group = self.main, x = x, y = y, character = 'seeker'} end}
    end)
  end
end
