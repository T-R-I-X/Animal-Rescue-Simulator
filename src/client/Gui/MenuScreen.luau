-- // Gui MenuScreen.luau
--- // Handles the menu screen

local Menu = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Datastore = require(script.Parent.Parent.Lib.Datastore)

local currentCamera = workspace.CurrentCamera
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

local shelterGui = playerGui:WaitForChild("Shelter")
local hudGui = playerGui:WaitForChild("Hud")

local container1 = hudGui:WaitForChild("Container")
local container2 = shelterGui:WaitForChild("Container")

local menuFrame = container1:WaitForChild("Menu")
--local selector = container2:WaitForChild("LocationSelector") TODO add selector
local customize = container2:WaitForChild("Customize")

local gameRoot = workspace.PrimaryPart

local menuTrove = Trove.new()

function Menu.render()
	menuFrame.Visible = true

	local newGameBtn = menuFrame:WaitForChild("NewGame")
	local loadBtn = menuFrame:WaitForChild("Load")
	local settingBtn = menuFrame:WaitForChild("Settings")

	local replica = Datastore.get()
	if replica.Data.initialized == false then
		loadBtn.BackgroundColor3 = Color3.fromRGB(82, 82, 82)
	else
		loadBtn.BackgroundColor3 = Color3.fromRGB(61, 181, 255)
	end

	menuTrove:Add(replica:OnChange({ "initialized" }, function(newValue)
		if newValue == true then
			loadBtn.BackgroundColor3 = Color3.fromRGB(61, 181, 255)
		else
			loadBtn.BackgroundColor3 = Color3.fromRGB(82, 82, 82)
		end
	end))

	local children = menuFrame:GetChildren()
	table.sort(children, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	local function tweenMenu()
		for _, instance in ipairs(children) do
			if instance.Name ~= "Confirmation" then
				TweenService:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Circular), {
					Position = instance:GetAttribute("InitialPosition"),
				}):Play()
				task.wait(0.2)
			end
		end
	end

	for _, instance in ipairs(children) do
		if instance.Name ~= "Confirmation" then
			instance:SetAttribute("InitialPosition", instance.Position)
			instance.Position = UDim2.fromScale(0.5, 1.2)
		end
	end

	task.spawn(tweenMenu)

	local currentRot = 0

	menuTrove:Add(RunService.RenderStepped:Connect(function(dt)
		if currentRot >= 360 then
			currentRot = 0
		end
		currentRot += 10 * dt

		local newPos = gameRoot.CFrame * CFrame.Angles(0, math.rad(currentRot), 0) * CFrame.new(0, 65, 65)
		currentCamera.CFrame = CFrame.new(newPos.Position, gameRoot.Position)
	end))

	menuTrove:Add(newGameBtn.Activated:Connect(function()
		menuFrame:SetAttribute("Visible", false)

		task.defer(function()
			customize:SetAttribute("Visible", true)
		end)
	end))

	menuTrove:Add(loadBtn.Activated:Connect(function()
		--if Datastore.Replica.Data.initialized == true then
		--else
		--end
	end))

	menuTrove:Add(settingBtn.Activated:Connect(function() end))
end

function Menu.destroy()
	menuFrame.Visible = false
	menuTrove:Clean()

	for _, instance in ipairs(menuFrame:GetChildren()) do
		if instance:GetAttribute("InitialPosition") ~= nil then
			instance:SetAttribute("InitialPosition", nil)
		end
	end
end

return Menu
