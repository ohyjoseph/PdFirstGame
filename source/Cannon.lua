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
    self.goalY = 0

	self:setImage(IMAGES:getImage(1))
	self:add()
    self:setCenter(0, 0.5)
    self:moveTo(self.x, self.y)
end

function Cannon:update()
    self:applyVelocities()
    self:moveTowardGoalY()
	self:moveTo(self.x, self.y)
end

function Cannon:applyVelocities()
	self.x += self.dx
	self.y += self.dy
end

function Cannon:moveTowardGoalY()
    if self.y == self.goalY then
        return
    elseif self.y < self.goalY then
        self.y += 1
    elseif self.y > self.goalY then
        self.y -= 1
    end
end

function Cannon:updateGoalY(y)
    self.goalY = y
end

function Cannon:shootProjectile()
    local projectile = Projectile(self.x, self.y, PROJECTILE_DX)
    projectile:moveTo(self.x, self.y)
    
end