local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/boulder")

class("Projectile").extends(gfx.sprite)

function Projectile:init(x, y, dx, rotatesClockwise)
	Projectile.super.init(self)

	self.rotationCounter = math.random(1, #IMAGES - 1)

	self.x = x
	self.y = y
	self.rotatesClockwise = rotatesClockwise
    self.dx = dx
	self.dy = 0
	self.shouldRotate = true
	self.isDangerous = true
	self.hasTouchedLava = false


	self:setZIndex(101)
	self:setImage(IMAGES:getImage(1))
	self:setCollideRect(4, 6, 26, 22)
	self:setGroups(3)
	self:setCollidesWithGroups({1, 2, 3})
	self:moveTo(x, y)
	self:add()
end

function Projectile:collisionResponse(other)
	if other:isa(Projectile) or other:isa(Platform) then
		if not self.isDangerous then
			if not self.hasTouchedLava then
				if self.startFallY and self.y - self.startFallY >= 25 then
					SoundManager:playSound(SoundManager.kSoundProjectileLand)
				end
			end
			self:setUpdatesEnabled(false)
			self:setCollidesWithGroups({1, 3})
			self.dy = 0
			self:setZIndex(0)
			return gfx.sprite.kCollisionTypeSlide
		else
			SoundManager:playSound(SoundManager.kSoundProjectileDestroy)
			self:remove()
		end
	elseif other:isa(Player) then
		return gfx.sprite.kCollisionTypeOverlap
	end
end

function Projectile:update()
    self:applyVelocities()
	self.x, self.y, collisions, length = self:moveWithCollisions(self.x, self.y)
	self:executeCollisionResponses(collisions)
	self:updateSprite()
    self:removeSelfIfFarAway()
end

function Projectile:updateSprite()
	if self.shouldRotate then
		self:updateRotationCounter()
		self:setImage(IMAGES:getImage(self.rotationCounter))
	end
end

function Projectile:updateRotationCounter()
	if self.rotatesClockwise then
		self.rotationCounter += 1
	else
		self.rotationCounter -= 1
	end
	if self.rotationCounter > #IMAGES then
		self.rotationCounter = 1
	elseif self.rotationCounter < 1 then
		self.rotationCounter = #IMAGES
	end
end

function Projectile:collideWithLavaResponse()
	if not self.hasTouchedLava then
		self.hasTouchedLava = true
		if self:updatesEnabled() then
			self.dy = 0.33
			self.shouldRotate = false
		end
	end
end

function Projectile:applyVelocities()
	self.x += self.dx
	self.y += self.dy
end

function Projectile:playerCollisionResponse(otherSprite, normalX, normalY)
	if otherSprite:isa(Player) then
		otherSprite:hitByProjectileResponse(self)
	end
end

function Projectile:fall()
	self.isDangerous = false
	self.dx = 0
	self.dy = 6
	self:setCollideRect(4, 4, 26, 26)
end

function Projectile:removeSelfIfFarAway()
    if self.x > 500 or self.x < -50 then
        self:remove()
    end
end

function Projectile:executeCollisionResponses(collisions)
	for i, collision in pairs(collisions) do
		if collision then
			local normalCoor = collision["normal"]
			local normalX, normalY = normalCoor:unpack()
			local otherSprite = collision["other"]

			self:playerCollisionResponse(otherSprite, normalX, normalY)
		end
	end
end