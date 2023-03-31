local pd <const> = playdate
local gfx <const> = pd.graphics

class("Platform").extends(gfx.sprite)

function Platform:init(x, y)
	Platform.super.init(self)

	self.x = x
	self.y = y
	self.hasTouchedLava = false

	self.image = gfx.image.new("images/platform")
	self:setImage(self.image)
    self:setCollideRect(0, 0, self:getSize())
	self:setGroups(2)
	self:setCollidesWithGroups(1)
	self:moveTo(x, y)
	self:add()
end