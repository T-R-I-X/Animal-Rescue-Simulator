-- // lib Datastore.luau

local ProfileService = require(game.ReplicatedStorage.Packages.ProfileService)
local Replica = require(game.ReplicatedStorage.Packages.ReplicaService)
local WaitFor = require(game.ReplicatedStorage.Packages.WaitFor)
local MainData = require(script.Parent.Parent._Metadata.MainData)

export type Profile = ProfileService.Profile<MainData.MainData, any>
export type ProfileTable =
 {
    [Player]: {
        profile: Profile,
        update: (key:string, newValue:any) -> MainData.MainData,
        getKey: (key:string) -> any
    }
}

local Datastore = {}
Datastore._store = ProfileService.GetProfileStore("Game", MainData)

local Profiles: ProfileTable = {}

local function update(profile: Profile, key: string, value: number | string | { [any]: any } | { any } | Color3)
    
end

local function set(player:Player, profile: Profile)
    local cached = Profiles[player]
    if cached then error("", 2) end
    Profiles[player] = {
        
    } :: ProfileTable
end

function Datastore.get(player: Player, timeout: number) : Profile | nil
    WaitFor.Custom(function()
        return Profiles[player]
    end, timeout or 10):await()
    return Profiles[player]
end

function Datastore.load(player: Player) : Profile | nil                                                                               7m7m nil
    
end

return Datastore