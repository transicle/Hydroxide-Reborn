local PropertyWatcher = {}

local requiredMethods = {}

local watchers = {}
local watchEvent = Instance.new("BindableEvent")
local eventSet = false

local function connectEvent(callback)
    watchEvent.Event:Connect(callback)
    if not eventSet then eventSet = true end
end

local function addWatcher(instance, property)
    local key = tostring(instance) .. "." .. property
    if watchers[key] then return false end

    local ok, conn = pcall(function()
        return instance:GetPropertyChangedSignal(property):Connect(function()
            local ok2, value = pcall(function() return instance[property] end)
            local entry = {
                instance = instance,
                property = property,
                value = ok2 and value or nil,
                clock = os.clock(),
                timestamp = os.time(),
            }
            if eventSet then watchEvent:Fire(entry) end
        end)
    end)

    if ok and conn then
        watchers[key] = { instance = instance, property = property, connection = conn }
        return true
    end
    return false
end

local function removeWatcher(instance, property)
    local key = tostring(instance) .. "." .. property
    local w = watchers[key]
    if w then
        pcall(function() w.connection:Disconnect() end)
        watchers[key] = nil
        return true
    end
    return false
end

local function getWatchers()
    local list = {}
    for _, w in pairs(watchers) do
        table.insert(list, w)
    end
    return list
end

PropertyWatcher.RequiredMethods = requiredMethods
PropertyWatcher.AddWatcher = addWatcher
PropertyWatcher.RemoveWatcher = removeWatcher
PropertyWatcher.GetWatchers = getWatchers
PropertyWatcher.ConnectEvent = connectEvent

return PropertyWatcher
