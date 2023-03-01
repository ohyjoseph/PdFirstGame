import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Wall"

local gfx <const> = playdate.graphics

local FrameTimer_update = playdate.frameTimer.updateTimers

local function initialize()
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	local player = Player(200, 120, 12)
	player:add()
	player:moveTo(200, 120)
	local wall1 = Wall(350, 230, 50, 80)
	wall1:add()
	wall1:moveTo(350, 230)
	local wall2 = Wall(180, 240, 500, 30)
	wall2:add()
	wall2:moveTo(180, 240)
end

initialize()

function playdate.update()
	-- updateGame()
	-- drawGame()
	playdate.drawFPS(0,0) -- FPS widget
	FrameTimer_update()
	gfx.sprite.update()
end