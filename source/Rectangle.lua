local pd <const> = playdate
local gfx <const> = pd.graphics

class("Rectangle").extends(gfx.sprite)

function Rectangle:init(x, y, w, h)
	Rectangle.super.init(self)

	self.x = x
	self.y = y
    self.w = w
    self.h = h

	gfx.setColor(gfx.kColorWhite)
	local rectImage = gfx.image.new(self.w, self.h)
    self:setCenter(0, 0)
	gfx.pushContext(rectImage)
		gfx.fillRect(0, 0, self.w, self.h)
	gfx.popContext()
	gfx.setColor(gfx.kColorBlack)
	self:setImage(rectImage)
	self:add()
    self:moveTo(0, 195)
end

function Rectangle:update()
	self:moveTo(self.x, self.y)
end