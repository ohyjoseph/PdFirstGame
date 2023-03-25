local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/cannon")

local PROJECTILE_DX = 4.5
local SHOOT_PREP_FRAMES = 35
local SHOOT_FRAMES = 10
local COOLDOWN_FRAMES = 20
local PROJECTILE_X_OFFSET = 45

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
    self.projectileXOffset = PROJECTILE_X_OFFSET
    self.movementAllowed = true

    if not self.isFacingRight then
        self.projectileDx *= -1
        self.projectileXOffset *= -1
    end

	self:setImage(IMAGES:getImage(1), self:getSpriteOrientation())
	self:add()
    if self.isFacingRight then
        self:setCenter(0, 0.5)
    else
        self:setCenter(1, 0.5)
    end
        
    self:moveTo(x, y)
end

function Cannon:update()
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

function Cannon:moveTowardGoalY()
    if not self.movementAllowed then
        return
    end
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

function Cannon:startShootingProjectile()
    self:setImage(IMAGES:getImage(2), self:getSpriteOrientation())
    self.movementAllowed = false
    pd.frameTimer.new(SHOOT_PREP_FRAMES, function()
        self:shootProjectile()
    end)
end

function Cannon:shootProjectile()
    self:setImage(IMAGES:getImage(3), self:getSpriteOrientation())
    local projectile = Projectile(self.x + self.projectileXOffset, self.y, self.projectileDx, self.isFacingRight)
    pd.frameTimer.new(SHOOT_FRAMES, function()
        self:cooldown()
    end)
end

function Cannon:cooldown()
    self:setImage(IMAGES:getImage(4), self:getSpriteOrientation())
    pd.frameTimer.new(COOLDOWN_FRAMES, function()
        self.movementAllowed = true
        self:setImage(IMAGES:getImage(1), self:getSpriteOrientation())
    end)
end