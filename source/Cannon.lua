local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/cannon")

local PROJECTILE_DX = 4.5

class("Cannon").extends(gfx.sprite)

function Cannon:init(x, y)
	Cannon.super.init(self)

	self.x = x
	self.y = y
    self.dx = 0
	self.dy = 0
	self.isDangerous = true

	self:setImage(IMAGES:getImage(1))
	self:add()
end

function Cannon:update()
    self:applyVelocities()
	self:moveTo(self.x, self.y)
	self:moveTo(self.x, self.y)
end

function Cannon:applyVelocities()
	self.x += self.dx
	self.y += self.dy
end

function Cannon:shootProjectile()
    Projectile(self.x, self.y, PROJECTILE_DX)
end