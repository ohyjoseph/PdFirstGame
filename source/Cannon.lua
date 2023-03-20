local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/cannon")

local PROJECTILE_DX = 4.5

class("Cannon").extends(gfx.sprite)

function Cannon:init(x, y, isFacingRight)
	Cannon.super.init(self)

	self.x = x
	self.y = y
    self.dx = 0
	self.dy = 0
    self.goalY = 0
    self.isFacingRight = isFacingRight

    self.projectileDx = PROJECTILE_DX
    if not self.isFacingRight then
        self.projectileDx *= -1
    end

	self:setImage(IMAGES:getImage(1), self:getSpriteOrientation())
	self:add()
    if self.isFacingRight then
        self:setCenter(0, 0.5)
    else
        self:setCenter(1, 0.5)
    end
        
    self:moveTo(self.x, self.y)
end

function Cannon:update()
    self:applyVelocities()
    self:moveTowardGoalY()
	self:moveTo(self.x, self.y)
end

function Cannon:getSpriteOrientation()
	if self.isFacingRight then
		return gfx.kImageUnflipped
	else
		return gfx.kImageFlippedX
	end
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
    local projectile = Projectile(self.x, self.y, self.projectileDx, self.isFacingRight)
    projectile:moveTo(self.x, self.y)
end