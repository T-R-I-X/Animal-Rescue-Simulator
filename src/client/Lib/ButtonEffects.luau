--!strict
-- // Lib ButtonEffects.luau
--- // Handles button effects

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Trove = require(ReplicatedStorage.Packages.Trove)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Effects = {}
Effects.Troves = {}
Effects.Tags = {
	ButtonRipple = function(object: ImageButton | TextButton)
		if not Effects.Troves["ButtonRipple"] then
			Effects.Troves.ButtonRipple = {}
		end

		local newTrove = Trove.new()
		Effects.Troves.ButtonRipple[object] = newTrove

		object.ClipsDescendants = true
		object.AutoButtonColor = false

		newTrove:Add(object.Activated:Connect(function()
			local mouseX, mouseY = mouse.X, mouse.Y
			local rippleImage = Instance.new("ImageLabel")
			rippleImage.AnchorPoint = Vector2.new(0.5, 0.5)
			rippleImage.Size = UDim2.fromScale(0.02, 0.02)
			rippleImage.BackgroundTransparency = 1
			rippleImage.Image = "rbxassetid://70913100200078"
			rippleImage.ImageTransparency = 0
			rippleImage.Parent = object
			rippleImage.ScaleType = Enum.ScaleType.Fit
			rippleImage.Position =
				UDim2.fromOffset(mouseX - object.AbsolutePosition.X, mouseY - object.AbsolutePosition.Y)

			local tween = TweenService:Create(rippleImage, TweenInfo.new(1), {
				Size = UDim2.fromScale(1, 5),
				ImageTransparency = 1,
			})
			tween:Play()
			tween.Completed:Wait()
			rippleImage:Destroy()
		end))
	end,
	ButtonHover = function(object: ImageButton | TextButton)
		if not Effects.Troves["ButtonHover"] then
			Effects.Troves.ButtonHover = {}
		end

		local original = object.Size
		local newTrove = Trove.new()
		Effects.Troves.ButtonHover[object] = newTrove

		object.AutoButtonColor = false

		newTrove:Add(object.MouseEnter:Connect(function()
			local tween = TweenService:Create(
				object,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
                    Size = original + UDim2.fromScale(0.005, 0.005)
                }
			)
            tween:Play()
		end))
        newTrove:Add(object.MouseLeave:Connect(function()
            local tween = TweenService:Create(
				object,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{ Size = original }
			)
            tween:Play()
        end))
	end,
	ButtonClick = function(object: ImageButton | TextButton)
        if not Effects.Troves["ButtonClick"] then
			Effects.Troves.ButtonClick = {}
		end

		local original = object.Size
		local newTrove = Trove.new()
		Effects.Troves.ButtonClick[object] = newTrove

		object.AutoButtonColor = false

		newTrove:Add(object.Activated:Connect(function()
			local tween = TweenService:Create(
				object,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true),
				{
                    Size = original - UDim2.fromScale(0.005, 0.005)
                }
			)
            tween:Play()
		end))
    end,
	ButtonParticles = function(object: ImageButton | TextButton) end,
}

for tagName, tagFunction in pairs(Effects.Tags) do
	CollectionService:GetInstanceAddedSignal(tagName):Connect(function(obj)
		tagFunction(obj)
	end)
	CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(obj)
		if Effects.Troves[tagName] then
			local _trove = Effects.Troves[tagName][obj]
			_trove:Clean()
		end
	end)

	for _, object in ipairs(CollectionService:GetTagged(tagName)) do
		tagFunction(object)
	end
end

return Effects
