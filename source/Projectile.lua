local pd <const> = playdate
local gfx <const> = pd.graphics

local WIDTH = 40
local HEIGHT = 10
local VELOCITY = 3

class("Projectile").extends(gfx.sprite)

function Projectile:init(x, y)
	Projectile.super.init(self)

	self.x = x
	self.y = y
    self.dx = VELOCITY
	self.dy = 0
	self.isDangerous = true

	local rectImage = gfx.image.new(WIDTH, HEIGHT)
	gfx.pushContext(rectImage)
		gfx.fillRect(0, 0, WIDTH, HEIGHT)
	gfx.popContext()
	self:setImage(rectImage)
    self:setCollideRect(0, 0, self:getSize())
	self:setGroups(3)
	self:setCollidesWithGroups({1, 2, 3})
	self:add()
end

function Projectile:collisionResponse(other)
	if other:isa(Projectile) or other:isa(Wall) then
		return gfx.sprite.kCollisionTypeSlide
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