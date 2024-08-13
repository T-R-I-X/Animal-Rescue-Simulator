--!strict
-- // lib Replicate.luau
--- // Handles replicating values from server to client

local Replicate = {}
Replicate.__index = Replicate

local ReplicatedTokens: { [string]: any | { any } } = {}
local Queue = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local Concur = require(ReplicatedStorage.Packages.Concur)
local Log = require(ReplicatedStorage.Shared.Logging).new("Replicate")

--
local UpdateValue = Net:RemoteEvent("UpdateReplicated")

Net:Handle("GetInitialValue", function(player: Player, token: string | nil)
	local cache = ReplicatedTokens[token]
	if not player:IsDescendantOf(Players) then
		return
	end
	if cache then
		Log:Fatal(`{token} does not exist in REPLICATEDTOKENS`)
		return
	end
	return cache:GetValue()
end)

task.spawn(function()
	while true do
		if #Queue < 1 then
			task.wait()
			return
		end -- avoid console spam

		local tasks = {}
		for _, queued in next, Queue do
			table.insert(
				tasks,
				Concur.spawn(function(queued)
					local queuePlayer = queued.Player
					if queuePlayer and typeof(queuePlayer) == "Instance" then
						if queuePlayer:IsA("Player") and queuePlayer:IsDescendantOf(Players) then
							UpdateValue:FireClient(queuePlayer, queued.Value)
						else
							Log:Warn(`queue dropped for USER`)
						end
					else
						UpdateValue:FireAllClients(queued.Value)
					end
				end, queued)
			)
		end

		Log:Debug(`updated queue for #{#tasks}`)
		Concur.all(tasks)
		task.wait()
	end
end)

function Replicate.new(token: string, initialValue: any, player: Player?)
	local self = setmetatable({
		_token = token,
		_player = player,
		data = initialValue,
	}, Replicate)
	table.insert(Queue, {
		Player = self._player,
		Value = self.data,
	})
    return self
end

function Replicate:TiePlayer(player: Player)
    self._player = player
    table.insert(Queue, {
        Player = self._player,
        Value = self.data
    })
end

function Replicate:UpdateValue(newValue: any)
	self.data = newValue
	table.insert(Queue, {
		Player = self._player,
		Value = self.data,
	})
end
