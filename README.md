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
