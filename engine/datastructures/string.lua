-- Returns the substring to the left of the first instance of the pattern passed in
-- a = 'assets/images/player_32.png'
-- a:left('/') -> 'assets'
function string:left(p)
  local i = self:find(p)
  if i then
    local out = self:sub(1, i-1)
    return out ~= "" and out
  end
end


-- Returns the substring to the right of the first instance of the pattern passed in
-- a = 'assets/images/player_32.png'
-- a:right('/') -> 'images/player_32.png'
function string:right(p)
  local _, j = self:find(p)
  if j then
    local out = self:sub(j+1)
    return out ~= "" and out
  end
end


-- Splits the string into words in a table according to the separator pattern passed in
-- paid_comment = 'This engine is really great!'
-- paid_comment:split('%s') -> {'This', 'engine', 'is', 'really', 'great!'}
function string:split(s)
  if not s then s = "%s" end
  local out = {}
  for str in self:gmatch("([^" .. s .. "]+)") do
    table.insert(out, str)
  end
  return out
end


-- Returns the character at a particular index
-- a = 'engine'
-- a:index(2) -> 'n'
-- a:index(3) -> 'g'
-- a:index(-1) -> 'e'
function string:index(i)
  return self:sub(i, i)
end


-- Returns the capitalized string
-- a = 'engine'
-- a:capitalize() -> 'Engine'
function string:capitalize()
  return self:gsub("^%l", string.upper)
end
