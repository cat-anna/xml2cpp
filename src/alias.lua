
local Assert = x2c.Assert

-----------------------

local Alias_t, Alias_t_mt = x2c.MakeTypeClass()

function Alias_t:GenResetToDefault(member, name, writter, ...)
	self.source_type:GenResetToDefault(member, name, writter, ...)
end

function Alias_t:GenWrite(member, name, writter)
	self.source_type:GenWrite(member, name, writter)
end

function Alias_t:GenRead(member, name, writter)
	self.source_type:GenRead(member, name, writter)
end


local function make_alias(data)
	setmetatable(data, Alias_t_mt)
	return data
end

local function WriteAliasImpl(data, writter)
	writter:DefLine { 
		"using ", 
		data:LocalName(), 
		" = ", 
		data.source_type:GlobalName(), 
		";" 
	}
	writter:DefLine ""
end

local function AliasNamespace(self, Type, NewName)
	error(self, "Namespace aliasing is not supported")
end

local function AliasType(self, Type, NewName)
	data = { }

	data.source_type = Type
	data.name = NewName
	data.local_name = NewName
	data.object_type = Type:Type()
	data.namespace = x2c.CurrentNamespace
	data.config = table.shallow_clone(data.namespace.config);

	data = make_alias(data)
	x2c.CurrentNamespace:Add(data)
	info("Aliased ", data, " to ", data.source_type)
	WriteAliasImpl(data, x2c.output)
	return data
end

local AliasMeta = { }

function AliasMeta.__call(self, Type, NewName)
	Assert.type(Type, self, " Invalid type for aliasing: ", Type)
	
	if Type:Type() == "Namespace" then
		return AliasNamespace(self, Type, NewName)
	else
		return AliasType(self, Type, NewName)
	end	
end

x2c.MakeMetaObject(AliasMeta, "Alias")

-----------------------

local UseMeta = { }

local function UseNamespace(self, Type)
	error(self, "Namespace using is not supported")
end

local function UseType(self, Type)
	return Alias(Type, Type:GetName())
end

function UseMeta.namespace( Type)
	error(UseMeta, "Namespace using is not supported")
end

function UseMeta.type(Type)
	error(UseMeta, "Type using is not supported")
end

function UseMeta.__call(self, Type)
	Assert.type(Type, self, " Invalid type for aliasing: ", Type)

	if Type:Type() == "Namespace" then
		return UseNamespace(self, Type)
	else
		return UseType(self, Type)
	end	
end

x2c.MakeMetaObject(UseMeta, "Use")
