

local GUI = {}
local Player = require("player")
local Map = require("map")

local g_width = love.graphics.getWidth()
local g_height = love.graphics.getHeight()

function GUI:load()
  self.coins = {}
  self.coins.img = love.graphics.newImage("assets/coin.png")
  self.coins.width = self.coins.img:getWidth()
  self.coins.height = self.coins.img:getHeight()
  self.coins.scale = 3
  self.coins.x = g_width - 200
  self.coins.y = 50
  
  self.kunais = {}
  self.kunais.img = love.graphics.newImage("assets/GuiKunai.png")
  self.kunais.width = self.kunais.img:getWidth()
  self.kunais.height = self.kunais.img:getHeight()
  self.kunais.scale = 0.25
  self.kunais.x = g_width - 200
  self.kunais.y = 125
  
  self.hearts = {}
  self.hearts.img = love.graphics.newImage("assets/heart.png")
  self.hearts.width = self.hearts.img:getWidth()
  self.hearts.height = self.hearts.img:getHeight()
  self.hearts.x = 0
  self.hearts.y = 30
  self.hearts.scale = 3
  self.hearts.spacing = self.hearts.width * self.hearts.scale + 30

  self.level = {}
  self.level.x = 0
  self.level.y = g_height - 50
  self.level.time = 0

  self.font = love.graphics.newFont("assets/bit.ttf", 36)
end

function GUI:increaseLevelTime(dt)
  self.level.time = self.level.time + dt
end

function GUI:update(dt)
  self:increaseLevelTime(dt)
end

function GUI:draw()
  self:displayCoins()
  self:displayCoinText()
  self:displayKunais()
  self:displayKunaiText()
  self:displayLevelText()
  self:displayLevelTimeText()
  self:displayHearts()
end

function GUI:displayHearts()
  for i=1,Player.health.current do
    local x = self.hearts.x + self.hearts.spacing * i
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.draw(self.hearts.img, x + 2, self.hearts.y + 2, 0, self.hearts.scale, self.hearts.scale)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.hearts.img, x, self.hearts.y, 0, self.hearts.scale, self.hearts.scale)
  end
end

function GUI:displayKunais()
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.draw(self.kunais.img, self.kunais.x + 2, self.kunais.y + 2, 0, self.kunais.scale, self.kunais.scale)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.kunais.img, self.kunais.x, self.kunais.y, 0, self.kunais.scale, self.kunais.scale)
end

function GUI:displayKunaiText()
  love.graphics.setFont(self.font)
  local x = self.kunais.x + self.kunais.width * self.kunais.scale
  local y = self.kunais.y + self.kunais.height / 2 * self.kunais.scale - self.font:getHeight() / 2
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.print(" : "..Player.kunais, x + 2, y + 2)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(" : "..Player.kunais, x, y)
end

function GUI:displayCoins()
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.draw(self.coins.img, self.coins.x + 2, self.coins.y + 2, 0, self.coins.scale, self.coins.scale)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.coins.img, self.coins.x, self.coins.y, 0, self.coins.scale, self.coins.scale)
end

function GUI:displayCoinText()
  love.graphics.setFont(self.font)
  local x = self.coins.x + self.coins.width * self.coins.scale
  local y = self.coins.y + self.coins.height / 2 * self.coins.scale - self.font:getHeight() / 2
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.print(" : "..Player.coins, x + 2, y + 2)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(" : "..Player.coins, x, y)
end

function GUI:displayLevelText()
  love.graphics.setFont(self.font)
  local x = self.hearts.x + self.hearts.spacing
  local y = self.level.y
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.print(" LEVEL: "..Map.currentLevel, x + 2, y + 2)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(" LEVEL: "..Map.currentLevel, x, y)
end

function GUI:displayLevelTimeText()
  love.graphics.setFont(self.font)
  local x = g_width - 200
  local y = self.level.y
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.print(" TIME: "..math.ceil(self.level.time), x + 2, y + 2)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(" TIME: "..math.ceil(self.level.time), x, y)
end

return GUI
