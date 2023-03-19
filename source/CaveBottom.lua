local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.image.new("images/caveBottom")

class("CaveBottom").extends(gfx.sprite)

function CaveBottom:init(x, y, dx)
	CaveBottom.super.init(self)

	self.image = gfx.image.new("images/caveBottom")
	self:setImage(self.image)
	self:add()
    self:setZIndex(-1)

    self:setCenter(1, 1)
    self:moveTo(400, 240)
end