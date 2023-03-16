import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Wall"
import "Projectile"
import "Score"
import "SoundManager"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local projectileSpawnTimer = playdate.frameTimer.new(200)

local player
local score

local function initialize()
	gfx.setBackgroundColor(gfx.kColorBlack)
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	lowestY = 300
	player = Player(200, 196)
	player:add()
	player:moveTo(200, 196)
	local wall = Wall(180, 250, 1000, 30)
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
	score:setScore(math.floor((196 - lowestY) / 22))
	gfx.setDrawOffset(0, 140 - lowestY)
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