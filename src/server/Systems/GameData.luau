-- Handles the loading of game data. Should be called on server startup.

local Net = require(game.ReplicatedStorage.Packages.Net)
local Concur = require(game.ReplicatedStorage.Packages.Concur)
local Log = require(game.ReplicatedStorage.Shared.Logging).new("GameData")

local GameData = {}
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
end

return GameData
