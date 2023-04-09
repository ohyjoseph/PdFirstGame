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
import "Gem"
import "MenuGem"
import "Pillar"
import "Blackout"
import "MenuGem"


local pd <const> = playdate
local gfx <const> = pd.graphics

local player
local STARTING_LOWEST_Y = 168
local PLAYER_ROPE_X_DIFF = 10
local ROPE_X = 140
local slideAnimator

class("MenuScene").extends(gfx.sprite)

function MenuScene:init()
    startUp()
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
    math.randomseed(pd.getSecondsSinceEpoch())
    gfx.setDrawOffset(0, 0)
    gfx.setBackgroundColor(gfx.kColorBlack)
    pd.display.setRefreshRate(45) -- Sets framerate to 45 fps
    caveBottom = CaveBottom()
    lowestY = STARTING_LOWEST_Y

    slideAnimator = gfx.animator.new(2000, -50, 165, pd.easingFunctions.outQuad)
    SoundManager:playSound(SoundManager.kSoundSlideDownRope)
    player = Player(ROPE_X - PLAYER_ROPE_X_DIFF, -40)
    player:add()
    player.isOnRope = true
    player.g = 0.015
    player.dy = 1.1

    local platform = Platform(200, 220)
    platform:setZIndex(0)

    Pillar(200, 177)

    Rope(ROPE_X, -75)
    platform:setZIndex(0)

    Rectangle(-10, 230, 420, 20)

    MenuGem(200, 160)
end
