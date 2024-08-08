local metadata = {}
metadata._Loaded = false

local function loadMetadataInFolder(folder:Folder):nil
    for _, file in ipairs(script.Parent._Metadata:GetChildren()) do
        if file:IsA("Folder") then
            loadMetadataInFolder(file)
        elseif file:IsA("ModuleScript") then
            if folder.Name == "_Metadata" then
                metadata[file.Name] = require(file)
            else
                if metadata[folder.Name] == nil then
                    metadata[folder.Name] = {}
                end
                metadata[folder.Name][file.Name] = require(file)
            end
        end
    end
end

if metadata._Loaded ~= true then
    loadMetadataInFolder(script.Parent._Metadata)
    metadata._Loaded = true
end

return metadata :: {[string]: {[string]: table} | table}