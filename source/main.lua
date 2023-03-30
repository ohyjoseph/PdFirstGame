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

isMenuGemCollected = false

local hasUsedMenuScene = false
local isInGameScene = false
local shakeCounter = 0

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
	shakeCounter = 0
end

function cameraShake()
    shakeCounter += 1
    x, y = gfx.getDrawOffset()
    if shakeCounter % 6 == 0 then
        gfx.setDrawOffset(x + 1, y + 1)
    elseif shakeCounter % 3 == 0 then
        gfx.setDrawOffset(x - 1, y - 1)
    end
end

function SAVE_HIGH_SCORE(newScore)
    local gameData = {
        highScore = newScore
    }
    playdate.datastore.write(gameData)
end

function LOAD_HIGH_SCORE()
    local gameData = playdate.datastore.read()
    if gameData then
        return gameData.highScore
    end
	return 0
end

HIGH_SCORE = LOAD_HIGH_SCORE()