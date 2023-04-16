local pd <const> = playdate
local gfx <const> = pd.graphics

local GEM_SPAWN_X_OFFSET = 70

class("GemSpawner").extends(gfx.sprite)

function GemSpawner:init(y, yBetweenTriggers)
    GemSpawner.super.init(self)
    self.yBetweenTriggers = yBetweenTriggers

    self:setCollideRect(0, self.y, 400, 1)
    self:setGroups(5)
    self:setCollidesWithGroups(1)
    self:moveTo(0, y)
    self:add()
end

function GemSpawner:collisionResponse(other)
    if other:isa(Player) then
        return gfx.sprite.kCollisionTypeOverlap
    end
end

function GemSpawner:update()
    unused, unused2, collisions, length = self:checkCollisions(self.x, self.y)
    self:executeCollisionResponses(collisions)
end

function GemSpawner:executeCollisionResponses(collisions)
    for i, collision in pairs(collisions) do
        if collision then
            local otherSprite = collision["other"]
            if otherSprite:isa(Player) then
                local newY = self.y - self.yBetweenTriggers
                local gemNewX = math.random(GEM_SPAWN_X_OFFSET, 400 - GEM_SPAWN_X_OFFSET)
                Gem(gemNewX, newY)
                self:moveWithCollisions(self.x, newY)
            end
        end
    end
end