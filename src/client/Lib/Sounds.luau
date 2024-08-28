--!strict
-- // Lib GuiSounds.luau
--- // Handles all gui sounds

local SoundService = game:GetService("SoundService")

local Datastore = require(script.Parent.Datastore)

local Sounds = {}
Sounds._initted = false
Sounds.Groups = {}
Sounds.CachedSounds = {}

function Sounds.init()
    Sounds._initted = true

	for _, soundGroup in SoundService:GetChildren() do
		if soundGroup:IsA("SoundGroup") then
			for _, sound in ipairs(soundGroup:GetChildren()) do
				if sound:IsA("Sound") then
					Sounds.CachedSounds[sound.Name] = sound
				end
			end

			Sounds.Groups[soundGroup.Name] = soundGroup
		end
	end

	--settings: {
	--	sfxEnabled: boolean,
	--	musicEnabled: boolean,
	--
	--	sfxVolume: number,
	--	musicVolume: number,
	--},

    Datastore.waitFor()
	local replica = Datastore.Replica

	replica:ListenToChange("settings", function(newValue)
		--Sounds.Groups.SFX.Enabled = newValue.settings.sfxEnabled
		Sounds.Groups.SFX.Volume = newValue.settings.sfxVolume

		--Sounds.Groups.Music.Enabled = newValue.musicEnabled
		Sounds.Groups.SFX.Volume = newValue.settings.musicVolume
	end)

	--Sounds.Groups.SFX.Enabled = replica.Data.sfxEnabled
	Sounds.Groups.SFX.Volume = replica.Data.settings.sfxVolume

	--Sounds.Groups.Music.Enabled = replica.Data.musicEnabled
	Sounds.Groups.SFX.Volume = replica.Data.settings.musicVolume
end

function Sounds.play(soundName: string)
	local sound = Sounds.CachedSounds[soundName] :: Sound
	if sound then
		sound:Play()
	end
end

function Sounds.stop(soundName: string)
	local sound = Sounds.CachedSounds[soundName] :: Sound
	if sound then
		if sound.Playing then
			sound:Stop()
		end
	end
end

if Sounds._initted == false then
    Sounds.init()
end

return Sounds
