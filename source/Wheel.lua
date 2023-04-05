local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/wheel")

class("Wheel").extends(gfx.sprite)

function Wheel:init(x, y)
    Wheel.super.init(self)

    self:setZIndex(101)

    self.rotationI = 1
    self.rotationTimer = pd.frameTimer.new(2)
    self.rotationTimer.discardOnCompletion = false
    self.rotationTimer.repeats = true

    self:setImage(IMAGES:getImage(self.rotationI))
    self:add()
    self:moveTo(x, y)
end

function Wheel:turnClockwise(dy)
    if self.rotationTimer.frame <= 1 then
        return
    end
    if self.rotationI >= #IMAGES then
        self.rotationI = 1
        self:setImage(IMAGES:getImage(self.rotationI))
        return
    end
    self.rotationI += 1
    self:setImage(IMAGES:getImage(self.rotationI))
end

function Wheel:turnCounterClockwise(dy)
    if self.rotationTimer.frame <= 1 then
        return
    end
    if self.rotationI <= 1 then
        self.rotationI = #IMAGES
        self:setImage(IMAGES:getImage(self.rotationI))
        return
    end
    self.rotationI -= 1
    self:setImage(IMAGES:getImage(self.rotationI))
end