-- The Group class is responsible for object management.
-- A common usage is to create different groups for different "layers" of behavior in the game:
--[[
Game = Object:extend()
Game:implement(State)
function Game:on_enter()
  self.main = Group():set_as_physics_world(192)
  self.effects = Group()
  self.floor = Group()
  self.ui = Group():no_camera()
end


function Game:update(dt)
  self.main:update(dt)
  self.floor:update(dt)
  self.effects:update(dt)
  self.ui:update(dt)
end


function Game:draw()
  self.floor:draw()
  self.main:sort_by_y()
  self.main:draw()
  self.effects:draw()
  self.ui:draw()
end
]]--

-- This is a simple example where you have four groups, each for a different purpose.
-- The main group is where all gameplay objects are and thus the only one that's using the physics world (box2d).
-- If you need an object to collide with another physically then they have to use the same physics world, and thus also the same group.
-- The effects and floor groups are purely visual, one for drawing things on the floor (it's a top-down-ish 2.5D game), like shadows, and the other for drawing visual effects on top of everything else.
-- As you can see in the draw function, floor is drawn first and effects is drawn after all gameplay objects.
-- These three groups above also all use the game's main camera instance as their targets since we want gameplay objects, floor and visual effects to be drawn according to the camera's transform.
-- Finally, the UI group is the one that doesn't have a camera attached to it because we want its objects to be drawn in fixed locations on the screen.
-- And this group is also drawn last because generally UI elements go on top of literally everything else.
Group = Object:extend()
function Group:init()
  self.t = Trigger()
  self.camera = camera
  self.objects = {}
  self.objects.by_id = {}
  self.objects.by_class = {}
  self.cells = {}
  self.cell_size = 64
  return self
end


function Group:update(dt)
  self.t:update(dt)
  for _, object in ipairs(self.objects) do
    if object.force_update then
      object:update(1/refresh_rate)
    else
      object:update(dt)
    end
  end
  if self.world then self.world:update(dt) end

  self.cells = {}
  for _, object in ipairs(self.objects) do
    local cx, cy = math.floor(object.x/self.cell_size), math.floor(object.y/self.cell_size)
    if tostring(cx) == tostring(0/0) or tostring(cy) == tostring(0/0) then goto continue end
    if not self.cells[cx] then self.cells[cx] = {} end
    if not self.cells[cx][cy] then self.cells[cx][cy] = {} end
    table.insert(self.cells[cx][cy], object)
    ::continue::
  end

  for i = #self.objects, 1, -1 do
    if self.objects[i].dead then
      if self.objects[i].destroy then self.objects[i]:destroy() end
      self.objects.by_id[self.objects[i].id] = nil
      table.delete(self.objects.by_class[getmetatable(self.objects[i])], function(v) return v.id == self.objects[i].id end)
      table.remove(self.objects, i)
    end
  end
end


-- scroll_factor_x and scroll_factor_y can be used for parallaxing, they should be values between 0 and 1
-- The closer to 0, the more of a parallaxing effect there will be.
function Group:draw(scroll_factor_x, scroll_factor_y)
  if self.camera then self.camera:attach(scroll_factor_x, scroll_factor_y) end
    for _, object in ipairs(self.objects) do
      if not object.hidden then
        object:draw()
      end
    end
  if self.camera then self.camera:detach() end
end


-- Draws only objects within the indexed range
-- group:draw_range(1, 3) -> draws only 1st, 2nd and 3rd objects in this group
function Group:draw_range(i, j, scroll_factor_x, scroll_factor_y)
  if self.camera then self.camera:attach(scroll_factor_x, scroll_factor_y) end
    for k = i, j do
      if not self.objects[k].hidden then
        self.objects[k]:draw()
      end
    end
  if self.camera then self.camera:detach() end
end


-- Draws only objects of a certain class
-- group:draw_class(Solid) -> draws only objects of the Solid class
function Group:draw_class(class, scroll_factor_x, scroll_factor_y)
  if self.camera then self.camera:attach(scroll_factor_x, scroll_factor_y) end
    for _, object in ipairs(self.objects) do
      if object:is(class) and not object.hidden then
        object:draw()
      end
    end
  if self.camera then self.camera:detach() end
end


-- Draws all objects except those of specified classes
-- group:draw_all_except({Solid, SolidGeometry}) -> draws all objects except those of the Solid and SolidGeometry classes
function Group:draw_all_except(classes, scroll_factor_x, scroll_factor_y)
  if self.camera then self.camera:attach(scroll_factor_x, scroll_factor_y) end
    for _, object in ipairs(self.objects) do
      if not table.any(classes, function(v) return object:is(v) end) and not object.hidden then
        object:draw()
      end
    end
  if self.camera then self.camera:detach() end
end


-- Sets this group as one without a camera, useful for things like UIs
function Group:no_camera()
  self.camera = nil
  return self
end


-- Sorts all objects in this group by their y position
-- This is useful for top-down 2.5D games so that objects further up on the screen are drawn first and look like they're further away from the camera
-- Objects can additionally have a .y_sort_offset attribute which gets added to this function's calculations
-- This attribute is useful for objects that are longer vertically and need some adjusting otherwise the point at which they get drawn behind looks off
function Group:sort_by_y()
  table.sort(self.objects, function(a, b) return (a.y + (a.y_sort_offset or 0)) < (b.y + (b.y_sort_offset or 0)) end)
end


-- Returns the mouse position based on the camera used by this group
-- mx, my = group:get_mouse_position() 
function Group:get_mouse_position()
  if self.camera then
    return self.camera.mouse.x, self.camera.mouse.y
  else
    local mx, my = love.mouse.getPosition()
    return mx/sx, my/sy
  end
end


function Group:destroy()
  for _, object in ipairs(self.objects) do if object.destroy then object:destroy() end end
  self.objects = {}
  self.objects.by_id = {}
  self.objects.by_class = {}
  if self.world then
    self.world:destroy()
    self.world = nil
  end
  return self
end


-- Adds an existing object to the group
-- player = Player{x = 160, y = 80}
-- group:add(player)
-- Creates an object and automatically add it to the group
-- player = Player{group = group, x = 160, y = 80}
-- The object has its .group attribute set to this group, and has a random .id set if it doesn't already have one
function Group:add(object)
  local class = getmetatable(object)
  object.group = self

  if not object.id then object.id = random:uid() end
  self.objects.by_id[object.id] = object
  if not self.objects.by_class[class] then self.objects.by_class[class] = {} end
  table.insert(self.objects.by_class[class], object)
  table.insert(self.objects, object)
  return object
end


-- Returns an object by its unique id
-- group:get_object_by_id(id) -> the object
function Group:get_object_by_id(id)
  return self.objects.by_id[id]
end


-- Returns the first object found after searching for it by property, the property value must be unique among all objects
-- group:get_object_by_property('special_id', 347762) -> the object
function Group:get_object_by_property(key, value)
  for _, object in ipairs(self.objects) do
    if object[key] == value then
      return object
    end
  end
end


-- Returns an object after searching for it by properties with all of them matching, the property value match must be unique among all objects
-- group:get_object_by_properties({'special_id_1', 'special_id_2'}, {347762, 32452}) -> the object
function Group:get_object_by_properties(keys, values)
  for _, object in ipairs(self.objects) do
    local this_is_the_object = true
    for i = 1, #keys do
      if object[keys[i]] ~= values[i] then
        this_is_the_object = false
      end
    end
    if this_is_the_object then
      return object
    end
  end
end


-- Returns all objects of a specific class
-- group:get_objects_by_class(Star) -> all objects of class Star in a table
function Group:get_objects_by_class(class)
  if not self.objects.by_class[class] then return {}
  else return table.shallow_copy(self.objects.by_class[class]) end
end


-- Returns all objects of the specified classes
-- group:get_objects_by_classes({Star, Enemy, Projectile}) -> all objects of class Star, Enemy or Projectile in a table
function Group:get_objects_by_classes(class_list)
  local objects = {}
  for _, class in ipairs(class_list) do table.insert(objects, self:get_objects_by_class(class)) end
  return table.flatten(objects, true)
end


-- Returns all objects inside the shape, using its .x, .y attributes as the center and its .w, .h attributes as its bounding size.
-- If object_types is passed in then it only returns object of those classes.
-- The bounding size is used to select objects quickly and roughly, and then more specific and expensive collision methods are run on the objects returned from that selection.
-- group:get_objects_in_shape(Rectangle(player.x, player.y, 100, 100, player.r), {Enemy1, Enemy2}) -> all Enemy1 and Enemy2 instances in a 100x100 rotated rectangle around the player
-- group:get_objects_in_shape(Rectangle(player.x, player.y, 100, 100, player.r), {Enemy1, Enemy2}, {object_1, object_2}) -> same as above except excluding object instances object_1 and object_2
function Group:get_objects_in_shape(shape, object_types, exclude_list)
  local out = {}
  local exclude_list = exclude_list or {}
  local cx1, cy1 = math.floor((shape.x-shape.w)/self.cell_size), math.floor((shape.y-shape.h)/self.cell_size)
  local cx2, cy2 = math.floor((shape.x+shape.w)/self.cell_size), math.floor((shape.y+shape.h)/self.cell_size)
  for i = cx1, cx2 do
    for j = cy1, cy2 do
      local cx, cy = i, j
      if self.cells[cx] then
        local cell_objects = self.cells[cx][cy]
        if cell_objects then
          for _, object in ipairs(cell_objects) do
            if object_types then
              if not table.any(exclude_list, function(v) return v.id == object.id end) then
                if table.any(object_types, function(v) return object:is(v) end) and object.shape and object.shape:is_colliding_with_shape(shape) then
                  table.insert(out, object)
                end
              end
            else
              if object.shape and object:is_colliding_with_shape(shape) then
                table.insert(out, object)
              end
            end
          end
        end
      end
    end
  end
  return out
end


-- Returns the closest object in this group to the object passed in
-- Optionally also pass in a function which will only allow objects that pass its test to be considered in the calculations
-- group:get_closest_object(player) -> closest object to the player, if the player is in this group then this object will be the player itself
-- group:get_closest_object(player, function(o) return o.id ~= player.id end) -> closest object to the player that isn't the player
function Group:get_closest_object(object, select_function)
  if not select_function then select_function = function(o) return true end end
  local min_distance, min_index = 100000, 0
  for i, o in ipairs(self.objects) do
    if select_function(o) then
      local d = math.distance(o.x, o.y, object.x, object.y)
      if d < min_distance then
        min_distance = d
        min_index = i
      end
    end
  end
  return self.objects[min_index]
end


-- Sets this group as a physics box2d world
-- This means that objects inserted here can also be initialized as physics objects (see the gameobject file for more on this)
-- group:set_as_physics_world(192, 0, 400) -> a common platformer setup with vertical downward gravity
-- group:set_as_physics_world(192) -> a common setup for most non-platformer games
-- If your game takes place in smaller world coordinates (i.e. you set game_width and game_height to 320x240 or something) then you'll want smaller meter values, like 32 instead of 192
-- Read more on meter values for box2d worlds here: https://love2d.org/wiki/love.physics.setMeter
-- The last argument, tags, is a list of strings corresponding to collision tags that will be assigned to different objects, for instance:
-- group:set_as_physics_world(192, 0, 0, {'player', 'enemy', 'projectile', 'ghost'})
-- As different physics objects have different collision behaviors in regards to one another, the tags created here will facilitate the delineation of those differences.
function Group:set_as_physics_world(meter, xg, yg, tags)
  love.physics.setMeter(meter or 192)
  self.tags = table.unify(table.push(tags, 'solid'))
  self.collision_tags = {}
  self.trigger_tags = {}
  for i, tag in ipairs(self.tags) do
    self.collision_tags[tag] = {category = i, masks = {}}
    self.trigger_tags[tag] = {category = i, triggers = {}}
  end

  self.world = love.physics.newWorld(xg or 0, yg or 0)
  self.world:setCallbacks(
    function(fa, fb, c)
      local oa, ob = self:get_object_by_id(fa:getUserData()), self:get_object_by_id(fb:getUserData())
      if fa:isSensor() or fb:isSensor() then
        if fa:isSensor() then if oa.on_trigger_enter then oa:on_trigger_enter(ob, c) end end
        if fb:isSensor() then if ob.on_trigger_enter then ob:on_trigger_enter(oa, c) end end
      else
        if oa.on_collision_enter then oa:on_collision_enter(ob, c) end
        if ob.on_collision_enter then ob:on_collision_enter(oa, c) end
      end
    end,
    function(fa, fb, c)
      local oa, ob = self:get_object_by_id(fa:getUserData()), self:get_object_by_id(fb:getUserData())
      if fa:isSensor() or fb:isSensor() then
        if fa:isSensor() then if oa.on_trigger_exit then oa:on_trigger_exit(ob, c) end end
        if fb:isSensor() then if ob.on_trigger_exit then ob:on_trigger_exit(oa, c) end end
      else
        if oa.on_collision_exit then oa:on_collision_exit(ob, c) end
        if ob.on_collision_exit then ob:on_collision_exit(oa, c) end
      end
    end
  )
  return self
end


-- Enables physical collision between objects of two tags
-- on_collision_enter and on_collision_exit callbacks will be called when objects of these two tags physically collide
-- By default, every object physically collides with every other object
-- group:set_as_physics_world(192, 0, 0, {'player', 'enemy', 'projectile', 'ghost', 'solid'})
-- group:enable_collision_between('player', 'enemy')
function Group:enable_collision_between(tag1, tag2)
  table.delete(self.collision_tags[tag1].masks, self.collision_tags[tag2].category)
end


-- Disables physical collision between objects of two tags
-- on_collision_enter and on_collision_exit callbacks will NOT be called when objects of these two tags pass through each other
-- group:set_as_physics_world(192, 0, 0, {'player', 'enemy', 'projectile', 'ghost', 'solid'})
-- group:disable_collision_between('ghost', 'solid')
-- group:disable_collision_between('player', 'projectile')
function Group:disable_collision_between(tag1, tag2)
  table.insert(self.collision_tags[tag1].masks, self.collision_tags[tag2].category)
end


-- Enables trigger collision between objects of two tags
-- When objects have physical collision disabled between one another, you might still want to have the engine generate enter and exit events when they start/stop overlapping
-- This is the function that makes that happen
-- group:set_as_physics_world(192, 0, 0, {'player', 'enemy', 'projectile', 'ghost', 'solid'})
-- group:disable_collision_between('ghost', 'solid')
-- group:enable_trigger_between('ghost', 'solid') -> now when a ghost passes through a solid, on_trigger_enter and on_trigger_exit will be called
function Group:enable_trigger_between(tag1, tag2)
  table.insert(self.trigger_tags[tag1].triggers, self.trigger_tags[tag2].category)
end


-- Disables trigger collision between objects of two tags
-- This will only work if enable_trigger_between has been called for a pair of tags
-- In general you shouldn't use this, as trigger collisions are disabled by default for all objects
function Group:disable_trigger_between(tag1, tag2)
  table.delete(self.trigger_tags[tag1].triggers, self.trigger_tags[tag2].category)
end


-- Returns a table of all physics objects that collide with the segment passed in
-- This requires that the group is set as a physics world first and only works on objects initialized as physics objects (see gameobject file)
-- This function returns a table of hits, each hit is of the following format: {
--   x = hit's x position, y = hit's y position,
--   nx = hit's x normal, ny = hit's y normal,
--   fraction = a number from 0 to 1 representing the fraction of the segment where the hit happened,
--   other = the object hit by the segment
-- }
-- So if the following call group:raycast(100, 100, 800 800) hits 3 objects, it will return something like this: {
--   [1] = {x = ..., y = ..., nx = ..., ny = ..., fraction = ..., other = the 1st object hit},
--   [2] = {x = ..., y = ..., nx = ..., ny = ..., fraction = ..., other = the 2nd object hit},
--   [3] = {x = ..., y = ..., nx = ..., ny = ..., fraction = ..., other = the 3rd object hit},
-- }
-- Where ... just stands for some number.
function Group:raycast(x1, y1, x2, y2)
  if not self.world then return end

  self.raycast_hitlist = {}
  self.world:rayCast(x1, y1, x2, y2, function(fixture, x, y, nx, ny, fraction)
    local hit = {}
    hit.fixture = fixture
    hit.x, hit.y = x, y
    hit.nx, hit.ny = nx, ny
    hit.fraction = fraction
    table.insert(self.raycast_hitlist, hit)
    return 1
  end)

  local hits = {}
  for _, hit in ipairs(self.raycast_hitlist) do
    local obj = self:get_object_by_id(hit.fixture:getUserData())
    hit.fixture = nil
    hit.other = obj
    table.insert(hits, hit)
  end

  return hits
end
