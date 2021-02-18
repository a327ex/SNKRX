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

  self.x1, self.y1 = gw/2 - 0.8*gw/2, gh/2 - 0.8*gh/2
  self.x2, self.y2 = gw/2 + 0.8*gw/2, gh/2 + 0.8*gh/2

  Wall{group = self.main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}

  self.player = Unit{group = self.main, x = gw/2, y = gh/2, player = true, leader = true, character = 'vagrant'}
  -- self.player:add_follower(Unit{group = self.main, player = true, color = red[0]})
end


function Arena:on_enter(from)
  
end


function Arena:update(dt)
  self:update_game_object(dt*slow_amount)
  self.main:update(dt*slow_amount)
  self.effects:update(dt*slow_amount)
  self.ui:update(dt*slow_amount)
end


function Arena:draw()
  self.main:draw()
  self.effects:draw()
  self.ui:draw()
end
