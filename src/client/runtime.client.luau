local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = require(ReplicatedStorage:WaitForChild("Shared").Framework)
Framework.LoadAll(script.Parent.Systems, true)

require(script.Parent.Lib.ButtonEffects)