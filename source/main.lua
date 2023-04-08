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
music = playdate.sound.fileplayer.new("sound/lavaLoop")

local menu = playdate.getSystemMenu()
menu:addOptionsMenuItem("Lava Vol", {"off", "low", "med", "high"}, "med", function(volumeText)
	music:setVolume(translateMenuVolume(volumeText))
	SAVE_LAVA_VOLUME()
end)
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
	music:pause()
	gfx.sprite.removeAll()
	for i, timer in pairs(playdate.frameTimer.allTimers()) do
		timer:remove()
	end
	shouldCameraShake = false
	shakeTable = {counter = 0, prevX = 0, prevY = 0}
end

function getLavaVolume()
	return translateMenuVolume(menu:getMenuItems()[1]:getValue())
end

function translateMenuVolume(volumeText)
	if volumeText == "low" then
		return 0.33
	elseif volumeText == "med" then
		return 0.66
	elseif volumeText == "high" then
		return 1
	end
	return 0
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
	if forLength < 5 then
		forLength += 1
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
    if gameData and type(gameData) == "table" then
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

function SAVE_LAVA_VOLUME()
	local newLavaVolumeTable = {}
	table.insert(newLavaVolumeTable, menu:getMenuItems()[1]:getValue())
	playdate.datastore.write(newLavaVolumeTable, "lavaVolume")
end

function LOAD_LAVA_VOLUME()
	return playdate.datastore.read("lavaVolume")
end


function initLavaVolume()
	local lavaVolumeTable = LOAD_LAVA_VOLUME()
	if lavaVolumeTable and lavaVolumeTable[1] then
		menu:getMenuItems()[1]:setValue(lavaVolumeTable[1])
	else
		menu:getMenuItems()[1]:setValue("med")
	end
end

initLavaVolume()

HIGH_SCORES = LOAD_HIGH_SCORES()
HIGH_SCORE = GET_HIGH_SCORE()