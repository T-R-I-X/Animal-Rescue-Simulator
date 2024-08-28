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
		PromptInitialize = Net:RemoteEvent("PromptInitialize"),
		SelectedShelter = Net:RemoteFunction("SelectedShelter"),
		UpdateShelter = Net:RemoteFunction("UpdateShelter"),
	}

	function Shelter.Init(): nil
		Players.PlayerRemoving:Connect(Shelter.PlayerLeft)

		Shelter.Remotes.UpdateShelter.OnServerInvoke = function(player, shelterType, primaryColor, secondaryColor)
			local success, msg = pcall(function()
				assert(player and player:IsDescendantOf(Players), "PARAM player was not in the game.")
				assert(shelterType and typeof(shelterType) == "number", "PARAM shelterType was not a NUMBER.")
				assert(primaryColor and typeof(primaryColor) == "Color3", "PARAM primaryColor was not a COLOR3.")
				assert(secondaryColor and typeof(secondaryColor) == "Color3", "PARAM secondaryColor was not a COLOR3.")

				local result = Datastore.get(player, 25)
				if not result then
					return false, "game data not found."
				end

				local data = result.get()
				print(data.initialized)
				assert(data.initialized == false, "facility already initialized, wipe player data first!") -- check if they are initialized TODO add gamepass check for customization

				local newTable = data.facility
				newTable.mainColor = primaryColor
				newTable.secondaryColor = secondaryColor
				newTable.typeof = shelterType

				result.update("facility", newTable)
				result.update("initialized", true)
				return true, "updated facility."
			end)

			return success, msg
		end

		Shelter.Remotes.SelectedShelter.OnServerInvoke = function(player, shelter)
			assert(shelter and type(shelter) == "number", "PARAM shelter was not a number.")
			local success, result = Shelter.LoadShelter(player, shelter)

			if success then
				Log:Log("loaded shelter for " .. player.Name)
			else
				Log:Debug("error shelter: " .. player.Name .. "( @" .. player.DisplayName .. " ) " .. result)
			end

			return success, result
		end
	end

	function Shelter.LoadShelter(player: Player, spot: number): (boolean, string | nil)
		local result = Datastore.get(player, 25)
		if not result then
			return false, "game data not found."
		end

		result = result.get()

		local shelterModel = shelterFolder:FindFirstChild(tostring(spot))
		if not shelterModel then
			return false, "shelter not found in workspace."
		end

		--facility: {
		--	typeof: number,
		--	upgrades: { number },
		--	petsIncubating: { { id: number, rarity: number, progress: number } },
		--	staff: { { name: string, level: number } },
		--	resources: {
		--		food: number,
		--		water: number,
		--		medicine: number,
		--	},
		--	mainColor: Color3,
		--	secondaryColor: Color3,
		--},

		local facilityData = result.facility

		if result.initialized == nil then
			Shelter.Remotes.PromptInitialize:FireClient(player)
			return false, "shelter hasn't been initialized."
		end

		if shelterModel:GetAttribute("Owner") == nil then
			shelterModel:SetAttribute("Owner", player.UserId)
			PlayerOwned.Shelters[player] = shelterModel

			Shelter.Remotes.ShelterLoaded:FireClient(player)

			player.Character.PrimaryPart:PivotTo(shelterModel.PrimaryPart.CFrame) -- shelterModel.PrimaryPart.CFrame

			return true, "shelter was loaded."
		else
			return false, "couldn't select this shelter."
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
