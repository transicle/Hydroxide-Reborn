local Explorer = {}

local requiredMethods = {}

local knownServices = {
    "Workspace", "Players", "Lighting", "ReplicatedStorage", "ReplicatedFirst",
    "StarterGui", "StarterPack", "StarterPlayer", "Teams", "SoundService",
    "Chat", "LocalizationService", "HttpService", "RunService", "TweenService",
    "UserInputService", "GuiService", "InsertService", "CoreGui",
}

local function getChildren(instance)
    local ok, children = pcall(function() return instance:GetChildren() end)
    return ok and children or {}
end

local function getServices()
    local services = {}
    for _, name in ipairs(knownServices) do
        local ok, service = pcall(function() return game:GetService(name) end)
        if ok and service then
            table.insert(services, service)
        end
    end
    return services
end

Explorer.RequiredMethods = requiredMethods
Explorer.GetChildren = getChildren
Explorer.GetServices = getServices

return Explorer
