local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(gfx.sprite)

function Player:init(x, y, r)
	Player.super.init(self)
	self:moveTo(x,y)
	local circleImage = gfx.image.new(r*2, r*2)
	gfx.pushContext(circleImage)
		gfx.fillCircleAtPoint(r,r,r)
	gfx.popContext()
	self:setImage(circleImage)
	self:add()
	
    self.label = {
		x = 155,
		y = 240 - 25,
		xspeed = 0,
		yspeed = 0,
		radius = 25,
		friction = 1.5,
	}
end

function Player:update()
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
	self:moveTo(math.floor(self.label.x), math.floor(self.label.y))
end