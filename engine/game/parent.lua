-- This useful to add to objects that need to have some kind of relationship with their parents.
-- Call the appropriate function in the object's update function every frame.
-- The game object must have a .parent attribute defined and pointing to another game object.
Parent = Object:extend()


-- Follows the parent's transform exclusively.
-- This means that if the parent dies the entity also dies.
-- The .parent attribute is niled on death.
function Parent:follow_parent_exclusively()
  if self.parent and self.parent.dead then
    self.parent = nil
    self.dead = true
    return
  end
  self.x, self.y = self.parent.x, self.parent.y
  self.r = self.parent.r
  self.sx, self.sy = self.parent.sx, self.parent.sy
end
