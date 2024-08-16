--!strict
-- // Systems Shelter .luau
--- // Handles animal shelters on client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)

local currentCamera = workspace.CurrentCamera
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

local hudGui = playerGui:WaitForChild("Hud")
local container = hudGui:WaitForChild("Container")
local menuFrame = container:WaitForChild("Menu")

local spawnLocation = workspace:WaitForChild("SpawnLocation")

local menuTrove = Trove.new()

local Shelter = {}
do
	Shelter.Remotes = {
		PromptColorAndStyle = Net:RemoteEvent("PickColorAndStyle"),
		LoadingShelter = Net:RemoteEvent("LoadingShelter"),
		ShelterLoaded = Net:RemoteEvent("ShelterLoaded"),
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
			menuFrame.Visible = true

            local newGameBtn = menuFrame:WaitForChild("NewGame")
            local loadBtn = menuFrame:WaitForChild("Load")
            local settingBtn = menuFrame:WaitForChild("Settings")

            local children = menuFrame:GetChildren()
            table.sort(children, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)

			for _, instance in ipairs(children) do
				--if instance:IsA("TextButton") then
					instance:SetAttribute("InitialPosition", instance.Position)
					instance.Position = UDim2.fromScale(0.5, 1.2)
				--end
			end

            task.spawn(function()
                for _, instance in ipairs(children) do
                    --if instance:IsA("TextButton") then
                        TweenService:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Circular), {
                            Position = instance:GetAttribute("InitialPosition"),
                        }):Play()
                        instance:SetAttribute("InitialPosition", nil)
                        task.wait(0.2)
                    --end
                end
            end)

			local currentRot = 0

			menuTrove:Add(RunService.RenderStepped:Connect(function(dt)
				if currentRot >= 360 then
					currentRot = 0
				end
				currentRot += 10 * dt

				local newPos = spawnLocation.CFrame * CFrame.Angles(0, math.rad(currentRot), 0) * CFrame.new(0, 65, 65)
				currentCamera.CFrame = CFrame.new(newPos.Position, spawnLocation.Position)
			end))

            menuTrove:Add()
		else
			menuTrove:Clean()
			menuFrame.Visible = false
		end
	end)
end

return Shelter
