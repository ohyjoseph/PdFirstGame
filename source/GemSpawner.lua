local pd <const> = playdate
local gfx <const> = pd.graphics

local GEM_SPAWN_X_OFFSET = 70

class("GemSpawner").extends(gfx.sprite)

function GemSpawner:init(y, yBetweenTriggers)
	GemSpawner.super.init(self)
	self.y = y
    self.yBetweenTriggers = yBetweenTriggers

	self:setCollideRect(0, self.y, 400, 1)
	self:setGroups(5)
	self:setCollidesWithGroups(1)
	self:add()
end

function GemSpawner:collisionResponse(other)
	if other:isa(Player) then
        return gfx.sprite.kCollisionTypeOverlap
    end
end

function GemSpawner:update()
	unused, unused2, collisions, length = self:checkCollisions(0, 0)
    self:executeCollisionResponses(collisions)
end

function GemSpawner:executeCollisionResponses(collisions)
    for i, collision in pairs(collisions) do
		if collision then
            local otherSprite = collision["other"]
            if otherSprite:isa(Player) then
                local newY = self.y - self.yBetweenTriggers
                local gemNewX = math.random(GEM_SPAWN_X_OFFSET, 400 - GEM_SPAWN_X_OFFSET)
                local gem = Gem(gemNewX, newY)
                gem:moveTo(gemNewX, newY)

                local gemSpawner = GemSpawner(newY, self.yBetweenTriggers)
                gemSpawner:moveTo(0, newY)
                self:remove()
            end
        end
    end
end

-- function GemSpawner:playerCollisionResponse(otherSprite, normalX, normalY)
-- 	if otherSprite:isa(Player) then
-- 		otherSprite:hitByGemSpawnerResponse()
-- 	end
-- end