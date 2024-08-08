-- Handles the animal shelters. Should be called on server startup.

local Net = require(game.ReplicatedStorage.Packages.Net)
local Concur = require(game.ReplicatedStorage.Packages.Concur)
local Log = require(game.ReplicatedStorage.Shared.Logging).new("GameData")
local WaitFor = require(game.ReplicatedStorage.Packages.WaitFor)

local GameData = require(script.Parent.GameData)

local shelterFolder = workspace.Shelters

local PlayerOwned = {}
PlayerOwned.Remotes = {}
local Shelter = {}
do
	function Shelter.Init(): nil
        Net:RemoteEvent("PickShelter")
        Net:RemoteEvent("LoadingShelter")
        Net:RemoteEvent("ShelterLoaded")

        local all = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            table.insert(all, Concur.spawn(Shelter.PlayerJoined, p))
        end
        Concur.all(all)

        game.Players.PlayerAdded:Connect(Shelter.PlayerJoined)
        game.Players.PlayerRemoving:Connect(Shelter.PlayerLeft)
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
        local result = GameData.GetProfile(player)
        if result == nil then return false, "profile not found" end

        local shelter = result.Data.facility

        if shelter == nil then
            Net:RemoteEvent("PickShelter"):FireClient(player)
            return false, "shelter not picked"
        end

        local newShelter
        for _, shelterModel in ipairs(shelterFolder:GetChildren()) do
            if shelterModel:GetAttribute("Owner") == nil then
                shelterModel:SetAttribute("Owner", player.UserId)
                PlayerOwned[player] = shelterModel
                newShelter = shelterModel

                Net:Re

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

    function Shelter.GetPlayerShelter(player: Player): (Model | nil)
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
