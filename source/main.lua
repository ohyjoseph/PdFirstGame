import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Wall"
import "Rectangle"
import "Projectile"
import "Score"
import "SoundManager"
import "Lava"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local projectileSpawnTimer = playdate.frameTimer.new(200)

local player
local score
local lava

local STARTING_LOWEST_Y = 162

local function initialize()
	gfx.setBackgroundColor(gfx.kColorBlack)
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	lowestY = STARTING_LOWEST_Y
	player = Player(210, 100)
	player:add()
	player:moveTo(210, 100)
	local wall = Wall(210, 210, 180, 62)
	wall:setZIndex(0)
	wall:add()
	wall:moveTo(210, 210)
	-- local rect = Rectangle(0, 195, 420, 150)
	-- lava = Lava()

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
		timer:pause()
	end
	initialize()
end

initialize()

function playdate.update()
	score:setScore(math.floor((STARTING_LOWEST_Y - lowestY) / 22))
	gfx.setDrawOffset(0, STARTING_LOWEST_Y - lowestY)
	print(player.y)
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