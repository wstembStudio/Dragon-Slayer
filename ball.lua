

local Ball = {}
Ball.__index = Ball

local ActiveBalls = {}
local Player = require("player")

function Ball.removeAll()
  for i,v in ipairs(ActiveBalls) do
    v.physics.body:destroy()
  end

  ActiveBalls = {}
end

function Ball.new(x,y)
  local instance = setmetatable({}, Ball)
  instance.img = love.graphics.newImage("assets/ball.png")
  instance.width = instance.img:getWidth() 
  instance.height = instance.img:getHeight() 
  instance.size = instance.img:getWidth() /2
  
  instance.x = x + instance.width/2
  instance.y = y + instance.height/2
  instance.r = 0

  instance.damage = 1

  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
  instance.physics.shape = love.physics.newCircleShape(instance.size)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  instance.physics.body:setMass(1000)
  table.insert(ActiveBalls, instance)
end

function Ball:syncPhysics()
  self.x, self.y = self.physics.body:getPosition()
  self.r = self.physics.body:getAngle()
end

function Ball:update(dt)
  self:syncPhysics()
end

function Ball:draw()
  love.graphics.draw(self.img, self.x, self.y, self.r, 1, 1, self.width / 2, self.height / 2)
end

function Ball.updateAll(dt)
  for i,instance in ipairs(ActiveBalls) do
    instance:update(dt)
  end
end

function Ball.drawAll()
  for i,instance in ipairs(ActiveBalls) do
    instance:draw()
  end
end

function Ball.beginContact(a, b, collision)
  for i,instance in ipairs(ActiveBalls) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        Player:takeDamage(instance.damage)
      end
    end
  end
end

return Ball