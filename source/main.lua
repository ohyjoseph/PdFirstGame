import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "Player"
import "Wall"

local gfx <const> = playdate.graphics

local function initialize()
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	local player = Player(200.0, 120, 12)
	player:add()
	local wall = Wall(350, 200, 50, 80)
	wall:add()
end

initialize()

function playdate.update()
	-- updateGame()
	-- drawGame()
	playdate.drawFPS(0,0) -- FPS widget
	gfx.sprite.update()
end