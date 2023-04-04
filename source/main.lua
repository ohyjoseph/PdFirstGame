import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Platform"
import "Rectangle"
import "Cannon"
import "Projectile"
import "Gem"
import "GemSpawner"
import "Score"
import "SoundManager"
import "Fluid"
import "CaveBottom"

import "MenuScene"
import "GameScene"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

DEFAULT_FONT = gfx.getFont()

isMenuGemCollected = false

local hasUsedMenuScene = false
local isInGameScene = false
local shakeTable = {counter = 0, prevX = 0, prevY = 0}

local scene

local menu = playdate.getSystemMenu()
menu:addMenuItem("Back to Intro", function()
	reset()
	hasUsedMenuScene = false
	isInGameScene = false
	isMenuGemCollected = false
end)
menu:addMenuItem("Restart Run", function()
	reset()
	hasUsedMenuScene = true
	isMenuGemCollected = true
	isInGameScene = false
end)

function playdate.update()
	if not hasUsedMenuScene then
		scene = MenuScene()
		hasUsedMenuScene = true
	end

	if isMenuGemCollected and not isInGameScene then
		scene = GameScene()
		isInGameScene = true
	end

	scene:update()

	gfx.sprite.update()
	FrameTimer_update()
end

function reset()
	gfx.sprite.removeAll()
	for i, timer in pairs(playdate.frameTimer.allTimers()) do
		timer:remove()
	end
	shouldCameraShake = false
	shakeTable = {counter = 0, prevX = 0, prevY = 0}
end

function cameraShake()
    shakeTable.counter += 1
    x, y = gfx.getDrawOffset()
    if shakeTable.counter % 6 == 0 then
        gfx.setDrawOffset(x + math.random(-3, 3), y + math.random(-3, 3))
		shakeTable.prevX = x
		shakeTable.prevY = y
    elseif shakeTable.counter % 3 == 0 then
        gfx.setDrawOffset(shakeTable.prevX, shakeTable.prevY)
    end
end

function arrayFirstFiveEqual(table1, table2)
	for i = 1, 5 do
		if table1[i] ~= table2[i] then
			return false
		end
	end
	return true
end

function SAVE_HIGH_SCORE(newScore)
	local forLength = 5
	local highScoresLength = #HIGH_SCORES
	if highScoresLength < forLength then
		forLength = highScoresLength
	end
	local newHighScores = {}
	table.sort(HIGH_SCORES, function(a, b)
		return a > b
	end)
	for i = 1, forLength do
		table.insert(newHighScores, HIGH_SCORES[i])
	end
	table.insert(newHighScores, newScore)
	table.sort(newHighScores, function(a, b)
		return a > b
	end)

	local highScoreTablesEqual = arrayFirstFiveEqual(HIGH_SCORES, newHighScores)
	if not highScoreTablesEqual then
		local highScoresToSave = {}
		for i = 1, forLength do
			table.insert(highScoresToSave, newHighScores[i])
		end
		playdate.datastore.write(highScoresToSave)
		HIGH_SCORES = highScoresToSave
	end
	return not highScoreTablesEqual
end

function LOAD_HIGH_SCORES()
    local gameData = playdate.datastore.read()
    if gameData then
        return gameData
    end
	return {}
end

function GET_HIGH_SCORE()
	local highScores = LOAD_HIGH_SCORES()
	local highScoresLength = #highScores
	if highScoresLength < 1 then
		return 0
	else
		return highScores[highScoresLength]
	end
end

HIGH_SCORES = LOAD_HIGH_SCORES()
HIGH_SCORE = GET_HIGH_SCORE()
-- SAVE_HIGH_SCORE(1)