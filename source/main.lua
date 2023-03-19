import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Platform"
import "Rectangle"
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

local STARTING_LOWEST_Y = 157
local goalYOffset = 0

local function initialize()
	gfx.setDrawOffset(0, 0)
	gfx.setBackgroundColor(gfx.kColorBlack)
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	lowestY = STARTING_LOWEST_Y
	player = Player(210, 100)
	player:add()
	player:moveTo(210, 100)
	local platform = Platform(200, 220, 180, 62)
	platform:setZIndex(0)
	platform:add()
	platform:moveTo(200, 220)
	-- local rect = Rectangle(0, 195, 420, 150)
	-- lava = Lava()

	caveBottom = CaveBottom()

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
	print(lowestY)
	playdate.drawFPS(0,0) -- FPS widget
	FrameTimer_update()
	gfx.sprite.update()

	if projectileSpawnTimer.frame >= 150 then
		local projectileY = player.y - 5
		if projectileY < lowestY - 5 then
			projectileY = lowestY - 5
		end
		local projectile = Projectile(-20, projectileY, 4.5)
		projectile:moveTo(-20, projectileY)
		projectile:add()
		projectileSpawnTimer:reset()
	end
end

function updateGoalYOffset()
	goalYOffset = STARTING_LOWEST_Y - lowestY
end

function moveCameraTowardGoal()
	if cameraOffsetTimer.frame == 0 then
		local xOffset, yOffset = gfx.getDrawOffset()
		-- scroll 2 pixels at a time to prevent flickering from dithering
		if goalYOffset == yOffset or goalYOffset - 1 == yOffset or goalYOffset + 1 == yOffset then
			return
		elseif goalYOffset > yOffset then
			gfx.setDrawOffset(0, yOffset + 2)
		elseif goalYOffset < yOffset then
			gfx.setDrawOffset(0, yOffset - 2)
		
		end
	end
end