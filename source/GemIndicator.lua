local pd <const> = playdate
local gfx <const> = pd.graphics
local image = gfx.image.new("images/GemIndicator")

class("GemIndicator").extends(gfx.sprite)

function GemIndicator:init(x, gemY, gemHeight)
    GemIndicator.super.init(self)

    self.smallestGemY = gemY + gemHeight / 2

    self:setZIndex(899)
    self:setIgnoresDrawOffset(true)
    self:setCenter(0.5, 0)
    self:setImage(image)
    self:add()
    self:moveTo(x, 0)
end

function GemIndicator:update()
    self:removeIfGemOnScreen()
end

function GemIndicator:removeIfGemOnScreen()
    if self:isGemOnScreen() then
        self:remove()
    end
end

function GemIndicator:isGemOnScreen(sprite)
    local xOffset, yOffset = gfx.getDrawOffset()
    if yOffset + self.smallestGemY > 0 then
        return true
    end
    return false
end
