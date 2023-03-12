local pd <const> = playdate
local gfx <const> = pd.graphics

class("Projectile").extends(gfx.sprite)

function Projectile:init(x, y, dx)
	Projectile.super.init(self)

	self.x = x
	self.y = y
	self.r = 20
    self.dx = dx
	self.dy = 0
	self.isDangerous = true

	gfx.setColor(gfx.kColorWhite)
	local circleImage = gfx.image.new(self.r*2, self.r*2)
	gfx.pushContext(circleImage)
		gfx.fillCircleAtPoint(self.r, self.r ,self.r)
	gfx.popContext()
	self:setImage(circleImage)
	self:setCollideRect(4, 4, self.r*2 - 8, self.r*2 - 8)
	self:setGroups(3)
	self:setCollidesWithGroups({1, 2, 3})
	self:add()
end

function Projectile:collisionResponse(other)
	if other:isa(Projectile) or other:isa(Wall) then
		if not self.isDangerous then
			self:setUpdatesEnabled(false)
			self.dy = 0
			self:setZIndex(0)
			return gfx.sprite.kCollisionTypeSlide
		else
			self:remove()
		end
	elseif other:isa(Player) then
		return gfx.sprite.kCollisionTypeOverlap
	end
end

function Projectile:update()
    self:applyVelocities()
	self:moveWithCollisions(self.x, self.y)
	self.x, self.y, collisions, length = self:moveWithCollisions(self.x, self.y)
	self:executeCollisionResponses(collisions)
    self:removeSelfIfFarAway()
end

function Projectile:applyVelocities()
	self.x += self.dx
	self.y += self.dy
end

function Projectile:playerCollisionResponse(otherSprite, normalX, normalY)
	if otherSprite:isa(Player) then
		otherSprite:hitByProjectileResponse()
	end
end

function Projectile:fall()
	self.isDangerous = false
	self.dx = 0
	self.dy = 6
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