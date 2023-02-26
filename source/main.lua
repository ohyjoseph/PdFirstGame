import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "Player"

local gfx <const> = playdate.graphics

local function initialize()
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	local player = Player(200, 120, 20)
	player:add()
end

initialize()

function playdate.update()
	-- updateGame()
	-- drawGame()
	playdate.drawFPS(0,0) -- FPS widget
	gfx.sprite.update()
end