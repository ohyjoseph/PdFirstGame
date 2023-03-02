local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(gfx.sprite)

local MAX_DX = 8
local MAX_DY = 10
local TERMINAL_Y = 16
local G = 0.6
local FRICTION = 1.6
local JUMP_FORCE = 5

function Player:init(x, y, r)
	Player.super.init(self)

	self.jumpTimer = pd.frameTimer.new(6)
	self.jumpTimer:pause()
	self.jumpTimer.discardOnCompletion = false

	self.r = r

	self.x = x
	self.y = y
	self.dx = 0
	self.dy = 0

	self.onGround = false

	local circleImage = gfx.image.new(self.r*2, self.r*2)
	gfx.pushContext(circleImage)
		gfx.fillCircleAtPoint(self.r, self.r ,self.r)
	gfx.popContext()
	self:setImage(circleImage)
	self:setCollideRect(3, 3, self.r*2 - 6, self.r*2 - 6)
	self:add()
	self:moveWithCollisions(self.x, self.y)
end

function Player:collisionResponse(other)
	return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
	print(self.jumpTimer.frame)
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		self.dx += 2
	end
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		self.dx -= 2
	end
	if playdate.buttonJustPressed(playdate.kButtonA) then
		self:jump()
	elseif playdate.buttonIsPressed(playdate.kButtonA) then
		self:continueJump()
	end

	self:applyFriction()
	self:applyGravity()
	self:applyVelocities()

	local collisions

	self.x, self.y, collisions = self:moveWithCollisions(self.x, self.y)
	if collisions[1] then
		local coor = collisions[1]["normal"]
		local x, y = coor:unpack()
		-- print(x, y)
		if y == -1 then
			self.dy = 0
			self.onGround = true
			self.jumpTimer:pause()
			self.jumpTimer:reset()
		else
			self.onGround = false
		end
	end
end

function Player:jump()
	if self.onGround and self.jumpTimer.frame == 0 then
		self.jumpTimer:reset()
		self.jumpTimer:start()
		self.dy -= JUMP_FORCE
	end
end

function Player:continueJump()
	if self.jumpTimer.frame < 6 and self.jumpTimer.frame >= 1 then
		self.dy -= JUMP_FORCE
	else
		self.jumpTimer:pause()
		self.jumpTimer:reset()
	end
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
		self.dx -= FRICTION
		if self.dx < 0 then
			self.dx = 0
		end
	elseif self.dx < 0 then
		self.dx += FRICTION
		if self.dx > 0 then
			self.dx = 0
		end
	end
	if self.dx > MAX_DX then
		self.dx = MAX_DX
	end
	if self.dx < -MAX_DX then
		self.dx = -MAX_DX
	end
end

function Player:applyGravity()
	self.dy += G
	if self.y >= 240 and self.dy > 0 then
		self.dy = 0
	end
	if self.dy < -MAX_DY then
		self.dy = -MAX_DY
	end
	if self.dy > TERMINAL_Y then
		self.dy = TERMINAL_Y
	end
end