-- Copies the table deeply, including metatables
function table.copy(t)
  local t_type = type(t)
  local copy
  if t_type == "table" then
    copy = {}
    for k, v in next, t, nil do
      copy[table.copy(k)] = table.copy(v)
    end
    setmetatable(copy, table.copy(getmetatable(t)))
  else
    copy = t
  end
  return copy
end


-- Copies the table shallowly, meaning that tables inside the table will not be created anew, and only be referenced in the copy
function table.shallow_copy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return copy
end


-- t = {}
-- table.array(t, 5) -> {1, 2, 3, 4, 5}
function table.array(t, n)
  for i = 1, n do
    table.push(t, i)
  end
  return t
end

-- t = {"a", "b", "c", "d"}
-- table.get(t, 1) -> "a"
-- table.get(t, 1, 3) -> {"a", "b", "c"}
-- table.get(t, 2, -1) -> {"b", "c", "d"}
function table.get(t, i, j)
  if i < 0 then i = #t + i + 1 end
  if not j then return t[i] end
  if j < 0 then j = #t + j + 1 end
  if i == j then return t[i] end
  local out = {}
  for k = i, j, math.sign(j-i) do
    table.push(out, t[k])
  end
  return out
end


-- t = {"a", "b", "c", "d"}
-- table.set(t, 1, 1) -> {1, "b", "c", "d"}
-- table.set(t, 1, 3, 2) -> {2, 2, 2, "d"}
-- table.set(t, 2, -1, 3) -> {"a", 3, 3, 3}
function table.set(t, i, j, v)
  if i < 0 then i = #t + i + 1 end
  if not v then t[i] = j; return t end
  if j < 0 then j = #t + j + 1 end
  if i == j then t[i] = v; return t end
  for k = i, j, math.sign(j-i) do
    t[k] = v
  end
  return t
end


-- Returns the index of the first instance of value v
-- t = {4, 3, 2, 4, "a", 1, "a"}
-- table.index(t, 4) -> 1
-- table.index(t, "a") -> 5
function table.index(t, v)
  for i, u in ipairs(t) do
    if u == v then
      return i
    end
  end
end


-- Returns the last value of the table
-- t = {1, 2, 3, 4}
-- table.back(t) -> 4
function table.back(t)
  return t[#t]
end


-- Returns the first n values
-- t = {4, 3, 2, 1}
-- table.head(t) -> 4
-- table.head(t, 2) -> {4, 3}
-- If n is defined then it always returns a table, even with only 1 value.
function table.head(t, n)
  local out = {}
  for i = 1, (n or 1) do
    table.push(out, t[i])
  end
  if n then return out
  else
    if #out == 1 then return out[1]
    else return out end
  end
end


-- Returns the last n values
-- t = {5, 4, 3, 2, 1}
-- table.tail(t) -> 1
-- table.tail(t, 2) -> {2, 1}
-- If n is defined then it always returns a table, even with only 1 value.
function table.tail(t, n)
  local out = {}
  for i = #t-(n or #t-1)+1, #t do
    table.push(out, t[i])
  end
  if n then return out
  else
    if #out == 1 then return out[1]
    else return out end
  end
end


-- Inserts value at the end of the table
-- t = {1, 2}
-- table.push(t, "a") -> {1, 2, "a"}
function table.push(t, v)
  table.insert(t, v)
  return t
end


-- Removes the first n values and returns them as well as the modified table
-- t = {4, 3, 2, 1}
-- table.shift(t) -> 4, {3, 2, 1}
-- table.shift(t, 3) -> {4, 3, 2}, {1}
function table.shift(t, n)
  local out = {}
  for i = 1, (n or 1) do
    table.insert(out, table.remove(t, 1))
  end
  if #out == 1 then return out[1], t
  else return out, t end
end


-- Inserts values at the start of the table
-- t = {3, 4}
-- table.unshift(t, 1, 2) -> {1, 2, 3, 4}
function table.unshift(t, ...)
  for j, v in ipairs({...}) do
    table.insert(t, 1+j-1, v)
  end
  return t
end


-- Removes the last value and returns it as well as the modified table
-- t = {1, 2, 3, 4}
-- table.pop(t) -> 4, {1, 2, 3}
function table.pop(t)
  return table.remove(t, #t), t
end


-- Deletes all instances of value v
-- t = {1, 1, 2, 3, 2, 3, 4, 4}
-- table.delete(t, 1) -> {2, 3, 2, 3, 4, 4}
-- t = {{id = 1}, {id = 1}, {id = 2}}
-- table.delete(t, function(v) return v.id == 1 end) -> {{id = 2}}
function table.delete(t, v)
  if type(v) == 'function' then
    for i = #t, 1, -1 do
      if v(t[i]) then
        table.remove(t, i)
      end
    end
  else
    for i = #t, 1, -1 do
      if v == t[i] then
        table.remove(t, i)
      end
    end
  end
  return t
end


-- Deletes the elements in the given range and returns them as well as the modified table
-- t = {1, 2, 3}
-- table.slice(t, 1) -> 1, {2, 3}
-- table.slice(t, 2, -1) -> {2, 3}, 1
function table.slice(t, i, j)
  if i < 0 then i = #t + i + 1 end
  if not j then return t[i] end
  if j < 0 then j = #t + j + 1 end
  if i == j then return t[i] end
  local out = {}
  for k = j, i, -math.sign(j-i) do
    table.insert(out, table.remove(t, k))
  end
  if #out == 1 then return out[1], t
  else return table.reverse(out), t end
end


-- Removes duplicates
-- t = {1, 1, 2, 2, 3, 3}
-- table.unify(t) -> {1, 2, 3}
-- t = {{id = 1}, {id = 1}, {id = 2}}
-- table.unify(t, function(v) return v.id end) -> {{id = 1}, {id = 2}}
function table.unify(t, f)
  if not f then f = function(v) return v end end
  local seen = {}
  for i = #t, 1, -1 do
    if not seen[f(t[i])] then
      seen[f(t[i])] = true
    else
      table.remove(t, i)
    end
  end
  return t
end


-- Counts the number of elements in the table
-- t = {1, 1, 5, 5, 4, 1, 3, 2, 0, 9, 8, 5, 1, 5, 5, 4, 6}
-- table.count(t, 1) -> 4
-- table.count(t, 5) -> 5
-- table.count(t, 6) -> 1
-- table.count(t, 4) -> 2
function table.count(t, v)
  local n = 0
  for i = 1, #t do
    if t[i] == v then
      n = n + 1
    end
  end
  return n
end


-- Applies function f to all table elements and replaces each element for the value returned by f
function table.map(t, f, ...)
  for k, v in ipairs(t) do
    t[k] = f(v, k, ...)
  end
  return t
end


-- Applies function f to all table elements resulting in a single output value
-- t = {1, 2, 3}
-- table.reduce(t, function(memo, v) return memo + v end) -> 6
-- t = {'a', 'b', 'c'}
-- table.reduce(t, function(memo, v) return memo .. v end) -> 'abc'
-- t = {{id = 1}, {id = 2}, {id = 3}}
-- table.reduce(t, function(memo, v) return memo + v.id end, 0) -> 6
-- The memo variable starts as the first argument in the array, but sometimes, as in the last example, that's not the desired functionality.
-- For those cases the third argument comes in handy and can be used to set the initial value of memo directly.
function table.reduce(t, f, dv, ...)
  local memo = dv or t[1]
  if dv then
    for i = 1, #t do
      memo = f(memo, t[i], i, ...)
    end
  else
    for i = 2, #t do
      memo = f(memo, t[i], i, ...)
    end
  end
  return memo
end


-- Applies function f to all array elements without changing the array
function table.foreach(t, f, ...)
  for k, v in ipairs(t) do
    f(v, k, ...)
  end
  return t
end


-- Applies function f to all array elements and adds the results to a new array
function table.foreachn(t, f, ...)
  local out = {}
  for k, v in ipairs(t) do
    table.insert(out, f(v, k, ...))
  end
  return out
end


-- Applies filter function f which removes all elements that pass the filter and returns them as well as the modified table
-- t = {1, 2, 3, 4}
-- table.reject(t, function(v) return v >= 3 end) -> {3, 4}, {1, 2}
-- table.reject(t, function(v) return v == 1 end) -> 1, {2, 3, 4}
function table.reject(t, f, ...)
  local out = {}
  for i = #t, 1, -1 do
    if f(t[i], i, ...) then
      table.insert(out, table.remove(t, i))
    end
  end
  if #out == 1 then return out[1], t
  else return table.reverse(out), t end
end


-- Applies filter function f which collects all elements that pass the filter and returns them; the original table is not modified
-- t = {1, 2, 3, 4}
-- table.select(t, function(v) return v >= 3 end) -> {3, 4}
-- table.select(t, function(v) return v == 1 end) -> 1
function table.select(t, f, ...)
  local out = {}
  for i = 1, #t do
    if f(t[i], i, ...) then
      table.insert(out, t[i])
    end
  end
  return out
end


-- Returns true if any values in the table pass the test
function table.any(t, f, ...)
  for i, v in ipairs(t) do
    if f(v, i, ...) then
      return true
    end
  end
end


-- Returns true if all values in the table pass the test
function table.all(t, f, ...)
  for i, v in ipairs(t) do
    if not f(v, i, ...) then
      return false
    end
  end
  return true
end


-- Check if table contains value v and return its index
-- If value v is a function instead then it checks according to the check performed by that function
-- t = {4, 3, 2, 1}
-- table.contains(t, 4) -> 1
-- t = {{id = 4}, {id = 3}, {id = 2}, {id = 1}}
-- table.contains(t, function(v) return v.id == 3 end) -> 2
function table.contains(t, v)
  if type(v) == "function" then
    for i, u in ipairs(t) do
      if v(u) then return i end
    end
  else
    for i, u in ipairs(t) do
      if u == v then return i end
    end
  end
end


-- t = {{1, 2}, {3, {4, 5}}, {6, 7}, 8}
-- table.flatten(t) -> {1, 2, 3, 4, 5, 6, 7, 8}
-- table.flatten(t, true) -> {1, 2, 3, {4, 5}, 6, 7, 8}
function table.flatten(t, shallow)
  local out = {}
  local u
  for k, v in ipairs(t) do
    if type(v) == "table" and getmetatable(t) == nil then
      u = shallow and v or table.flatten(v)
      for _, x in ipairs(u) do
        table.insert(out, x)
      end
    else
      table.insert(out, v)
    end
  end
  return out
end


-- t = {1, 2, 3, 4}
-- table.tostring(t) -> '{[1] = 1, [2] = 2, [3] = 3, [4] = 4}'
function table.tostring(t)
  if type(t) == "table" then
    local str = "{"
    for k, v in pairs(t) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      str = str .. "[" .. k .. "] = " .. table.tostring(v) .. ", "
    end
    if str ~= "{" then return str:sub(1, -3) .. "}"
    else return str .. "}" end
  elseif type(t) == "string" then
    return '"' .. tostring(t) .. '"'
  else return tostring(t) end
end


-- Returns the first n values, same as head
-- t = {4, 3, 2, 1}
-- table.first(t) -> 4
-- table.first(t, 2) -> {4, 3}
function table.first(t, n)
  if n == 1 then return t[1] end
  local out = {}
  for i = 1, (n or 1) do
    table.push(out, t[i])
  end
  if #out == 1 then return out[1]
  else return out end
end


function table.first2(t, n)
  if n == 1 then return {t[1]} end
  local out = {}
  for i = 1, (n or 1) do
    table.push(out, t[i])
  end
  return out
end


-- Returns the last n values, same as tail
-- t = {4, 3, 2, 1}
-- table.last(t) -> 1
-- table.last(t, 2) -> {2, 1}
function table.last(t, n)
  if n == 1 then return t[#t] end
  local out = {}
  for i = #t-n+1, #t do
    table.push(out, t[i])
  end
  if #out == 1 then return out[1]
  else return out end
end


-- t = {"a", "b", "c", "d"}
-- table.reverse(t) -> {"d", "c", "b", "a"}
-- table.reverse(t, 2, 3) -> {"a", "c", "b", "d"}
-- table.reverse(t, 2, -1) -> {"a", "d", "c", "b"}
function table.reverse(t, i, j)
  if not i then i = 1 end
  if i < 0 then i = #t + i + 1 end
  if not j then j = #t end
  if j < 0 then j = #t + j + 1 end
  if i == j then return t end
  for k = 0, (j-i+1)/2-1, math.sign(j-i) do
    t[i+k], t[j-k] = t[j-k], t[i+k]
  end
  return t
end


-- Shifts the table to the right n times, the last value is warped over to become the first value
-- t = {1, 2, 3, 4}
-- table.rotate(t) -> {4, 1, 2, 3}
-- table.rotate(t, 2) -> {3, 4, 1, 2}
function table.rotate(t, n)
  if not n then n = 1 end
  if n < 0 then n = #t + n end
  t = table.reverse(t, 1, #t)
  t = table.reverse(t, 1, #t-n)
  t = table.reverse(t, #t-n+1, #t)
  return t
end


-- Returns a random value from the table
-- t = {1, 2, 3}
-- table.random(t) -> 1 or 2 or 3 randomly
function table.random(t)
  return t[love.math.random(1, #t)]
end


-- t = {1, 2, 3, 4, 5}
-- table.shuffle(t) -> {3, 4, 1, 2, 5}
-- table.shuttle(t) -> {2, 5, 1, 4, 3}
-- table.shuffle(t) -> {5, 4, 1, 3, 2}
function table.shuffle(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end


-- Merges both tables based on their indexes, if the second table has values in the same indexes as the first table then those will overwrite the first values.
-- t1 = {1, 2, ['a'] = 3, ['b'] = function() end}
-- t2 = {nil, 8, 4, 5, ['a'] = 8}
-- table.merge(t1, t2) -> {1, 2, 8, 4, 5, ['a'] = 8, ['b'] = function() end}
function table.merge(t1, t2)
  local out = {}
  for k, v in pairs(t1) do out[k] = v end
  for k, v in pairs(t2) do out[k] = v end
  return out
end
