

types = { }
local types_mt = { }

function types_mt.__newindex()
	error("Attempt to modify types metaobject!")
end

function types_mt.__index(self, key)
	local f = rawget(types, key)
	if not f then
		error("Types: there is no such internal type - ", key)
		return
	end
	
	return f
end

-----------------------

local IType = { }
local IType_mt = { __index = IType }

local function make_type(t)
	setmetatable(t, IType_mt)
	return t
end

function IType_mt.__newindex()
	error("Attempt to modify internal type")
end

function IType_mt.__call(self, arg)
	local t = { }
	
	for k,v in pairs(self) do
		t[k] = v
	end

	t.default = self.default
	t.name = self.name
		
	for k,v in pairs(arg) do
		
		t[k] = v
	end
	
	t.name = self.name
	return make_type(t)
end

-----------------------

function IType:LocalName()
	return self.local_name or self.name
end

function IType:GlobalName()
	return self.name
end

IType.GetName = IType.GlobalName

function IType:GetDefault()
	return self.default
end

function IType:GetDefaultValue()
	if self.format then
		return string.format(self.format, self.default)
	end
	return self.default
end

function IType:GenResetToDefault(member, name, writter)
	writter:DefLine {
		member,
		" = ",
		self:GetDefaultValue(),
		";",
	}
end

function IType:Type()
	return "Type"
end

function IType:GenWrite(member, name, writter)
	writter:DefLine { "{" }
	writter:BeginBlock()
	writter:DefLine { "auto item = node.child(", name, ");", }
	writter:DefLine { "if(!item) item = node.append_child(", name, ");", }
	writter:DefLine { "item.text() = ", string.format(self.write_format or "%s", member), ";", }	
	writter:EndBlock()	
	writter:DefLine { "}" }
end

function IType:GenRead(member, name, writter)
	writter:DefLine { "{" }
	writter:BeginBlock()
	writter:DefLine { "auto item = node.child(", name, ");", }
	writter:DefLine { "if(!item) return false;", }
	writter:DefLine { member, " = item.text().", self.pugi_read, "(", ");", }	
	writter:EndBlock()	
	writter:DefLine { "}" }
end

-----------------------

types.s8  = make_type { name =   "int8_t", default = "0", pugi_read="as_int",   integral = true, write_format="static_cast<int>(%s)" }
types.u8  = make_type { name =  "uint8_t", default = "0", pugi_read="as_uint",  integral = true, write_format="static_cast<unsigned>(%s)" }
types.s16 = make_type { name =  "int16_t", default = "0", pugi_read="as_int",   integral = true, write_format="static_cast<int>(%s)" }
types.u16 = make_type { name = "uint16_t", default = "0", pugi_read="as_uint",  integral = true, write_format="static_cast<unsigned>(%s)" }
types.s32 = make_type { name =  "int32_t", default = "0", pugi_read="as_int",   integral = true }
types.u32 = make_type { name = "uint32_t", default = "0", pugi_read="as_uint",  integral = true }
types.s64 = make_type { name =  "int64_t", default = "0", pugi_read="as_long",  integral = true }
types.u64 = make_type { name = "uint64_t", default = "0", pugi_read="as_ulong", integral = true }

types.float = make_type { name = "float", default = "0.0f", pugi_read="as_float" }
types.double = make_type { name = "double", default = "0.0", pugi_read="as_double" }
types.bool = make_type { name = "bool", default = "false", pugi_read="as_bool" }
types.string = make_type { name = "std::string", local_name="string", default = "", pugi_read="as_string", format="\"%s\"", write_format="%s.c_str()" }

--types.bytes/hex

setmetatable(types, types_mt )
