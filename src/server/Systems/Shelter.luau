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
PlayerOwned.Shelters = {}

local Shelter = {}
do
	Shelter.Remotes = {
		PromptColorAndStyle = Net:RemoteEvent("PickColorAndStyle"),
		LoadingShelter = Net:RemoteEvent("LoadingShelter"),
		ShelterLoaded = Net:RemoteEvent("ShelterLoaded"),
	}

	function Shelter.Init(): nil
		Players.PlayerRemoving:Connect(Shelter.PlayerLeft)
		Net:Handle("SelectedShelter", function(player, shelter)
			assert(shelter and type(shelter) == "number", "shelter was incorrect")
			local success, result = Shelter.LoadShelter(player, shelter)

			if success then
				Log:Log("loaded shelter for " .. player.Name)
			else
				Log:Debug("error shelter: " .. player.Name .. "( @" .. player.DisplayName .. " ) " .. result)
			end

            return success, result
		end)
	end

	function Shelter.LoadShelter(player: Player, shelterName: number): (boolean, string | nil)
		local result = Datastore.get(player, 25)
		if not result then
			return false, "profile not found"
		end

		result = result.get()

		local shelterModel = shelterFolder:FindFirstChild(tostring(shelterName))
		if not shelterModel then
			return false, "shelter not found in workspace"
		end
		local shelter = result.facility

		if shelter.resources == nil then
			Shelter.Remotes.PromptColorAndStyle:FireClient(player)
			return false, "shelter hasn't been initialized"
		end

		if shelterModel:GetAttribute("Owner") == nil then
			shelterModel:SetAttribute("Owner", player.UserId)
			PlayerOwned.Shelters[player] = shelterModel

			Shelter.Remotes.ShelterLoaded:FireClient(player)

			player.Character.PrimaryPart:PivotTo(shelterModel.PrimaryPart.CFrame) -- shelterModel.PrimaryPart.CFrame

			return true, "shelter loaded"
		else
			return false, "couldn't find a new shelter"
		end
	end

	function Shelter.PlayerLeft(player: Player): nil
		if PlayerOwned.Shelters[player] then
			PlayerOwned.Shelters[player]:SetAttribute("Owner", nil)
			PlayerOwned.Shelters[player] = nil
		end
	end

	function Shelter.GetPlayerShelter(player: Player): Model | nil
		return PlayerOwned.Shelters[player]
	end

	function Shelter.WaitForPlayerShelter(player: Player, timeout: number | nil): Model
		WaitFor.Custom(function()
			return PlayerOwned.Shelters[player]
		end, timeout or 10):await()
		return PlayerOwned.Shelters[player]
	end
end

return Shelter
