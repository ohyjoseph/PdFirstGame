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

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local projectileSpawnTimer
local cameraOffsetTimer

local PROJECTILE_FREQUENCY = 120
local LAVA_STARTING_Y = 180
local LAVA_RISE_COUNTER_FRAMES = 10
local MIN_LAVA_CAMERA_Y_OFFSET = 230
local player
local score
local lava
local caveBottom
local leftCannon
local rightCannon
local STARTING_LOWEST_Y = 168
local lowestY
local goalYOffset = 0
local gemSpawner

class("MenuScene").extends(gfx.sprite)

function MenuScene:init()
	startUp()
end

function MenuScene:update()
end

function startUp()
    math.randomseed(playdate.getSecondsSinceEpoch())
	gfx.setDrawOffset(0, 0)
	gfx.setBackgroundColor(gfx.kColorBlack)
	playdate.display.setRefreshRate(45) -- Sets framerate to 45 fps
	caveBottom = CaveBottom()
	lowestY = STARTING_LOWEST_Y
	player = Player(210, 168)
	player:add()
	local platform = Platform(200, 220, 180, 62)
	platform:setZIndex(0)
	platform:add()
end