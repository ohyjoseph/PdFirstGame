import "GemIndicator"

local pd <const> = playdate
local gfx <const> = pd.graphics
local COLLISION_X_BUFFER = 12
local COLLISION_Y_BUFFER = 12
local IMAGES = gfx.imagetable.new("images/gem")

class("Gem").extends(gfx.sprite)

function Gem:init(x, y)
    Gem.super.init(self)

    self.rotationTimer = pd.frameTimer.new(#IMAGES * 6, 1, #IMAGES)
    self.rotationTimer.repeats = true

    self:setImage(IMAGES:getImage(1))
    local width, height = self:getSize()
    self.gemIndicator = GemIndicator(x, y, height)

    self:setCollideRect(-COLLISION_X_BUFFER, -COLLISION_Y_BUFFER,
        width + COLLISION_X_BUFFER * 2, height + COLLISION_Y_BUFFER * 2)
    self:setGroups(4)
    self:setCollidesWithGroups(1)
    self:add()
    self:moveTo(x, y)
end

function Gem:collisionResponse(other)
    if other:isa(Player) and other.isOnGround then
        addToMultiplier(1)
        self:removeClean()
        SoundManager:playSound(SoundManager.kSoundGemPickup)
        return gfx.sprite.kCollisionTypeOverlap
    end
end

function Gem:update()
    self:checkCollisions(self.x, self.y)
    self:updateSprite()
end

function Gem:updateSprite()
    self:setImage(IMAGES:getImage(math.floor(self.rotationTimer.value + 0.5)))
end

function Gem:removeClean()
    if self.gemIndicator then
        self.gemIndicator:remove()
    end
    self.rotationTimer:remove()
    self:remove()
end
