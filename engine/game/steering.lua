-- Sets the object as a steerable object.
-- This is implemented in the Physics mixin because it plays well with the rest of it, thus, to make a game object steerable it needs to implement the Physics mixin.
-- The implementation of steering behaviors here mostly follows the one from chapter 3 of the book "Programming Game AI by Example"
-- https://github.com/wangchen/Programming-Game-AI-by-Example-src
-- self:set_as_steerable(100, 1000)
function Physics:set_as_steerable(max_v, max_f, max_turn_rate, turn_multiplier)
  self.steerable = true
  self.steering_enabled = true
  self.heading = Vector()
  self.side = Vector()
  self.steering_force = Vector()
  self.applied_force = Vector()
  self.applied_impulse = Vector()
  self.mass = 1
  self.max_v = max_v or 100
  self.max_f = max_f or 2000
  self.max_turn_rate = max_turn_rate or 2*math.pi
  self.turn_multiplier = turn_multiplier or 2
  self.seek_f = Vector()
  self.flee_f = Vector()
  self.pursuit_f = Vector()
  self.evade_f = Vector()
  self.wander_f = Vector()
  local r = random:float(0, 2*math.pi)
  self.wander_target = Vector(40*math.cos(r), 40*math.sin(r))
  self.path_follow_f = Vector()
  self.separation_f = Vector()
  self.alignment_f = Vector()
  self.cohesion_f = Vector()
  self.apply_force_f = Vector()
  self.apply_impulse_f = Vector()
end


function Physics:steering_update(dt)
  if self.steerable and self.steering_enabled then
    local steering_force = self:calculate_steering_force(dt):div(self.mass)
    local applied_force = self:calculate_applied_force(dt):div(self.mass)
    local applied_impulse = self:calculate_applied_impulse(dt):div(self.mass)
    self:apply_force(steering_force.x + applied_force.x, steering_force.y + applied_force.y)
    local vx, vy = self:get_velocity()
    local v = Vector(vx, vy):truncate(self.max_v)
    self:set_velocity(v.x + applied_impulse.x, v.y + applied_impulse.y)
    if v:length_squared() > 0.00001 then
      self.heading = v:clone():normalize()
      self.side = self.heading:perpendicular()
    end
    self.apply_force_f:set(0, 0)
    -- self.apply_impulse_f:set(0, 0)
  end
end


function Physics:calculate_steering_force(dt)
  self.steering_force:set(0, 0)
  if self.seeking then self.steering_force:add(self.seek_f) end
  if self.fleeing then self.steering_force:add(self.flee_f) end
  if self.pursuing then self.steering_force:add(self.pursuit_f) end
  if self.evading then self.steering_force:add(self.evade_f) end
  if self.wandering then self.steering_force:add(self.wander_f) end
  if self.path_following then self.steering_force:add(self.path_follow_f) end
  if self.separating then self.steering_force:add(self.separation_f) end
  if self.aligning then self.steering_force:add(self.alignment_f) end
  if self.cohesing then self.steering_force:add(self.cohesion_f) end
  self.seeking = false
  self.fleeing = false
  self.pursuing = false
  self.evading = false
  self.wandering = false
  self.path_following = false
  self.separating = false
  self.aligning = false
  self.cohesing = false
  return self.steering_force:truncate(self.max_f)
end


function Physics:calculate_applied_force(dt)
  self.applied_force:set(0, 0)
  if self.applying_force then self.applied_force:add(self.apply_force_f) end
  return self.applied_force
end


function Physics:calculate_applied_impulse(dt)
  self.applied_impulse:set(0, 0)
  if self.applying_impulse then self.applied_impulse:add(self.apply_impulse_f) end
  return self.applied_impulse
end


-- Applies force f to the object at the given angle r for duration s
-- This plays along with steering behaviors, whereas the apply_force function simply applies it directly to the body and doesn't work when steering behaviors are enabled
-- self:apply_steering_force(100, math.pi/4)
function Physics:apply_steering_force(f, r, s)
  self.applying_force = true
  self.apply_force_f:set(f*math.cos(r), f*math.sin(r))
  if s then
    self.t:after((s or 0.01)/2, function()
      self.t:tween((s or 0.01)/2, self.apply_force_f, {x = 0, y = 0}, math.linear, function()
        self.applying_force = false
        self.apply_force_f:set(0, 0)
      end, 'apply_steering_force_2')
    end, 'apply_steering_force_1')
  end
end


-- Applies impulse f to the object at the given angle r for duration s
-- This plays along with steering behaviors, whereas the apply_impulse function simply applies it directly to the body and doesn't work when steering behaviors are enabled
-- self:apply_steering_impulse(100, math.pi/4, 0.5)
function Physics:apply_steering_impulse(f, r, s)
  self.applying_impulse = true
  self.apply_impulse_f:set(f*math.cos(r), f*math.sin(r))
  if s then
    self.t:after((s or 0.01)/2, function()
      self.t:tween((s or 0.01)/2, self.apply_impulse_f, {x = 0, y = 0}, math.linear, function()
        self.applying_impulse = false
        self.apply_impulse_f:set(0, 0)
      end, 'apply_steering_impulse_2')
    end, 'apply_steering_impulse_1')
  end
end


-- Arrive steering behavior
-- Makes this object accelerate towards a destination, slowing down the closer it gets to it
-- deceleration - how fast the object will decelerate once it gets closer to the target, higher values will make the deceleration more abrupt, do not make this value 0
-- weight - how much the force of this behavior affects this object compared to others
-- self:seek_point(player.x, player.y)
function Physics:seek_point(x, y, deceleration, weight)
  self.seeking = true
  local tx, ty = x - self.x, y - self.y
  local d = math.length(tx, ty)
  if d > 0 then
    local v = d/((deceleration or 1)*0.08)
    v = math.min(v, self.max_v)
    local dvx, dvy = v*tx/d, v*ty/d
    local vx, vy = self:get_velocity()
    self.seek_f:set((dvx - vx)*self.turn_multiplier*(weight or 1), (dvy - vy)*self.turn_multiplier*(weight or 1))
  else self.seek_f:set(0, 0) end
end


-- Same as self:seek_point but for objects instead.
-- self:seek_object(player)
function Physics:seek_object(object, deceleration, weight)
  return self:seek_point(object.x, object.y, deceleration, weight)
end


-- Same as self:seek_point and self:seek_object but for the mouse instead.
-- self:seek_mouse()
function Physics:seek_mouse(deceleration, weight)
  local mx, my = self.group.camera:get_mouse_position()
  return self:seek_point(mx, my, deceleration, weight)
end


-- Separation steering behavior
-- Keeps this object separated from other objects of specific classes according to the radius passed in
-- What this function does is simply look at all nearby objects and apply forces to this object such that it remains separated from them
-- self:separate(40, {Enemy}) -> when this is called every frame, this applies forces to this object to keep it separated from other Enemy instances by 40 units at all times
function Physics:steering_separate(rs, class_avoid_list, weight)
  self.separating = true
  local fx, fy = 0, 0
  local objects = table.flatten(table.foreachn(class_avoid_list, function(v) return self.group:get_objects_by_class(v) end), true)
  for _, object in ipairs(objects) do
    if object.id ~= self.id and math.distance(object.x, object.y, self.x, self.y) < 2*rs then
      local tx, ty = self.x - object.x, self.y - object.y
      local nx, ny = math.normalize(tx, ty)
      local l = math.length(nx, ny)
      fx = fx + rs*(nx/l)
      fy = fy + rs*(ny/l)
    end
  end
  self.separation_f:set(fx*(weight or 1), fy*(weight or 1))
end


-- Wander steering behavior
-- Makes the object move in a jittery manner, adding some randomness to its movement while keeping the overall direction
-- What this function does is project a circle in front of the entity and then choose a point randomly inside that circle for the entity to move towards and it does that every frame
-- rs - the radius of the circle
-- distance - the distance of the circle from this object, the further away the smoother the changes to movement will be
-- jitter - the amount of jitter to the movement, the higher it is the more abrupt the changes will be
-- self:wander(50, 100, 20)
function Physics:wander(rs, distance, jitter, weight)
  self.wandering = true
  self.wander_target:add(random:float(-1, 1)*(jitter or 20), random:float(-1, 1)*(jitter or 20))
  self.wander_target:normalize()
  self.wander_target:mul(rs or 40)
  local target_local = self.wander_target:clone():add(distance or 40, 0)
  local target_world = steering.point_to_world_space(target_local, self.heading, self.side, Vector(self.x, self.y))
  self.wander_f:set((target_world.x - self.x)*(weight or 1), (target_world.y - self.y)*(weight or 1))
end




-- Steering behavior specific auxiliary functions, shouldn't really be used elsewhere
C2DMatrix = Object:extend()
function C2DMatrix:init()
  self._11, self._12, self._13 = 0, 0, 0
  self._21, self._22, self._23 = 0, 0, 0
  self._31, self._32, self._33 = 0, 0, 0
  self:identity()
end


function C2DMatrix:multiply(other)
  local mat_temp = C2DMatrix()
  mat_temp._11 = (self._11 * other._11) + (self._12 * other._21) + (self._13 * other._31);
  mat_temp._12 = (self._11 * other._12) + (self._12 * other._22) + (self._13 * other._32);
  mat_temp._13 = (self._11 * other._13) + (self._12 * other._23) + (self._13 * other._33);
  mat_temp._21 = (self._21 * other._11) + (self._22 * other._21) + (self._23 * other._31);
  mat_temp._22 = (self._21 * other._12) + (self._22 * other._22) + (self._23 * other._32);
  mat_temp._23 = (self._21 * other._13) + (self._22 * other._23) + (self._23 * other._33);
  mat_temp._31 = (self._31 * other._11) + (self._32 * other._21) + (self._33 * other._31);
  mat_temp._32 = (self._31 * other._12) + (self._32 * other._22) + (self._33 * other._32);
  mat_temp._33 = (self._31 * other._13) + (self._32 * other._23) + (self._33 * other._33);
  self._11 = mat_temp._11; self._12 = mat_temp._12; self._13 = mat_temp._13
  self._21 = mat_temp._21; self._22 = mat_temp._22; self._23 = mat_temp._23
  self._31 = mat_temp._31; self._32 = mat_temp._32; self._33 = mat_temp._33
end


function C2DMatrix:identity()
  self._11, self._12, self._13 = 1, 0, 0
  self._21, self._22, self._23 = 0, 1, 0
  self._31, self._32, self._33 = 0, 0, 1
end


function C2DMatrix:transform_vector(point)
  local temp_x = (self._11 * point.x) + (self._21 * point.y) + (self._31)
  local temp_y = (self._12 * point.x) + (self._22 * point.y) + (self._32)
  point.x, point.y = temp_x, temp_y
end


function C2DMatrix:translate(x, y)
  local mat = C2DMatrix()
  mat._11 = 1; mat._12 = 0; mat._13 = 0;
  mat._21 = 0; mat._22 = 1; mat._23 = 0;
  mat._31 = x; mat._32 = y; mat._33 = 1;
  self:multiply(mat)
end


function C2DMatrix:scale(sx, sy)
    local mat = C2DMatrix()
    mat._11 = sx; mat._12 = 0;  mat._13 = 0;
    mat._21 = 0;  mat._22 = sy; mat._23 = 0;
    mat._31 = 0;  mat._32 = 0;  mat._33 = 1;
    self:multiply(mat)
end


function C2DMatrix:rotate(fwd, side)
    local mat = C2DMatrix()
    mat._11 = fwd.x;  mat._12 = fwd.y;  mat._13 = 0;
    mat._21 = side.x; mat._22 = side.y; mat._23 = 0;
    mat._31 = 0;      mat._32 = 0;      mat._33 = 1;
    self:multiply(mat)
end


function C2DMatrix:rotater(r)
    local mat = C2DMatrix()
    local sin = math.sin(r)
    local cos = math.cos(r)
    mat._11 =  cos;  mat._12 = sin;  mat._13 = 0;
    mat._21 = -sin;  mat._22 = cos;  mat._23 = 0;
    mat._31 = 0;     mat._32 = 0;    mat._33 = 1;
    self:multiply(mat)
end


steering = {}
function steering.point_to_world_space(point, heading, side, position)
  local trans_point = Vector(point.x, point.y)
  local mat_transform = C2DMatrix()
  mat_transform:rotate(heading, side)
  mat_transform:translate(position.x, position.y)
  mat_transform:transform_vector(trans_point)
  return trans_point
end


function steering.point_to_local_space(point, heading, side, position)
  local trans_point = Vector(point.x, point.y)
  local mat_transform = C2DMatrix()
  local tx, ty = -position:dot(heading), -position:dot(side)
  mat_transform._11 = heading.x; mat_transform._12 = side.x;
  mat_transform._21 = heading.y; mat_transform._22 = side.y;
  mat_transform._31 = tx;        mat_transform._32 = ty;
  mat_transform:transform_vector(trans_point)
  return trans_point
end


function steering.vector_to_world_space(v, heading, side)
  local trans_v = Vector(v.x, v.y)
  local mat_transform = C2DMatrix()
  mat_transform:rotate(heading, side)
  mat_transform:transform_vector(trans_v)
  return trans_v
end


function steering.rotate_vector_around_origin(v, r)
  local mat = C2DMatrix()
  mat:rotater(r)
  mat:transform_vector(v)
  return v
end
