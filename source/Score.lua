local screenWidth = playdate.display.getWidth()
local gfx = playdate.graphics

class('Score').extends(playdate.graphics.sprite)

function Score:init(initialScore, initialMultiplier)
	Score.super.init(self)
	self:setIgnoresDrawOffset(true)
	self:setZIndex(900)
	self.scoreFont = gfx.font.new('Score/Roobert-24-Medium-Numerals');
	gfx.setFont(self.scoreFont)
	self:setCenter(1, 0)
	if initialScore then
		self.score = initialScore
	else
		self.score = 0
	end
	if initialMultiplier then
		self.multiplier = initialMultiplier
	else
		self.multiplier = 1
	end
	self:add()
end

function Score:setUpToDraw()
	local displayString = self:getDisplayString()
	local width, height = gfx.getTextSize(displayString)
	self:setSize(width, height)
	self:moveTo(screenWidth - 6, 6)
	self:markDirty()
end

function Score:setScore(newNumber)
	self.score = newNumber
	self:setUpToDraw()
end

function Score:addToScore(value)
	self:setScore(self.score + value)
end

function Score:setMultiplier(newNumber)
	self.multiplier = newNumber
	self:setUpToDraw()
end

function Score:addToMultiplier(value)
	self:setMultiplier(self.multiplier + value)
end

-- draw callback from the sprite library
function Score:draw()
	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	local displayString = self:getDisplayString()
	local width = gfx.getTextSize(displayString)
	gfx.drawTextAligned(displayString, width, 0, kTextAlignment.right);
end

function Score:getDisplayString()
	return "*" .. self.score .. "*\nx" .. self.multiplier
end
