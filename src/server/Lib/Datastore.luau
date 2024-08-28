--!strict
-- // lib Datastore.luau
--- // Handles interacting with ProfileService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsService = game:GetService("AnalyticsService")

local ProfileService = require(ReplicatedStorage.Packages.ProfileService)
local Replica = require(ReplicatedStorage.Shared.Replica)
local WaitFor = require(ReplicatedStorage.Packages.WaitFor)
local TemplateData = require(script.Parent.Parent._Metadata.TemplateData)

local SharedReplicaTypes = require(ReplicatedStorage.Shared.Replica.SharedTypes)

export type Profile = ProfileService.Profile<TemplateData.Main, any>
export type CacheProfile = {
	profile: Profile,
	replica: SharedReplicaTypes.Replica,
	update: (key: string, value: any) -> TemplateData.Main,
	get: () -> TemplateData.Main,
	wipe: () -> nil
}
export type ProfileTable = {
	[Player]: CacheProfile,
}

local Datastore = {}
Datastore.activeWipe = {}
Datastore.mock = true
Datastore._store = ProfileService.GetProfileStore("Game", TemplateData)

local Profiles: ProfileTable = {}

local function update(
	profile: Profile,
	replica: SharedReplicaTypes.Replica,
	key: string,
	value: number | string | { [any]: any } | { any } | Color3
): TemplateData.Main
	assert(profile and (key and typeof(key) == "string"), "Missing required arguments")
	local doesKeyExist = profile.Data[key]
	if doesKeyExist then
		profile.Data[key] = value
		replica:SetValue(key, value)
	else
		error(`Key doesn't exist in <{profile.UserIds[1]}> KEY {key}`)
	end
end

local function wipe(player: Player, profile: Profile): nil
	Datastore.activeWipe[player] = true
	profile:Release()

	local success, err = pcall(function()
		return profile:WipeProfileAsync()
	end)

	if success == true then
		warn(`SUCCESS wipe for PLAYER {player.UserId}`)
		AnalyticsService:LogCustomEvent(player, "DataWipe", {
			UserId = `<{player.UserId}>`,
			Status = "SUCCESS",
			Message = "",
		})
	else
		warn(`FAILED wipe for PLAYER {player.UserId}`)
		AnalyticsService:LogCustomEvent(player, "DataWipe", {
			UserId = `<{player.UserId}>`,
			Status = "FAILED",
			Message = err,
		})
		player:Kick("Failed to wipe profile data.")
	end

	Datastore.activeWipe[player] = nil
end

local function set(player: Player, profile: Profile): nil
	local cached = Profiles[player]
	if cached then
        error(`{player.Name} <{player.UserId}> is already cached in profiles`)
    end

	local newReplica = Replica.new({
		ClassToken = `Data_{player.UserId}`,
    	Data = profile.Data,
    	Replication = { player },
	})

	Profiles[player] = {
		profile = profile,
		replica = newReplica,
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
