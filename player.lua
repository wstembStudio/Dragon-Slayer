
local Player = {}
local Kunai = require("kunai")

function Player:load()

  self.x = 2600
  self.y = 0
  self.startX = self.x
  self.startY = self.y
  self.sizeScale = 0.12
  self.width = 232 * self.sizeScale
  self.height = 439 * self.sizeScale
  self.xVel = 0
  self.yVel = 200
  self.maxSpeed = 300
  self.acceleration = 4000
  self.friction = 2500
  self.gravity = 1500
  self.jumpAmount = -500
  self.health = {current = 3, max = 3}
  self.damage = 1
  
  self.coins = 0
  self.diamonds = 0
  self.kunais = 3
  self.keys = 3

  self.color = {
    red = 1,
    green = 1,
    blue = 1,
    speed = 3
  }

  self.graceTime = 0
  self.graceDuration = 0.1
  
  self.attackTime = 0
  self.attackDuration = 0.25
  
  self.throwTime = 0
  self.throwDuration = 0.25
  
  self.deadTime = 0
  self.deadDuration = 0.5

  self.alive = true
  self.grouded = false
  self.hasDoubleair = true
  self.startAttack = false
  self.hasAttacked = false
  self.startThrow = false
  self.hasThrown = false
  self.climbing = false
  self.touchLadder = false

  self.direction = "right"
  self.state = "idle"

  self:loadAssets()

  self.physics = {}
  self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
  self.physics.body:setFixedRotation(true)
  self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.body:setGravityScale(0)


end

function Player:loadAssets()
  self.animation = {timer = 0, rate = 0.025}

  self.animation.run = {total = 10, current = 1, img = {}}
  for i=1, self.animation.run.total do
    self.animation.run.img[i] = love.graphics.newImage("assets/player/run/"..i..".png")
  end

  self.animation.idle = {total = 10, current = 1, img = {}}
  for i=1, self.animation.idle.total do
    self.animation.idle.img[i] = love.graphics.newImage("assets/player/idle/"..i..".png")
  end

  self.animation.air = {total = 1, current = 1, img = {}}
  for i=1, self.animation.air.total do
    self.animation.air.img[i] = love.graphics.newImage("assets/player/air/"..i..".png")
  end
  
  self.animation.attack = {total = 10, current = 1, img = {}}
  for i=1, self.animation.attack.total do
    self.animation.attack.img[i] = love.graphics.newImage("assets/player/attack/"..i..".png")
  end
  
  self.animation.throw = {total = 10, current = 1, img = {}}
  for i=1, self.animation.throw.total do
    self.animation.throw.img[i] = love.graphics.newImage("assets/player/throw/"..i..".png")
  end
  
  self.animation.dead = {total = 20, current = 1, img = {}}
  for i=1, self.animation.dead.total do
    self.animation.dead.img[i] = love.graphics.newImage("assets/player/dead/"..i..".png")
  end
  
  self.animation.climb = {total = 10, current = 1, img = {}}
  for i=1, self.animation.climb.total do
    self.animation.climb.img[i] = love.graphics.newImage("assets/player/climb/"..i..".png")
  end

  self.animation.draw = self.animation.idle.img[1]
  self.animation.width = self.animation.draw:getWidth() 
  self.animation.height = self.animation.draw:getHeight() 
end

function Player:takeDamage(amount)
  self:tintRed()
  if self.health.current - amount > 0 then
    self.health.current =  self.health.current - amount
  else
    self.health.current = 0
    self:die()
  end
end

function Player:die()
  self.alive = false
end

function Player:fall()
  if self.y > MapHeight then
    self.alive = false
  end
end

function Player:respawn()
  if self.deadTime > self.deadDuration then
    self.deadTime = 0
    self.physics.body:setPosition(self.startX, self.startY)
    self.health.current = self.health.max
    self.alive = true
  end
end

function Player:resetPosition()
  self.physics.body:setPosition(self.startX, self.startY)
end

function Player:tintRed()
  self.color.green = 0
  self.color.blue = 0
end

function Player:unTint(dt)
  self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
  self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
  self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Player:incrementCoins()
  self.coins = self.coins + 1
end

function Player:incrementDiamonds()
  self.diamonds = self.diamonds + 1
end

function Player:update(dt)
  self:fall()
  self:unTint(dt)
  self:respawn()
  self:setState()
  self:setDirection()
  self:animate(dt)
  self:decreaseGraceTime(dt)
  self:syncPhysics()
  self:move(dt)
  self:applyFriction(dt)
  self:applyGravity(dt)
  self:increaseAttackTime(dt)
  self:stopAttack()
  self:stopThrow()
  self:dealDamage()
  self:increaseDeadTime(dt)
  self:increaseThrowTime(dt)
  self:climb(dt)
end

function Player:setState()
  if not self.alive then
    self.state = "dead"
  elseif self.startThrow == true then
    self.state = "throw"
  elseif self.startAttack == true then
    self.state = "attack"
  elseif self.climbing == true then
    self.state = "climb"
  elseif not self.grounded then
    self.state = "air"
  elseif self.xVel == 0 then
    self.state = "idle"
  elseif self.xVel ~= 0 then
    self.state = "run"
  end
end

function Player:setDirection()
  if self.xVel > 0 then
    self.direction = "right"
  elseif self.xVel < 0 then
    self.direction = "left"
  end
end

function Player:animate(dt)
  self.animation.timer = self.animation.timer + dt
  if self.animation.timer > self.animation.rate then
    self.animation.timer = 0
    self:setNewFrame()
  end
end

function Player:setNewFrame()
  local anim = self.animation[self.state]
  if anim.current < anim.total then
    anim.current = anim.current + 1
  else
    anim.current = 1
  end
  self.animation.draw = anim.img[anim.current]

end

function Player:decreaseGraceTime(dt)
  if not self.grounded then
    self.graceTime = self.graceTime - dt
  end
end

function Player:decreaseKunais()
  Player.kunais = Player.kunais - 1
end

function Player:resetKey()
  Player.keys = 0
end

function Player:increaseAttackTime(dt)
  if self.startAttack == true then
    self.attackTime = self.attackTime + dt
  end
end

function Player:increaseKeys(dt)
  self.keys = self.keys + 1
end

function Player:increaseThrowTime(dt)
  if self.startThrow == true then
    self.throwTime = self.throwTime + dt
  end
end

function Player:increaseDeadTime(dt)
  if not self.alive == true then
    self.deadTime = self.deadTime + dt
  end
end

function Player:stopAttack()
  if self.attackTime >= self.attackDuration then
    self.startAttack = false
    self.hasAttacked = false
    self.attackTime = 0
  end
end

function Player:stopThrow()
  if self.throwTime >= self.throwDuration then
    self.startThrow = false
    self.hasThrown = false
    self.throwTime = 0
  end
end

function Player:applyGravity(dt)
  if not self.grounded then 
    self.yVel = self.yVel + self.gravity * dt
  end
end

function Player:dealDamage()
  local Enemy = require("enemy")
  local enemyTable = Enemy:getEnemyTable()
  if self.startAttack == true and self.hasAttacked == false then
    for i, enemy in ipairs(enemyTable) do
      local distanceX = math.abs(enemy.x - self.x) <= 32 + enemy.width/2 + self.width/2
      local distanceY = math.abs(enemy.y - self.y) <= 16 + enemy.height/2 + self.height/2
      if distanceX and distanceY then
        enemy:takeDamage(self.damage)
        self.hasAttacked = true
      end
    end
  end
end

function Player:move(dt)
  if self.alive then
    if love.keyboard.isDown("d") then
      self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
    elseif love.keyboard.isDown("q") then
      self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
    else
      Player:applyFriction(dt)
    end
  end
end

function Player:applyFriction(dt)
  if self.xVel > 0 then
    self.xVel = math.max(self.xVel - self.friction * dt, 0)
  elseif self.xVel < 0 then
    self.xVel = math.min(self.xVel + self.friction * dt, 0)
  end
end

function Player:syncPhysics()
  self.x, self.y = self.physics.body:getPosition()
  self.physics.body:setLinearVelocity(self.xVel, self.yVel)

end

function Player:beginContact(a, b, collision)
  if self.grounded == true then return end
  local nx, ny = collision:getNormal()
  if a == self.physics.fixture then
    if ny > 0 then
      self:land(collision)
    elseif ny < 0 then
      self.yVel = 0
    end 
  elseif b == self.physics.fixture then
    if ny < 0 then
      self:land(collision)
    elseif ny > 0 then
      self.yVel = 0
    end 
  end
end

function Player:land(collision)
  self.currentGroundedCollision = collision
  self.yVel = 0
  self.grounded = true
  self.hasDoubleair = true
  self.graceTime = self.graceDuration
end

function Player:climb(dt)
  if self.touchLadder == true then
    if love.keyboard.isDown("z") then
      self.climbing = true
      self.yVel = -100
    else
      self.climbing = false
    end
  else
    self.climbing = false
  end
end

function Player:jump(key)
  if self.alive then
    if (key == "space") then
      if self.grounded or self.graceTime > 0 or self.touchLadder then
        self.yVel = self.jumpAmount
        self.grounded = false
        self.graceTime = 0
      elseif self.hasDoubleair then
        self.hasDoubleair = false
        self.yVel = self.jumpAmount * 0.8
      end
    end
  end
end

function Player:bounce()
  self.yVel = self.jumpAmount*2
end

function Player:attack(button)
  if self.alive then
    if button == 1 and self.startAttack == false then
      if love.mouse.isDown(2) and self.kunais > 0 then
        local mx, my = love.mouse.getPosition()
        Kunai:new(self.x, self.y, mx, my)
        self.startThrow = true
        Player.decreaseKunais()
      else
        self.startAttack = true
      end
    end
  end
end

function Player:endContact(a, b, collision)
  if a == self.physics.fixture or b == self.physics.fixture then
    if self.currentGroundedCollision == collision then
      self.grounded = false
    end
  end
end

function Player:draw()
  local scaleX = self.sizeScale
  if self.direction == "left" then
    scaleX = -scaleX
  end
  local scaleY = self.sizeScale
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
  --love.graphics.rectangle("fill" ,self.x -self.width/2, self.y-self.height/2, self.width, self.height)
  love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, scaleY, self.animation.width/2, self.animation.height/2)
  love.graphics.setColor(1,1,1,1)
end

return Player
