local pd <const> = playdate
local gfx <const> = pd.graphics

class("Clearout").extends(gfx.sprite)

function Clearout:init()
	Clearout.super.init(self)

	local WIDTH = 420
	local HEIGHT = 260

	self.clearAnimator = gfx.animator.new(200, 0, 1, playdate.easingFunctions.linear, 100)

	self:setZIndex(1003)
	local rectImage = gfx.image.new(WIDTH, HEIGHT)
	self:setCenter(0, 0)
	gfx.pushContext(rectImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.setDitherPattern(self.clearAnimator:currentValue())
	gfx.fillRect(0, 0, WIDTH, HEIGHT)
	gfx.popContext()
	self:setImage(rectImage)
	self:add()
	self:moveTo(-10, -10)

	pd.frameTimer.new(15, function()
		self:remove()
	end)
end

function Clearout:update()
	local rectImage = gfx.image.new(self.width, self.height)
	gfx.pushContext(rectImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.setDitherPattern(self.clearAnimator:currentValue())
	gfx.fillRect(0, 0, self.width, self.height)
	gfx.popContext()
	self:setImage(rectImage)
end
