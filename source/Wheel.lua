local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/wheel")

class("Wheel").extends(gfx.sprite)

function Wheel:init(x, y)
	Wheel.super.init(self)

    self:setZIndex(101)

	self:setImage(IMAGES:getImage(1))
	self:add()
    self:moveTo(x, y)
end