-- The base random class.
-- You can create a new Random object with its own seed by passing it in on the constructor.
-- A global instance of this called "random" is available by default.
Random = Object:extend()
function Random:init(seed)
  seed = seed or os.time()
  self.generator = love.math.newRandomGenerator(seed)
end


-- Returns true at the given chance.
-- random:bool(50) -> returns true 50% of the time
-- random:bool(25) -> returns true 25% of the time
-- random:bool(3) -> returns true 3% of the time
function Random:bool(chance)
  if self.generator:random(1, 1000) < 10*(chance or 50) then
    return true
  end
end


-- Returns a random real number between the range.
-- random:float(0, 1) -> returns a random number between 0 and 1, like 0.432
-- random:float(-100, 45.2) -> returns a random number between -100 and 45.2, like -99.7
function Random:float(min, max)
  min = min or 0
  max = max or 1
  return (min > max and (self.generator:random()*(min - max) + max)) or (self.generator:random()*(max - min) + min)
end


-- Returns a random integer number between the range.
-- random:int(1, 7) -> returns a random integer between 1 and 7, like 4
-- random:int(-2, 0) -> returns a random integer between -2 and 0, like -2
function Random:int(min, max)
  return self.generator:random(min or 0, max or 1)
end


-- Returns a random value of the table.
-- a = {7, 6, 5, 4}
-- random:table(a) -> returns either 7, 6, 5 or 4 randomly
function Random:table(t)
  return t[self.generator:random(1, #t)]
end

-- Returns a random value of the table and also removes it.
-- a = {7, 6, 5, 4}
-- random:table_remove(a) -> returns either 7, 6, 5 or 4 randomly and removes it from the table as well
function Random:table_remove(t)
  return table.remove(t, self.generator:random(1, #t))
end


-- Returns a 1 at the given chance, otherwise returns -1.
-- random:sign(65) -> returns 1 65% of the time and -1 35% of the time
-- random:sign(20) -> returns 1 20% of the time and -1 80% of the time
function Random:sign(chance)
  if self.generator:random(1, 1000) < 10*(chance or 50) then return 1
  else return -1 end
end


-- Returns a random index at the given weights.
-- random:weighted_pick(50, 30, 20) -> will return 1 50% of the time, 2 30% of the time and 3 20% of the time
-- random:weighted_pick(10, 8, 2) -> will return 1 50% of the time, 2 40% of the time and 3 10% of the time
-- random:weighted_pick(2, 1) -> will return 1 66% of the time, will return 2 33% of the time
function Random:weighted_pick(...)
  local weights = {...}
  local total_weight = 0
  local pick = 0
  for _, weight in ipairs(weights) do total_weight = total_weight + weight end

  total_weight = self:float(0, total_weight)
  for i = 1, #weights do
    if total_weight < weights[i] then
      pick = i
      break
    end
    total_weight = total_weight - weights[i]
  end
  return pick
end


-- Returns a unique identifier.
function Random:uid()
  local fn = function(x)
    local r = self:int(1, 16) - 1
    r = (x == "x") and (r + 1) or (r % 4) + 9
    return ("0123456789abcdef"):sub(r, r)
  end
  return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end
