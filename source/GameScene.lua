import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Platform"
import "Rectangle"
import "Cannon"
import "Wheel"
import "Projectile"
import "Gem"
import "GemSpawner"
import "Score"
import "SoundManager"
import "Fluid"
import "CaveBottom"
import "Clearout"
import "ScoreWidget"
import "TipWidget"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local cameraOffsetTimer
local STARTING_PROJECTILE_SHOOT_LIMIT = 120
local STARTING_LAVA_RISE_LIMIT = 10
local CATCHUP_LAVA_RISE_LIMIT = 2
local LAVA_STARTING_Y = 180
local MIN_LAVA_STARTING_Y_OFFSET = 40

local UPDATE_CANNONS_LIMIT = 20
local updateCannonsCounter

local MAX_PROJECTILE_Y_OFFSET = 40
local PROJECTILE_Y_OFFSET_DIFF = 16 / (MAX_PROJECTILE_Y_OFFSET)
local HARDEST_PROJECTILE_Y_OFFSET_DIFF = 40
local projectileYOffset

-- the lower the slower the difficulty ramps up
local DIFFICULTY_SPEED_SCALE = 0.15
local LAVA_DIFFICULTY_SCALE =  0.05
local PROJECTILE_DIFFICULTY_SCALE = 0.015
local LAVA_RISE_SPEED_DIFF = STARTING_LAVA_RISE_LIMIT * LAVA_DIFFICULTY_SCALE * DIFFICULTY_SPEED_SCALE
local PROJECTILE_FREQ_SPEED_DIFF = STARTING_PROJECTILE_SHOOT_LIMIT * PROJECTILE_DIFFICULTY_SCALE * DIFFICULTY_SPEED_SCALE


local HARDEST_LAVA_RISE_LIMIT = 3
local HARDEST_PROJECTILE_SHOOT_LIMIT = 95

local lavaRiseCounterLimit
local projectileShootCounterLimit
local atMaxDifficulty= false
local player
local score
local lava
local caveBottom
local leftCannon
local rightCannon
local STARTING_LOWEST_Y = 168
local lowestY
local goalYOffset = 0
local isPaused = false
local gemSpawner
local clearout

class("GameScene").extends(gfx.sprite)

function GameScene:init()
	initialize()
end

function GameScene:update()
	if not isPaused then
		updateGoalYOffset()
		moveCameraTowardGoal()
		-- playdate.drawFPS(0,0) -- FPS widget

		setDifficulty()
		changeLavaSpeedWithLowestY()
		moveLava()
	
		updateCannons()
		chooseAndFireCannon()
		removeProjectilesAndGemsBelowLava()
	end
end

function setDifficulty()
	if atMaxDifficulty then
		lavaRiseCounterLimit = HARDEST_LAVA_RISE_LIMIT
		projectileShootCounterLimit =  HARDEST_PROJECTILE_SHOOT_LIMIT
		projectileYOffset = HARDEST_PROJECTILE_Y_OFFSET_DIFF
	else
		local height = (-math.floor(lowestY / 22) + 7)
		lavaRiseCounterLimit = math.ceil(STARTING_LAVA_RISE_LIMIT - LAVA_RISE_SPEED_DIFF * height)
		projectileShootCounterLimit = math.ceil(STARTING_PROJECTILE_SHOOT_LIMIT - PROJECTILE_FREQ_SPEED_DIFF * height)
		projectileYOffset = math.ceil(PROJECTILE_Y_OFFSET_DIFF * height)
		if lavaRiseCounterLimit <= HARDEST_LAVA_RISE_LIMIT then
			atMaxDifficulty = true
			lavaRiseCounterLimit = HARDEST_LAVA_RISE_LIMIT
			projectileShootCounterLimit =  HARDEST_PROJECTILE_SHOOT_LIMIT
			projectileYOffset = HARDEST_PROJECTILE_Y_OFFSET_DIFF
		end
	end
	print("DIFF", lavaRiseCounterLimit, projectileShootCounterLimit, projectileYOffset)
end

function initialize()
    math.randomseed(playdate.getSecondsSinceEpoch())
	gfx.setDrawOffset(0, 0)
	gfx.setBackgroundColor(gfx.kColorBlack)
	Clearout()
	playdate.display.setRefreshRate(45) -- Sets framerate to 45 fps
	caveBottom = CaveBottom()
	lowestY = STARTING_LOWEST_Y
	local platform = Platform(200, 220, 180, 62)
	platform:setZIndex(0)
	platform:add()
	
	atMaxDifficulty = false
	lavaRiseCounterLimit = STARTING_LAVA_RISE_LIMIT
	projectileShootCounterLimit = STARTING_PROJECTILE_SHOOT_LIMIT
	projectileYOffset = 0

	isPaused = false

	score = Score()

	player = Player(210, STARTING_LOWEST_Y, score)

	leftCannon = Cannon(0, player.y, true)
	rightCannon = Cannon(400, player.y, false)

	cameraOffsetTimer = playdate.frameTimer.new(9)
	cameraOffsetTimer.discardOnCompletion = false
	cameraOffsetTimer.repeats = true
	updateCannonsCounter = 0
	projectileShootCounter = 0
	projectileShootCounterLimit = STARTING_PROJECTILE_SHOOT_LIMIT
	lavaRiseCounter = 0
	lavaRiseCounterLimit = STARTING_LAVA_RISE_LIMIT

	gemSpawner = GemSpawner(player.y, 240)

	-- local rect = Rectangle(0, 195, 420, 150)
	lava = Fluid(0, LAVA_STARTING_Y, 400, 90)
end

function showScoreWidget()
	isPaused = true
	leftCannon:setUpdatesEnabled(false)
	rightCannon:setUpdatesEnabled(false)
	createTipWidget()
	local scoreWidget = ScoreWidget(score.score)
	scoreWidget:moveTo(200, 120)
end

function resetGame()
	gfx.sprite.removeAll()
	for i, timer in pairs(playdate.frameTimer.allTimers()) do
		timer:remove()
	end
	initialize()
end

function chooseAndFireCannon()
	projectileShootCounter += 1
	if projectileShootCounter >= projectileShootCounterLimit then
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
		projectileShootCounter = 0
	end
end

function updateCannons()
	updateCannonsCounter += 1
	if updateCannonsCounter >= UPDATE_CANNONS_LIMIT then
		updateCannonsCounter = 0
		leftCannon:updateGoalY(getRandomCannonYGoal())
		rightCannon:updateGoalY(getRandomCannonYGoal())
	end
end

function getRandomCannonYGoal()
	local randomCannonYGoal = player.y - math.random(-2, projectileYOffset)
	local lowestGoalYPossible = lowestY - MAX_PROJECTILE_Y_OFFSET
	if randomCannonYGoal < lowestGoalYPossible then
		randomCannonYGoal = lowestGoalYPossible
	end
	return randomCannonYGoal
end

function moveCameraTowardGoal()
	if lowestY == STARTING_LOWEST_Y or player.isDead then
		return
	end
	local xOffset, yOffset = gfx.getDrawOffset()
	-- scroll 2 pixels at a time to prevent flickering from dithering
	if goalYOffset == yOffset or goalYOffset - 1 == yOffset or goalYOffset + 1 == yOffset then
		return
	elseif player.y < player.lastGroundY - 150 then
		gfx.setDrawOffset(0, yOffset + 2)
	elseif goalYOffset > yOffset then
		if cameraOffsetTimer.frame == 0 or cameraOffsetTimer.frame == 5 then
			gfx.setDrawOffset(0, yOffset + 2)
		end
	elseif goalYOffset < yOffset then
		if cameraOffsetTimer.frame %2 == 0 then
			gfx.setDrawOffset(0, yOffset - 2)
		end
	end
end

function moveLava()
	if not player.isDead then
		lavaRiseCounter += 1
		if lavaRiseCounter > lavaRiseCounterLimit then
			lava:moveWithCollisions(lava.x, lava.y - 1)
			lavaRiseCounter = 0
		end
	end
end

function changeLavaSpeedWithLowestY()
	if lava.y > (lowestY + MIN_LAVA_STARTING_Y_OFFSET) then
		lavaRiseCounterLimit = CATCHUP_LAVA_RISE_LIMIT
	end
end

function removeProjectilesAndGemsBelowLava()
	local sprites = gfx.sprite.getAllSprites()
	for i = 1, #sprites do
		local sprite = sprites[i]
		-- makes sure sprite is far enough below lava before deleting
		if (sprite:isa(Projectile) or sprite:isa(Gem)) and sprite.y > lava.y + 150 then
			print("REMOVED SPRITE")
			sprite:remove()
		end
	end
end

function updateGoalYOffset()
	if player.y > player.lastGroundY then
		goalYOffset = STARTING_LOWEST_Y - player.y - 20
	elseif player.y < player.lastGroundY - 150 then
		goalYOffset = STARTING_LOWEST_Y - player.y
	else
		goalYOffset = STARTING_LOWEST_Y - player.lastGroundY - 15
	end
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

function getTip()
	if score.score <= 1 then
		return  "Jump on boulders to\nstack them up!"
	elseif score.multiplier <= 1 then
		return "Gems can only be collected\nwhile standing!"
	elseif score.multiplier <= 5 then
		return "Collect gems to increase\nthe score multiplier!"
	elseif score.multiplier <= 10 then
		return "Stack boulders towards gems\n to get high scores!"
	end
end

function createTipWidget()
	local tipText = getTip()
	if tipText then
		local tipWidget = TipWidget(getTip())
		tipWidget:moveTo(200, 9)
	end
end