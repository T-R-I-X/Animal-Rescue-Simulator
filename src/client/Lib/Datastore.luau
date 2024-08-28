-- // Lib Datastore.luau
--- // Handles the replicated data

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Replica = require(ReplicatedStorage.Packages.Replica)
local WaitFor = require(ReplicatedStorage.Packages.WaitFor)

local player = Players.LocalPlayer

local Datastore = {}
Datastore.initialized = false
Datastore.Replicas = {}

function Datastore.waitFor(playerWait: Player | nil): Replica.ReplicaAny
	playerWait = playerWait or player
	if Datastore.Replicas[playerWait] then
		return Datastore.Replicas[playerWait]
	end

	WaitFor.Custom(function()
		--print("Waiting for replica")
		return Datastore.Replicas[playerWait]
	end):await()

	return Datastore.Replicas[playerWait]
	--task.wait(0.15) --prevents race condition
end

function Datastore.get(playerCache: Player | nil): Replica.ReplicaAny
	playerCache = playerCache or player
	if Datastore.Replicas[playerCache] then
		return Datastore.Replicas[playerCache]
	else
		return Datastore.waitFor(playerCache)
	end
end

if Datastore.initialized == false then
	Datastore.initialized = true

	Players.PlayerRemoving:Connect(function(p)
		Datastore.Replicas[p] = nil
	end)

	Replica.Controller:OnNewReplicaWithToken("GameData", function(replica: Replica.ReplicaAny)
		print(`RECIEVED REPLICA for GAMEDATA`)

		local playerFound = Players:GetPlayerByUserId(replica.Tags.ownerId)
		if playerFound then
			print(`CACHED REPLICA for PLAYER <{replica.Tags.ownerId}>`)
			Datastore.Replicas[playerFound] = replica
		end
	end)

	Replica:OnInitialDataReceived(function()
		print("Recieved INITIAL data for REPLICA")
		game:SetAttribute("InitalData", true)
	end)

	Replica.Controller:RequestData()
end

return Datastore
