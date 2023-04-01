local pd <const> = playdate
local gfx <const> = pd.graphics

class("Pillar").extends(gfx.sprite)

function Pillar:init(x, y)
	Pillar.super.init(self)

	self.image = gfx.image.new("images/pillar")
	self:setImage(self.image)
	self:moveTo(x, y)
	self:add()
end
