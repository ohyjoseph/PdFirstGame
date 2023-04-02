local snd = playdate.sound

SoundManager = {}

SoundManager.kSoundJump = 'jump'
SoundManager.kSoundStomp = 'stomp'
SoundManager.kSoundPlayerHit = 'playerHit'
SoundManager.kSoundCannonShotLeft = 'cannonShotLeft'
SoundManager.kSoundCannonShotRight = 'cannonShotRight'
SoundManager.kSoundDeathJingle = 'deathJingle'
SoundManager.kSoundGemPickup = 'gemPickup'
SoundManager.kSoundHitByProjectile = 'hitByProjectile'
SoundManager.kSoundLavaFall = 'lavaFall'
SoundManager.kSoundProjectileDestroy = 'projectileDestroy'
SoundManager.kSoundProjectileLand = 'projectileLand'
SoundManager.kSoundSlideDownRope = 'slideDownRope'

local sounds = {}

for _, v in pairs(SoundManager) do
	sounds[v] = snd.sampleplayer.new('sound/' .. v)
end

SoundManager.sounds = sounds

function SoundManager:playSound(name)
	self.sounds[name]:play(1)
end

function SoundManager:stopSound(name)
	self.sounds[name]:stop()
end
