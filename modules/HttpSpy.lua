local HttpSpy = {}

local HttpService = game:GetService("HttpService")

local requiredMethods = {
    hookMetaMethod = true,
    newCClosure = true,
    getNamecallMethod = true,
}

local logs = {}
local logEvent = Instance.new("BindableEvent")
local enabled = false
local eventSet = false

local function connectEvent(callback)
    logEvent.Event:Connect(callback)
    if not eventSet then eventSet = true end
end

local function logEntry(method, url, reqBody, responseCode, responseBody)
    if not enabled then return end
    local entry = {
        method = method or "GET",
        url = url or "?",
        reqBody = reqBody,
        responseCode = responseCode or 0,
        responseBody = responseBody,
        clock = os.clock(),
        timestamp = os.time(),
    }
    table.insert(logs, entry)
    if eventSet then logEvent:Fire(entry) end
end

local httpNmcHook
httpNmcHook = hookMetaMethod(HttpService, "__namecall", newCClosure(function(self, ...)
    local method = getNamecallMethod()

    if not enabled then
        return httpNmcHook(self, ...)
    end

    if method == "RequestAsync" then
        local reqDict = ... or {}
        local ok, result = pcall(httpNmcHook, self, ...)
        local code = ok and type(result) == "table" and result.StatusCode or (ok and 200 or 0)
        local body = ok and type(result) == "table" and result.Body or (ok and tostring(result) or tostring(result))
        logEntry(reqDict.Method or "GET", reqDict.Url, reqDict.Body, code, body)
        if ok then return result else error(result, 2) end

    elseif method == "GetAsync" then
        local url = select(1, ...)
        local ok, result = pcall(httpNmcHook, self, ...)
        logEntry("GET", url, nil, ok and 200 or 0, ok and tostring(result) or tostring(result))
        if ok then return result else error(result, 2) end

    elseif method == "PostAsync" then
        local url, body = select(1, ...), select(2, ...)
        local ok, result = pcall(httpNmcHook, self, ...)
        logEntry("POST", url, body, ok and 200 or 0, ok and tostring(result) or tostring(result))
        if ok then return result else error(result, 2) end
    end

    return httpNmcHook(self, ...)
end))

HttpSpy.RequiredMethods = requiredMethods
HttpSpy.Logs = logs
HttpSpy.ConnectEvent = connectEvent
HttpSpy.SetEnabled = function(state) enabled = state end
HttpSpy.Clear = function() logs = {} end

return HttpSpy
