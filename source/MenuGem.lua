local pd <const> = playdate
local gfx <const> = pd.graphics

local SCREEN_SHAKE_DELAY_FRAMES = 20
local TRANSTION_FRAMES = 65
local BLACKOUT_DELAY_FRAMES = 30

class("MenuGem").extends(Gem)

function MenuGem:init(x, y)
	MenuGem.super.init(self)

	self:setCollideRect(-10, 0, 47, 20)
    self:moveTo(x, y)
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
                        if playdate.buttonJustPressed(playdate.kButtonB) then
                            otherSprite.isHoldingGem = true
                            self:setZIndex(1001)
                            if otherSprite.isFacingRight then
                                self:moveTo(otherSprite.x + otherSprite.dx + 11, self.y - 10)
                            else
                                self:moveTo(otherSprite.x + otherSprite.dx - 11, self.y - 10)
                            end
                            pd.frameTimer.new(SCREEN_SHAKE_DELAY_FRAMES, function()
                                shouldCameraShake = true
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
end