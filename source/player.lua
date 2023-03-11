local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(gfx.sprite)

local MAX_DX = 6
local MAX_DY = 12
local TERMINAL_Y = 16
local G = 0.6
local FRICTION = 1.63
local WALK_FORCE = 1.9
local JUMP_FORCE = 7.5
local CONTINUE_JUMP_FORCE = 0.2
local IDLE_FRAMES = 80
local MAX_CONTINUE_JUMP_FRAMES = 10
local MAX_COYOTE_FRAMES = 7
local BOUNCE_FORCE = 6

function Player:init(x, y)
	Player.super.init(self)

	self.idleTimer = pd.frameTimer.new(IDLE_FRAMES)

	self.jumpTimer = pd.frameTimer.new(MAX_CONTINUE_JUMP_FRAMES)
	self.jumpTimer:pause()
	self.jumpTimer.discardOnCompletion = false

	self.coyoteTimer = pd.frameTimer.new(MAX_COYOTE_FRAMES)
	self.coyoteTimer:pause()
	self.coyoteTimer.discardOnCompletion = false

	self.x = x
	self.y = y
	self.dx = 0
	self.dy = 0

	self.isOnGround = false
	self.isFacingRight = true

	self.playerImages = gfx.imagetable.new('images/gaery')

	self:setImage(self.playerImages:getImage(1))
	self:setZIndex(1000)
	self:setCollideRect(4, 0, 23, 44)
	self:setGroups(1)
	self:setCollidesWithGroups({2, 3})
	self:add()
	self:moveWithCollisions(self.x, self.y)
end

function Player:collisionResponse(other)
	if other:isa(Wall) then
		return gfx.sprite.kCollisionTypeSlide
	elseif other:isa(Projectile) then
		if other.isDangerous then
			return gfx.sprite.kCollisionTypeBounce
		else
			return gfx.sprite.kCollisionTypeSlide
		end
	end
end

function Player:update()
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		self.dx += WALK_FORCE
	end
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		self.dx -= WALK_FORCE
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
	self:executeCollisionResponses(collisions)

	self:updateIsFacingRight()
	self:updateSprite()
end

function Player:updateIsFacingRight()
	if self.dx > 0 then
		self.isFacingRight = true
	elseif self.dx < 0 then
		self.isFacingRight = false
	end
end

function Player:updateSprite()
	if self.dx == 0 and self.isOnGround then
		if self.idleTimer.frame == 1 or self.idleTimer.frame == 2 or
		self.idleTimer.frame == 3 or self.idleTimer.frame == 4 or
		self.idleTimer.frame == 5 or self.idleTimer.frame == 6 or
		self.idleTimer.frame == 7 or self.idleTimer.frame == 8 or
		self.idleTimer.frame == 41 or self.idleTimer.frame == 42 or
		self.idleTimer.frame == 43 or self.idleTimer.frame == 44 or
		self.idleTimer.frame == 45 or self.idleTimer.frame == 46 or
		self.idleTimer.frame == 47 or self.idleTimer.frame == 48 then
			if self.isFacingRight then
				self:setImage(self.playerImages:getImage(1))
			else
				self:setImage(self.playerImages:getImage(1), gfx.kImageFlippedX)
			end
		elseif self.idleTimer.frame <= 40 then
			if self.isFacingRight then
				self:setImage(self.playerImages:getImage(2))
			else
				self:setImage(self.playerImages:getImage(2), gfx.kImageFlippedX)
			end
		elseif self.idleTimer.frame <= 80 then
			if self.isFacingRight then
				self:setImage(self.playerImages:getImage(3))
			else
				self:setImage(self.playerImages:getImage(3), gfx.kImageFlippedX)
			end
		end
	else
		if self.isFacingRight then
			self:setImage(self.playerImages:getImage(1))
		else
			self:setImage(self.playerImages:getImage(1), gfx.kImageFlippedX)
		end
	end
	if (self.idleTimer.frame == IDLE_FRAMES) then
		self.idleTimer:reset()
	end
end

function Player:jump()
	if ((self.coyoteTimer.frame > 0 and self.coyoteTimer.frame < MAX_COYOTE_FRAMES) or self.isOnGround) and self.jumpTimer.frame == 0 then
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

function Player:hitByProjectileResponse()
	print("HIT")
	resetGame()
end

-- returns if Player is touching a floor
function Player:slideCollisionResponse(collisionType, normalX, normalY)
	local isTouchingAFloor = false

	if collisionType == gfx.sprite.kCollisionTypeSlide then
		-- Walking into sprite
		if normalX == 1 then 
			self.dx = WALK_FORCE
		elseif normalX == -1 then 
			self.dx = -WALK_FORCE
		end
		
		-- Head touching sprite
		if normalY == 1 then
			if self.dy < -CONTINUE_JUMP_FORCE then
				self.dy = -CONTINUE_JUMP_FORCE
			end
		-- Feet touching sprite
		elseif normalY == -1 then
			isTouchingAFloor = true
		end
	end
	return isTouchingAFloor
end

function Player:projectileCollisionResponse(otherSprite, normalX, normalY)
	if otherSprite:isa(Projectile) then
		if normalY == -1 then
			if self.dy < -BOUNCE_FORCE then
				self.dy += -BOUNCE_FORCE
			else 
				self.dy = -BOUNCE_FORCE
			end
			otherSprite:fall()
		else
			if otherSprite.isDangerous then
				self:hitByProjectileResponse()
			end
		end
	end
end

function Player:executeCollisionResponses(collisions)
	local isTouchingAFloor = false
	for i, collision in pairs(collisions) do
		if collision then
			local normalCoor = collision["normal"]
			local normalX, normalY = normalCoor:unpack()
			local otherSprite = collision["other"]
			local collisionType = collision["type"]

			local isStandingOnOther = self:slideCollisionResponse(collisionType, normalX, normalY)
			self:projectileCollisionResponse(otherSprite, normalX, normalY)

			if isTouchingAFloor == false then
				isTouchingAFloor = isStandingOnOther
			end 
		end
	end
	if isTouchingAFloor then
		self.isOnGround = true
		self.dy = 0
		self.jumpTimer:pause()
		self.jumpTimer:reset()
		self.coyoteTimer:pause()
		self.coyoteTimer:reset()

		if self.y < lowestY then
			lowestY = self.y
			print(lowestY)
		end
	else
		self.isOnGround = false
		self.coyoteTimer:start()
	end
end