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

local isInGameScene = false

local scene = MenuScene()

function playdate.update()
	if isMenuGemCollected and not isInGameScene then
		scene = GameScene()
		isInGameScene = true
	end

	scene:update()

	gfx.sprite.update()
	FrameTimer_update()
end