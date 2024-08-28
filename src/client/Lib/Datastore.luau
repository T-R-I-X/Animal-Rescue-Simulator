--!strict
-- // Lib Datastore.luau
--- // Handles the replicated data

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Replica = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Replica"))
local WaitFor = require(ReplicatedStorage.Packages.WaitFor)

local player = Players.LocalPlayer

local Datastore = {}
Datastore.Replica = nil

Replica.ReplicaOfClassCreated(`Data_{player.UserId}`, function(replica)
    Datastore.Replica = replica
end)

function Datastore.waitFor()
    if Datastore.Replica then return end

    WaitFor.Custom(function()
        return Datastore.Replica ~= nil
    end):await()

    task.wait(0.15) --prevents race condition
end

return Datastore