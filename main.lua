local vector = require "thirdparty.hump.vector"
local lume = require "thirdparty.lume.lume"
local Object = require "thirdparty.classic.classic"

player = vector.new(400, 400)
inventoryOpen = true

local Menu = Object:extend()

function Menu:new()
  -- properties
  self.size = 100
  self.seconds = 1

  -- state
  self.currentSize = 0
  self.currentRing = 1
  self.currentElement = 1
  self.rotationOffset = 0
  self.nextElement = 1
  self.openCloseTime = 0
  self.leftRightTime = 0
  self.isMoving = false
  self.isOpening = false
  self.isOpen = false
  self.isClosing = false
  self.isClosed = true

  -- elements
  self.rings = {
    {1, 2, 3, 4},
    {1, 2, 3, 4, 6, 7, 8, 10, 30}
  }
end

function Menu:print()
  print("t", self.openCloseTime)
  print("isOpen", self.isOpen, "isClosed", self.isClosed)
  print("isOpening", self.isOpening, "isClosing", self.isClosing)
end

function Menu:left()
  if self.isMoving then
    return
  end
  local numberOfElementsInRing = #self.rings[self.currentRing]
  self.nextElement = self.nextElement - 1
  if self.nextElement <= 0 then
    self.nextElement = numberOfElementsInRing
  end
  self.isMoving = true
end

function Menu:right()
  if self.isMoving then
    return
  end
  local numberOfElementsInRing = #self.rings[self.currentRing]
  self.nextElement = self.nextElement + 1
  if self.nextElement > numberOfElementsInRing then
    self.nextElement = 1
  end
  self.isMoving = true
end

function Menu:up()
  local numberOfRings = #self.rings
  self.currentRing = self.currentRing - 1
  if self.currentRing <= 0 then
    self.currentRing = numberOfRings
  end
  self.currentElement = 1
  self.rotationOffset = 0
  self.nextElement = 1
  self.leftRightTime = 0
  self.isMoving = false
end

function Menu:down()
  local numberOfRings = #self.rings
  self.currentRing = self.currentRing + 1
  if self.currentRing > numberOfRings then
    self.currentRing = 1
  end
  self.currentElement = 1
  self.rotationOffset = 0
  self.nextElement = 1
  self.leftRightTime = 0
  self.isMoving = false
end

function Menu:open()
  if self.isClosed then
    self.isClosed = false
    self.isClosing = false
    self.isOpening = true
  end
end

function Menu:close()
  if self.isOpen then
    self.isOpen = false
    self.isOpening = false
    self.isClosing = true
  end
end

function Menu:toggle()
  if self.isOpen then
    self:close()
  elseif self.isClosed then
    self:open()
  end
end

function Menu:slice(e)
  return (math.pi * 2 / #self.rings[self.currentRing]) * (e or 1)
end

function Menu:draw(location)
  -- if self.isClosed == false then
  love.graphics.circle("line", location.x, location.y, self.currentSize)

  local numberOfElementsInRing = #self.rings[self.currentRing]
  local radSlice = self:slice()

  for e = 0, numberOfElementsInRing - 1 do
    local offset =
      location +
      vector.new(math.cos(radSlice * e + self.rotationOffset), math.sin(radSlice * e + self.rotationOffset)) *
        self.currentSize
    local textOffset = (offset - location):normalized() * 30 + offset
    love.graphics.circle("line", offset.x, offset.y, 20)
    love.graphics.print(self.rings[self.currentRing][e + 1], textOffset.x, textOffset.y)
  end

  love.graphics.print(numberOfElementsInRing .. "/" .. self.currentElement .. "/" .. self.nextElement, 10, 10)
  love.graphics.print(#self.rings .. "/" .. self.currentRing, 10, 40)
  -- end
end

function Menu:update(dt)
  if self.isOpening then
    self.openCloseTime = self.openCloseTime + (dt * 1 / self.seconds)
    self.currentSize = lume.smooth(0, self.size, self.openCloseTime)
    if self.openCloseTime >= 1 then
      self.openCloseTime = 1
      self.isOpen = true
      self.isOpening = false
      self:print()
    end
  elseif self.isClosing then
    self.openCloseTime = self.openCloseTime - (dt * 1 / self.seconds)
    self.currentSize = lume.smooth(0, self.size, self.openCloseTime)
    if self.openCloseTime <= 0 then
      self.openCloseTime = 0
      self.isClosed = true
      self.isClosing = false
      self:print()
    end
  end

  if self.isMoving then
    self.leftRightTime = self.leftRightTime + (dt * 1 / self.seconds)
    self.rotationOffset = lume.smooth(self:slice(self.currentElement), self:slice(self.nextElement), self.leftRightTime)

    if self.leftRightTime >= 1 then
      self.leftRightTime = 0
      self.currentElement = self.nextElement
      self.isMoving = false
    end
  end
end

menu = Menu()
menu:open()

function love.load()
  love.graphics.setBackgroundColor(0.2, 0.2, 0.3)
end

function love.update(dt)
  menu:update(dt)
end

function love.draw()
  love.graphics.clear(0.1, 0.1, 0.3, 1)

  -- draw player
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.circle("fill", player.x, player.y, 10)

  menu:draw(player)
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
  if key == "space" then
    menu:toggle()
  end

  if key == "left" then
    menu:left()
  end

  if key == "right" then
    menu:right()
  end

  if key == "up" then
    menu:up()
  end

  if key == "down" then
    menu:down()
  end
end
