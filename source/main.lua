import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Platform"
import "SoundManager"
import "CaveBottom"

import "MenuScene"
import "GameScene"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sprite <const> =  gfx.sprite
local spriteUpdate <const> = sprite.update
local FrameTimer_update = pd.frameTimer.updateTimers

DEFAULT_FONT = gfx.getFont()

isMenuGemCollected = false

local hasUsedMenuScene = false
local isInGameScene = false
local shakeTable = {counter = 0, prevX = 0, prevY = 0}

local scene
music = pd.sound.fileplayer.new("sound/lavaLoop")

local menu = pd.getSystemMenu()
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

function pd.update()
	if not hasUsedMenuScene then
		if scene then
			scene:remove()
		end
		for i, timer in pairs(pd.frameTimer.allTimers()) do
			timer:remove()
		end
		scene = MenuScene()
		hasUsedMenuScene = true
	end

	if isMenuGemCollected and not isInGameScene then
		if scene then
			scene:remove()
		end
		for i, timer in pairs(pd.frameTimer.allTimers()) do
			timer:remove()
		end
		scene = GameScene()
		isInGameScene = true
	end

	scene:update()

	spriteUpdate()
	FrameTimer_update()
end

function reset()
	SoundManager:stopSound(SoundManager.kSoundQuake)
	music:pause()
	sprite.removeAll()
	for i, timer in pairs(pd.frameTimer.allTimers()) do
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

function arrayFirstTenEqual(table1, table2)
	for i = 1, 10 do
		if table1[i] ~= table2[i] then
			return false
		end
	end
	return true
end

function SAVE_HIGH_SCORE(newScore)
	if newScore <= 0 then
		return
	end
	local forLength = 10
	local highScoresLength = #HIGH_SCORES
	if highScoresLength < forLength then
		forLength = highScoresLength
	end
	if forLength < 10 then
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

	local highScoreTablesEqual = arrayFirstTenEqual(HIGH_SCORES, newHighScores)
	if not highScoreTablesEqual then
		local highScoresToSave = {}
		for i = 1, forLength do
			table.insert(highScoresToSave, newHighScores[i])
		end
		pd.datastore.write(highScoresToSave)
		HIGH_SCORES = highScoresToSave
	end
	return not highScoreTablesEqual
end

function LOAD_HIGH_SCORES()
    local gameData = pd.datastore.read()
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
	pd.datastore.write(newLavaVolumeTable, "lavaVolume")
end

function LOAD_LAVA_VOLUME()
	return pd.datastore.read("lavaVolume")
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