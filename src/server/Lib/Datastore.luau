--!strict
-- // lib Datastore.luau
--- // Handles interacting with ProfileService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsService = game:GetService("AnalyticsService")

local ProfileService = require(ReplicatedStorage.Packages.ProfileService)
local WaitFor = require(ReplicatedStorage.Packages.WaitFor)
local TemplateData = require(script.Parent.Parent._Metadata.TemplateData)

export type Profile = ProfileService.Profile<TemplateData.Main, any>
export type CacheProfile = {
	profile: Profile,
	update: (key: string, value: any) -> TemplateData.Main,
	get: () -> TemplateData.Main,
}
export type ProfileTable = {
	[Player]: CacheProfile,
}

local Datastore = {}
Datastore.mock = true
Datastore._store = ProfileService.GetProfileStore("Game", TemplateData)

local Profiles: ProfileTable = {}

local function update(
	profile: Profile,
	key: string,
	value: number | string | { [any]: any } | { any } | Color3
): TemplateData.Main
	assert(profile and (key and type(key) == "string"), "Missing required arguments")
	local doesKeyExist = profile.Data[key]
	if doesKeyExist then
		profile.Data[key] = value
	else
		error(`Key doesn't exist in <{profile.UserIds[1]}> KEY {key}`)
	end
end

local function set(player: Player, profile: Profile): nil
	local cached = Profiles[player]
	if cached then
        error(`{player.Name} <{player.UserId}> is already cached in profiles`)
    end
	Profiles[player] = {
		profile = profile,
		update = function(key: string, value: any): TemplateData.Main
			return update(profile, key, value)
		end,
		get = function(): TemplateData.Main
			return profile.Data
		end,
	}
end

function Datastore.get(player: Player, timeout: number): CacheProfile | nil
	WaitFor.Custom(function()
		return Profiles[player]
	end, timeout or 10):await()
	return Profiles[player]
end

function Datastore.load(player: Player): CacheProfile | nil
	if ProfileService.ServiceLocked == true then
		player:Kick("service locked")
		return
	end
	local profileStore = if Datastore.mock == true then Datastore._store.Mock else Datastore._store
	local profile: Profile = profileStore:LoadProfileAsync(`GamePlayer#{player.UserId}`)
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function(placeId, jobId)
			if Profiles[player] then
				Profiles[player] = nil
			end
			player:Kick(`profile released <{placeId}> <{jobId}>`)
		end)

		if player:IsDescendantOf(Players) then
			set(player, profile)
            return Profiles[player]
		else
			profile:Release()
		end
	else
		player:Kick("failed to get profile")
	end
end

-- handle internal issues
ProfileService.IssueSignal:Connect(function(message: string, storeName: string, key: string)
	local newKey = string.split(key, "#")[2] -- gross work around, hate analytics !!@@@!@!@!
	if tonumber(newKey) then
		local player = Players:GetPlayerByUserId(newKey)
		AnalyticsService:LogCustomEvent(player, "ProfileServiceIssue", 1, {
			UserId = `<{player.UserId}>`,
			Message = message,
			StoreName = storeName,
			Key = key,
		})
	end
end)

return Datastore
