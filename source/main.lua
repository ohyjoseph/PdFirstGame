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
	x, y = gfx.getDrawOffset()
	shakeTable = {counter = 0, prevX = x, prevY = y}
end

function cameraShake()
    shakeTable.counter += 1
    x, y = gfx.getDrawOffset()
    if shakeTable.counter % 6 == 0 then
        gfx.setDrawOffset(x + math.random(-3, 3), y + math.random(-3, 3))
		shakeTable.prevX = x
		shakeTable.prevY = y
    elseif shakeTable.counter % 3 == 0 then
		print("SHAKE", shakeTable.prevX, shakeTable.prevY)
        gfx.setDrawOffset(shakeTable.prevX, shakeTable.prevY)
    end
end

function SAVE_HIGH_SCORE(newScore)
	if newScore > HIGH_SCORE then
		local gameData = {
			highScore = newScore
		}
		playdate.datastore.write(gameData)
		HIGH_SCORE = newScore
	end
end

function LOAD_HIGH_SCORE()
    local gameData = playdate.datastore.read()
    if gameData then
        return gameData.highScore
    end
	return 0
end

HIGH_SCORE = LOAD_HIGH_SCORE()