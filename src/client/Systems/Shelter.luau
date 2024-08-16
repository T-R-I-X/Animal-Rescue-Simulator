--!strict
-- // Systems Shelter.luau
--- // Handles animal shelters on client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)

local currentCamera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local playerGui = player:WaitForChild("PlayerGui")

local shelterGui = playerGui:WaitForChild("Shelter")
local container = shelterGui:WaitForChild("Container")
local selector = container:WaitForChild("LocationSelector")
local customize = container:WaitForChild("Customize")

local shelterFolder = workspace.Shelters
local shelterModelFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ShelterModels")

local selectorTrove = Trove.new()
local wheelTrove = Trove.new()

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

		Shelter.Remotes.PromptColorAndStyle.OnClientEvent:Connect(function()
			customize:SetAttribute("Visible", true)
			selector:SetAttribute("Visible", false)
		end)

		--selector:SetAttribute("Visible", true)
	end

	selector:GetAttributeChangedSignal("Visible"):Connect(function()
		local isVisible = selector:GetAttribute("Visible")
		if isVisible then
			local currentShelter = 1
			local currentRot = 0
			local maxShelters = #shelterFolder:GetChildren()

			local offset = CFrame.new(0, 25, 25)

			local confirmBtn = selector:WaitForChild("Confirm") :: TextButton
			local nextBtn = selector:WaitForChild("Next") :: TextButton
			local previousBtn = selector:WaitForChild("Previous") :: TextButton

			selectorTrove:Add(confirmBtn.Activated:Connect(function()
				local success, err = Net:Invoke("SelectedShelter", currentShelter)
				if success then
					selector:SetAttribute("Visible", false)
				else
					warn(err)
				end
			end))

			selectorTrove:Add(nextBtn.Activated:Connect(function()
				currentShelter += 1
				if currentShelter > maxShelters then
					currentShelter = 1
				end
			end))

			selectorTrove:Add(previousBtn.Activated:Connect(function()
				currentShelter -= 1
				if currentShelter < 1 then
					currentShelter = maxShelters
				end
			end))

			selectorTrove:Add(mouse.WheelForward:Connect(function()
				if (offset.Position - CFrame.new(0, 25, 25).Position).Magnitude < 0.0001 then
					offset = CFrame.new(0, 25, 25)
				else
					offset -= CFrame.new(0, 2, 2).Position
				end
			end))

			selectorTrove:Add(mouse.WheelBackward:Connect(function()
				if (offset.Position - CFrame.new(0, 60, 60).Position).Magnitude < 2 then
					return
				else
					offset += CFrame.new(0, 2, 2).Position
				end
			end))

			selectorTrove:Add(RunService.RenderStepped:Connect(function(dt)
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

			selector.Visible = true
		else
			selector.Visible = false
			selectorTrove:Clean()
		end
	end)

	customize:GetAttributeChangedSignal("Visible"):Connect(function()
		local isVisible = customize:GetAttribute("Visible")
		if isVisible then
			customize.Visible = true

			local confirmBtn = customize:WaitForChild("Confirm") :: TextButton
			local nextBtn = customize:WaitForChild("Next") :: TextButton
			local previousBtn = customize:WaitForChild("Previous") :: TextButton
			local primaryBtn = customize:WaitForChild("Primary") :: TextButton
			local secondaryBtn = customize:WaitForChild("Secondary") :: TextButton

			local wheelContainer = customize:WaitForChild("Wheel") :: Frame

			local colors = wheelContainer:WaitForChild("Color") :: ImageButton
			local slider = wheelContainer:WaitForChild("Slider") :: Frame

			local defaultColorBtn = primaryBtn.BackgroundColor3
			local selectedColorBtn = Color3.new(0.176470, 0.517647, 0.725490)
			local selectedTextColor = Color3.new(0.705882, 0.705882, 0.705882)
			local secondaryColor = Color3.fromHSV(0, 0.0, 1)
			local primaryColor = Color3.fromHSV(0, 0.0, 1)
			local shelterStyle = 1
            local currentRot = 0
            local maxShelterStyle = #shelterModelFolder:GetChildren()
            local shelterModel = nil
			local isSecondary = false
			local isPrimary = true
			local holdingColor = false
			local holdingSlider = false

			wheelContainer:SetAttribute("PrimaryPicker", UDim2.fromScale(0.5, 0.5))
			wheelContainer:SetAttribute("SecondaryPicker", UDim2.fromScale(0.5, 0.5))

			wheelContainer:SetAttribute("PrimarySlider", UDim2.fromScale(0.5, 0.087))
			wheelContainer:SetAttribute("SecondarySlider", UDim2.fromScale(0.5, 0.087))

			local function updateColor()
				local colourPickerCentre = Vector2.new(
					colors.Picker.AbsolutePosition.X + (colors.Picker.AbsoluteSize.X / 2),
					colors.Picker.AbsolutePosition.Y + (colors.Picker.AbsoluteSize.Y / 2)
				)

				local centreOfWheel = Vector2.new(
					colors.AbsolutePosition.X + (colors.AbsoluteSize.X / 2),
					colors.AbsolutePosition.Y + (colors.AbsoluteSize.Y / 2)
				)

				local h = (
					math.pi
					- math.atan2(colourPickerCentre.Y - centreOfWheel.Y, colourPickerCentre.X - centreOfWheel.X)
				) / (math.pi * 2)

				local s = (centreOfWheel - colourPickerCentre).Magnitude / (colors.AbsoluteSize.X / 2)
				local v = math.abs((slider.Slider.Slider.AbsolutePosition.Y - slider.Slider.AbsolutePosition.Y) / slider.Slider.AbsoluteSize.Y - 1)

				local hsv = Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1))

				slider.Slider.UIGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(h, s, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
				})

				return hsv
			end

			local function updateBtnColors()
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

			wheelTrove:Add(primaryBtn.Activated:Connect(function()
				isPrimary = true
				isSecondary = false
				updateBtnColors()

				local colorPickerPosition, sliderPosition =
					wheelContainer:GetAttribute("PrimaryPicker"), wheelContainer:GetAttribute("PrimarySlider")
				colors.Picker.Position = colorPickerPosition
				slider.Slider.Slider.Position = sliderPosition
				updateColor()
			end))

			wheelTrove:Add(secondaryBtn.Activated:Connect(function()
				isPrimary = false
				isSecondary = true
				updateBtnColors()

				local colorPickerPosition, sliderPosition =
					wheelContainer:GetAttribute("SecondaryPicker"), wheelContainer:GetAttribute("SecondarySlider")
				colors.Picker.Position = colorPickerPosition
				slider.Slider.Slider.Position = sliderPosition
				updateColor()
			end))

            wheelTrove:Add(nextBtn.Activated:Connect(function()
                if shelterStyle >= maxShelterStyle then
                    shelterStyle = 1
                else
                    shelterStyle += 1
                end
            end))

            wheelTrove:Add(previousBtn.Activated:Connect(function()
                if shelterStyle <= 1 then
                    shelterStyle = maxShelterStyle
                else
                    shelterStyle -= 1
                end
            end))

			wheelTrove:Add(colors.MouseButton1Down:Connect(function()
				holdingColor = true
			end))

			wheelTrove:Add(slider.Slider.ActiveControl.MouseButton1Down:Connect(function()
				holdingSlider = true
			end))

			wheelTrove:Add(UserInput.InputEnded:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
					return
				end

				holdingColor = false
				holdingSlider = false
			end))

			wheelTrove:Add(UserInput.InputChanged:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseMovement then
					return
				end
				if holdingColor == false and holdingSlider == false then
					return
				end

				local mousePos = UserInput:GetMouseLocation()
					- Vector2.new(0, game:GetService("GuiService"):GetGuiInset().Y)

				local centreOfWheel = Vector2.new(
					colors.AbsolutePosition.X + (colors.AbsoluteSize.X / 2),
					colors.AbsolutePosition.Y + (colors.AbsoluteSize.Y / 2)
				)
				local distanceFromWheel = (mousePos - centreOfWheel).Magnitude

				if distanceFromWheel <= colors.AbsoluteSize.X / 2 and holdingColor then
					local newPos =
						UDim2.new(0, mousePos.X - colors.AbsolutePosition.X, 0, mousePos.Y - colors.AbsolutePosition.Y)
					colors.Picker.Position = newPos

					if isSecondary then
						wheelContainer:SetAttribute("SecondaryPicker", newPos)
					else
						wheelContainer:SetAttribute("PrimaryPicker", newPos)
					end
				elseif holdingSlider then
					local newPos = UDim2.new(
						slider.Slider.Slider.Position.X.Scale,
						0,
						0,
						math.clamp(mousePos.Y - slider.Slider.AbsolutePosition.Y, 0, slider.Slider.AbsoluteSize.Y)
					)
					slider.Slider.Slider.Position = newPos

					if isSecondary then
						wheelContainer:SetAttribute("SecondarySlider", newPos)
					else
						wheelContainer:SetAttribute("PrimarySlider", newPos)
					end
				end

				if isSecondary then
					secondaryColor = updateColor(centreOfWheel)
				else
					primaryColor = updateColor(centreOfWheel)
				end
			end))

            wheelTrove:Add(RunService.RenderStepped:Connect(function(dt)
                if shelterModel and shelterModel.Name ~= tostring(shelterStyle) or shelterModel == nil then
                    if shelterModel then shelterModel:Destroy() end
                    shelterModel = shelterModelFolder:WaitForChild(tostring(shelterStyle)):Clone()
                    shelterModel.Name = "ClonedShelter"
                    shelterModel.Parent = workspace
                    shelterModel:PivotTo(workspace:WaitForChild("Spintable").PrimaryPart.CFrame)
                end

                for _, primaryPart: BasePart in ipairs(shelterModel:WaitForChild("PrimaryColors"):GetChildren()) do
                    primaryPart.Color = primaryColor
                end

                for _, secondaryPart: BasePart in ipairs(shelterModel:WaitForChild("SecondaryColors"):GetChildren()) do
                    secondaryPart.Color = secondaryColor
                end

                if currentRot >= 360 then
					currentRot = 0
				end
				currentRot += 10 * dt

                shelterModel:PivotTo(shelterModel.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(currentRot), 0))
            end))

            local primary = workspace:WaitForChild("Spintable").PrimaryPart

            currentCamera.CameraType = Enum.CameraType.Scriptable

            local newPos = primary.CFrame * CFrame.new(0, 45, 45)
			currentCamera.CFrame = CFrame.new(newPos.Position, primary.Position)
			updateBtnColors()
		else
			customize.Visible = false
			wheelTrove:Clean()
		end
	end)
end

return Shelter
