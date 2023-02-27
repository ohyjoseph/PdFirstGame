local pd <const> = playdate
local gfx <const> = pd.graphics

class("Wall").extends(gfx.sprite)

function Wall:init(x, y, w, h)
	Wall.super.init(self)

	self.x = x
	self.y = y
    self.w = w
    self.h = h

	local rectImage = gfx.image.new(self.w, self.h)
	gfx.pushContext(rectImage)
		gfx.fillRect(0, 0, self.w, self.h)
	gfx.popContext()
	self:setImage(rectImage)
    self:setCollideRect(0, 0, self:getSize())
    self:moveWithCollisions(self.x, self.y)
	self:add()
end

function Wall:update()
	self:moveWithCollisions(self.x, self.y)
end