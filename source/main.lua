import "Player" -- DEMO
local player = Player(0, 0) -- DEMO

local gfx <const> = playdate.graphics

local function loadGame()
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
end

local function updateGame()
	player:update() -- DEMO
end

local function drawGame()
	gfx.clear() -- Clears the screen
	player:draw() -- DEMO
end

loadGame()

function playdate.update()
	updateGame()
	drawGame()
	playdate.drawFPS(0,0) -- FPS widget
end