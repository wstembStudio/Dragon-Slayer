

local Diamond = {}
Diamond.__index = Diamond
local ActiveDiamonds = {}
local Player = require("player")

function Diamond.new(x,y)
   local instance = setmetatable({}, Diamond)
   instance.x = x
   instance.y = y
   instance.scaleSize = 1
   instance.img = love.graphics.newImage("assets/smallDiamond.png")
   instance.width = instance.img:getWidth() *instance.scaleSize 
   instance.height = instance.img:getHeight() *instance.scaleSize 
   instance.scaleX = 1
   instance.randomTimeOffset = math.random(0, 100)
   instance.toBeRemoved = false

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.fixture:setSensor(true)
   table.insert(ActiveDiamonds, instance)
end

function Diamond:remove()
   for i,instance in ipairs(ActiveDiamonds) do
      if instance == self then
         Player:incrementDiamonds()
         self.physics.body:destroy()
         table.remove(ActiveDiamonds, i)
      end
   end
end

function Diamond.removeAll()
   for i,v in ipairs(ActiveDiamonds) do
      v.physics.body:destroy()
   end

   ActiveDiamonds = {}
end

function Diamond:update(dt)
   self:spin(dt)
   self:checkRemove()
end

function Diamond:checkRemove()
   if self.toBeRemoved then
      self:remove()
   end
end

function Diamond:spin(dt)
   self.scaleX = math.sin(love.timer.getTime() * 2 + self.randomTimeOffset)
end

function Diamond:draw()
   love.graphics.draw(self.img, self.x, self.y, 0, self.scaleSize*self.scaleX, self.scaleSize, self.width / 2, self.height / 2)
end

function Diamond.updateAll(dt)
   for i,instance in ipairs(ActiveDiamonds) do
      instance:update(dt)
   end
end

function Diamond.drawAll()
   for i,instance in ipairs(ActiveDiamonds) do
      instance:draw()
   end
end

function Diamond.beginContact(a, b, collision)
   for i,instance in ipairs(ActiveDiamonds) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            instance.toBeRemoved = true
            return true
         end
      end
   end
end

return Diamond