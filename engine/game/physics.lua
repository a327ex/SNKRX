-- A physics mixin. Responsible for turning the game object it's attached to into a full fledged physics object.
-- Currently the only default way to add collision to objects is via this mixin.
-- In the future I want to create a way that doesn't make use of box2d for simpler games, but that also uses roughly the same API so that gameplay code doesn't have to be different regardless of which one you're using.
-- Using any of the "set_as" init functions requires the game object to have a group attached to it.
Physics = Object:extend()


-- Sets this object as a physics rectangle.
-- Its body_type can be either 'static', 'dynamic' or 'kinematic' (see box2d for more info) and its tag has to have been created in group:set_as_physics_world.
-- Its .shape variable is set to a Rectangle instance and this instance is updated to be in sync with the physics body every frame.
function Physics:set_as_rectangle(w, h, body_type, tag)
  if not self.group then error("The GameObject must have a group defined for the Physics mixin to function") end
  self.tag = tag
  self.shape = Rectangle(self.x, self.y, w, h)
  self.body = love.physics.newBody(self.group.world, self.x, self.y, body_type or "dynamic")
  local shape = love.physics.newRectangleShape(self.shape.w, self.shape.h)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self.id)
  self.fixture:setCategory(self.group.collision_tags[tag].category)
  self.fixture:setMask(unpack(self.group.collision_tags[tag].masks))
  if #self.group.trigger_tags[tag].triggers > 0 then
    self.sensor = love.physics.newFixture(self.body, shape)
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


-- Sets this object as a physics line.
-- Its body_type can be either 'static', 'dynamic' or 'kinematic' (see box2d for more info) and its tag has to have been created in group:set_as_physics_world.
-- Its .shape variable is set to a Line instance and this instance is updated to be in sync with the physics body every frame.
function Physics:set_as_line(x1, y1, x2, y2, body_type, tag)
  if not self.group then error("The GameObject must have a group defined for the Physics mixin to function") end
  self.tag = tag
  self.shape = Line(x1, y1, x2, y2)
  self.body = love.physics.newBody(self.group.world, 0, 0, body_type or "dynamic")
  local shape = love.physics.newEdgeShape(self.shape.x1, self.shape.y1, self.shape.x2, self.shape.y2)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self.id)
  self.fixture:setCategory(self.group.collision_tags[tag].category)
  self.fixture:setMask(unpack(self.group.collision_tags[tag].masks))
  if #self.group.trigger_tags[tag].triggers > 0 then
    self.sensor = love.physics.newFixture(self.body, shape)
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


-- Sets this object as a physics chain (a collection of edges)
-- Its body_type can be either 'static', 'dynamic' or 'kinematic' (see box2d for more info) and its tag has to have been created in group:set_as_physics_world.
-- If loop is set to true, then the collection of edges will be closed, forming a polygon. Otherwise it will be open.
-- Its .shape variable is set to a Chain instance and this instance is updated to be in sync with the physics body every frame.
function Physics:set_as_chain(loop, vertices, body_type, tag)
  if not self.group then error("The GameObject must have a group defined for the Physics mixin to function") end
  self.tag = tag
  self.shape = Chain(loop, vertices)
  self.body = love.physics.newBody(self.group.world, 0, 0, body_type or "dynamic")
  local shape = love.physics.newChainShape(self.shape.loop, self.shape.vertices)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self.id)
  self.fixture:setCategory(self.group.collision_tags[tag].category)
  self.fixture:setMask(unpack(self.group.collision_tags[tag].masks))
  if #self.group.trigger_tags[tag].triggers > 0 then
    self.sensor = love.physics.newFixture(self.body, shape)
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


-- Sets this object as a physics polygon.
-- Its body_type can be either 'static', 'dynamic' or 'kinematic' (see box2d for more info) and its tag has to have been created in group:set_as_physics_world.
-- Its .shape variable is set to a Polygon instance and this instance is updated to be in sync with the physics body every frame.
function Physics:set_as_polygon(vertices, body_type, tag)
  if not self.group then error("The GameObject must have a group defined for the Physics mixin to function") end
  self.tag = tag
  self.shape = Polygon(vertices)
  self.body = love.physics.newBody(self.group.world, 0, 0, body_type or "dynamic")
  self.body:setPosition(self.x, self.y)
  local shape = love.physics.newPolygonShape(self.shape.vertices)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self.id)
  self.fixture:setCategory(self.group.collision_tags[tag].category)
  self.fixture:setMask(unpack(self.group.collision_tags[tag].masks))
  if #self.group.trigger_tags[tag].triggers > 0 then
    self.sensor = love.physics.newFixture(self.body, shape)
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


-- Sets this object as a physics circle.
-- Its body_type can be either 'static', 'dynamic' or 'kinematic' (see box2d for more info) and its tag has to have been created in group:set_as_physics_world.
-- Its .shape variable is set to a Circle instance and this instance is updated to be in sync with the physics body every frame.
function Physics:set_as_circle(rs, body_type, tag)
  if not self.group then error("The GameObject must have a group defined for the Physics mixin to function") end
  self.tag = tag
  self.shape = Circle(self.x, self.y, rs)
  self.body = love.physics.newBody(self.group.world, self.x, self.y, body_type or "dynamic")
  local shape = love.physics.newCircleShape(self.shape.rs)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self.id)
  self.fixture:setCategory(self.group.collision_tags[tag].category)
  self.fixture:setMask(unpack(self.group.collision_tags[tag].masks))
  if #self.group.trigger_tags[tag].triggers > 0 then
    self.sensor = love.physics.newFixture(self.body, shape)
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


-- Sets this object as a physics triangle.
-- Its body_type can be either 'static', 'dynamic' or 'kinematic' (see box2d for more info) and its tag has to have been created in group:set_as_physics_world.
-- Its .shape variable is set to a Triangle instance and this instance is updated to be in sync with the physics body every frame.
function Physics:set_as_triangle(w, h, body_type, tag)
  if not self.group then error("The GameObject must have a group defined for the Physics mixin to function") end
  self.tag = tag
  self.shape = Triangle(self.x, self.y, w, h)
  self.body = love.physics.newBody(self.group.world, 0, 0, body_type or "dynamic")
  self.body:setPosition(self.x, self.y)
  local x1, y1 = h/2, 0
  local x2, y2 = -h/2, -w/2
  local x3, y3 = -h/2, w/2
  local shape = love.physics.newPolygonShape({x1, y1, x2, y2, x3, y3})
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setUserData(self.id)
  self.fixture:setCategory(self.group.collision_tags[tag].category)
  self.fixture:setMask(unpack(self.group.collision_tags[tag].masks))
  if #self.group.trigger_tags[tag].triggers > 0 then
    self.sensor = love.physics.newFixture(self.body, shape)
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


function Physics:connect(other, direction)
  if not self.joints then self.joints = {} end
  local d = Vector(0, 0)
  if direction == 'right' then d:set(1, 0)
  elseif direction == 'left' then d:set(-1, 0)
  elseif direction == 'up' then d:set(0, -1)
  elseif direction == 'down' then d:set(0, 1) end
  self.joints[direction] = love.physics.newRevoluteJoint(self.body, other.body, self.x + 0.5*d.x*self.shape.w, self.y + 0.5*d.y*self.shape.h)
  return self
end


-- Automatically called by the group instance this game object belongs to whenever it dies.
function Physics:destroy()
  if self.body then
    if self.fixtures then for _, fixture in ipairs(self.fixtures) do fixture:destroy() end end
    if self.sensors then for _, sensor in ipairs(self.sensors) do sensor:destroy() end end
    if self.sensor and (self.sensor.type and self.sensor:type() == 'Fixture') then
      self.sensor:destroy()
      self.sensor = nil
    end
    self.fixture:destroy()
    self.body:destroy()
    self.fixture, self.body = nil, nil
    if self.fixtures then self.fixtures = nil end
    if self.sensors then self.sensors = nil end
  end
end


function Physics:draw_physics(color, line_width)
  if self.shape then self.shape:draw(color, line_width or 4) end
end


-- Returns the angle from a point to this object
-- r = self:angle_from_point(player.x, player.y) -> angle from the player to this object
function Physics:angle_from_point(x, y)
  return math.atan2(self.y - y, self.x - x)
end


-- Returns the angle from this object to another object
-- r = self:angle_to_object(player) -> angle from this object to the player
function Physics:angle_to_object(object)
  return self:angle_to_point(object.x, object.y)
end


-- Returns the angle from an object to this object
-- r = self:angle_from_object(player) -> angle from the player to this object
function Physics:angle_from_object(object)
  return self:angle_from_point(object.x, object.y)
end


-- Returns the angle from this object to the mouse
-- r = self:angle_to_mouse()
function Physics:angle_to_mouse()
  local mx, my = self.group.camera:get_mouse_position()
  return math.atan2(my - self.y, mx - self.x)
end


-- Returns the distance from this object to a point
-- d = self:distance_to_point(player.x, player.y)
function Physics:distance_to_point(x, y)
  return math.distance(self.x, self.y, x, y)
end


-- Returns the distance from an object to this object
-- d = self:distance_to_object(player)
function Physics:distance_to_object(object)
  return math.distance(self.x, self.y, object.x, object.y)
end


-- Returns the distance from this object to the mouse
-- d = self:angle_to_mouse()
function Physics:distance_to_mouse()
  local mx, my = self.group.camera:get_mouse_position()
  return math.distance(self.x, self.y, mx, my)
end


-- Returns true if this GameObject is colliding with the given point.
-- colliding = self:is_colliding_with_point(x, y)
function Physics:is_colliding_with_point(x, y)
  return self:is_colliding_with_point(x, y)
end


-- Returns true if this GameObject is colliding with the mouse.
-- colliding = self:is_colliding_with_mouse()
function Physics:is_colliding_with_mouse()
  return self:is_colliding_with_point(self.group.camera:get_mouse_position())
end


-- Returns true if this GameObject is colliding with another GameObject.
-- Both must be physics objects set with one of the set_as_shape functions.
-- colliding = self:is_colliding_with_object(other)
function Physics:is_colliding_with_object(object)
  return self:is_colliding_with_shape(object.shape)
end


-- Returns true if this GameObject is colliding with the given shape.
-- colliding = self:is_colliding_with_shape(shape)
function Physics:is_colliding_with_shape(shape)
  return self.shape:is_colliding_with_shape(shape)
end


-- Exactly the same as group:get_objects_in_shape, except additionally it automatically removes this object from the results.
-- self:get_objects_in_shape(Circle(self.x, self.y, 100), {Enemy1, Enemy2, Enemy3}) -> all objects of class Enemy1, Enemy2 and Enemy3 in a circle of radius 100 around this object
function Physics:get_objects_in_shape(shape, object_types)
  return table.select(self.group:get_objects_in_shape(shape, object_types), function(v) return v.id ~= self.id end)
end


-- Returns the closest object to this object in the given shape, optionally excluding objects in the exclude list passed in.
-- self:get_closest_object_in_shape(Circle(self.x, self.y, 100), {Enemy1, Enemy2, Enemy3}) -> closest object of class Enemy1, Enemy2 or Enemy3 in a circle of radius 100 around this object
-- self:get_closest_object_in_shape(Circle(self.x, self.y, 100), {Enemy1, Enemy2, Enemy3}, {object_1, object_2}) -> same as above except excluding object instances object_1 and object_2
function Physics:get_closest_object_in_shape(shape, object_types, exclude_list)
  local objects = self:get_objects_in_shape(shape, object_types)
  local min_d, min_i = 1000000, 0
  local exclude_list = exclude_list or {}
  for i, object in ipairs(objects) do
    if not table.any(exclude_list, function(v) return v.id == object.id end) then
      local d = math.distance(self.x, self.y, object.x, object.y)
      if d < min_d then
        min_d = d
        min_i = i
      end
    end
  end
  if i ~= 0 then return objects[min_i] end
end


-- Returns a random object in the given shape, excluding this object and also optionally excluding objects in the exclude list passed in.
-- self:get_random_object_in_shape(Circle(self.x, self.y, 100), {Enemy1, Enemy2, Enemy3}) -> random object of class Enemy1, Enemy2 or Enemy3 in a circle of radius 100 around this object
-- self:get_random_object_in_shape(Circle(self.x, self.y, 100), {Enemy1, Enemy2, Enemy3}, {object_1, object_2}) -> same as above except excluding object instances object_1 and object_2
function Physics:get_random_object_in_shape(shape, object_types, exclude_list)
  local objects = self:get_objects_in_shape(shape, object_types)
  local exclude_list = exclude_list or {}
  local random_object = random:table(objects)
  local tries = 0
  if random_object then
    while table.any(exclude_list, function(v) return v.id == random_object.id end) and tries < 20 do
      random_object = random:table(objects)
      tries = tries + 1
    end
  end
  return random_object
end


function Physics:update_physics(dt)
  self:update_position()
  self:steering_update(dt)
end


-- Updates the .x, .y attributes of this object, useful to call before drawing something if you need its position as recent as position
-- self:update_position()
function Physics:update_position()
  if self.body then self.x, self.y = self.body:getPosition() end
  return self
end


-- Sets the object's position directly, avoid using if you need velocity/acceleration calculations to make sense and be accurate, as teleporting the object around messes up its physics
-- self:set_position(100, 100)
function Physics:set_position(x, y)
  if self.body then self.body:setPosition(x, y) end
  return self:update_position()
end


-- Returns the object's position as two values 
-- x, y = self:get_position()
function Physics:get_position()
  self:update_position()
  if self.body then return self.body:getPosition() end
end


-- Sets the object as a bullet
-- Bullets will collide and generate proper collision responses regardless of their velocity, despite being more expensive to calculate
-- self:set_bullet(true)
function Physics:set_bullet(v)
  if self.body then self.body:setBullet(v) end
  return self
end


-- Sets the object to have fixed rotation
-- When box2d objects don't have fixed rotation, whenever they collide with other objects they will rotate around depending on where the collision happened
-- Setting this to true prevents that from happening, useful for every type of game where you don't need accurate physics responses in terms of the characters rotation
-- self:set_fixed_rotation(true)
function Physics:set_fixed_rotation(v)
  self.fixed_rotation = v
  if self.body then self.body:setFixedRotation(v) end
  return self
end


-- Sets the object's velocity
-- self:set_velocity(100, 100)
function Physics:set_velocity(vx, vy)
  if self.body then self.body:setLinearVelocity(vx, vy) end
  return self
end


-- Returns the object's velocity as two values
-- vx, vy = self:get_velocity()
function Physics:get_velocity()
  if self.body then return self.body:getLinearVelocity() end
end


-- Sets the object's damping
-- The higher this value, the more the object will resist movement and the faster it will stop moving after forces are applied to it
-- self:set_damping(10)
function Physics:set_damping(v)
  if self.body then self.body:setLinearDamping(v) end
  return self
end


-- Sets the object's angular velocity
-- If set_fixed_rotation is set to true then this will do nothing
-- self:set_angular_velocity(math.pi/4)
function Physics:set_angular_velocity(v)
  if self.body then self.body:setAngularVelocity(v) end
  return self
end


-- Sets the object's angular damping
-- The higher this value, the more the object will resist rotation and the faster it will stop rotating after angular forces are applied to it
-- self:set_angular_damping(10)
function Physics:set_angular_damping(v)
  if self.body then self.body:setAngularDamping(v) end
  return self
end


-- Returns the object's angle
-- r = self:get_angle()
function Physics:get_angle()
  if self.body then return self.body:getAngle() end
end


-- Sets the object's angle
-- If set_fixed_rotation is set to true then this will do nothing
-- self:set_angle(math.pi/8)
function Physics:set_angle(v)
  if self.body then self.body:setAngle(v) end
  return self
end


-- Sets the object's restitution
-- This is a value from 0 to 1 and the higher it is the more energy the object will conserve when bouncing off other objects
-- At 1, it will bounce perfectly and not lose any velocity
-- At 0, it will not bounce at all
-- self:set_restitution(0.75)
function Physics:set_restitution(v)
  if self.fixture then
    self.fixture:setRestitution(v)
  elseif self.fixtures then
    for _, fixture in ipairs(self.fixtures) do
      fixture:setRestitution(v)
    end
  end
  return self
end


-- Sets the object's friction
-- This is a value from 0 to infinity, but generally between 0 and 1, the higher it is the more friction there will be when this object slides with another
-- At 0 friction is turned off and the object will slide with no resistance
-- The friction calculation takes into account the friction of both objects sliding on one another, so if one object has friction set to 0 then it will treat the interaction as if there's no friction
-- self:set_friction(1)
function Physics:set_friction(v)
  if self.fixture then
    self.fixture:setFriction(v)
  elseif self.fixtures then
    for _, fixture in ipairs(self.fixtures) do
      fixture:setFriction(v)
    end
  end
  return self
end


-- Applies an instantaneous amount of force to the object
-- self:apply_impulse(100*math.cos(angle), 100*math.sin(angle))
function Physics:apply_impulse(fx, fy)
  if self.body then self.body:applyLinearImpulse(fx, fy) end
  return self
end


-- Applies an instantaneous amount of angular force to the object
-- self:apply_angular_impulse(8*math.pi)
function Physics:apply_angular_impulse(f)
  if self.body then self.body:applyAngularImpulse(f) end
  return self
end


-- Applies a continuous amount of force to the object
-- self:apply_force(100*math.cos(angle), 100*math.sin(angle))
function Physics:apply_force(fx, fy, x, y)
  if self.body then self.body:applyForce(fx, fy, x or self.x, y or self.y) end
  return self
end


-- Applies torque to the object
-- self:apply_torque(math.pi)
function Physics:apply_torque(t)
  if self.body then self.body:applyTorque(t) end
  return self
end


-- Sets the object's mass
-- self:set_mass(1000)
function Physics:set_mass(mass)
  if self.body then self.body:setMass(mass) end
  return self
end


-- Sets the object's gravity scale
-- This is a simple multiplier on the world's gravity, but applied only to this object
function Physics:set_gravity_scale(v)
  if self.body then self.body:setGravityScale(v) end
  return self
end


-- Locks the object horizontally, meaning it can never move up or down.
-- self:lock_horizontally()
function Physics:lock_horizontally()
  local vx, vy = self:get_velocity()
  self:set_velocity(vx, 0)
end


-- Locks the object vertically, meaning it can never move left or right.
-- self:lock_vertically()
function Physics:lock_vertically()
  local vx, vy = self:get_velocity()
  self:set_velocity(0, vy)
end


-- Moves this object towards another object
-- You can either do this by using the speed argument directly, or by using the max_time argument
-- max_time will override speed since it will make it so that the object reaches the target in a given time
-- self:move_towards_object(player, 40) -> moves towards the player with 40 speed
-- self:move_towards_object(player, nil, 2) -> moves towards the player with speed such that it would reach him in 2 seconds if he never moved
function Physics:move_towards_object(object, speed, max_time)
  if max_time then speed = self:distance_to_point(object.x, object.y)/max_time end
  local r = self:angle_to_point(object.x, object.y)
  self:set_velocity(speed*math.cos(r), speed*math.sin(r))
  return self
end


-- Same as move_towards_object except towards a point
-- self:move_towards_point(player.x, player.y, 40)
function Physics:move_towards_point(x, y, speed, max_time)
  if max_time then speed = self:distance_to_point(x, y)/max_time end
  local r = self:angle_to_point(x, y)
  self:set_velocity(speed*math.cos(r), speed*math.sin(r))
  return self
end


-- Same as move_towards_object and move_towards_point except towards the mouse
-- self:move_towards_mouse(nil, 1)
function Physics:move_towards_mouse(speed, max_time)
  if max_time then speed = self:distance_to_mouse()/max_time end
  local r = self:angle_to_mouse()
  self:set_velocity(speed*math.cos(r), speed*math.sin(r))
  return self
end


-- Same as move_towards_mouse but does so only on the x axis
-- self:move_towards_mouse_horizontally(nil, 1)
function Physics:move_towards_mouse_horizontally(speed, max_time)
  if max_time then speed = self:distance_to_mouse()/max_time end
  local r = self:angle_to_mouse()
  local vx, vy = self:get_velocity()
  self:set_velocity(speed*math.cos(r), vy)
  return self
end


-- Same as move_towards_mouse but does so only on the y axis
-- self:move_towards_mouse_vertically(nil, 1)
function Physics:move_towards_mouse_vertically(speed, max_time)
  if max_time then speed = self:distance_to_mouse()/max_time end
  local r = self:angle_to_mouse()
  local vx, vy = self:get_velocity()
  self:set_velocity(vx, speed*math.sin(r))
  return self
end


-- Moves the object along an angle, most useful for simple projectiles that don't need any complex movements
-- self:move_along_angle(100, math.pi/4)
function Physics:move_along_angle(speed, r)
  self:set_velocity(speed*math.cos(r), speed*math.sin(r))
  return self
end


-- Rotates the object towards another object using a rotational lerp, which is a value from 0 to 1
-- Higher values will rotate the object faster, lower values will make the turn have a smooth delay to it
-- self:rotate_towards_object(player, 0.2)
function Physics:rotate_towards_object(object, lerp_value)
  self:set_angle(math.lerp_angle(lerp_value, self:get_angle(), self:angle_to_point(object.x, object.y)))
  return self
end


-- Same as rotate_towards_object except towards a point
-- self:rotate_towards_point(player.x, player.y, 0.2)
function Physics:rotate_towards_point(x, y, lerp_value)
  self:set_angle(math.lerp_angle(lerp_value, self:get_angle(), self:angle_to_point(x, y)))
  return self
end


-- Same as rotate_towards_object and rotate_towards_point except towards the mouse
-- self:rotate_towards_mouse(0.2)
function Physics:rotate_towards_mouse(lerp_value)
  self:set_angle(math.lerp_angle(lerp_value, self:get_angle(), self:angle_to_mouse()))
  return self
end


-- Rotates the object towards its own velocity vector using a rotational lerp, which is a value from 0 to 1
-- Higher values will rotate the object faster, lower values will make the turn have a smooth delay to it
-- self:rotate_towards_velocity(0.2)
function Physics:rotate_towards_velocity(lerp_value)
  local vx, vy = self:get_velocity()
  self:set_angle(math.lerp_angle(lerp_value, self:get_angle(), self:angle_to_point(self.x + vx, self.y + vy)))
  return self
end


-- Same as accelerate_towards_object except towards a point
-- self:accelerate_towards_object(player.x, player.y, 100, 10, 2)
function Physics:accelerate_towards_point(x, y, max_speed, deceleration, turn_coefficient)
  local tx, ty = x - self.x, y - self.y
  local d = math.length(tx, ty)
  if d > 0 then
    local speed = d/((deceleration or 1)*0.08)
    speed = math.min(speed, max_speed)
    local current_vx, current_vy = speed*tx/d, speed*ty/d
    local vx, vy = self:get_velocity()
    self:apply_force((current_vx - vx)*(turn_coefficient or 1), (current_vy - vy)*(turn_coefficient or 1))
  end
  return self
end


-- Accelerates the object towards another object
-- Other than the object, the 3 arguments available are:
-- max_speed - the maximum speed the object can have in this acceleration
-- deceleration - how fast the object will decelerate once it gets closer to the target, higher values will make the deceleration more abrupt, do not make this value 0
-- turn_coefficient - how strong is the turning force for this object, higher values will make it turn faster
-- self:accelerate_towards_object(player, 100, 10, 2)
function Physics:accelerate_towards_object(object, max_speed, deceleration, turn_coefficient)
  return self:accelerate_towards_point(object.x, object.y, max_speed, deceleration, turn_coefficient)
end


-- Same as accelerate_towards_object and accelerate_towards_point but towards the mouse
-- self:accelerate_towards_mouse(100, 10, 2)
function Physics:accelerate_towards_mouse(max_speed, deceleration, turn_coefficient)
  local mx, my = self.group.camera:get_mouse_position()
  return self:accelerate_towards_point(mx, my, max_speed, deceleration, turn_coefficient)
end


-- Keeps this object separated from other objects of specific classes according to the radius passed in
-- What this function does is simply look at all nearby objects and apply forces to this object such that it remains separated from them
-- self:separate(40, {Enemy}) -> when this is called every frame, this applies forces to this object to keep it separated from other Enemy instances by 40 units at all times
function Physics:separate(rs, class_avoid_list)
  local fx, fy = 0, 0
  local objects = table.flatten(table.foreachn(class_avoid_list, function(v) return self.group:get_objects_by_class(v) end), true)
  for _, object in ipairs(objects) do
    if object.id ~= self.id and math.distance(object.x, object.y, self.x, self.y) < 2*rs then
      local tx, ty = self.x - object.x, self.y - object.y
      local n = Vector(tx, ty):normalize()
      local l = n:length()
      fx = fx + rs*(n.x/l)
      fy = fy + rs*(n.y/l)
    end
  end
  self:apply_force(fx, fy)
  return self
end


-- Returns the angle from this object to a point
-- r = self:angle_to_point(player.x, player.y) -> angle from this object to the player
function Physics:angle_to_point(x, y)
  return math.atan2(y - self.y, x - self.x)
end


-- Sets the object as a steerable object.
-- The implementation of steering behaviors here mostly follows the one from chapter 3 of the book "Programming Game AI by Example"
-- https://github.com/wangchen/Programming-Game-AI-by-Example-src
