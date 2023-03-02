local pd <const> = playdate
local gfx <const> = pd.graphics

local WIDTH = 40
local HEIGHT = 10
local VELOCITY = 3

class("Projectile").extends(gfx.sprite)

function Projectile:init(x, y)
	Projectile.super.init(self)

	self.x = x
	self.y = y
    self.dx = VELOCITY

	local rectImage = gfx.image.new(WIDTH, HEIGHT)
	gfx.pushContext(rectImage)
		gfx.fillRect(0, 0, WIDTH, HEIGHT)
	gfx.popContext()
	self:setImage(rectImage)
    self:setCollideRect(0, 0, self:getSize())
	self:setGroups(2)
	self:setCollidesWithGroups(1)
	self:add()
    self:moveWithCollisions(self.x, self.y)
end

function Projectile:update()
    self:applyVelocities()
	self:moveWithCollisions(self.x, self.y)
end

function Projectile:applyVelocities()
	self.x += self.dx
end