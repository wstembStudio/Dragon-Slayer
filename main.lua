if arg[#arg] == "-debug" then require("mobdebug").start() end
love.graphics.setDefaultFilter("nearest", "nearest")
love.mouse.setVisible(false)

local g_width = love.graphics.getWidth()
local g_height = love.graphics.getHeight()

local Player = require("player")
local Coin = require("coin")
local GUI = require("gui")
local Spike = require("spike")
local Stone = require("stone")
local Camera = require("camera")
local Enemy = require("enemy")
local Map = require("map")
local Diamond = require("diamond")
local Kunai = require("kunai")
local Ladder = require("ladder")
local Saw = require("saw")
local Bouncer = require("bouncer")
local Ball = require("ball")
local Key = require("key")
local Door = require("door")

function love.load()
	Enemy.loadAssets()
	Map:load()
	sky = love.graphics.newImage("assets/PNG/sky_background.jpg")
	GUI:load()
	Player:load()
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
	Coin.updateAll(dt)
	Spike.updateAll(dt)
	Stone.updateAll(dt)
  Diamond.updateAll(dt)
  Door.updateAll(dt)
  Kunai.updateAll(dt)
	Enemy.updateAll(dt)
  Ladder.updateAll(dt)
  Bouncer.updateAll(dt)
  Saw.updateAll(dt)
  Ball.updateAll(dt)
  Key.updateAll(dt)
	GUI:update(dt)
	Camera:setPosition(Player.x, 0)
	Map:update(dt)
end

function love.draw()
	love.graphics.draw(sky)
	Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

	Camera:apply()
  Door.drawAll()
	Player:draw()
	Enemy.drawAll()
	Coin.drawAll()
	Spike.drawAll()
  Kunai.drawAll()
  Door.drawAll()
	Stone.drawAll()
  Ladder.drawAll()
  Ball.drawAll()
  Saw.drawAll()
  Key.drawAll()
  Bouncer.drawAll()
  Diamond.drawAll()
	Camera:clear()

	GUI:draw()
  love.graphics.print(Player.keys, 10, 100)
end

function love.keypressed(key)
	Player:jump(key)
end

function love.mousepressed(x ,y , button)
  Player:attack(button)
end

function beginContact(a, b, collision)
	if Coin.beginContact(a, b, collision) then return end
  if Key.beginContact(a, b, collision) then return end
  if Diamond.beginContact(a, b, collision) then return end
	if Spike.beginContact(a, b, collision) then return end
  if Kunai.beginContact(a, b, collision) then return end
  if Bouncer.beginContact(a, b, collision) then return end
  if Door.beginContact(a, b, collision) then return end
  Ladder.beginContact(a, b, collision)
  Ball.beginContact(a, b, collision) 
  Saw.beginContact(a, b, collision) 
	Enemy.beginContact(a, b, collision)
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
  Ladder.endContact(a, b, collision)
  Door.endContact(a, b, collision)
end
