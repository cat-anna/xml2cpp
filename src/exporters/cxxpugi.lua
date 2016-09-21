local CXXPugi = inheritsFrom(x2c.Classes.Exporter)
x2c.Exporters.cxxpugi = CXXPugi

------------------------------------------------------------------------

local StrucTypeMt = require "exporters/cxxpugi-structure"

function CXXPugi:MakeStructure(data)
	return setmetatable(data, StrucTypeMt)
end

------------------------------------------------------------------------

local CXXPugiTypes = require "exporters/cxxpugi-types"

------------------------------------------------------------------------

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

function Alias_t:WriteImplementation(block)
	block:Line { "using ", self:LocalName(), " = ", self.source_type:GlobalName(), ";", }
end

function Alias_t:GetBaseType()
	if not self.source_type or not self.source_type.GetBaseType then
		return self
	end
	return self.source_type:GetBaseType()
end

function CXXPugi:MakeAlias(data)
	setmetatable(data, Alias_t_mt)
	return data
end

------------------------------------------------------------------------

local EnumTypeMt = require "exporters/cxxpugi-enum"

function CXXPugi:MakeEnum(data)
	return setmetatable(data, EnumTypeMt)
end

------------------------------------------------------------------------

local ContainerTypeMt = require "exporters/cxxpugi-containers"

function CXXPugi:MakeContainer(data)
	return setmetatable(data, ContainerTypeMt)
end

------------------------------------------------------------------------

function CXXPugi:Init(Config)
    self.Base.Init(self, Config)
    self.ImplList = CXXPugiTypes
	
	for k,v in pairs(CXXPugiTypes) do
		x2c.GlobalNamespace:Add(v)
	end
end

function CXXPugi:Write()
	self.Writter = x2c.Classes.CXXWritter:Create(self.Config.FileName)
		
	self.Writter:WriteFileHeader()
	self.Writter:WriteX2CImpl(self.ImplList)
	
	local block = self.Writter:AddFileBlock()
	
	local namespace = nil
	
	for i,v in ipairs(self.Types) do
		--print(v.value:GetName())
		local t = v.value
		local tnamespace = t.namespace
		
		if tnamespace ~= namespace then
			if namespace then
				namespace:WriteLeave(block)
			end
			
			namespace = tnamespace
			namespace:WriteEnter(block)
		end
		
		if i > 1 then
			block:Line { }
		end
		
		t:WriteImplementation(block)
	end
	
	if namespace then
		namespace:WriteLeave(block)
	end
	
    self.Writter:Close()
end

function CXXPugi:InitTypeExporterInfo(data)
    data.exportsettings = data.pugi or { }
end

function CXXPugi:InitTypeExporterMemberInfo(data)
    if not data.pugi then
        data.pugi = { }
    end
    
    data.exportsettings = data.pugi
end
