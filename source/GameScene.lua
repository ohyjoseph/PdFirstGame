import "Cannon"
import "Wheel"
import "Projectile"
import "ProjectileBreak"
import "Gem"
import "GemSpawner"
import "Score"
import "SoundManager"
import "Fluid"
import "CaveBottom"
import "Clearout"
import "ScoreWidget"
import "TipWidget"

local pd <const> = playdate
local scoreboards <const> = pd.scoreboards
local gfx <const> = pd.graphics
local getDrawOffset <const> = gfx.getDrawOffset
local setDrawOffset <const> = gfx.setDrawOffset
local getAllSprites <const> = gfx.sprite.getAllSprites
local querySpritesAlongLines <const> = gfx.sprite.querySpritesAlongLine
local removeAllSprites <const> = gfx.sprite.removeAll

local cameraOffsetTimer
local STARTING_PROJECTILE_SHOOT_LIMIT = 120
local STARTING_LAVA_RISE_LIMIT = 10
local CATCHUP_LAVA_RISE_LIMIT = 2
local LAVA_STARTING_Y = 180
local MIN_LAVA_STARTING_Y_OFFSET = 40

local UPDATE_CANNONS_LIMIT = 20
local updateCannonsCounter

local LOWEST_ALLOWED_Y = 400

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
local leftCannon
local rightCannon
local STARTING_LOWEST_Y = 168
local lowestY
local goalYOffset
local isPaused = false

local highestHeight

local cameraMovedPastStart
local caveBottom

local removalTimer

local shouldStopCamera

class("GameScene").extends(gfx.sprite)

function GameScene:init()
	initialize()
end

function GameScene:update()
	if not isPaused then
		updateGoalYOffset()
		moveCameraTowardGoal()
		-- pd.drawFPS(0,0) -- FPS widget

		setDifficulty()
		changeLavaSpeedWithLowestY()
		moveLava()
	
		updateCannons()
		chooseAndFireCannon()
		removeProjectilesAndGemsBelowLava()

		shiftObjects()
	end
end

function setDifficulty()
	if atMaxDifficulty then
		lavaRiseCounterLimit = HARDEST_LAVA_RISE_LIMIT
		projectileShootCounterLimit =  HARDEST_PROJECTILE_SHOOT_LIMIT
		projectileYOffset = HARDEST_PROJECTILE_Y_OFFSET_DIFF
	else
		lavaRiseCounterLimit = math.ceil(STARTING_LAVA_RISE_LIMIT - LAVA_RISE_SPEED_DIFF * highestHeight)
		projectileShootCounterLimit = math.ceil(STARTING_PROJECTILE_SHOOT_LIMIT - PROJECTILE_FREQ_SPEED_DIFF * highestHeight)
		projectileYOffset = math.ceil(PROJECTILE_Y_OFFSET_DIFF * highestHeight)
		if lavaRiseCounterLimit <= HARDEST_LAVA_RISE_LIMIT then
			atMaxDifficulty = true
			lavaRiseCounterLimit = HARDEST_LAVA_RISE_LIMIT
			projectileShootCounterLimit =  HARDEST_PROJECTILE_SHOOT_LIMIT
			projectileYOffset = HARDEST_PROJECTILE_Y_OFFSET_DIFF
		end
	end
	-- print("DIFF", lavaRiseCounterLimit, projectileShootCounterLimit, projectileYOffset)
end

function initialize()
	music:setVolume(getLavaVolume())
	music:play(0)

    math.randomseed(pd.getSecondsSinceEpoch())
	setDrawOffset(0, 0)
	gfx.setBackgroundColor(gfx.kColorBlack)
	Clearout()
	pd.display.setRefreshRate(45) -- Sets framerate to 45 fps
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

	cameraOffsetTimer = pd.frameTimer.new(6)
	cameraOffsetTimer.discardOnCompletion = false
	cameraOffsetTimer.repeats = true
	removalTimer = pd.frameTimer.new(225)
	removalTimer.discardOnCompletion = false
	removalTimer.repeats = true
	updateCannonsCounter = 0
	projectileShootCounter = 0
	projectileShootCounterLimit = STARTING_PROJECTILE_SHOOT_LIMIT
	lavaRiseCounter = 0
	lavaRiseCounterLimit = STARTING_LAVA_RISE_LIMIT

	GemSpawner(player.y, 100)

	lava = Fluid(0, LAVA_STARTING_Y, 400, 90)

	goalYOffset = 0
	highestHeight = 0
	cameraMovedPastStart = false
	shouldStopCamera = false
end

function AddScoreToLeaderboard()
	local boardId = "highscores"
	if score.score > 0 then
		scoreboards.addScore(boardId, score.score, AddScoreToLeaderboardCb)
	end
end

function AddScoreToLeaderboardCb(status, result)
	print("AddScoreToLeaderBoardCb")
    print(status.code)
    print(status.message)
    printTable(result)
end

function showScoreWidget()
	isPaused = true
	leftCannon:setUpdatesEnabled(false)
	rightCannon:setUpdatesEnabled(false)
	createTipWidget()
	local scoreWidget = ScoreWidget(score.score)
	scoreWidget:moveTo(200, 120)

	shouldStopCamera = true

	music:setVolume(0, 0, 2, function(musicPlayer)
		musicPlayer:pause()
	end)
end

function resetGame()
	removeAllSprites()
	music:pause()
	for i, timer in pairs(pd.frameTimer.allTimers()) do
		timer:remove()
	end
	initialize()
end

function chooseAndFireCannon()
	projectileShootCounter += 1
	if projectileShootCounter >= projectileShootCounterLimit then
		local leftCannonHasClearShot = cannonHasClearShot(leftCannon)
		local rightCannonHasClearShot = cannonHasClearShot(rightCannon)
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

function cannonHasClearShot(cannon)
	local sprites = querySpritesAlongLines(cannon.x, cannon.y, player.x, cannon.y)
	for i = 1, #sprites do
		local sprite = sprites[i]
		if (sprite:isa(Projectile) and not sprite.isDangerous)  then
			return false
		end
	end
	return true
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
	if shouldStopCamera then
		return
	end
	if not cameraMovedPastStart and lowestY == STARTING_LOWEST_Y then
		return
	end
	cameraMovedPastStart = true
	local xOffset, yOffset = getDrawOffset()
	-- scroll 2 pixels at a time to prevent flickering from dithering
	if goalYOffset == yOffset or goalYOffset - 1 == yOffset or goalYOffset + 1 == yOffset then
		return
	elseif player.y < player.lastGroundY - 150 then
		setDrawOffset(0, yOffset + 1)
	elseif goalYOffset > yOffset then
		if cameraOffsetTimer.frame == 0 or cameraOffsetTimer.frame == 3 then
			setDrawOffset(0, yOffset + 1)
		end
	elseif goalYOffset < yOffset then
		setDrawOffset(0, yOffset - 1)
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
	if removalTimer.frame >= removalTimer.duration then
		local sprites = getAllSprites()
		for i = 1, #sprites do
			local sprite = sprites[i]
			-- makes sure sprite is far enough below lava before deleting
			if (sprite:isa(Projectile) or sprite:isa(Gem)) and sprite.y > lava.y + 150 then
				sprite:removeClean()
			end
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

function addToHighestHeight(value)
	highestHeight += value
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

function addYToObjects()
	local sprites = getAllSprites()
	for i = 1, #sprites do
		local sprite = sprites[i]
		local spriteClassName = sprite.className
		if spriteClassName ~= "GemIndicator" and spriteClassName ~= "Score" then
			local x, y, width, height = sprite:getCollideBounds()
			if not width == 0 and not height == 0 then
				-- print ("COL", spriteCollideRect)
				sprite:moveWithCollisions(sprite.x, sprite.y + LOWEST_ALLOWED_Y)
			else
				sprite:moveTo(sprite.x, sprite.y + LOWEST_ALLOWED_Y)
			end
		elseif spriteClassName == "GemIndicator" then
			sprite.smallestGemY += LOWEST_ALLOWED_Y
		end
	end
	local offsetX, offsetY = getDrawOffset()
	goalYOffset -= LOWEST_ALLOWED_Y
	setDrawOffset(offsetX, offsetY - LOWEST_ALLOWED_Y)
	lowestY += LOWEST_ALLOWED_Y
	player.lastGroundY += LOWEST_ALLOWED_Y
	leftCannon.goalY += LOWEST_ALLOWED_Y
	rightCannon.goalY += LOWEST_ALLOWED_Y
end

function shiftObjects()
	if lowestY <= -LOWEST_ALLOWED_Y then
		addYToObjects()
		if caveBottom then
			caveBottom:remove()
		end
	end
end

function setShouldStopCamera(value)
	shouldStopCamera = value
end