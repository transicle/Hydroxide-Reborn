local WebSocketSpy = {}

local requiredMethods = {}

local logs = {}
local logEvent = Instance.new("BindableEvent")
local enabled = false
local eventSet = false
local hooked = false

local function connectEvent(callback)
    logEvent.Event:Connect(callback)
    if not eventSet then eventSet = true end
end

local function logEntry(entry)
    table.insert(logs, entry)
    if eventSet then logEvent:Fire(entry) end
end

local function tryHook()
    if hooked then return end
    if not (WebSocket and WebSocket.connect) then return end
    hooked = true

    local originalConnect = WebSocket.connect
    WebSocket.connect = newCClosure(function(url)
        local ws = originalConnect(url)

        if enabled then
            logEntry({
                kind = "connect",
                url = url or "?",
                clock = os.clock(),
                timestamp = os.time(),
            })
        end

        if ws then
            if ws.OnMessage then
                ws.OnMessage:Connect(function(msg)
                    if not enabled then return end
                    logEntry({
                        kind = "recv",
                        url = url,
                        data = msg,
                        clock = os.clock(),
                        timestamp = os.time(),
                    })
                end)
            end

            if ws.OnClose then
                ws.OnClose:Connect(function()
                    if not enabled then return end
                    logEntry({
                        kind = "close",
                        url = url,
                        clock = os.clock(),
                        timestamp = os.time(),
                    })
                end)
            end

            if ws.Send then
                local originalSend = ws.Send
                ws.Send = newCClosure(function(self, data)
                    if enabled then
                        logEntry({
                            kind = "send",
                            url = url,
                            data = data,
                            clock = os.clock(),
                            timestamp = os.time(),
                        })
                    end
                    return originalSend(self, data)
                end)
            end
        end

        return ws
    end)
end

tryHook()

WebSocketSpy.RequiredMethods = requiredMethods
WebSocketSpy.Logs = logs
WebSocketSpy.ConnectEvent = connectEvent
WebSocketSpy.SetEnabled = function(state)
    enabled = state
    tryHook()
end
WebSocketSpy.Clear = function() logs = {} end

return WebSocketSpy
