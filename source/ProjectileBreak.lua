local pd <const> = playdate
local gfx <const> = pd.graphics

local IMAGES = gfx.imagetable.new("images/boulderBreak")

class("ProjectileBreak").extends(gfx.sprite)

function ProjectileBreak:init(x, y, dx)
	ProjectileBreak.super.init(self)

    self:setCenter(0.5, 0)

    self.dx = dx
    self.breakTimer = pd.frameTimer.new(#IMAGES, function()
        self.breakTimer:remove()
        self:remove()
    end)

	self:setZIndex(1001)
	self:setImage(IMAGES:getImage(1))
	self:moveTo(x, y)
	self:add()
end

function ProjectileBreak:update()
    self:setImage(IMAGES:getImage(self.breakTimer.frame))
    self:moveTo(self.x + self.dx, self.y)
end