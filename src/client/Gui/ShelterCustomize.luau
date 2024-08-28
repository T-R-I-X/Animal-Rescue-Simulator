local ShelterCustomize = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)

local currentCamera = workspace.CurrentCamera
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local shelterModelFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ShelterModels")
local currentTrove = Trove.new()

local shelterGui = playerGui:WaitForChild("Shelter")
local container = shelterGui:WaitForChild("Container")
ShelterCustomize.frame = container:WaitForChild("Customize")

local confirmBtn = ShelterCustomize.frame:WaitForChild("Confirm") :: TextButton
local nextBtn = ShelterCustomize.frame:WaitForChild("Next") :: TextButton
local previousBtn = ShelterCustomize.frame:WaitForChild("Previous") :: TextButton

local selectionColors = ShelterCustomize.frame:WaitForChild("SelectionColors")
local primaryBtn = selectionColors:WaitForChild("Primary") :: TextButton
local secondaryBtn = selectionColors:WaitForChild("Secondary") :: TextButton

local wheelContainer = ShelterCustomize.frame:WaitForChild("Wheel") :: Frame
local colors = wheelContainer:WaitForChild("Color") :: ImageButton
local slider = wheelContainer:WaitForChild("Slider") :: Frame

local defaultColorBtn = primaryBtn.BackgroundColor3
local selectedColorBtn = Color3.new(0.176470, 0.517647, 0.725490)
local selectedTextColor = Color3.new(0.705882, 0.705882, 0.705882)

local function updateColor()
	local colorPickerCenter = colors.Picker.AbsolutePosition + (colors.Picker.AbsoluteSize / 2)
	local centerOfWheel = colors.AbsolutePosition + (colors.AbsoluteSize / 2)

	local h = (math.pi - math.atan2(colorPickerCenter.Y - centerOfWheel.Y, colorPickerCenter.X - centerOfWheel.X))
		/ (math.pi * 2)
	local s = (centerOfWheel - colorPickerCenter).Magnitude / (colors.AbsoluteSize.X / 2)
	local v = math.abs(
		(slider.Slider.Slider.AbsolutePosition.Y - slider.Slider.AbsolutePosition.Y) / slider.Slider.AbsoluteSize.Y - 1
	)

	local hsv = Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1))
	slider.Slider.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(h, s, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
	})

	return hsv
end

local function updateBtnColors(isPrimary)
	if isPrimary then
		primaryBtn.BackgroundColor3 = selectedColorBtn
		secondaryBtn.BackgroundColor3 = defaultColorBtn
		primaryBtn.TextLabel.TextColor3 = selectedTextColor
		secondaryBtn.TextLabel.TextColor3 = Color3.new(1, 1, 1)
	else
		primaryBtn.BackgroundColor3 = defaultColorBtn
		secondaryBtn.BackgroundColor3 = selectedColorBtn
		primaryBtn.TextLabel.TextColor3 = Color3.new(1, 1, 1)
		secondaryBtn.TextLabel.TextColor3 = selectedTextColor
	end
end

function ShelterCustomize.render()
	local primaryColor = Color3.fromHSV(0, 0.0, 1)
	local secondaryColor = Color3.fromHSV(0, 0.0, 1)
	local shelterStyle = 1
	local currentRot = 0
	local maxShelterStyle = #shelterModelFolder:GetChildren()
	local shelterModel
	local isPrimary = true
	local holdingColor = false
	local holdingSlider = false

	wheelContainer:SetAttribute("PrimaryPicker", UDim2.fromScale(0.5, 0.5))
	wheelContainer:SetAttribute("SecondaryPicker", UDim2.fromScale(0.5, 0.5))
	wheelContainer:SetAttribute("PrimarySlider", UDim2.fromScale(0.5, 0.087))
	wheelContainer:SetAttribute("SecondarySlider", UDim2.fromScale(0.5, 0.087))

	currentTrove:Add(confirmBtn.Activated:Connect(function()
		local success, msg = Net:Fire("UpdateShelter"):InvokeServer(shelterStyle, primaryColor, secondaryColor)
		if success then
			ShelterCustomize.frame.Visible = false
			ShelterCustomize.frame.Visible = true
		else
			warn(msg)
		end
	end))

	local function handleColorButtonClick(isPrimarySelected)
		isPrimary = isPrimarySelected
		updateBtnColors(isPrimary)

		local colorPickerPosition = wheelContainer:GetAttribute(isPrimary and "PrimaryPicker" or "SecondaryPicker")
		local sliderPosition = wheelContainer:GetAttribute(isPrimary and "PrimarySlider" or "SecondarySlider")

		colors.Picker.Position = colorPickerPosition
		slider.Slider.Slider.Position = sliderPosition
		updateColor()
	end

	currentTrove:Add(primaryBtn.Activated:Connect(function()
		handleColorButtonClick(true)
	end))
	currentTrove:Add(secondaryBtn.Activated:Connect(function()
		handleColorButtonClick(false)
	end))

	currentTrove:Add(nextBtn.Activated:Connect(function()
		shelterStyle = shelterStyle >= maxShelterStyle and 1 or shelterStyle + 1
	end))

	currentTrove:Add(previousBtn.Activated:Connect(function()
		shelterStyle = shelterStyle <= 1 and maxShelterStyle or shelterStyle - 1
	end))

	currentTrove:Add(colors.MouseButton1Down:Connect(function()
		holdingColor = true
	end))
	currentTrove:Add(slider.Slider.ActiveControl.MouseButton1Down:Connect(function()
		holdingSlider = true
	end))

	currentTrove:Add(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			holdingColor = false
			holdingSlider = false
		end
	end))

	currentTrove:Add(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		if not holdingColor and not holdingSlider then
			return
		end

		local mousePos = UserInputService:GetMouseLocation()
			- Vector2.new(0, game:GetService("GuiService"):GetGuiInset().Y)
		local centerOfWheel = colors.AbsolutePosition + (colors.AbsoluteSize / 2)
		local distanceFromWheel = (mousePos - centerOfWheel).Magnitude

		if holdingColor and distanceFromWheel <= colors.AbsoluteSize.X / 2 then
			local newPos =
				UDim2.new(0, mousePos.X - colors.AbsolutePosition.X, 0, mousePos.Y - colors.AbsolutePosition.Y)
			colors.Picker.Position = newPos
			wheelContainer:SetAttribute(isPrimary and "PrimaryPicker" or "SecondaryPicker", newPos)
		elseif holdingSlider then
			local newPos = UDim2.new(
				slider.Slider.Slider.Position.X.Scale,
				0,
				0,
				math.clamp(mousePos.Y - slider.Slider.AbsolutePosition.Y, 0, slider.Slider.AbsoluteSize.Y)
			)
			slider.Slider.Slider.Position = newPos
			wheelContainer:SetAttribute(isPrimary and "PrimarySlider" or "SecondarySlider", newPos)
		end

		if isPrimary then
			primaryColor = updateColor()
		else
			secondaryColor = updateColor()
		end
	end))

	currentTrove:Add(RunService.RenderStepped:Connect(function(dt)
		if not shelterModel or shelterModel.Name ~= tostring(shelterStyle) then
			if shelterModel then
				shelterModel:Destroy()
			end
			shelterModel = shelterModelFolder:WaitForChild(tostring(shelterStyle)):Clone()
			shelterModel.Name = "ClonedShelter"
			shelterModel.Parent = workspace
			shelterModel:PivotTo(workspace:WaitForChild("Spintable").PrimaryPart.CFrame)
		end

		currentCamera.CameraType = Enum.CameraType.Scriptable
		local spintablePrimary = workspace:WaitForChild("Spintable").PrimaryPart
		local newPos = spintablePrimary.CFrame * CFrame.new(0, 45, 45)
		currentCamera.CFrame = CFrame.new(newPos.Position, spintablePrimary.Position)

		for _, primaryPart: BasePart in ipairs(shelterModel:WaitForChild("PrimaryColors"):GetChildren()) do
			primaryPart.Color = primaryColor
		end

		for _, secondaryPart: BasePart in ipairs(shelterModel:WaitForChild("SecondaryColors"):GetChildren()) do
			secondaryPart.Color = secondaryColor
		end

		currentRot = (currentRot >= 360) and 0 or (currentRot + 10 * dt)
		shelterModel:PivotTo(shelterModel.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(currentRot), 0))
	end))

	updateBtnColors(isPrimary)
	ShelterCustomize.frame.Visible = true
end

function ShelterCustomize.destroy()
	ShelterCustomize.frame.Visible = true
	currentTrove:Clean()
end

return ShelterCustomize
