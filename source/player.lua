local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(gfx.sprite)

local MAX_DX = 4
local MAX_DY = 12
local TERMINAL_Y = 16
local FRICTION = 1.6
local DEFAULT_GRAVITY = 0.6
local EXTERNAL_FRICTION = 0.175
local WALK_FORCE = 1.8
local JUMP_FORCE = 8.5
local CONTINUE_JUMP_FORCE = 0.3
local MAX_IDLE_FRAMES = 100
local MAX_RUN_FRAMES = 20
local MAX_CONTINUE_JUMP_FRAMES = 12
local MAX_COYOTE_FRAMES = 6
local STUNNED_FRAMES = 50
local JUMP_BOUNCE_FORCE = 7.5
local BOUNCE_FORCE = 6
local DEATH_FRAMES = 100
local halfPlayerWidth = 15

function Player:init(x, y, score)
	Player.super.init(self)

	self.idleTimer = pd.frameTimer.new(MAX_IDLE_FRAMES)
	self.idleTimer.discardOnCompletion = false
	self.runTimer = pd.frameTimer.new(MAX_RUN_FRAMES)
	self.runTimer.discardOnCompletion = false

	self.jumpTimer = pd.frameTimer.new(MAX_CONTINUE_JUMP_FRAMES)
	self.jumpTimer:pause()
	self.jumpTimer.discardOnCompletion = false

	self.coyoteTimer = pd.frameTimer.new(MAX_COYOTE_FRAMES)
	self.coyoteTimer:pause()
	self.coyoteTimer.discardOnCompletion = false

	self.unstunTimer = nil

	self.isStunned = false
	self.isDead = false
	self.isHoldingGem = false

	self.isOnRope = false

	self.score = score

	self.x = x
	self.y = y
	self.dx = 0
	self.dy = 0
	
	self.g = DEFAULT_GRAVITY

	self.externalDx = 0

	self.lastGroundY = y

	self.isOnGround = false
	self.isFacingRight = true

	self.playerImages = gfx.imagetable.new('images/gaery')

	self:setImage(self.playerImages:getImage(1))
	self:setZIndex(1000)
	self:setCollideRect(4, 0, 22, 44)
	self:setGroups(1)
	self:setCollidesWithGroups({2, 3})
	self:add()
	self:moveWithCollisions(x, y)
end

function Player:collisionResponse(other)
	if other:isa(Platform) or other:isa(Rectangle) then
		return gfx.sprite.kCollisionTypeSlide
	end
	if other:isa(Projectile) then
		if other.isDangerous then
			return gfx.sprite.kCollisionTypeBounce
		else
			return gfx.sprite.kCollisionTypeSlide
		end
	end
end

function Player:update()
	self:respondToControls()

	self:applyFriction()
	self:applyExternalFriction()
	self:applyGravity()
	self:applyVelocities()

	local collisions

	self.x, self.y, collisions, length = self:moveWithCollisions(self.x, self.y)
	self:executeCollisionResponses(collisions)

	self:getOffRope()

	self:unstunPlayer()

	self:updateIsFacingRight()
	self:updateSprite()
end

function Player:unstunPlayer()
	if self.isOnGround and self.isStunned then
		if not self.unstunTimer then
			self.unstunTimer = pd.frameTimer.new(STUNNED_FRAMES, function()
				self.isStunned = false
				self.unstunTimer = nil
			end)
		end
	end
end

function Player:getOffRope()
	if self.isOnGround and self.isOnRope then
		self.isOnRope = false
		self.g = DEFAULT_GRAVITY
	end
end

function Player:respondToControls()
	if self.isStunned or self.isDead or self.isOnRope or self.isHoldingGem  then
		return
	end
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
end

function Player:updateIsFacingRight()
	if self.dx > 0 then
		self.isFacingRight = true
	elseif self.dx < 0 then
		self.isFacingRight = false
	end
end

function Player:updateSprite()
	if self.isDead then
		self:setImage(self.playerImages:getImage(7), self:getSpriteOrientation())
		return
	elseif self.isStunned then
		self:setImage(self.playerImages:getImage(8), self:getSpriteOrientation())
		return
	elseif self.isOnRope then
		self:setImage(self.playerImages:getImage(9))
		return
	elseif self.isHoldingGem then
		self:setImage(self.playerImages:getImage(10), self:getSpriteOrientation())
		return
	end

	if self.isOnGround then
		self.lastGroundY = self.y
		if self.dx == 0 and self.idleTimer.frame > 20 then
			if (self.idleTimer.frame >= 21 and self.idleTimer.frame <= 28) or
			(self.idleTimer.frame >= 61 and self.idleTimer.frame <= 68) then
				self:setImage(self.playerImages:getImage(1), self:getSpriteOrientation())
			elseif self.idleTimer.frame <= 60 then
				self:setImage(self.playerImages:getImage(2), self:getSpriteOrientation())
			elseif self.idleTimer.frame <= 100 then
				self:setImage(self.playerImages:getImage(3), self:getSpriteOrientation())
			end
		elseif self.dx == 0 then
			self:setImage(self.playerImages:getImage(1), self:getSpriteOrientation())
		elseif self.dx ~= 0 then
			if self.runTimer.frame <= 10 then
				self:setImage(self.playerImages:getImage(4), self:getSpriteOrientation())
			else
				self:setImage(self.playerImages:getImage(5), self:getSpriteOrientation())
			end
		end
	elseif self.jumpTimer.frame ~= 0 then
		self:setImage(self.playerImages:getImage(6), self:getSpriteOrientation())
	end
	if self.runTimer.frame >= MAX_RUN_FRAMES or self.dx == 0 then
		self.runTimer:reset()
	end
	if (self.idleTimer.frame >= MAX_IDLE_FRAMES or self.dx ~= 0 or self.isOnGround == false) then
		self.idleTimer:reset()
	end
end

function Player:getSpriteOrientation()
	if self.isFacingRight then
		return gfx.kImageUnflipped
	else
		return gfx.kImageFlippedX
	end
end

function Player:saveHighScore()
	SAVE_HIGH_SCORE(self.score.score)
end

function Player:jump()
	if ((self.coyoteTimer.frame > 0 and self.coyoteTimer.frame < MAX_COYOTE_FRAMES) or self.isOnGround) and self.jumpTimer.frame == 0 then
		self.jumpTimer:reset()
		self.jumpTimer:start()
		self.dy = -JUMP_FORCE
		SoundManager:playSound(SoundManager.kSoundJump)
	end
end

function Player:continueJump()
	if self.jumpTimer.frame < MAX_CONTINUE_JUMP_FRAMES and self.jumpTimer.frame > 1 then
		self.dy -= CONTINUE_JUMP_FORCE
	end
end

function Player:applyVelocities()
	self.x += (self.dx + self.externalDx)
	self.y += self.dy
	self:preventPlayerFromLeavingXBounds()
end

function Player:preventPlayerFromLeavingXBounds()
	if self.x - halfPlayerWidth < 0 then
		self.x = halfPlayerWidth
		self.dx = 0
	end
	if self.x + halfPlayerWidth > 400 then
		self.x = 400 - halfPlayerWidth
		self.dx = 0
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

function Player:applyExternalFriction()
	if self.externalDx > 0 then
		self.externalDx -= EXTERNAL_FRICTION
		if self.externalDx < 0 then
			self.externalDx = 0
		end
	elseif self.externalDx < 0 then
		self.externalDx += EXTERNAL_FRICTION
		if self.externalDx > 0 then
			self.externalDx = 0
		end
	end
end

function Player:applyGravity()
	self.dy += self.g
	if self.dy < -MAX_DY then
		self.dy = -MAX_DY
	end
	if self.dy > TERMINAL_Y then
		self.dy = TERMINAL_Y
	end
end

function Player:hitByProjectileResponse(projectile)
	if projectile.isDangerous then
		SoundManager:playSound(SoundManager.kSoundProjectileDestroy)
		SoundManager:playSound(SoundManager.kSoundPlayerHit)
		
		self.isStunned = true
		self.externalDx += projectile.dx
		projectile:remove()
	end
end

function Player:startDeath()
	self.isDead = true
	self:setCollisionsEnabled(false)
	self.dy = self.dy * 0.03
	self.g = 0.04

	SoundManager:playSound(SoundManager.kSoundDeathJingle)
	pd.frameTimer.new(DEATH_FRAMES, function()
		showScoreWidget()
	end)
end

-- returns if Player is touching a floor
function Player:slideCollisionResponse(collisionType, normalX, normalY)
	local isTouchingAFloor = false

	if collisionType == gfx.sprite.kCollisionTypeSlide then
		-- Walking into sprite
		if normalX == 1 then 
			self.dx = 0
		elseif normalX == -1 then
			self.dx = 0
		end
		
		-- Head touching sprite
		if normalY == 1 then
			if self.dy < -CONTINUE_JUMP_FORCE then
				self.dy = 0
			end
		-- Feet touching sprite
		elseif normalY == -1 then
			isTouchingAFloor = true
		end
	end
	return isTouchingAFloor
end

function Player:projectileCollisionResponse(otherSprite, normalX, normalY)
	if self.isStunned then
		return
	end
	if otherSprite:isa(Projectile) and otherSprite.isDangerous then
		if normalY == -1 then
			if self.dy < -BOUNCE_FORCE then
				self.dy += -BOUNCE_FORCE
			else
				if playdate.buttonIsPressed(playdate.kButtonA) then
					self.dy = -JUMP_BOUNCE_FORCE
				else
					self.dy = -BOUNCE_FORCE
				end
				otherSprite.startFallY = otherSprite.y
				SoundManager:playSound(SoundManager.kSoundStomp)
			end
			otherSprite:fall()
			otherSprite:setCollideRect(4, 4, 26, 26)
		else
			self:hitByProjectileResponse(otherSprite)
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

		if getLowestY() then
			if self.y < getLowestY() then
				-- delay by 1 frame in case player scores and grabs gem on the same frame
				-- ensuring the multiplier goes up before adding to the score
				pd.frameTimer.new(1, function()
					addToScore(getMutliplier() * math.floor((getLowestY() - self.y) / 22))
					setLowestY(self.y)
				end)
			end
		end
	else
		self.isOnGround = false
		self.coyoteTimer:start()
	end
end