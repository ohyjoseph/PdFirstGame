local pd <const> = playdate
local gfx <const> = pd.graphics

local SCREEN_SHAKE_DELAY_FRAMES = 20
local TRANSTION_FRAMES = 120
local BLACKOUT_DELAY_FRAMES = 50

class("MenuGem").extends(Gem)

function MenuGem:init(x, y)
    MenuGem.super.init(self, x, y)

    self:setCollideRect(0, 0, 27, 20)
end

function MenuGem:collisionResponse(other)
    if other:isa(Player) then
        return gfx.sprite.kCollisionTypeOverlap
    end
end

function MenuGem:update()
    local x, y, collisions = self:checkCollisions(self.x, self.y)
    self:checkCollisionsResponse(collisions)
    self:updateSprite()
end

function MenuGem:checkCollisionsResponse(collisions)
    for i, collision in pairs(collisions) do
        if collision then
            local otherSprite = collision["other"]
            if otherSprite:isa(Player) then
                if otherSprite.isOnGround then
                    if not otherSprite.isHoldingGem then
                        otherSprite.isHoldingGem = true
                        self:setZIndex(1001)
                        if otherSprite.isFacingRight then
                            self:moveTo(otherSprite.x + otherSprite.dx + 11, self.y - 10)
                        else
                            self:moveTo(otherSprite.x + otherSprite.dx - 11, self.y - 10)
                        end
                        pd.frameTimer.new(SCREEN_SHAKE_DELAY_FRAMES, function()
                            shouldCameraShake = true
                            SoundManager:playSound(SoundManager.kSoundQuake)
                            pd.frameTimer.new(BLACKOUT_DELAY_FRAMES, function()
                                local blackout = Blackout()
                                pd.frameTimer.new(TRANSTION_FRAMES, function()
                                    isMenuGemCollected = true
                                    gfx.sprite.removeAll()
                                end)
                            end)
                        end)
                    end
                end
            end
        end
    end
end
