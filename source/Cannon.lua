local pd <const> = playdate
local gfx <const> = pd.graphics
local IMAGES = gfx.imagetable.new("images/cannon")

local PROJECTILE_DX = 4.5
local SHOOT_PREP_FRAMES = 10
local SHOOT_FRAMES = 10
local COOLDOWN_FRAMES = 20
local PROJECTILE_X_OFFSET = 45

class("Cannon").extends(gfx.sprite)

function Cannon:init(x, y, isFacingRight)
	Cannon.super.init(self)

    self.wheel = Wheel(x, y)

    self:setZIndex(100)

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
        self.kSound = SoundManager.kSoundCannonShotLeft
    else
        self:setCenter(1, 0.5)
        self.kSound = SoundManager.kSoundCannonShotRight
    end
        
    self:moveTo(x, y)
end

function Cannon:update()
    self:updateDyTowardGoalY()
	self:moveTo(self.x, self.y + self.dy)
    if self.isFacingRight then
        self.wheel:moveTo(self.x + 9, self.y + 15)
        if self.dy > 0 then
            self.wheel:turnClockwise()
        elseif self.dy < 0 then
            self.wheel:turnCounterClockwise()
        end
    else
        self.wheel:moveTo(self.x - 9, self.y + 15)
        if self.dy > 0 then
            self.wheel:turnCounterClockwise()
        elseif self.dy < 0 then
            self.wheel:turnClockwise()
        end
    end
end

function Cannon:getSpriteOrientation()
	if self.isFacingRight then
		return gfx.kImageUnflipped
	else
		return gfx.kImageFlippedX
	end
end

function Cannon:updateDyTowardGoalY()
    if not self.movementAllowed or self.y == self.goalY then
        self.dy = 0
    elseif self.y < self.goalY and self.dy < 1 then
        self.dy += 1
    elseif self.y > self.goalY and self.dy > -1 then
        self.dy -= 1
    end
end

function Cannon:updateGoalY(y)
    self.goalY = y
end

function Cannon:startShootingProjectile()
    self:setImage(IMAGES:getImage(2), self:getSpriteOrientation())
    self.movementAllowed = false
    pd.frameTimer.new(SHOOT_PREP_FRAMES, function()
        self:startShootingProjectile2()
    end)
end

function Cannon:startShootingProjectile2()
    self:setImage(IMAGES:getImage(3), self:getSpriteOrientation())
    self.movementAllowed = false
    pd.frameTimer.new(SHOOT_PREP_FRAMES, function()
        self:startShootingProjectile3()
    end)
end

function Cannon:startShootingProjectile3()
    self:setImage(IMAGES:getImage(4), self:getSpriteOrientation())
    self.movementAllowed = false
    pd.frameTimer.new(SHOOT_PREP_FRAMES, function()
        self:shootProjectile()
    end)
end

function Cannon:shootProjectile()
    SoundManager:playSound(self.kSound)

    self:setImage(IMAGES:getImage(5), self:getSpriteOrientation())
    Projectile(self.x + self.projectileXOffset, self.y, self.projectileDx, self.isFacingRight)
    pd.frameTimer.new(SHOOT_FRAMES, function()
        self:cooldown()
    end)
end

function Cannon:cooldown()
    self:setImage(IMAGES:getImage(6), self:getSpriteOrientation())
    pd.frameTimer.new(COOLDOWN_FRAMES, function()
        self.movementAllowed = true
        self:setImage(IMAGES:getImage(1), self:getSpriteOrientation())
    end)
end