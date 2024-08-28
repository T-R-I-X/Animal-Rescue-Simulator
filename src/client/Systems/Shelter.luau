-- // Systems Shelter.luau
--- // Handles animal shelters on client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local ShelterCustomize = require(script.Parent.Parent.Gui.ShelterCustomize)
local ShelterSelector = require(script.Parent.Parent.Gui.ShelterSelector)

local player = Players.LocalPlayer

local Shelter = {}
do
	Shelter.Remotes = {
		PromptInitialize = Net:RemoteEvent("PromptInitialize"),
		SelectedShelter = Net:RemoteFunction("SelectedShelter"),
		UpdateShelter = Net:RemoteFunction("UpdateShelter"),
	}

	function Shelter.Init(): nil
		repeat
			task.wait()
		until player.Character

		Net:RemoteEvent("PromptInitialize").OnClientEvent:Connect(function()
			ShelterCustomize.frame:SetAttribute("Visible", true)
			ShelterSelector.frame:SetAttribute("Visible", false)
		end)
	end

	ShelterSelector.frame:GetAttributeChangedSignal("Visible"):Connect(function()
		local isVisible = ShelterSelector.frame:GetAttribute("Visible")
		if isVisible then
			ShelterSelector.render()
		else
			ShelterSelector.destroy()
		end
	end)

	ShelterCustomize.frame:GetAttributeChangedSignal("Visible"):Connect(function()
		local isVisible = ShelterCustomize.frame:GetAttribute("Visible")
		if isVisible then
			ShelterCustomize.render()
		else
			ShelterCustomize.destroy()
		end
	end)
end

return Shelter
