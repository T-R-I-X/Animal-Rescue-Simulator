--!strict
-- // Systems Shelter .luau
--- // Handles animal shelters on server

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local Concur = require(ReplicatedStorage.Packages.Concur)
local Log = require(ReplicatedStorage.Shared.Logging).new("Shelter")
local WaitFor = require(ReplicatedStorage.Packages.WaitFor)
local Datastore = require(script.Parent.Parent.Lib.Datastore)

local shelterFolder = workspace.Shelters

local PlayerOwned = {}
PlayerOwned.Remotes = {}
local Shelter = {}
do
	Shelter.Remotes = {
		PickShelter = Net:RemoteEvent("PickShelter"),
		LoadingShelter = Net:RemoteEvent("LoadingShelter"),
		ShelterLoaded = Net:RemoteEvent("ShelterLoaded"),
	}

	function Shelter.Init(): nil
		local all = {}
		for _, p in ipairs(game.Players:GetPlayers()) do
			table.insert(all, Concur.spawn(Shelter.PlayerJoined, p))
		end
		Concur.all(all)

		Players.PlayerAdded:Connect(Shelter.PlayerJoined)
		Players.PlayerRemoving:Connect(Shelter.PlayerLeft)
	end

	function Shelter.PlayerJoined(player: Player): nil
		local success, result = Shelter.LoadShelter(player)

		if success then
			Log:Log("loaded shelter for " .. player.Name)
		else
			Log:Debug("error shelter: " .. player.Name .. "( @" .. player.DisplayName .. " )" .. result)
			player:Kick("Error loading shelter: " .. result)
		end
	end

	function Shelter.LoadShelter(player: Player): (boolean, string | nil)
		local result = Datastore.get(player, 25)
		if result == nil then
			return false, "profile not found"
		end

        result = result.get()

		local shelter = result.facility

		if shelter == nil then
			Shelter.Remotes.PickShelter:FireClient(player)
			return false, "shelter not picked"
		end

		local newShelter
		for _, shelterModel in ipairs(shelterFolder:GetChildren()) do
			if shelterModel:GetAttribute("Owner") == nil then
				shelterModel:SetAttribute("Owner", player.UserId)
				PlayerOwned[player] = shelterModel
				newShelter = shelterModel

				Shelter.Remotes.ShelterLoaded:FireClient(player)

				player.Character.PrimaryPart:PivotTo(shelterModel.PrimaryPart.CFrame) -- shelterModel.PrimaryPart.CFrame
				break
			end
		end

		if newShelter then
			return true, "shelter loaded"
		else
			return false, "couldn't find a new shelter"
		end
	end

	function Shelter.PlayerLeft(player: Player): nil
		if PlayerOwned[player] then
			PlayerOwned[player]:SetAttribute("Owner", nil)
			PlayerOwned[player] = nil
		end
	end

	function Shelter.GetPlayerShelter(player: Player): Model | nil
		return PlayerOwned[player]
	end

	function Shelter.WaitForPlayerShelter(player: Player, timeout: number | nil): Model
		WaitFor.Custom(function()
			return GameData.Profiles[player]
		end, timeout or 10):await()
		return GameData.Profiles[player]
	end
end

return Shelter
