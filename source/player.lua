local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(gfx.sprite)

local count = 0

function Player:init(x, y, r)
	Player.super.init(self)

	self.r = r

	self.x = x
	self.y = y
	self.dx = 0
	self.dy = 0

	self.maxDx = 8
	self.maxDy = 8
	self.terminalY = 16
	self.g = .6
	self.friction = 1.6

	local circleImage = gfx.image.new(self.r*2, self.r*2)
	gfx.pushContext(circleImage)
		gfx.fillCircleAtPoint(self.r, self.r ,self.r)
	gfx.popContext()
	self:setImage(circleImage)
	self:setCollideRect(3, 3, self.r*2 - 6, self.r*2 - 6)
	self:moveWithCollisions(self.x, self.y)
	self:add()
end

function Player:collisionResponse(other)
	return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		self.dx += 2
	end
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		self.dx -= 2
	end
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self.dy -= 2
	end

	self:applyFriction()
	self:applyGravity()
	self:applyVelocities()

	self:moveWithCollisions(self.x, self.y)
end

function Player:applyVelocities()
	self.x += self.dx
	self.y += self.dy
	if self.y > 240 then
		self.y = 240
	end
end

function Player:applyFriction()
	if self.dx > 0 then
		self.dx -= self.friction
		if self.dx < 0 then
			self.dx = 0
		end
	elseif self.dx < 0 then
		self.dx += self.friction
		if self.dx > 0 then
			self.dx = 0
		end
	end
	if self.dx > self.maxDx then
		self.dx = self.maxDx
	end
	if self.dx < -self.maxDx then
		self.dx = -self.maxDx
	end
end

function Player:applyGravity()
	self.dy += self.g
	if self.y >= 240 and self.dy > 0 then
		self.dy = 0
	end
	if self.dy < -self.maxDy then
		self.dy = -self.maxDy
	end
	if self.dy > self.terminalY then
		self.dy = self.terminalY
	end
end