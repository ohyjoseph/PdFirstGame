import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import 'CoreLibs/frameTimer'

import "Player"
import "Platform"
import "Rectangle"
import "Cannon"
import "Projectile"
import "GemSpawner"
import "Score"
import "SoundManager"
import "Fluid"
import "CaveBottom"
import "Rope"
import "MenuGem"
import "Pillar"
import "Blackout"

local gfx <const> = playdate.graphics
local FrameTimer_update = playdate.frameTimer.updateTimers

local projectileSpawnTimer
local cameraOffsetTimer

local PROJECTILE_FREQUENCY = 120
local LAVA_STARTING_Y = 180
local LAVA_RISE_COUNTER_FRAMES = 10
local MIN_LAVA_CAMERA_Y_OFFSET = 230
local player
local score
local lava
local caveBottom
local leftCannon
local rightCannon
local STARTING_LOWEST_Y = 168
local PLAYER_ROPE_X_DIFF = 10
local ROPE_X = 140
local lowestY
local goalYOffset = 0
local gemSpawner
local slideAnimator

class("MenuScene").extends(gfx.sprite)

function MenuScene:init()
    startUp()
    SoundManager:playSound(SoundManager.kSoundSlideDownRope)
end

function MenuScene:update()
    if not slideAnimator:ended() then
        player.y = slideAnimator:currentValue()
    end
    if shouldCameraShake then
        cameraShake()
    end
end

function startUp()
    math.randomseed(playdate.getSecondsSinceEpoch())
    gfx.setDrawOffset(0, 0)
    gfx.setBackgroundColor(gfx.kColorBlack)
    playdate.display.setRefreshRate(45) -- Sets framerate to 45 fps
    caveBottom = CaveBottom()
    lowestY = STARTING_LOWEST_Y

    slideAnimator = gfx.animator.new(2000, -50, 165, playdate.easingFunctions.outQuad)
    player = Player(ROPE_X - PLAYER_ROPE_X_DIFF, -40)
    player:add()
    player.isOnRope = true
    player.g = 0.015
    player.dy = 1.1

    local platform = Platform(200, 220)
    platform:setZIndex(0)

    local pillar = Pillar(200, 177)

    local rope = Rope(ROPE_X, -75)
    platform:setZIndex(0)

    local rectangle = Rectangle(-10, 230, 420, 20)

    local menuGem = MenuGem(200, 160)
end
