import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Platform"
import "Rectangle"
import "Cannon"
import "Projectile"
import "Score"
import "SoundManager"
import "Lava"
import "CaveBottom"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local projectileSpawnTimer = playdate.frameTimer.new(200)
local cameraOffsetTimer = playdate.frameTimer.new(9)
cameraOffsetTimer.discardOnCompletion = false
cameraOffsetTimer.repeats = true

local player
local score
local lava
local caveBottom
local cannonLeft
local cannonRight
local STARTING_LOWEST_Y = 168
local goalYOffset = 0

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	gfx.setDrawOffset(0, 0)
	gfx.setBackgroundColor(gfx.kColorBlack)
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	caveBottom = CaveBottom()
	lowestY = STARTING_LOWEST_Y
	player = Player(210, 168)
	player:add()
	player:moveTo(210, 168)
	local platform = Platform(200, 220, 180, 62)
	platform:setZIndex(0)
	platform:add()
	platform:moveTo(200, 220)
	-- local rect = Rectangle(0, 195, 420, 150)
	-- lava = Lava()
	cannonLeft = Cannon(0, player.y, true)
	cannonLeft:moveTo(0, player.y)
	cannonRight = Cannon(400, player.y, false)
	cannonRight:moveTo(400, player.y, false)

	score = Score()
	score:setZIndex(900)
	score:addSprite()
	score:setIgnoresDrawOffset(true)
	projectileSpawnTimer:start()
end

function resetGame()
	gfx.sprite.removeAll()
	for i, timer in pairs(playdate.frameTimer.allTimers()) do
		timer:reset()
	end
	initialize()
end

initialize()

function playdate.update()
	score:setScore(math.floor((STARTING_LOWEST_Y - lowestY) / 22))
	updateGoalYOffset()
	moveCameraTowardGoal()
	playdate.drawFPS(0,0) -- FPS widget
	FrameTimer_update()
	gfx.sprite.update()

	updateCannons()

	if projectileSpawnTimer.frame >= 150 then
		if math.random(1, 2) == 1 then
			cannonRight:shootProjectile()
		else
			cannonLeft:shootProjectile()
		end
		projectileSpawnTimer:reset()
	end
end

function updateCannons()
	cannonLeft:updateGoalY(player.y)
	cannonRight:updateGoalY(player.y)
end

function updateGoalYOffset()
	goalYOffset = STARTING_LOWEST_Y - player.lastGroundY
	print("goal", goalYOffset)
end

function moveCameraTowardGoal()
	local xOffset, yOffset = gfx.getDrawOffset()
	-- scroll 2 pixels at a time to prevent flickering from dithering
	if goalYOffset == yOffset or goalYOffset - 1 == yOffset or goalYOffset + 1 == yOffset then
		return
	elseif goalYOffset > yOffset then
		if cameraOffsetTimer.frame == 0 then
			gfx.setDrawOffset(0, yOffset + 2)
		end
	elseif goalYOffset < yOffset then
		if cameraOffsetTimer.frame %2 == 0 then
			gfx.setDrawOffset(0, yOffset - 2)
		end
	end
end