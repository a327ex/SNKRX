Solid = Object:extend()
Solid:implement(GameObject)
Solid:implement(Physics)


function Solid:init(args)
  self:init_game_object(args)
  self:set_as_chain(true, self.vertices, 'static', 'solid')
end


function Solid:update(dt)
  self:update_game_object(dt)
end


function Solid:draw()
  self:draw_game_object()
end
