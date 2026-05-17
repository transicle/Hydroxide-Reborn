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

	for _, thread in pairs(getreg()) do
		if typeof(thread) ~= "thread" then
			continue
		end

		local Source
		local ok, s = pcall(debug.info or debug.getinfo, thread, 1, "s")
		if ok then Source = s end

		if Source and (Source:match(".Core.Anti") or Source:match(".Plugins.Anti_Cheat")) then
			AdonisDetected = true
			table.insert(AdonisAnticheatThreads, thread)
		end
	end

	return AdonisDetected
end

function Adonis.Bypass()
	for _, thread in ipairs(AdonisAnticheatThreads) do
		pcall(coroutine.close, thread)
	end

	local AdonisTables = {}

	if filtergc then
		local ContendorAdonisTables = filtergc("table", {
			Keys = { "Detected", "RLocked" }
		}, false)

		for _, AdonisTable in ipairs(ContendorAdonisTables) do
			if typeof(rawget(AdonisTable, "Detected")) ~= "function" then continue end
			table.insert(AdonisTables, AdonisTable)
		end
	else
		for _, Table in pairs(getgc(true)) do
			if typeof(Table) ~= "table" then
				continue
			end

			local IsAdonisOrigin = typeof(rawget(Table, "Detected")) == "function" and rawget(Table, "RLocked")
			if not IsAdonisOrigin then continue end

			table.insert(AdonisTables, Table)
		end
	end

	for _, AdonisEntry in ipairs(AdonisTables) do
		for _, DetectionFunc in pairs(AdonisEntry) do
			if typeof(DetectionFunc) ~= "function" or isfunctionhooked(DetectionFunc) then
				continue
			end

			local original = hookfunction(DetectionFunc, newcclosure(function(action, info, nocrash)
				coroutine.yield()
				return task.wait(9e9)
			end))
			oh.Hooks[original] = DetectionFunc
		end
	end

	return true
end

return Adonis
