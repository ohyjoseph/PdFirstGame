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
	self:setGroups(3)
	self:setCollidesWithGroups(1)
	self:add()
    self:moveWithCollisions(self.x, self.y)
end

function Projectile:update()
    self:applyVelocities()
	self:moveWithCollisions(self.x, self.y)
    self:removeSelf()
end

function Projectile:applyVelocities()
	self.x += self.dx
end

function Projectile:removeSelf()
    if self.x > 500 or self.x < -50 then
        self:remove()
    end
end

-- function Player:executeCollisionResponses(collisions)
-- 	local isTouchingAFloor = false
	
-- 	for i, collision in pairs(collisions) do
-- 		if collision then
-- 			local coor = collision["normal"]
-- 			local x, y = coor:unpack()
-- 			if y == -1 then
-- 				isTouchingAFloor = true
-- 			end
-- 		end
-- 	end

-- 	if isTouchingAFloor then
-- 		self.onGround = true
-- 		self.dy = 0
-- 		self.jumpTimer:pause()
-- 		self.jumpTimer:reset()
-- 		self.coyoteTimer:pause()
-- 		self.coyoteTimer:reset()
-- 	else
--	    self.onGround = false
-- 		self.coyoteTimer:start()
-- 	end
-- 	print(self.coyoteTimer.frame)
-- end