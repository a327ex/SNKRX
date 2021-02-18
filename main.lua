require 'engine'
require 'shared'
require 'arena'
require 'objects'


function init()
  shared_init()

  input:bind('move_left', {'a', 'left'})
  input:bind('move_right', {'d', 'right'})
  input:bind('move_up', {'w', 'up'})
  input:bind('move_down', {'s', 'down'})

  main = Main()
  main:add(Arena'arena')
  main:go_to'arena'
end


function update(dt)
  main:update(dt)
end


function draw()
  shared_draw(function()
    main:draw()
  end)
end


function love.run()
  return engine_run({
    game_name = 'SNAKRX',
    window_width = 480*3,
    window_height = 270*3,
  })
end
