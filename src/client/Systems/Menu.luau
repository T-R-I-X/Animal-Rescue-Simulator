-- // Systems Shelter .luau
--- // Handles the main menu for the game

local Players = game:GetService("Players")

local MenuScreen = require(script.Parent.Parent.Gui.MenuScreen)

local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

local hudGui = playerGui:WaitForChild("Hud")
local container = hudGui:WaitForChild("Container")
local menuFrame = container:WaitForChild("Menu")

local Menu = {}
do
	function Menu.Init(): nil
		repeat
			task.wait()
		until player.Character

		--task.wait(2)
		menuFrame:SetAttribute("Visible", true)
	end

	menuFrame:GetAttributeChangedSignal("Visible"):Connect(function()
		local isVisible = menuFrame:GetAttribute("Visible")

		if isVisible then
			MenuScreen.render()
		else
			MenuScreen.destroy()
		end
	end)
end

return Menu
