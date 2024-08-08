local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local _loader = require(Packages:WaitForChild("Loader"))
local logging = require(script.Parent.Logging).new("_CoreFramework")

local Framework = {}

local function loadAll(moduleFolder:Folder, callOnStart:boolean?)
    callOnStart = if callOnStart == nil then false else callOnStart

    logging:Debug("loading all modules in " .. moduleFolder.Name .. ", with callOnStart = " .. tostring(callOnStart))

    _loader.SpawnAll(
        _loader.LoadDescendants(moduleFolder, function(module)
            local disabled = module:GetAttribute("Disabled")

            if disabled == true then return false end -- don't load disabled modules
            if module.Parent:IsA("ModuleScript") then return false end -- don't load modules that are under other modules

            return true
        end),
        "Init"
    )

    logging:Log("loaded all modules on " .. logging._Side)
end

Framework.LoadAll = loadAll
Framework.Developer = {}
Framework.Developer.AdminLevels = { Operator = 0, Administrator = 1, Moderator = 2, Tester = 3, Everyone = 4 }
Framework.Developer.GameMasters = { { id = 0, level = Framework.Developer.AdminLevels.Operator, label = "Operator" } }
return Framework