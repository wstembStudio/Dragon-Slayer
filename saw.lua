

local Saw = {}
Saw.__index = Saw



local ActiveSaws = {}
local Player = require("player")

function Saw.removeAll()
  for i,v in ipairs(ActiveSaws) do
    v.physics.body:destroy()
  end

  ActiveSaws = {}
end

function Saw.new(x,y)
  local instance = setmetatable({}, Saw)
  instance.rotationSpeed = 5

  instance.img = love.graphics.newImage("assets/smallSaw.png")
  instance.width = instance.img:getWidth() 
  instance.height = instance.img:getHeight() 
  instance.size = instance.img:getWidth() /2
  
  instance.x = x + instance.width/2
  instance.y = y + instance.height/2
  instance.r = 0

  instance.damage = 1

  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
  instance.physics.shape = love.physics.newCircleShape(instance.size)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  table.insert(ActiveSaws, instance)
end

function Saw:update(dt)
  self:spin(dt)
end

function Saw:spin(dt)
  self.r = self.r + self.rotationSpeed *dt
end

function Saw:draw()
  love.graphics.draw(self.img, self.x, self.y, self.r, 1, 1, self.width / 2, self.height / 2)
end

function Saw.updateAll(dt)
  for i,instance in ipairs(ActiveSaws) do
    instance:update(dt)
  end
end

function Saw.drawAll()
  for i,instance in ipairs(ActiveSaws) do
    instance:draw()
  end
end

function Saw.beginContact(a, b, collision)
  for i,instance in ipairs(ActiveSaws) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        Player:takeDamage(instance.damage)
      end
    end
  end
end

return Saw