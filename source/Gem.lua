local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/gem")

class("Gem").extends(gfx.sprite)

function Gem:init(x, y)
	Gem.super.init(self)

	self.x = x
	self.y = y

	self:setImage(IMAGES:getImage(1))
	self:setCollideRect(-4, -4, 35, 28)
	self:setGroups(4)
	self:setCollidesWithGroups(1)
	self:add()
end

function Gem:collisionResponse(other)
	if other:isa(Player) then
        addToMultiplier(1)
        self:remove()
        return gfx.sprite.kCollisionTypeOverlap
    end
end

function Gem:update()
	self:moveWithCollisions(self.x, self.y)

    self:removeSelfIfFarAway()
end

-- function Gem:playerCollisionResponse(otherSprite, normalX, normalY)
-- 	if otherSprite:isa(Player) then
-- 		otherSprite:hitByGemResponse()
-- 	end
-- end

function Gem:removeSelfIfFarAway()
    if self.x > 500 or self.x < -50 then
        self:remove()
    end
end