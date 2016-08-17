

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

function IType:GenWrite(member, name, writter, exportsettings)
	exportsettings = exportsettings or { }
	
	local methodname
	local accessname
	if exportsettings.useattribute then
		methodname = "attribute"
		accessname = "item"
	else
		methodname = "child"
		accessname = "item.text()"
	end
	
	writter:DefLine { "{" }
	writter:BeginBlock()
	writter:DefLine { "auto item = node.", methodname, "(", name, ");", }
	writter:DefLine { "if(!item) item = node.append_", methodname, "(", name, ");", }
	writter:DefLine { accessname, " = ", string.format(self.write_format or "%s", member), ";", }
	writter:EndBlock()	
	writter:DefLine { "}" }
end

function IType:GenRead(member, name, writter, exportsettings)
	exportsettings = exportsettings or { }

	local methodname
	local accessname
	if exportsettings.useattribute then
		methodname = "attribute"
		accessname = "item"
	else
		methodname = "child"
		accessname = "item.text()"
	end
	
	local req = exportsettings.require
	
	local readline = { member, " = ", accessname, ".", self.pugi_read, "(", member, ");", }		
	
	writter:DefLine { "{" }
	writter:BeginBlock()	
	writter:DefLine { "auto item = node.", methodname, "(", name, ");", }
	
	if req then
		writter:DefLine { "if(!item) return false;", }
		writter:DefLine(readline)
	else
		writter:DefLine { "if(item)", }
		writter:DefBlockLine(readline)
	end
	writter:EndBlock()	
	writter:DefLine { "}" }
end

-----------------------

local TypesMeta = { }

TypesMeta.s8  = make_type { name =   "int8_t", default = "0", pugi_read="as_int",   integral = true, write_format="static_cast<int>(%s)" }
TypesMeta.u8  = make_type { name =  "uint8_t", default = "0", pugi_read="as_uint",  integral = true, write_format="static_cast<unsigned>(%s)" }
TypesMeta.s16 = make_type { name =  "int16_t", default = "0", pugi_read="as_int",   integral = true, write_format="static_cast<int>(%s)" }
TypesMeta.u16 = make_type { name = "uint16_t", default = "0", pugi_read="as_uint",  integral = true, write_format="static_cast<unsigned>(%s)" }
TypesMeta.s32 = make_type { name =  "int32_t", default = "0", pugi_read="as_int",   integral = true }
TypesMeta.u32 = make_type { name = "uint32_t", default = "0", pugi_read="as_uint",  integral = true }
TypesMeta.s64 = make_type { name =  "int64_t", default = "0", pugi_read="as_long",  integral = true }
TypesMeta.u64 = make_type { name = "uint64_t", default = "0", pugi_read="as_ulong", integral = true }

TypesMeta.float = make_type { name = "float", default = "0.0f", pugi_read="as_float" }
TypesMeta.double = make_type { name = "double", default = "0.0", pugi_read="as_double" }
TypesMeta.bool = make_type { name = "bool", default = "false", pugi_read="as_bool" }
TypesMeta.string = make_type { name = "std::string", local_name="string", default = "", pugi_read="as_string", format="\"%s\"", write_format="%s.c_str()" }

--types.bytes/hex

x2c.MakeMetaObject(TypesMeta, "Types")
