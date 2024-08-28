--!strict
-- // Systems Shelter .luau
--- // Handles animal shelters on server

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local WaitFor = require(ReplicatedStorage.Packages.WaitFor)
local Datastore = require(script.Parent.Parent.Lib.Datastore)

local shelterFolder = ReplicatedStorage.Assets.ShelterModels
local spotFolder = workspace.Shelters

local PlayerOwned = {}
PlayerOwned.Shelters = {}

local Shelter = {}
do
	Shelter.Remotes = {
		PromptInitialize = Net:RemoteEvent("PromptInitialize"),
		SelectedShelter = Net:RemoteFunction("SelectedShelter"),
		UpdateShelter = Net:RemoteFunction("UpdateShelter"),
	}

	function Shelter.Init(): nil
		Players.PlayerRemoving:Connect(Shelter.PlayerLeft)

		Shelter.Remotes.UpdateShelter.OnServerInvoke = function(player, shelterType, primaryColor, secondaryColor)
			local success, msg = pcall(function()
				assert(player and player:IsDescendantOf(Players), "PARAM player was not in the game.")
				assert(shelterType and typeof(shelterType) == "number", "PARAM shelterType was not a NUMBER.")
				assert(primaryColor and typeof(primaryColor) == "Color3", "PARAM primaryColor was not a COLOR3.")
				assert(secondaryColor and typeof(secondaryColor) == "Color3", "PARAM secondaryColor was not a COLOR3.")

				local result = Datastore.get(player, 25)
				if not result then
					return false, "game data NOT FOUND."
				end

				local data = result.get()
				assert(data.initialized == false, "FACILITY already INITIALIZED, WIPE player data FIRST!") -- check if they are initialized TODO add gamepass check for customization

				local newTable = data.facility
				newTable.mainColor = primaryColor
				newTable.secondaryColor = secondaryColor
				newTable.typeof = shelterType

				result.update("facility", newTable)
				result.update("initialized", true)
				return true, "updated facility."
			end)

			return success, msg
		end

		Shelter.Remotes.SelectedShelter.OnServerInvoke = function(player, shelter)
			assert(shelter and type(shelter) == "number", "PARAM shelter was not a number.")
			local success, result = Shelter.LoadShelter(player, shelter)

			if success then
				print("LOADED shelter for " .. player.Name)
			else
				warn("ERROR shelter: " .. player.Name .. "( @" .. player.DisplayName .. " ) " .. result)
			end

			return success, result
		end
	end

	function Shelter.LoadShelter(player: Player, spot: number): (boolean, string | nil)
		local result = Datastore.get(player)
		if not result then
			return false, "game data NOT FOUND."
		end

		result = result.get()
		if result.initialized == nil then
			Shelter.Remotes.PromptInitialize:FireClient(player)
			return false, "shelter hasn't been initialized."
		end

		local spotModel = spotFolder:FindFirstChild(tostring(spot))
		if not spotModel then
			return false, "spot NOT FOUND in workspace."
		end

		--facility: {
		--	typeof: number,
		--	upgrades: { number },
		--	petsIncubating: { { id: number, rarity: number, progress: number } },
		--	staff: { { name: string, level: number } },
		--	resources: {
		--		food: number,
		--		water: number,
		--		medicine: number,
		--	},
		--	mainColor: Color3,
		--	secondaryColor: Color3,
		--},
		local facilityData = result.facility

		local shelterModel = shelterFolder:FindFirstChild(tostring(facilityData.typeof))
		if not shelterModel then
			return false, "shelter NOT FOUND in shelter models."
		end

		shelterModel = shelterModel:Clone()
		shelterModel.Name = `{player.Name}'s Shelter`
		shelterModel:ScaleTo(1)
		shelterModel:PivotTo(spotModel.PrimaryPart.CFrame * CFrame.new(0, -1.5, 0))

		-- Sign setup
		local signModel = shelterModel.Sign
		local surfaceGui = signModel.PrimaryPart.SurfaceGui
		local billboardGui = signModel.PrimaryPart.BillboardGui

		local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

		surfaceGui.Frame.TextLabel.Text = `@{player.Name}`
		if content and isReady then
			billboardGui.Frame.Default.Visible = false
			billboardGui.Frame.ImageLabel.Visible = true
			billboardGui.Frame.ImageLabel.Image = content
		end

		for _, primaryPart: BasePart in ipairs(shelterModel:WaitForChild("PrimaryColors"):GetChildren()) do
			primaryPart.Color = facilityData.mainColor
		end

		for _, secondaryPart: BasePart in ipairs(shelterModel:WaitForChild("SecondaryColors"):GetChildren()) do
			secondaryPart.Color = facilityData.secondaryColor
		end

		if spotModel:GetAttribute("Owner") == nil then
			spotModel:SetAttribute("Owner", player.UserId)
			shelterModel.Parent = workspace

			PlayerOwned.Shelters[player] = {
				model = shelterModel,
				spot = spotModel,
			}
			player.Character.PrimaryPart:PivotTo(shelterModel.Spawn.CFrame) -- shelterModel.PrimaryPart.CFrame

			return true, "shelter was LOADED."
		else
			return false, "couldn't SELECT this shelter."
		end
	end

	function Shelter.PlayerLeft(player: Player): nil
		if PlayerOwned.Shelters[player] then
			PlayerOwned.Shelters[player].model:Destroy()
			PlayerOwned.Shelters[player].spot:SetAttribute("Owner", nil)
			PlayerOwned.Shelters[player] = nil
		end
	end

	function Shelter.GetPlayerShelter(player: Player): Model | nil
		return PlayerOwned.Shelters[player]
	end

	function Shelter.WaitForPlayerShelter(player: Player, timeout: number | nil): Model
		WaitFor.Custom(function()
			return PlayerOwned.Shelters[player]
		end, timeout or 10):await()
		return PlayerOwned.Shelters[player]
	end
end

return Shelter
