

local Door = {}
Door.__index = Door
local Player = require("player")

local ActiveDoors = {}

function Door.removeAll()
  for i,v in ipairs(ActiveDoors) do
    v.physics.body:destroy()
  end

  ActiveDoors = {}
end

function Door.new(x,y)
  local instance = setmetatable({}, Door)
  
  instance.x = x 
  instance.y = y 
  instance.r = 0
 
  instance.key = {current = 0, max = 3}
  
  instance.state = "close"
  instance.isTouch = false
  
  instance.animation = {timer = 0, rate = 0.5}
  instance.animation.close = love.graphics.newImage("assets/door/close/1.jpg")
  instance.animation.open = love.graphics.newImage("assets/door/open/1.jpg")
  instance.img = instance.animation.close
  
  instance.scaleSize = 0.130
  
  instance.width = instance.img:getWidth() * instance.scaleSize
  instance.height = instance.img:getHeight() * instance.scaleSize
  
  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, instance.x + instance.width/2, instance.y + instance.height/2, "static")
  instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  instance.physics.fixture:setSensor(true)
  table.insert(ActiveDoors, instance)
end

function Door:update(dt)
  self:open()
  self:animate()
  self:teleport()
end

function Door:remove()
  for i,instance in ipairs(ActiveDoors) do
    if instance == self then
      self.physics.body:destroy()
      table.remove(ActiveDoors, i)
    end
  end
end

function Door:increamentKeys(amount)
  self.key.current = self.key.current + amount
end

function Door:animate()
  if self.state == "close" then
    self.img = self.animation.close
  else
    self.img = self.animation.open
  end
end

function Door:open()
  if self.key.current >= self.key.max then
    self.state = "open"
  end
end

function Door:draw()
  love.graphics.draw(self.img, self.x, self.y, self.r, self.scaleSize, self.scaleSize, self.width / 2, self.height / 2)
  if self.state == "close" then
    love.graphics.print(self.key.current.."/"..self.key.max, self.x, self.y - self.width/2, 0, 0.5, 0.5)
  end
end

function Door.updateAll(dt)
  for i,instance in ipairs(ActiveDoors) do
    instance:update(dt)
  end
end

function Door.drawAll()
  for i,instance in ipairs(ActiveDoors) do
    instance:draw()
  end
end

function Door:teleport()
  local Map = require("map")
  if self.isTouch == true then
    if self.state == "open" then
      if love.keyboard.isDown("e") then
        Map:next()
      end
    end
  end
end

function Door.beginContact(a, b, collision)
  for i,instance in ipairs(ActiveDoors) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        instance:increamentKeys(Player.keys)
        Player:resetKey()
        instance.isTouch = true
        return true
      end
    end
  end
end

function Door.endContact(a, b, collision)
  for i,instance in ipairs(ActiveDoors) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        instance.isTouch = false
      end
    end
  end
end

return Door

