-- Handles the loading of game data. Should be called on server startup.

local ProfileService = require(game.ReplicatedStorage.Packages.ProfileService)
local Net = require(game.ReplicatedStorage.Packages.Net)
local Concur = require(game.ReplicatedStorage.Packages.Concur)
local WaitFor = require(game.ReplicatedStorage.Packages.WaitFor)
local Replica = require(game.ReplicatedStorage.Packages.ReplicaService)
local Log = require(game.ReplicatedStorage.Shared.Logging).new("GameData")

local MainData = require(script.Parent.Parent._Metadata.MainData)

local _store = ProfileService.GetProfileStore("Game", MainData)

local GameData: { Profiles: { [Player]: { profile: ProfileService.Profile<MainData.MainData, any>, update: (key:string, newValue:any) -> MainData.MainData, getKey: (key:string) -> any } } } = {
	Profiles = {},
}
do
	function GameData.Init(): nil
		Net:Handle("DataIsLoaded", function(player: Player)
			return GameData.Profiles[player] ~= nil
		end)

        local all = {}
		for _, p in ipairs(game.Players:GetPlayers()) do
			table.insert(all, Concur.spawn(function(player:Player)
                GameData.PlayerJoined(player)
            end, p))
		end
        Concur.all(all):OnCompleted(function()
            Log:Log(#all .. " preloaded")
        end)

		game.Players.PlayerAdded:Connect(GameData.PlayerJoined)
	end

	function GameData.PlayerJoined(player: Player)
		local success, result = GameData.LoadPlayer(player)

		if success then
			Log:Log("loaded data for " .. player.Name)
		else
			Log:Debug("error loading data: " .. player.Name .. "( @" .. player.DisplayName .. " )" .. result)
			player:Kick("Error loading data: " .. result)
		end
	end

	function GameData.LoadPlayer(player: Player): (boolean, string)
		if player:IsA("Player") and player:IsDescendantOf(game.Players) then
			local profile: ProfileService.Profile<MainData.MainData, any> = _store:LoadProfileAsync(player.UserId, true)

			if profile ~= nil then
				profile:AddUserId(player.UserId)
				profile:Reconcile()
				profile:ListenToRelease(function()
					GameData.Profiles[player] = nil
					player:Kick()
				end)

				GameData.Profiles[player] = profile
				return true, profile
			else
				return false, "Profile failed to load."
			end
		end

		return false, "Player isn't a player?"
	end

    function GameData.GetProfile(player: Player, timeout:number?): ProfileService.Profile<MainData.MainData, any> | nil
        if player:IsA("Player") and player:IsDescendantOf(game.Players) then
            WaitFor.Custom(function()
                return GameData.Profiles[player]
            end, timeout or 10):await()
            return GameData.Profiles[player]
        end
        return nil
    end
end

return GameData
