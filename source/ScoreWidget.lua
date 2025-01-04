-- The UI popup that slides down when the results are
-- being displayed to show the current height and max
-- height

local pd <const> = playdate
local scoreboards <const> = pd.scoreboards
local gfx <const> = pd.graphics

class('ScoreWidget').extends(gfx.sprite)

function ScoreWidget:init(score)
    self.showGlobalRankings = false
    self.isLoadingGlobalRankings = false

    self.dialogWidth = 200
    self.dialogHeight = 230
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

function GetScoreBoardsCallbackTest(status, result) 
    print("pizza")
    print(pd.metadata.bundleID)
    print(status.code)
    print(status.message)
    printTable(result)
end

function GetScoresCallbackTest(status, result) 
    print("icecream")
    print(status.code)
    print(status.message)
    printTable(result)
end

function ScoreWidget:update()
    if self.isLoadingGlobalRankings then
        if pd.buttonJustPressed(pd.kButtonA) then
            resetGame()
        end
        self:drawLoadingGlobalRankingsWidget()
        return
    end
    if self.showGlobalRankings == false then
        if pd.buttonJustPressed(pd.kButtonB) then
            self.showGlobalRankings = true
            self.isLoadingGlobalRankings = true
            self.flashTimer:reset()
            self:drawLoadingGlobalRankingsWidget()
            scoreboards.getScores("highscores", function(status, result)
                self.isLoadingGlobalRankings = false
                local dialogImage = gfx.image.new(self.dialogWidth, self.dialogHeight)
                gfx.pushContext(dialogImage)
                gfx.setColor(gfx.kColorWhite)
                gfx.fillRoundRect(0, 0, self.dialogWidth, self.dialogHeight, self.cornerRadius)
                gfx.setColor(gfx.kColorBlack)
                gfx.fillRoundRect(self.borderWidth, self.borderWidth, self.dialogWidth - self.borderWidth * 2,
                self.dialogHeight - self.borderWidth * 2, self.cornerRadius)
                gfx.setColor(gfx.kColorWhite)
                gfx.setImageDrawMode(gfx.kDrawModeInverted)
                gfx.drawTextAligned("*Global Rankings*", self.dialogWidth / 2, 10, kTextAlignment.center)
                local SCORE_Y_OFFSET = 22
                local SCORE_Y_SPACING = 15
                gfx.setFont(self.font)
                for i = #result.scores, 1, -1 do
                    local scoreString
                    if result.scores[i].rank == 1 then
                        scoreString = "1ST "
                    elseif result.scores[i].rank == 2 then
                        scoreString = "2ND "
                    elseif result.scores[i].rank == 3 then
                        scoreString = "3RD "
                    else
                        scoreString = result.scores[i].rank .. "TH "
                    end
                    gfx.setImageDrawMode(gfx.kDrawModeInverted)
                    gfx.drawText(scoreString, self.leftPadding, SCORE_Y_OFFSET + SCORE_Y_SPACING * i)
                    gfx.drawTextAligned(result.scores[i].value, self.leftPadding + 89, SCORE_Y_OFFSET + SCORE_Y_SPACING * i, kTextAlignment.right)
                end
                gfx.setImageDrawMode(gfx.kDrawModeInverted)
                gfx.drawTextAligned("*A* _to restart_", self.dialogWidth / 5, 185, kTextAlignment.left)
                gfx.drawTextAligned("*B* _for high scores_", self.dialogWidth / 5, 205, kTextAlignment.left)
                gfx.popContext()
                self:setImage(dialogImage)
            end)
            print("after getScoresCb")
        else
            self:drawLocalScoresWidget()
        end  
    else
        if pd.buttonJustPressed(pd.kButtonB) then
            self.showGlobalRankings = false
            self.isLoadingGlobalRankings = false
            self.flashTimer:reset()
            self:drawLocalScoresWidget()
        else
            if self.isLoadingGlobalRankings then
                self:drawLoadingGlobalRankingsWidget()
            end
        end
    end
    if pd.buttonJustPressed(pd.kButtonA) then
        resetGame()
    end
end

function ScoreWidget:drawLocalScoresWidget()
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
    gfx.setFont(self.font)
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
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    gfx.drawTextAligned("*A* _to restart_", self.dialogWidth / 5, 185, kTextAlignment.left)
    gfx.drawTextAligned("*B* _for global rankings_", self.dialogWidth / 5, 205, kTextAlignment.left)
    gfx.popContext()
    self:setImage(dialogImage)
end

function ScoreWidget:drawLoadingGlobalRankingsWidget()
    local dialogImage = gfx.image.new(self.dialogWidth, self.dialogHeight)
    gfx.pushContext(dialogImage)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(0, 0, self.dialogWidth, self.dialogHeight, self.cornerRadius)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(self.borderWidth, self.borderWidth, self.dialogWidth - self.borderWidth * 2,
    self.dialogHeight - self.borderWidth * 2, self.cornerRadius)
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    if self.flashTimer.frame <= self.flashTimer.duration * 0.5 then
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
    else
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    end
    gfx.drawTextAligned("*Loading...*", self.dialogWidth / 2, 10, kTextAlignment.center)
    gfx.popContext()
    self:setImage(dialogImage)
end
