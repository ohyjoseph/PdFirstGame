local pd <const> = playdate
local gfx <const> = pd.graphics

class("Wall").extends(gfx.sprite)

function Wall:init(x, y, w, h)
	Wall.super.init(self)

	self.x = x
	self.y = y
    self.w = w
    self.h = h

	gfx.setColor(gfx.kColorWhite)
	local rectImage = gfx.image.new(self.w, self.h)
	gfx.pushContext(rectImage)
		gfx.fillRect(0, 0, self.w, self.h)
	gfx.popContext()
	gfx.setColor(gfx.kColorBlack)
	self:setImage(rectImage)
    self:setCollideRect(0, 0, self:getSize())
	self:setGroups(2)
	self:setCollidesWithGroups(1)
	self:add()
    self:moveWithCollisions(self.x, self.y)
end

function Wall:update()
	self:moveWithCollisions(self.x, self.y)
end