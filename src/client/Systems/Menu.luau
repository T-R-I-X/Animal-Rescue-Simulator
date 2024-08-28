--!strict
-- // Systems Shelter .luau
--- // Handles animal shelters on client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Datastore = require(script.Parent.Parent.Lib.Datastore)

local currentCamera = workspace.CurrentCamera
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

local hudGui = playerGui:WaitForChild("Hud")
local container1 = hudGui:WaitForChild("Container")
local menuFrame = container1:WaitForChild("Menu")

local shelterGui = playerGui:WaitForChild("Shelter")
local container2 = shelterGui:WaitForChild("Container")
local selector = container2:WaitForChild("LocationSelector")
local customize = container2:WaitForChild("Customize")

local gameRoot = workspace:WaitForChild("Root")

local menuTrove = Trove.new()

local Shelter = {}
do
	Shelter.Remotes = {
		PromptInitialize = Net:RemoteEvent("PromptInitialize"),
	}

	function Shelter.Init(): nil
		repeat
			task.wait()
		until player.Character

		task.wait(2)
		menuFrame:SetAttribute("Visible", true)
	end


	menuFrame:GetAttributeChangedSignal("Visible"):Connect(function()
		local isVisible = menuFrame:GetAttribute("Visible")

		if isVisible then
		else
			
		end
	end)
end

return Shelter
