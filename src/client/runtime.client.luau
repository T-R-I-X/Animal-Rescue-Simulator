local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WaitFor = require(ReplicatedStorage.Packages.WaitFor)

require(script.Parent.Lib.Datastore) -- initalize datastore

WaitFor.Custom(function()
	return game:GetAttribute("InitalData")
end):andThen(function()
	local Framework = require(ReplicatedStorage:WaitForChild("Shared").Framework)
	Framework.LoadAll(script.Parent.Systems, true)

	require(script.Parent.Lib.ButtonEffects)
end)
