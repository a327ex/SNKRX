-- A Spring class. This is extremely useful for juicing things up.
-- See this article https://github.com/a327ex/blog/issues/60 for more details.
-- The argument passed in are: the initial value of the spring, its stiffness and damping.
Spring = Object:extend()
function Spring:init(x, k, d)
  self.x = x or 0
  self.k = k or 100
  self.d = d or 10
  self.target_x = self.x
  self.v = 0
end


function Spring:update(dt)
  local a = -self.k*(self.x - self.target_x) - self.d*self.v
  self.v = self.v + a*dt
  self.x = self.x + self.v*dt
end


-- Pull the spring with a certain amount of force. This force should be related to the initial value you set to the spring.
function Spring:pull(f, k, d)
  if k then self.k = k end
  if d then self.d = d end
  self.x = self.x + f
end


-- Animates the spring such that it reaches the target value in a smoothy springy motion.
-- Unlike pull, which tugs on the spring so that it bounces around the anchor, this changes that anchor itself.
function Spring:animate(x, k, d)
  if k then self.k = k end
  if d then self.d = d end
  self.target_x = x
end




--[[
NSpring = Object:extend()


function NSpring:new(x, z, o)
  self.x = x or 0
  self.z = z or 0.5
  self.o = o or 2*math.pi
  self.target_x = self.x
  self.v = 0
end


function NSpring:update(dt)
  local f = 1 + 2*dt*self.z*self.o
  local oo = self.o*self.o
  local hoo = dt*oo
  local hhoo = dt*hoo
  local det_inv = 1/(f+hhoo)
  local det_x = f*self.x + dt*self.v + hhoo*self.target_x
  local det_v = self.v + hoo*(self.target_x - self.x)
  self.x = det_x*det_inv
  self.v = det_v*det_inv
end


function NSpring:animate(target_x, pd, td)
  self.z = math.log(pd)/(self.o*td)
  self.target_x = target_x
end
]]--
