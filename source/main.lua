import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Wall"
import "Projectile"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local projectileSpawnTimer = playdate.frameTimer.new(200)

local function initialize()
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	local player = Player(200, 120, 12)
	player:add()
	player:moveTo(200, 120)
	local wall = Wall(180, 250, 500, 30)
	wall:add()
	wall:moveTo(180, 250)
	local wall2 = Wall(180, 230, 100, 70)
	wall2:add()
	wall2:moveTo(180, 230)
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
	playdate.drawFPS(0,0) -- FPS widget
	FrameTimer_update()
	gfx.sprite.update()

	if projectileSpawnTimer.frame >= 150 then
		local projectile = Projectile(-20, 180, 4.5)
		projectile:add()
		projectile:moveTo(-20, 180)
		projectileSpawnTimer:reset()
	end
end