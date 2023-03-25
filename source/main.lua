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
import "Lava"
import "CaveBottom"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local projectileSpawnTimer
local cameraOffsetTimer

local PROJECTILE_FREQUENCY = 120
local LAVA_STARTING_Y = 210
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

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	gfx.setDrawOffset(0, 0)
	gfx.setBackgroundColor(gfx.kColorBlack)
	playdate.display.setRefreshRate(75) -- Sets framerate to 50 fps
	caveBottom = CaveBottom()
	lowestY = STARTING_LOWEST_Y
	player = Player(210, 168)
	player:add()
	local platform = Platform(200, 220, 180, 62)
	platform:setZIndex(0)
	platform:add()
	
	leftCannon = Cannon(0, player.y, true)
	rightCannon = Cannon(400, player.y, false)

	score = Score()
	score:setScore(0)
	score:setZIndex(900)
	score:addSprite()
	score:setIgnoresDrawOffset(true)

	projectileSpawnTimer = playdate.frameTimer.new(PROJECTILE_FREQUENCY)
	projectileSpawnTimer:start()
	cameraOffsetTimer = playdate.frameTimer.new(9)
	cameraOffsetTimer.discardOnCompletion = false
	cameraOffsetTimer.repeats = true
	lavaRiseTimer = playdate.frameTimer.new(LAVA_RISE_COUNTER_FRAMES)
	lavaRiseTimer.discardOnCompletion = false
	lavaRiseTimer.repeats = true

	gemSpawner = GemSpawner(player.y, 240)
	gemSpawner:moveWithCollisions(0, player.y)

	-- local rect = Rectangle(0, 195, 420, 150)
	lava = Lava(LAVA_STARTING_Y)
end

function resetGame()
	gfx.sprite.removeAll()
	for i, timer in pairs(playdate.frameTimer.allTimers()) do
		timer:remove()
	end
	initialize()
end

initialize()

function playdate.update()
	-- score:setScore(math.floor((STARTING_LOWEST_Y - lowestY) / 22))
	updateGoalYOffset()
	moveCameraTowardGoal()
	-- playdate.drawFPS(0,0) -- FPS widget
	FrameTimer_update()
	gfx.sprite.update()

	moveLava()

	updateCannons()
	chooseAndFireCannon()

	removeProjectilesAndGemsBelowLava()
end

function chooseAndFireCannon()
	if projectileSpawnTimer.frame >= PROJECTILE_FREQUENCY then
		local leftCannonHasClearShot = #gfx.sprite.querySpritesAlongLine(leftCannon.x, leftCannon.y, player.x, player.y) <= 1
		local rightCannonHasClearShot = #gfx.sprite.querySpritesAlongLine(rightCannon.x, rightCannon.y, player.x, player.y) <= 1
		if (leftCannonHasClearShot and rightCannonHasClearShot) or (not leftCannonHasClearShot and not rightCannonHasClearShot) then
			if math.random(1, 2) == 1 then
				leftCannon:startShootingProjectile()
			else
				rightCannon:startShootingProjectile()
			end
		elseif (leftCannonHasClearShot) then
			leftCannon:startShootingProjectile()
		else
			rightCannon:startShootingProjectile()
		end
		projectileSpawnTimer:reset()
	end
end

function updateCannons()
	leftCannon:updateGoalY(player.y)
	rightCannon:updateGoalY(player.y)
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
	moveLavaWithCamera(yOffset)
end

function moveLava()
	if lavaRiseTimer.frame >= LAVA_RISE_COUNTER_FRAMES then
		lava.y -= 1
		lava:moveWithCollisions(0, lava.y)
	end
end

function moveLavaWithCamera(yOffset)
	if lava.y > MIN_LAVA_CAMERA_Y_OFFSET - yOffset then
		lava.y = MIN_LAVA_CAMERA_Y_OFFSET - yOffset
		lava:moveWithCollisions(0, lava.y)
	end
end

function removeProjectilesAndGemsBelowLava()
	local sprites = gfx.sprite.getAllSprites()
	for i = 1, #sprites do
		local sprite = sprites[i]
		-- makes sure sprite is far enough below lava before deleting
		if (sprite:isa(Projectile) or sprite:isa(Gem)) and sprite.y > lava.y + 50 then
			print("REMOVED SPRITE")
			sprite:remove()
		end
	end
end

function updateGoalYOffset()
	goalYOffset = STARTING_LOWEST_Y - player.lastGroundY
end

function addToScore(value)
	score:addToScore(value)
end

function addToMultiplier(value)
	score:addToMultiplier(value)
end

function getMutliplier()
	return score.multiplier
end

function getLowestY() 
	return lowestY
end

function setLowestY(value)
	lowestY = value
end