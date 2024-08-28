--!strict
-- // Systems Player.luau
--- // Handles player on server

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Datastore = require(script.Parent.Parent.Lib.Datastore)
local Net = require(ReplicatedStorage.Packages.Net)
local Concur = require(ReplicatedStorage.Packages.Concur)

local GameData = {}
do
	function GameData.Init(): nil
		Net:Handle("StartNewGame", function(player)
			local result = Datastore.get(player, 25)
			if result then
				local data = result.get()
				if data.initialized == true then
					return true, "wiped data."
				else
					return false, "can't start new game."
				end
			else
				return false, "couldn't get game data."
			end
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
		Concur.all(all)

		Players.PlayerAdded:Connect(Datastore.load)
	end
end

return GameData
