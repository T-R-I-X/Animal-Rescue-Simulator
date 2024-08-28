local ShelterSelector = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)

local currentCamera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local playerGui = player:WaitForChild("PlayerGui")

local currentTrove = Trove.new()

local shelterFolder = workspace.Shelters

local shelterGui = playerGui:WaitForChild("Shelter")
local container = shelterGui:WaitForChild("Container")

ShelterSelector.frame = container:WaitForChild("LocationSelector")

local confirmBtn = ShelterSelector.frame:WaitForChild("Confirm") :: TextButton
local nextBtn = ShelterSelector.frame:WaitForChild("Next") :: TextButton
local previousBtn = ShelterSelector.frame:WaitForChild("Previous") :: TextButton

function ShelterSelector.render()
	local currentShelter = 1
	local currentRot = 0
	local maxShelters = #shelterFolder:GetChildren()

	local offset = CFrame.new(0, 25, 25)

	currentTrove:Add(confirmBtn.Activated:Connect(function()
		local success, err = Net:Invoke("SelectedShelter", currentShelter)
		if success then
			ShelterSelector.frame:SetAttribute("Visible", false)
		else
			warn(err)
		end
	end))

	currentTrove:Add(nextBtn.Activated:Connect(function()
		currentShelter += 1
		if currentShelter > maxShelters then
			currentShelter = 1
		end
	end))

	currentTrove:Add(previousBtn.Activated:Connect(function()
		currentShelter -= 1
		if currentShelter < 1 then
			currentShelter = maxShelters
		end
	end))

	currentTrove:Add(mouse.WheelForward:Connect(function()
		if (offset.Position - CFrame.new(0, 25, 25).Position).Magnitude < 0.0001 then
			offset = CFrame.new(0, 25, 25)
		else
			offset -= CFrame.new(0, 2, 2).Position
		end
	end))

	currentTrove:Add(mouse.WheelBackward:Connect(function()
		if (offset.Position - CFrame.new(0, 60, 60).Position).Magnitude < 2 then
			return
		else
			offset += CFrame.new(0, 2, 2).Position
		end
	end))

	currentTrove:Add(RunService.RenderStepped:Connect(function(dt)
		local shelter = shelterFolder:WaitForChild(tostring(currentShelter))
		local primary = shelter.PrimaryPart

		if not primary then
			return
		end

		if currentRot >= 360 then
			currentRot = 0
		end
		currentRot += 10 * dt

		local newPos = primary.CFrame * CFrame.Angles(0, math.rad(currentRot), 0) * offset
		currentCamera.CFrame = CFrame.new(newPos.Position, primary.Position)
	end))

	ShelterSelector.frame.Visible = true
end

function ShelterSelector.destroy()
	ShelterSelector.frame.Visible = false
	currentTrove:Clean()
end

return ShelterSelector