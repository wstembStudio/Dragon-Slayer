

local Kunai = {}
Kunai.__index = Kunai

local ActiveKunais = {}

function Kunai.removeAll()
  for i,v in ipairs(ActiveKunais) do
    v.physics.body:destroy()
  end

  ActiveKunais = {}
end

function Kunai:direction(x)
  local Player = require("player")
  local mx = love.mouse.getX()
  if Player.direction == "right" then
    speed = 600
  else
    speed = -600
  end
  return speed
end

function Kunai:new( x, y, endX, endY)
  local instance = setmetatable({}, Kunai)
  instance.x = x
  instance.y = y
  instance.r = 0
  
  self.xVel = 0
  self.yVel = 0

  instance.img = love.graphics.newImage("assets/Kunai.png")

  instance.sizeScale = 0.12
  instance.width = 32 * instance.sizeScale
  instance.height = 160 * instance.sizeScale
  
  instance.vx = Kunai:direction(instance.x)
  instance.vy = 0
  instance.vr = 10
  
  instance.damage = 1

  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
  instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  instance.physics.fixture:setSensor(true)
  instance.physics.body:setGravityScale(0)
  table.insert(ActiveKunais, instance)
end

function Kunai:remove()
  for i,instance in ipairs(ActiveKunais) do
    if instance == self then
      self.physics.body:destroy()
      table.remove(ActiveKunais, i)
    end
  end
end

function Kunai:update(dt)
  self:syncPhysics()
  self:rotate(dt)
  self:dealDamage()
end

function Kunai:syncPhysics()
  self.x, self.y = self.physics.body:getPosition()
  self.physics.body:setLinearVelocity(self.vx, self.vy)
end

function Kunai:rotate(dt)
  self.r = self.r + self.vr *dt
end

function Kunai:draw()
  love.graphics.draw(self.img, self.x, self.y, self.r, self.sizeScale, self.sizeScale, self.width / 2, self.height / 2)
end

function Kunai.updateAll(dt)
  for i,instance in ipairs(ActiveKunais) do
    instance:update(dt)
  end
end

function Kunai.drawAll()
  for i,instance in ipairs(ActiveKunais) do
    instance:draw()
  end
end

function Kunai:dealDamage()
  local Enemy = require("enemy")
  local enemyTable = Enemy:getEnemyTable()
  for i, enemy in ipairs(enemyTable) do
    local distanceX = math.abs(enemy.x - self.x) <= enemy.width/2 + self.width/2
    local distanceY = math.abs(enemy.y - self.y) <= enemy.height/2 + self.height/2
    if distanceX and distanceY then
      enemy:takeDamage(self.damage)
      self:remove()
    end
  end
end

function Kunai.beginContact(a, b, collision)
  local Player = require("player")
  for i,instance in ipairs(ActiveKunais) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        return true
      end
      instance:remove()
    end
  end
end

return Kunai