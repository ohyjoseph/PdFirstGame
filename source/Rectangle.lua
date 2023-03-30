local pd <const> = playdate
local gfx <const> = pd.graphics

class("Rectangle").extends(gfx.sprite)

function Rectangle:init(x, y, width, height)
	Rectangle.super.init(self)

	self:setZIndex(-1)
	self:setGroups(2)
	local rectImage = gfx.image.new(width, height)
    self:setCenter(0, 0)
	self:setCollideRect(0, 0, width, height)
	gfx.pushContext(rectImage)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, width, height)
		gfx.setLineWidth(2)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(0, 0, width, height)
	gfx.popContext()
	self:setImage(rectImage)
	self:add()
    self:moveTo(x, y)
end