local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local _loader = require(Packages:WaitForChild("Loader"))

local Framework = {}

local function loadAll(moduleFolder: Folder, callOnStart: boolean?)
	callOnStart = if callOnStart == nil then false else callOnStart

	print("LOADING all MODULES in " .. moduleFolder.Name .. ", WITH callOnStart = " .. tostring(callOnStart))

	_loader.SpawnAll(
		_loader.LoadDescendants(moduleFolder, function(module)
			local disabled = module:GetAttribute("Disabled")

			if disabled == true then
				return false
			end -- don't load disabled modules
			if module.Parent:IsA("ModuleScript") then
				return false
			end -- don't load modules that are under other modules

			return true
		end),
		"Init"
	)

	print("LOADED all MODULES")
end

Framework.LoadAll = loadAll
Framework.Developer = {}
Framework.Developer.AdminLevels = { Operator = 0, Administrator = 1, Moderator = 2, Tester = 3, Everyone = 4 }
Framework.Developer.GameMasters = { { id = 0, level = Framework.Developer.AdminLevels.Operator, label = "Operator" } }
return Framework
