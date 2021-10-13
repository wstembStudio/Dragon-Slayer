

local Ladder = {}
Ladder.__index = Ladder
local ActiveLadder = {}
local Player = require("player")

function Ladder.new(x,y)
  local instance = setmetatable({}, Ladder)
  instance.x = x
  instance.y = y

  instance.width = 32
  instance.height = 96

  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, instance.x + instance.width/2, instance.y + instance.height/2, "static")
  instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  instance.physics.fixture:setSensor(true)
  table.insert(ActiveLadder, instance)
end

function Ladder.removeAll()
  for i,v in ipairs(ActiveLadder) do
    v.physics.body:destroy()
  end

  ActiveLadder = {}
end

function Ladder:update(dt)

end

function Ladder:draw()
  --love.graphics.rectangle("fill" ,self.x, self.y, self.width, self.height)
end

function Ladder.updateAll(dt)
  for i,instance in ipairs(ActiveLadder) do
    instance:update(dt)
  end
end

function Ladder.drawAll()
  for i,instance in ipairs(ActiveLadder) do
    instance:draw()
  end
end

function Ladder.beginContact(a, b, collision)
  for i,instance in ipairs(ActiveLadder) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        Player.touchLadder = true
      end
    end
  end
end

function Ladder.endContact(a, b, collision)
  for i,instance in ipairs(ActiveLadder) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        Player.touchLadder = false
      end
    end
  end
end

return Ladder