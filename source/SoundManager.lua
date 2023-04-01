local snd = playdate.sound

SoundManager = {}

SoundManager.kSoundBreakBlock = 'breakBlock'
SoundManager.kSoundJump = 'jump'
SoundManager.kSoundStomp = 'stomp'
SoundManager.kSoundBump = 'bump'
SoundManager.kSoundPlayerHit = 'playerHit'
SoundManager.kSoundCannonShotLeft = 'cannonShotLeft'
SoundManager.kSoundCannonShotRight = 'cannonShotRight'

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
