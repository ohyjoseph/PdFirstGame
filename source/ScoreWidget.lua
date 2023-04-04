-- The UI popup that slides down when the results are
-- being displayed to show the current height and max
-- height

local pd <const> = playdate
local gfx <const> = pd.graphics

class('ScoreWidget').extends(gfx.sprite)

function ScoreWidget:init(score)
    self.dialogWidth = 240
    self.dialogHeight = 140
    self.leftPadding = 30

    self.score = score

    -- It's good practice to have these "magic numbers"
    -- be stored into a variable with a name for better
    -- readability
    self.borderWidth = 3
    self.cornerRadius = 3

    self:setCenter(0.5, 0.5)
    self:setIgnoresDrawOffset(true)

    -- Making sure this sits on top of everything else
    self:setZIndex(2000)

    local dialogImage = gfx.image.new(self.dialogWidth, self.dialogHeight)
    gfx.pushContext(dialogImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, self.dialogWidth, self.dialogHeight, self.cornerRadius)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(self.borderWidth, self.borderWidth, self.dialogWidth - self.borderWidth * 2, self.dialogHeight  - self.borderWidth * 2, self.cornerRadius)
        gfx.setColor(gfx.kColorWhite)
        local scoreText = "Score: " .. self.score
        if self.score > HIGH_SCORE then
            SAVE_HIGH_SCORE(self.score)
            newHighScore = true
        else
            newHighScore = false
        end
        local highScoreText = "High Score: " .. HIGH_SCORE
        if newHighScore then
            highScoreText = highScoreText .. " - *NEW*"
        end
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        gfx.drawTextAligned("*Bye Bye Gaery*", self.dialogWidth / 2, 10, kTextAlignment.center)
        gfx.drawText(scoreText, self.leftPadding, 45)
        gfx.drawText(highScoreText, self.leftPadding, 75)
        gfx.drawTextAligned("_Press_ *A* _to restart_", self.dialogWidth / 2, 110, kTextAlignment.center)
    gfx.popContext()
    self:setImage(dialogImage)

    self:add()
end

function ScoreWidget:update()
    if playdate.buttonJustPressed(playdate.kButtonA) then
		resetGame()
	end
end