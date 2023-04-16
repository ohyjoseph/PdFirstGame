local pd <const> = playdate
local gfx <const> = pd.graphics

class('TipWidget').extends(gfx.sprite)

function TipWidget:init(text)
    self.dialogWidth = 200
    self.dialogHeight = 35
    self.leftPadding = 56
    self.text = text
    self.font = gfx.font.new('font/Mini Sans');
    gfx.setFont(self.font)

    self.flashTimer = pd.frameTimer.new(60)
	self.flashTimer.discardOnCompletion = false
    self.flashTimer.repeats = true

    self.borderWidth = 2
    self.cornerRadius = 5

    self:setCenter(0.5, 0)
    self:setIgnoresDrawOffset(true)

    -- Making sure this sits on top of everything else
    self:setZIndex(2000)

    self:add()
end

function TipWidget:update()
    self:drawWidget()
end

function TipWidget:drawWidget()
    local dialogImage = gfx.image.new(self.dialogWidth, self.dialogHeight)
    gfx.pushContext(dialogImage)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(0, 0, self.dialogWidth, self.dialogHeight, self.cornerRadius)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(self.borderWidth, self.borderWidth, self.dialogWidth - self.borderWidth * 2,
    self.dialogHeight - self.borderWidth * 2, self.cornerRadius)
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    gfx.setFont(self.font)
    gfx.drawTextAligned(self.text, self.dialogWidth / 2, 10, kTextAlignment.center)
    local SCORE_Y_OFFSET = 22
    local SCORE_Y_SPACING = 15
    local alreadyFoundNew = false

    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    gfx.popContext()
    self:setImage(dialogImage)
end
