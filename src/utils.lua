
local utils = { }
x2c.utils = utils

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function string:trim()
  return (self:gsub("^%s*(.-)%s*$", "%1"))
end

function table.shallow_clone(input)
	local t = { }
	for i,v in ipairs(input) do
		t[i] = v
	end
	for k,v in pairs(input) do
		t[k] = v
	end
	return t
end

local function xprint(line, sender, ...)
	local args
	
	if type(sender) == "table" then
		args = { sender, ": ", ... }
	else
		args = { sender, ... }
	end 
	
	for i,v in ipairs(args) do
		line[#line + 1] = tostring(v)
	end
	print(table.concat(line, ""))
end

function error(...)
	print ""
	local line = { 
		"ERROR: "
	}
	
	xprint(line, ...)
	print(debug.traceback())
	print ""
	os.exit(1)
end

function info(...)
	local line = { 
		"INFO: "
	}
	xprint(line, ...)
end

function IfThen(cond, TrueVal, FalseVal)
	if cond then
		return TrueVal
	else
		return FalseVal
	end
end

-----------------------

local Assert = { }
x2c.Assert = Assert

function Assert.String(t, sender, msg, ...)
	if type(t) ~= "string" then
		error(sender, msg or "Invalid string provided ", ...)
	end
end

function Assert.Table(t, sender, msg, ...)
	if type(t) ~= "table" then
		error(sender, msg or "Invalid string provided ", ...)
	end
end

function Assert.type(t, sender, msg, ...)
	if not t or not t.Type then
		error(sender, msg or "Invalid type provided ", ...)
	end
end

function Assert.type_nonnamespace(t, sender, msg, ...)
	if not t or not t.Type or t:Type() == "Namespace" then
		error(sender, msg or "Invalid type provided ", ...)
	end
end

-----------------------
-- part of lua-backup project
-- object-oriented support for lua

function inheritsFrom( base )
    local class = {}
    local mt = { __index = class }
    class.Base = base
    
    function class:Create(...)
       local inst = setmetatable( { } , mt )
       inst:Init(...)
       return inst
    end

    if base then
        setmetatable( class, { __index = base } )
    end

    return class
end

