local pd <const> = playdate
local gfx <const> = pd.graphics

class("Blackout").extends(gfx.sprite)

function Blackout:init()
	Blackout.super.init(self)

    local WIDTH = 420
    local HEIGHT = 260

    self.blackAnimator = gfx.animator.new(100, 1, 0, playdate.easingFunctions.linear)
    self.clearAnimator = gfx.animator.new(100, 0, 1, playdate.easingFunctions.linear, 500)
    self.blackAnimator2 = gfx.animator.new(100, 1, 0, playdate.easingFunctions.linear, 500 + 100 + 100 + 400)
    self.clearAnimator2 = gfx.animator.new(100, 0, 1, playdate.easingFunctions.linear, 500 + 100 + 100 + 400 + 100 + 800)
    self.blackAnimator3 = gfx.animator.new(150, 1, 0, playdate.easingFunctions.linear, 500 + 100 + 100 + 400 + 100 + 800 + 400)

	self:setZIndex(1003)
	local rectImage = gfx.image.new(WIDTH, HEIGHT)
    self:setCenter(0, 0)
	gfx.pushContext(rectImage)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(self.blackAnimator:currentValue())
		gfx.fillRect(0, 0, WIDTH, HEIGHT)
	gfx.popContext()
	self:setImage(rectImage)
	self:add()
    self:moveTo(-10, -10)
end

function Blackout:update()
    local ditherValue = self.blackAnimator:currentValue()
    if self.blackAnimator:ended() then
        ditherValue = self.clearAnimator:currentValue()
        if self.clearAnimator:ended() then
            if not self.blackAnimator2:ended() then
                print("WHT")
                ditherValue = self.blackAnimator2:currentValue()
            else
                if not self.clearAnimator2:ended() then
                    ditherValue = self.clearAnimator2:currentValue()
                else
                    if not self.blackAnimator3:ended() then
                        print("HELLO", self.blackAnimator3:currentValue())
                        ditherValue = self.blackAnimator3:currentValue()
                    else
                        ditherValue = 0
                    end
                end
            end
        end
    else
        ditherValue = self.blackAnimator:currentValue()
    end

    local rectImage = gfx.image.new(self.width, self.height)
    gfx.pushContext(rectImage)
		gfx.setColor(gfx.kColorBlack)
        print("BLACK", ditherValue)
		gfx.setDitherPattern(ditherValue)
		gfx.fillRect(0, 0, self.width, self.height)
	gfx.popContext()
	self:setImage(rectImage)
end