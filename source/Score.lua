local screenWidth = playdate.display.getWidth()
local gfx = playdate.graphics

class('Score').extends(playdate.graphics.sprite)

function Score:init()

	Score.super.init(self)
	self.scoreFont = gfx.font.new('Score/Roobert-24-Medium-Numerals');
	self:setCenter(1,0)
	self:setScore(0)
	self:setMultiplier(1)
	self:add()
end


function Score:setScore(newNumber)
	self.score = newNumber
	
	gfx.setFont(self.scoreFont)
	local width = gfx.getTextSize(self.score)
	self:setSize(width, 36)
	self:moveTo(screenWidth - 6, 6)
	self:markDirty()
end

function Score:addToScore(value)
	self:setScore(self.score + value)
end

function Score:setMultiplier(newNumber)
	self.multiplier = newNumber
	
	-- gfx.setFont(self.multiplierFont)
	-- local width = gfx.getTextSize(self.multiplier)
	-- self:setSize(width, 36)
	-- self:moveTo(screenWidth - 6, 6)
	-- self:markDirty()
end

function Score:addToMultiplier(value)
	self:setMultiplier(self.multiplier + value)
end

-- draw callback from the sprite library
function Score:draw(x, y, width, height)
	
	gfx.setFont(self.scoreFont)
	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	gfx.drawText(self.score, 0, 0);
		
end
