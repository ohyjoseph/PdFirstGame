-- The UI popup that slides down when the results are
-- being displayed to show the current height and max
-- height

local pd <const> = playdate
local gfx <const> = pd.graphics

class('ScoreWidget').extends(gfx.sprite)

function ScoreWidget:init(score)
    self.dialogWidth = 200
    self.dialogHeight = 140
    self.leftPadding = 56
    self.font = gfx.font.new('font/Air Buster');
    gfx.setFont(self.font)

    self.score = score

    self.flashTimer = pd.frameTimer.new(60)
	self.flashTimer.discardOnCompletion = false
    self.flashTimer.repeats = true

    -- It's good practice to have these "magic numbers"
    -- be stored into a variable with a name for better
    -- readability
    self.borderWidth = 2
    self.cornerRadius = 5

    self:setCenter(0.5, 0.5)
    self:setIgnoresDrawOffset(true)

    -- Making sure this sits on top of everything else
    self:setZIndex(2000)

    self:add()

    self.highScoresChanged = SAVE_HIGH_SCORE(self.score)
end

function ScoreWidget:update()
    self:drawWidget()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        resetGame()
    end
end

function ScoreWidget:drawWidget()
    local dialogImage = gfx.image.new(self.dialogWidth, self.dialogHeight)
    gfx.pushContext(dialogImage)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(0, 0, self.dialogWidth, self.dialogHeight, self.cornerRadius)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(self.borderWidth, self.borderWidth, self.dialogWidth - self.borderWidth * 2,
    self.dialogHeight - self.borderWidth * 2, self.cornerRadius)
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    gfx.drawTextAligned("*High Scores*", self.dialogWidth / 2, 10, kTextAlignment.center)
    local SCORE_Y_OFFSET = 22
    local SCORE_Y_SPACING = 15
    local alreadyFoundNew = false

    for i = #HIGH_SCORES, 1, -1 do
        local highScore = HIGH_SCORES[i]
        local isNewHighScore = false
        if not alreadyFoundNew and self.highScoresChanged and highScore == self.score then
            alreadyFoundNew = true
            isNewHighScore = true
            self.newHighScoreI = i
        end
        local scoreString
        if i == 1 then
            scoreString = "1ST "
        elseif i == 2 then
            scoreString = "2ND "
        elseif i == 3 then
            scoreString = "3RD "
        else
            scoreString = i .. "TH "
        end
        print("hi", i, self.newHighScoreI)
        if i == self.newHighScoreI then
            if self.flashTimer.frame <= self.flashTimer.duration * 0.67 then
                gfx.setImageDrawMode(gfx.kDrawModeInverted)
            else
                gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
            end
        else
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
        end
        gfx.drawText(scoreString, self.leftPadding, SCORE_Y_OFFSET + SCORE_Y_SPACING * i)
        gfx.drawTextAligned(HIGH_SCORES[i], self.leftPadding + 89, SCORE_Y_OFFSET + SCORE_Y_SPACING * i, kTextAlignment.right)
        if isNewHighScore then
            gfx.drawText("NEW", self.leftPadding + 99, SCORE_Y_OFFSET + SCORE_Y_SPACING * i)
        end
    end
    gfx.drawTextAligned("_Press_ *A* _to restart_", self.dialogWidth / 2, 115, kTextAlignment.center)
    gfx.popContext()
    self:setImage(dialogImage)
end
