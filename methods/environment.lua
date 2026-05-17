local methods = {}

local function secureCall(closure, ...)
    return closure(...)
end

methods.secureCall = secureCall
return methods
