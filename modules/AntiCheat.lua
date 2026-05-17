local AntiCheat = {}

local AnticheatData = {
	Disabled = false,
	Name = "N/A",
}

local bypassNames = { "Adonis" }
local GeneralPurposeBypasses = {}
local DedicatedPlaceACBypass = nil

for _, name in ipairs(bypassNames) do
	local ok, Data = pcall(import, "modules/anticheats/" .. name)
	if not ok or not Data then continue end

	local IsDedicatedACBypass
	if typeof(Data.Game) == "table" then
		IsDedicatedACBypass = table.find(Data.Game, game.PlaceId)
			or table.find(Data.Game, tostring(game.PlaceId))
	else
		IsDedicatedACBypass = tostring(Data.Game) == tostring(game.PlaceId)
	end

	if IsDedicatedACBypass and not DedicatedPlaceACBypass then
		DedicatedPlaceACBypass = Data
	elseif Data.Game == "*" then
		table.insert(GeneralPurposeBypasses, Data)
	end
end

if DedicatedPlaceACBypass then
	local detected = false
	pcall(function() detected = DedicatedPlaceACBypass.Detect() end)
	if detected then
		local ok = pcall(DedicatedPlaceACBypass.Bypass)
		if ok then
			AnticheatData.Name = DedicatedPlaceACBypass.Name
			AnticheatData.Disabled = true
		end
	end
end

if not AnticheatData.Disabled then
	for _, Data in ipairs(GeneralPurposeBypasses) do
		local detected = false
		pcall(function() detected = Data.Detect() end)
		if not detected then continue end

		local bypassed = false
		pcall(function() bypassed = Data.Bypass() end)
		if bypassed then
			AnticheatData.Name = Data.Name
			AnticheatData.Disabled = true
			break
		end
	end
end

AntiCheat.Data = AnticheatData
AntiCheat.Bypasses = GeneralPurposeBypasses
AntiCheat.DedicatedBypass = DedicatedPlaceACBypass

return AntiCheat
