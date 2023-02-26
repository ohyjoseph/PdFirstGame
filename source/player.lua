import "CoreLibs/graphics"
import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("player").extends()

function player:init(xspeed, yspeed)
    self.label = {
		x = 155,
		y = 240 - 25,
		xspeed = xspeed,
		yspeed = yspeed,
		radius = 25,
		friction = 1.5,
	}
end

function player:update()
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		self.label.xspeed += 2
	end
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		self.label.xspeed -= 2
	end
	if self.label.xspeed > 0 then
		self.label.xspeed -= self.label.friction
	elseif self.label.xspeed < 0 then
		self.label.xspeed += self.label.friction
	end
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self.label.yspeed -= 2
	end
	if self.label.yspeed < 0 then
		self.label.yspeed += self.label.friction
	end
	self.label.x += self.label.xspeed
	self.label.y += self.label.yspeed
	-- self.label.x = math.floor(self.label.x)
	-- self.label.y = math.floor(self.label.y)
end

function player:draw()
    local label = self.label;
    gfx.fillCircleAtPoint(label.x, label.y, label.radius)
end