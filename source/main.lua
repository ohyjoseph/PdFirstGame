import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Wall"
import "Projectile"
import "Score"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local projectileSpawnTimer = playdate.frameTimer.new(200)

local player
local score

local function initialize()
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	lowestY = 300
	player = Player(200, 120, 12)
	player:add()
	player:moveTo(200, 120)
	local wall = Wall(180, 250, 500, 30)
	wall:setZIndex(0)
	wall:add()
	wall:moveTo(180, 250)
	local wall2 = Wall(200, 230, 100, 50)
	wall2:add()
	wall2:moveTo(200, 230)
	wall2:setZIndex(0)
	score = Score()
	score:setZIndex(900)
	score:addSprite()
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
	-- updateGame()
	-- drawGame()
	score:setScore((196 - lowestY) / 25)
	playdate.drawFPS(0,0) -- FPS widget
	FrameTimer_update()
	gfx.sprite.update()

	if projectileSpawnTimer.frame >= 150 then
		local projectile = Projectile(-20, player.y - 5, 4.5)
		projectile:moveTo(-20, player.y - 5)
		projectile:add()
		projectileSpawnTimer:reset()
	end
end