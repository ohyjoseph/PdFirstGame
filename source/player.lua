local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(gfx.sprite)

local MAX_DX = 8
local MAX_DY = 10
local TERMINAL_Y = 16
local G = 0.6
local FRICTION = 1.6
local JUMP_FORCE = 9
local CONTINUE_JUMP_FORCE = 0.3
local MAX_CONTINUE_JUMP_FRAMES = 10
local MAX_COYOTE_FRAMES = 7

function Player:init(x, y, r)
	Player.super.init(self)

	self.jumpTimer = pd.frameTimer.new(MAX_CONTINUE_JUMP_FRAMES)
	self.jumpTimer:pause()
	self.jumpTimer.discardOnCompletion = false

	self.coyoteTimer = pd.frameTimer.new(MAX_COYOTE_FRAMES)
	self.coyoteTimer:pause()
	self.coyoteTimer.discardOnCompletion = false

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
	self:setGroups(1)
	self:setCollidesWithGroups({2, 3})
	self:add()
	self:moveWithCollisions(self.x, self.y)
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
	if playdate.buttonJustPressed(playdate.kButtonA) then
		self:jump()
	elseif playdate.buttonIsPressed(playdate.kButtonA) then
		self:continueJump()
	end

	self:applyFriction()
	self:applyGravity()
	self:applyVelocities()

	local collisions

	self.x, self.y, collisions, length = self:moveWithCollisions(self.x, self.y)
	print(length)
	self:executeCollisionResponses(collisions)
end

function Player:jump()
	if ((self.coyoteTimer.frame > 0 and self.coyoteTimer.frame < MAX_COYOTE_FRAMES) or self.onGround) and self.jumpTimer.frame == 0 then
		self.jumpTimer:reset()
		self.jumpTimer:start()
		self.dy = -JUMP_FORCE
	end
end

function Player:continueJump()
	if self.jumpTimer.frame < MAX_CONTINUE_JUMP_FRAMES and self.jumpTimer.frame > 1 then
		self.dy -= CONTINUE_JUMP_FORCE
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

function Player:executeCollisionResponses(collisions)
	local isTouchingAFloor = false
	
	for i, collision in pairs(collisions) do
		if collision then
			local coor = collision["normal"]
			local x, y = coor:unpack()
			if y == -1 then
				isTouchingAFloor = true
			end
		end
	end

	if isTouchingAFloor then
		self.onGround = true
		self.dy = 0
		self.jumpTimer:pause()
		self.jumpTimer:reset()
		self.coyoteTimer:pause()
		self.coyoteTimer:reset()
	else
	    self.onGround = false
		self.coyoteTimer:start()
	end
	print(self.coyoteTimer.frame)
end