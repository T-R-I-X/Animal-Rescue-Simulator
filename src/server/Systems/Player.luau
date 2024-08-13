--!strict
-- // Systems Player.luau
--- // Handles player on server

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Datastore = require(script.Parent.Parent.Lib.Datastore)
local Net = require(ReplicatedStorage.Packages.Net)
local Concur = require(ReplicatedStorage.Packages.Concur)
local Log = require(ReplicatedStorage.Shared.Logging).new("GameData")

local GameData = {}
do
	function GameData.Init(): nil
		Net:Handle("DataIsLoaded", function(player: Player)
			return
		end)

		local all = {}
		for _, p in ipairs(Players:GetPlayers()) do
			table.insert(
				all,
				Concur.spawn(function(player: Player)
					Datastore.load(player)
				end, p)
			)
		end
		Concur.all(all):OnCompleted(function()
			Log:Log(#all .. " preloaded")
		end)

		Players.PlayerAdded:Connect(Datastore.load)
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
end

return GameData
