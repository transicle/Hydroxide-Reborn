## Script

```lua
local owner = "transicle"
local branch = "main"

local function webImport(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide-Reborn/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
end

webImport("init")
webImport("ui/main")
```

# [REBORN] Hydroxide
Lua runtime introspection and network capturing tool for games on the Roblox engine. An optimized and updated version of the original project packed with new features.

## Features

* Upvalue Scanner
    * View/Modify Upvalues
    * View first-level values in table upvalues
    * View information of closure
* Constant Scanner
    * View/Modify Constants
    * View information of closure
* Script Scanner
    * View general information of scripts (source, protos, constants, etc.)
    * Retrieve all protos found in GC
* Module Scanner
    * View general information of modules (return value, source, protos, constants, etc.)
    * Retrieve all protos found in GC
* RemoteSpy
    * Log calls of remote objects (RemoteEvent, RemoteFunction, BindableEvent, BindableFunction)
    * Ignore/Block calls based on parameters passed
    * Traceback calling function/closure
* ClosureSpy
    * Log calls of closures
    * View general information of closures (location, protos, constants, etc.)
* HTTP Request Spy
    * Hook `HttpService:RequestAsync` / `HttpService:GetAsync` to log outbound HTTP calls alongside remotes
* Timestamps on Calls
    * Every logged call is stamped with `os.clock()` / `os.time()` so you can track call frequency and timing
* Remote/Closure Name Filtering
    * Live search box to filter the spy list by instance path or function name
* Export to File
    * Dump all captured remote logs as a Lua table to a `.lua` file via `writeFile`
* Argument Diff View
    * When the same remote fires repeatedly, highlights which arguments changed between calls
* Instance Property Watcher
    * Watch `Instance:GetPropertyChangedSignal` on arbitrary properties beyond just remotes
* Explorer
    * Full instance tree browser — replaces the empty stub and completes the original Hydroxide feature set
* WebSocket Spy
    * Hook `WebSocket.connect` (on supported executors) to log WebSocket connections and messages
* AntiCheat Bypass
    * Automatically detects and bypasses popular Roblox anticheats
    * **Adonis** — kills anticheat threads and hooks all detection functions to yield indefinitely
    * Bypass can be toggled via `SaveManager` state (`AnticheatBypass`)
    * Modular design: place-specific bypasses take priority over general-purpose ones

    <details>
    <summary>Adonis bypass implementation</summary>

    ```lua
    local Adonis = {
        Name = "Adonis",
        Game = "*",
    }

    local AdonisAnticheatThreads = {}
    function Adonis.Detect()
        if not getreg or not getgc or not isfunctionhooked then
            return false
        end

        local AdonisDetected = false

        for _, thread in getreg() do
            if typeof(thread) ~= "thread" then
                continue
            end

            local Source = debug.info(thread, 1, "s")
            if Source and (Source:match(".Core.Anti") or Source:match(".Plugins.Anti_Cheat")) then
                AdonisDetected = true
                table.insert(AdonisAnticheatThreads, thread)
            end
        end

        return AdonisDetected
    end

    function Adonis.Bypass()
        for _, thread in AdonisAnticheatThreads do
            pcall(coroutine.close, thread)
        end

        local AdonisTables = {}
        if filtergc then
            local ContendorAdonisTables = filtergc("table", {
                Keys = { "Detected", "RLocked" }
            }, false)

            for _, AdonisTable in ContendorAdonisTables do
                if typeof(rawget(AdonisTable, "Detected")) ~= "function" then continue end
                table.insert(AdonisTables, AdonisTable)
            end
        else
            for _, Table in getgc(true) do
                if typeof(Table) ~= "table" then
                    continue
                end

                local IsAdonisOrigin = typeof(rawget(Table, "Detected")) == "function" and rawget(Table, "RLocked")
                if not IsAdonisOrigin then continue end

                table.insert(AdonisTables, Table)
            end
        end

        for _, Adonis in AdonisTables do
            for _, DetectionFunc in Adonis do
                if typeof(DetectionFunc) ~= "function" or isfunctionhooked(DetectionFunc) then
                    continue
                end

                wax.shared.Hooks[DetectionFunc] = wax.shared.Hooking.HookFunction(
                    DetectionFunc,
                    function(action, info, nocrash)
                        coroutine.yield()
                        return task.wait(9e9)
                    end
                )
            end
        end

        return true
    end

    return Adonis
    ```

    </details>

    <details>
    <summary>Anticheat manager (main file)</summary>

    ```lua
    --[[
        Bypasses for popular roblox anticheats
    ]]

    local AnticheatData = {
        Disabled = false,
        Name = "N/A",
    }

    local BypassEnabled = wax.shared.SaveManager:GetState("AnticheatBypass", false)
    if not BypassEnabled then
        return AnticheatData
    end

    type Bypass = {
        Name: string,
        Game: string | number | { number } | { string },
        Detect: () -> boolean,
        Bypass: () -> boolean,
    }

    local GeneralPurposeBypasses: { Bypass } = {}
    local DedicatedPlaceACBypass: Bypass = nil

    local AnticheatBypasses = script.Parent.impl
    for _, Anticheat in AnticheatBypasses:GetChildren() do
        local Data = require(Anticheat) :: Bypass

        local IsDedicatedACBypass = (
            if typeof(Data.Game) == "table"
                then (table.find(Data.Game, game.PlaceId) or table.find(Data.Game, tostring(game.PlaceId)))
                else (tostring(Data.Game) == tostring(game.PlaceId))
        )

        if IsDedicatedACBypass then
            DedicatedPlaceACBypass = Data
            break
        end

        if Data.Game ~= "*" then
            continue
        end

        table.insert(GeneralPurposeBypasses, Data)
    end

    if DedicatedPlaceACBypass and DedicatedPlaceACBypass.Detect() then
        DedicatedPlaceACBypass.Bypass()

        AnticheatData.Name = DedicatedPlaceACBypass.Name
        AnticheatData.Disabled = true
        return AnticheatData
    end

    for _, Data in GeneralPurposeBypasses do
        if not Data.Detect() then
            continue
        end

        if Data.Bypass() then
            AnticheatData.Name = Data.Name
            AnticheatData.Disabled = true
            break
        end
    end

    return AnticheatData
    ```

    </details>