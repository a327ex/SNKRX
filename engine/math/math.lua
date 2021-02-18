-- Returns the 2D coordinates of a given index with a grid of a given width
-- math.index_to_coordinates(11, 10) -> 1, 2
-- math.index_to_coordinates(2, 4) -> 2, 1
-- math.index_to_coordinates(17, 7) -> 3, 3
-- math.index_to_coordinates(17, 4) -> 1, 5
-- math.index_to_coordinates(4, 4) -> 4, 1
function math.index_to_coordinates(n, w)
  local i, j = n % w, math.ceil(n/w)
  if i == 0 then i = w end
  return i, j
end


-- Returns the 1D index of the given 2D coordinates with a grid of a given width
-- math.coordinates_to_index(1, 2, 10) -> 11
-- math.coordinates_to_index(2, 1, 4) -> 2
-- math.coordinates_to_index(3, 3, 7) -> 17
-- math.coordinates_to_index(1, 5, 4) -> 17
-- math.coordinates_to_index(4, 1, 4) -> 4
function math.coordinates_to_index(i, j, w)
  return i + (j-1)*w
end


-- Returns rectangle vertices based on top-left and bottom-right coordinates
-- math.to_rectangle_vertices(0, 0, 40, 40) -> vertices for a rectangle centered on 20, 20
function math.to_rectangle_vertices(x1, y1, x2, y2)
  return {x1, y1, x2, y1, x2, y2, x1, y2}
end


-- Rotates the point by r radians with ox, oy as pivot.
-- x, y = math.rotate_point(player.x, player.y, math.pi/4)
function math.rotate_point(x, y, r, ox, oy)
  return x*math.cos(r) - y*math.sin(r) + ox - ox*math.cos(r) + oy*math.sin(r), x*math.sin(r) + y*math.cos(r) + oy - oy*math.cos(r) - ox*math.sin(r)
end


-- Scales the point by sx, sy with ox, oy as pivot.
-- x, y = math.scale_point(player.x, player.y, 2, 2, player.x - player.w/2, player.y - player.h/2)
function math.scale_point(x, y, sx, sy, ox, oy)
  return x*sx + ox - ox*sx, y*sy + oy - oy*sy
end


-- Rotates and scales the point by r radians and sx, sy with ox, oy as pivot.
-- x, y = math.rotate_scale_point(player.x, player.y, math.pi/4, 2, 2, player.x - player.w/2, player.y - player.h/2)
function math.rotate_scale_point(x, y, r, sx, sy, ox, oy)
  local rx, ry = math.rotate_point(x, y, r, ox, oy)
  return math.scale_point(rx, ry, sx, sy, ox, oy)
end


-- Returns -1 if the angle is on either left quadrants and 1 if its on either right quadrants.
-- h = math.angle_to_horizontal(math.pi/4) -> 1
-- h = math.angle_to_horizontal(-math.pi/4) -> 1
-- h = math.angle_to_horizontal(-3*math.pi/4) -> -1
-- h = math.angle_to_horizontal(3*math.pi/4) -> -1
function math.angle_to_horizontal(r)
  if r > math.pi/2 or r < -math.pi/2 then return -1
  elseif r <= math.pi/2 and r >= -math.pi/2 then return 1 end
end


-- Returns -1 if the angle is on either bottom quadrants and 1 if its on either top quadrants.
-- h = math.angle_to_horizontal(math.pi/4) -> -1
-- h = math.angle_to_horizontal(-math.pi/4) -> 1
-- h = math.angle_to_horizontal(-3*math.pi/4) -> 1
-- h = math.angle_to_horizontal(3*math.pi/4) -> -1
function math.angle_to_vertical(r)
  if r > 0 and r < math.pi then return -1
  elseif r <= 0 and r >= -math.pi then return 1 end
end


-- Snaps the value v to the closest number divisible by x and then centers it. This is useful when doing calculations for grids where each cell would be of size x, for instance.
-- v = math.snap_center(12, 16) -> 8
-- v = math.snap_center(17, 16) -> 24
-- v = math.snap_center(12, 12) -> 6
-- v = math.snap_center(13, 12) -> 18
function math.snap_center(v, x)
  return math.ceil(v/x)*x - x/2
end


-- Returns the squared distance between both points.
-- d = math.distance(player.x, player.y, enemy.x, enemy)
function math.distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end


-- Loops value t such that is never higher than length and never lower than 0.
-- v = math.loop(3, 2.5) -> 0.5
-- v = math.loop(3*math.pi, 2*math.pi) -> math.pi
function math.loop(t, length)
  return math.clamp(t-math.floor(t/length)*length, 0, length)
end


-- Clamps the value to between 0 and 1.
-- v = math.clamp01(-0.1) -> 0
-- v = math.clamp01(1.1) -> 1
function math.clamp01(v)
  if v < 0 then return 0
  elseif v > 1 then return 1
  else return v end
end


-- Rounds the number n to p digits of precision.
-- n = math.round(10.94, 1) -> 10.9
-- n = math.round(45.321, 0) -> 45
-- n = math.round(101.9157289403, 5) -> 101.91572
function math.round(n, p)
  local m = 10^(p or 0)
  return math.floor(n*m+0.5)/m
end


-- Floors value v to the closest number divisible by x.
-- v = math.snap(15, 16) -> 0
-- v = math.snap(17, 16) -> 16
-- v = math.snap(13, 4) -> 12
function math.snap(v, x)
  return math.round(v/x, 0)*x
end


-- Clamps value v between min and max.
-- v = math.clamp(-4, 0, 10) -> 0
-- v = math.clamp(83, 0, 10) -> 10
-- v = math.clamp(0, -10, -4) -> -4
function math.clamp(v, min, max)
  return math.min(math.max(v, min), max)
end


-- Returns the squared length of x, y.
-- l = math.length(x, y)
function math.length(x, y)
  return math.sqrt(x*x + y*y)
end


-- Returns the normalized values of x, y.
-- nx, ny = math.normalize(x, y)
function math.normalize(x, y)
  if math.abs(x) < 0.0001 and math.abs(y) < 0.0001 then return x, y end
  local l = math.length(x, y)
  return x/l, y/l
end


-- Returns the sign of value v.
-- s = math.sign(10) -> 1
-- s = math.sign(-10) -> -1
-- s = math.sign(0) -> 0 
function math.sign(v)
  if v > 0 then return 1
  elseif v < 0 then return -1
  else return 0 end
end


-- Returns the angle between point x, y and point px, py.
-- r = math.angle(player.x, player.y, enemy.x, enemy)
function math.angle(x, y, px, py)
  return math.atan2(py - y, px - x)
end


-- Remaps value v using its previous range of old_min, old_max into the new range new_min, new_max.
-- v = math.remap(10, 0, 20, 0, 1) -> 0.5 because 10 is 50% of 0, 20 and thus 0.5 is 50% of 0, 1
-- v = math.remap(3, 0, 3, 0, 100) -> 100
-- v = math.remap(2.5, -5, 5, -100, 100) -> 50
function math.remap(v, old_min, old_max, new_min, new_max)
  return ((v - old_min)/(old_max - old_min))*(new_max - new_min) + new_min
end


-- TODO: fix this since it doesn't work properly for some reason
-- Lerp corrected for usage with delta time, see more here https://www.construct.net/en/blogs/ashleys-blog-2/using-lerp-delta-time-924
-- f is a value between 0 and 1 that corresponds to how much of the distance between src and dst will be covered per second, regardless of frame rate.
-- math.lerp_dt(0.25, dt, self.x, self.x + 100) -> will cover 75% of the distance between self.x and self.x + 100 per second
function math.lerp_dt(f, dt, src, dst)
  return math.lerp((1-f^dt), src, dst)
end


-- Same as math.lerp_angle except correted for usage with delta time.
-- math.lerp_angle_dt(0.1, dt, enemy.r, enemy:angle_to_object(player)) -> will cover 90% of the distance between enemy.r and and the enemy's angle to the player per second
function math.lerp_angle_dt(f, dt, src, dst)
  return math.lerp_angle((1-f^dt), src, dst)
end


-- Lerps src to dst with lerp value.
-- v = math.lerp(0.2, self.x, self.x + 100)
function math.lerp(value, src, dst)
  return src*(1 - value) + dst*value
end

-- Lerps the src angle towards dst using value as the lerp amount.
-- enemy.r = math.lerp_angle(0.2, enemy.r, enemy:angle_to_object(player))
function math.lerp_angle(value, src, dst)
  local dt = math.loop((dst-src), 2*math.pi)
  if dt > math.pi then dt = dt - 2*math.pi end
  return src + dt*math.clamp01(value)
end




local PI = math.pi
local PI2 = math.pi/2
local LN2 = math.log(2)
local LN210 = 10*math.log(2)




function math.linear(t)
  return t
end


function math.sine_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return 1 - math.cos(t*PI2) end
end


function math.sine_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return math.sin(t*PI2) end
end


function math.sine_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return -0.5*(math.cos(t*PI) - 1) end
end


function math.sine_out_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  elseif t < 0.5 then return 0.5*math.sin((t*2)*PI2)
  else return -0.5*math.cos((t*2-1)*PI2) + 1 end
end


function math.quad_in(t)
  return t*t
end


function math.quad_out(t)
  return -t*(t-2)
end


function math.quad_in_out(t)
  if t < 0.5 then
    return 2*t*t
  else
    t = t - 1
    return -2*t*t + 1
  end
end


function math.quad_out_in(t)
  if t < 0.5 then
    t = t*2
    return -0.5*t*(t-2)
  else
    t = t*2 - 1
    return 0.5*t*t + 0.5
  end
end


function math.cubic_in(t)
  return t*t*t
end

function math.cubic_out(t)
  t = t - 1
  return t*t*t + 1
end


function math.cubic_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t
  else
    t = t - 2
    return 0.5*(t*t*t + 2)
  end
end


function math.cubic_out_in(t)
  t = t*2 - 1
  return 0.5*(t*t*t + 1)
end


function math.quart_in(t)
  return t*t*t*t
end


function math.quart_out(t)
  t = t - 1
  t = t*t
  return 1 - t*t
end


function math.quart_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t*t
  else
    t = t - 2
    t = t*t
    return -0.5*(t*t - 2)
  end
end


function math.quart_out_in(t)
  if t < 0.5 then
    t = t*2 - 1
    t = t*t
    return -0.5*t*t + 0.5
  else
    t = t*2 - 1
    t = t*t
    return 0.5*t*t + 0.5
  end
end


function math.quint_in(t)
  return t*t*t*t*t
end


function math.quint_out(t)
  t = t - 1
  return t*t*t*t*t + 1
end


function math.quint_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t*t*t
  else
    t = t - 2
    return 0.5*t*t*t*t*t + 1
  end
end


function math.quint_out_in(t)
  t = t*2 - 1
  return 0.5*(t*t*t*t*t + 1)
end


function math.expo_in(t)
  if t == 0 then return 0
  else return math.exp(LN210*(t - 1)) end
end


function math.expo_out(t)
  if t == 1 then return 1
  else return 1 - math.exp(-LN210*t) end
end


function math.expo_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1 end
  t = t*2
  if t < 1 then return 0.5*math.exp(LN210*(t - 1))
  else return 0.5*(2 - math.exp(-LN210*(t - 1))) end
end


function math.expo_out_in(t)
  if t < 0.5 then return 0.5*(1 - math.exp(-20*LN2*t))
  elseif t == 0.5 then return 0.5
  else return 0.5*(math.exp(20*LN2*(t - 1)) + 1) end
end


function math.circ_in(t)
  if t < -1 or t > 1 then return 0
  else return 1 - math.sqrt(1 - t*t) end
end


function math.circ_out(t)
  if t < 0 or t > 2 then return 0
  else return math.sqrt(t*(2 - t)) end
end


function math.circ_in_out(t)
  if t < -0.5 or t > 1.5 then return 0.5
  else
    t = t*2
    if t < 1 then return -0.5*(math.sqrt(1 - t*t) - 1)
    else
      t = t - 2
      return 0.5*(math.sqrt(1 - t*t) + 1)
    end
  end
end


function math.circ_out_in(t)
  if t < 0 then return 0
  elseif t > 1 then return 1
  elseif t < 0.5 then
    t = t*2 - 1
    return 0.5*math.sqrt(1 - t*t)
  else
    t = t*2 - 1
    return -0.5*((math.sqrt(1 - t*t) - 1) - 1)
  end
end


function math.bounce_in(t)
  t = 1 - t
  if t < 1/2.75 then return 1 - (7.5625*t*t)
  elseif t < 2/2.75 then
    t = t - 1.5/2.75
    return 1 - (7.5625*t*t + 0.75)
  elseif t < 2.5/2.75 then
    t = t - 2.25/2.75
    return 1 - (7.5625*t*t + 0.9375)
  else
    t = t - 2.625/2.75
    return 1 - (7.5625*t*t + 0.984375)
  end
end


function math.bounce_out(t)
  if t < 1/2.75 then return 7.5625*t*t
  elseif t < 2/2.75 then
    t = t - 1.5/2.75
    return 7.5625*t*t + 0.75
  elseif t < 2.5/2.75 then
    t = t - 2.25/2.75
    return 7.5625*t*t + 0.9375
  else
    t = t - 2.625/2.75
    return 7.5625*t*t + 0.984375
  end
end


function math.bounce_in_out(t)
  if t < 0.5 then
    t = 1 - t*2
    if t < 1/2.75 then return (1 - (7.5625*t*t))*0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (1 - (7.5625*t*t + 0.75))*0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (1 - (7.5625*t*t + 0.9375))*0.5
    else
      t = t - 2.625/2.75
      return (1 - (7.5625*t*t + 0.984375))*0.5
    end
  else
    t = t*2 - 1
    if t < 1/2.75 then return (7.5625*t*t)*0.5 + 0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (7.5625*t*t + 0.75)*0.5 + 0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (7.5625*t*t + 0.9375)*0.5 + 0.5
    else
      t = t - 2.625/2.75
      return (7.5625*t*t + 0.984375)*0.5 + 0.5
    end
  end
end


function math.bounce_out_in(t)
  if t < 0.5 then
    t = t*2
    if t < 1/2.75 then return (7.5625*t*t)*0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (7.5625*t*t + 0.75)*0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (7.5625*t*t + 0.9375)*0.5
    else
      t = t - 2.625/2.75
      return (7.5625*t*t + 0.984375)*0.5
    end
  else
    t = 1 - (t*2 - 1)
    if t < 1/2.75 then return 0.5 - (7.5625*t*t)*0.5 + 0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return 0.5 - (7.5625*t*t + 0.75)*0.5 + 0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return 0.5 - (7.5625*t*t + 0.9375)*0.5 + 0.5
    else
      t = t - 2.625/2.75
      return 0.5 - (7.5625*t*t + 0.984375)*0.5 + 0.5
    end
  end
end


local overshoot = 1.70158

function math.back_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return t*t*((overshoot + 1)*t - overshoot) end
end


function math.back_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t - 1
    return t*t*((overshoot + 1)*t + overshoot) + 1
  end
end


function math.back_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t*2
    if t < 1 then return 0.5*(t*t*(((overshoot*1.525) + 1)*t - overshoot*1.525))
    else
      t = t - 2
      return 0.5*(t*t*(((overshoot*1.525) + 1)*t + overshoot*1.525) + 2)
    end
  end
end


function math.back_out_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  elseif t < 0.5 then
    t = t*2 - 1
    return 0.5*(t*t*((overshoot + 1)*t + overshoot) + 1)
  else
    t = t*2 - 1
    return 0.5*t*t*((overshoot + 1)*t - overshoot) + 0.5
  end
end


local amplitude = 1
local period = 0.0003

function math.elastic_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t - 1
    return -(amplitude*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period))
  end
end


function math.elastic_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period) + 1 end
end


function math.elastic_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t*2
    if t < 1 then
      t = t - 1
      return -0.5*(amplitude*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period))
    else
      t = t - 1
      return amplitude*math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period)*0.5 + 1
    end
  end
end


function math.elastic_out_in(t)
  if t < 0.5 then
    t = t*2
    if t == 0 then return 0
    else return (amplitude/2)*math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period) + 0.5 end
  else
    if t == 0.5 then return 0.5
    elseif t == 1 then return 1
    else
      t = t*2 - 1
      t = t - 1
      return -((amplitude/2)*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period)) + 0.5
    end
  end
end
