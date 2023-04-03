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
    print("SCORE", score)

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
        -- gfx.setColor(gfx.kColorBlack)
        -- gfx.fillRoundRect(0, 0, self.dialogWidth, self.dialogHeight, self.cornerRadius)
        -- gfx.setColor(gfx.kColorWhite)
        -- gfx.fillRoundRect(self.borderWidth, self.borderWidth, self.dialogWidth - self.borderWidth * 2, self.dialogHeight  - self.borderWidth * 2, self.cornerRadius)
        -- gfx.setColor(gfx.kColorBlack)
        -- local scoreText = "Height: " .. self.score
        -- local newHighScore = false
        -- -- Here, I check if the height we're at is greater than the current
        -- -- max height. Then, I make sure to update it
        -- if self.score > HIGH_SCORE then
        --     SAVE_HIGH_SCORE(self.score)
        --     newHighScore = true
        -- end
        -- local highScoreText = "Max Height: " .. HIGH_SCORE
        -- if newHighScore then
        --     highScoreText = highScoreText .. " - *NEW*"
        -- end
        -- gfx.drawTextAligned("*Bye Bye Gaery*", self.dialogWidth / 2, 10, kTextAlignment.center)
        -- gfx.drawText(scoreText, self.leftPadding, 45)
        -- gfx.drawText(highScoreText, self.leftPadding, 75)
        gfx.drawTextAligned("_Press_ *A* _to restart_", self.dialogWidth / 2, 110, kTextAlignment.center)
    gfx.popContext()
    self:setImage(dialogImage)

    self:moveTo(200, -self.dialogHeight / 2)
    self:add()
end