

local Bouncer = {}
Bouncer.__index = Bouncer

local ActiveBouncer = {}
local Player = require("player")

function Bouncer.removeAll()
  for i,v in ipairs(ActiveBouncer) do
    v.physics.body:destroy()
  end

  ActiveBouncer = {}
end

function Bouncer.new(x,y)
  local instance = setmetatable({}, Bouncer)
  
  instance.img = love.graphics.newImage("assets/bouncer.png")
  instance.width = instance.img:getWidth() 
  instance.height = instance.img:getHeight()
  
  instance.x = x + instance.width/2
  instance.y = y + instance.height/2 

  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
  instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  instance.physics.fixture:setSensor(true)
  table.insert(ActiveBouncer, instance)
end

function Bouncer:update(dt)
  
end

function Bouncer:draw()
  love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

function Bouncer.updateAll(dt)
  for i,instance in ipairs(ActiveBouncer) do
    instance:update(dt)
  end
end

function Bouncer.drawAll()
  for i,instance in ipairs(ActiveBouncer) do
    instance:draw()
  end
end

function Bouncer.beginContact(a, b, collision)
  for i,instance in ipairs(ActiveBouncer) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        Player:bounce()
        return true
      end
    end
  end
end

return Bouncer