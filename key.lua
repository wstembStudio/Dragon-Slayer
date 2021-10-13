

local Key = {}
Key.__index = Key
local ActiveKeys = {}
local Player = require("player")

function Key.new(x,y)
   local instance = setmetatable({}, Key)
   
   instance.img = love.graphics.newImage("assets/key2.jpg")
   instance.width = instance.img:getWidth()
   instance.height = instance.img:getHeight()
   
   instance.x = x + instance.width/2
   instance.y = y + instance.height/2
   
   instance.scaleX = 1
   instance.randomTimeOffset = math.random(0, 100)
   instance.toBeRemoved = false

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.fixture:setSensor(true)
   table.insert(ActiveKeys, instance)
end

function Key:remove()
   for i,instance in ipairs(ActiveKeys) do
      if instance == self then
         self.physics.body:destroy()
         table.remove(ActiveKeys, i)
      end
   end
end

function Key.removeAll()
   for i,v in ipairs(ActiveKeys) do
      v.physics.body:destroy()
   end

   ActiveKeys = {}
end

function Key:update(dt)
   self:spin(dt)
   self:checkRemove()
end

function Key:checkRemove()
   if self.toBeRemoved then
      self:remove()
   end
end

function Key:spin(dt)
   self.scaleX = math.sin(love.timer.getTime() * 2 + self.randomTimeOffset)
end

function Key:draw()
   love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Key.updateAll(dt)
   for i,instance in ipairs(ActiveKeys) do
      instance:update(dt)
   end
end

function Key.drawAll()
   for i,instance in ipairs(ActiveKeys) do
      instance:draw()
   end
end

function Key.beginContact(a, b, collision)
   for i,instance in ipairs(ActiveKeys) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:increaseKeys()
            instance.toBeRemoved = true
            return true
         end
      end
   end
end

return Key
