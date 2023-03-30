local pd <const> = playdate
local gfx <const> = pd.graphics

class("Blackout").extends(gfx.sprite)

function Blackout:init()
	Blackout.super.init(self)

    local WIDTH = 420
    local HEIGHT = 260

	self:setZIndex(1003)
	local rectImage = gfx.image.new(WIDTH, HEIGHT)
    self:setCenter(0, 0)
	gfx.pushContext(rectImage)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0)
		gfx.fillRect(0, 0, WIDTH, HEIGHT)
	gfx.popContext()
	self:setImage(rectImage)
	self:add()
    self:moveTo(-10, -10)
end