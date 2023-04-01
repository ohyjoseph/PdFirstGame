local pd <const> = playdate
local gfx <const> = pd.graphics

class("Rope").extends(gfx.sprite)

function Rope:init(x, y)
	Rope.super.init(self)

	self:setCenter(0.5, 0)
	self.image = gfx.image.new("images/rope")
	self:setImage(self.image)
	self:moveTo(x, y)
	self:add()
end
