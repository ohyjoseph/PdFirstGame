local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/gem")

class("Gem").extends(gfx.sprite)

function Gem:init(x, y)
	Gem.super.init(self)

    self.rotationTimer = pd.frameTimer.new(#IMAGES * 8, 1, #IMAGES)
    self.rotationTimer.repeats = true

	self.x = x
	self.y = y

	self:setImage(IMAGES:getImage(1))
	self:setCollideRect(0, 0, 27, 20)
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
    self:updateSprite()
end

-- function Gem:playerCollisionResponse(otherSprite, normalX, normalY)
-- 	if otherSprite:isa(Player) then
-- 		otherSprite:hitByGemResponse()
-- 	end
-- end

function Gem:updateSprite()
    print(math.floor(self.rotationTimer.value + 0.5))
    self:setImage(IMAGES:getImage(math.floor(self.rotationTimer.value + 0.5)))
end