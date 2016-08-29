local Assert = x2c.Assert
---------------------------------------

local EnumType, EnumTypeMt = x2c.MakeTypeClass()

function EnumType:GenResetToDefault(member, name, block)
	local def = self:GetDefault()
	if def == nil then
		block:Line {
			"// for ",
			member,
			" of type ",
			self:GlobalName(),
			" default value is not set",
		}
	else
		block:Line { member, " = ", self:GlobalName(), "::", def, ";", }
	end
end

function EnumType:GetDefault()
	return self.default
end

---------------------------------------

function EnumType:WriteImplementation(block)
	if self.imported then
		block:MakeAlias(self:LocalName(), self.location)
	else
		if self.type then
			block:BeginBlockLine { "enum class ", self:LocalName(), " : ", self.type:LocalName(), " {", }
		else
			block:BeginBlockLine { "enum class ", self:LocalName(), " {", }
		end
		
		local nconf = self.namespace.config

		if self.values then
			for i,v in ipairs(self.values) do 
				if v.value then
					block:Line { v.name, " = ", vvalue, ",", }			
				else
					block:Line { v.name, ",", }
				end
			end			
		end
		
		block:EndBlockLine { "};", }
	end
	
	local attr = IfThen(self.exportsettings.useattribute, "true", "false")
	
	block:Line { "inline bool ", self:LocalName(), "_Write(pugi::xml_node node, ", self:LocalName(), " value, const char* name) {", }
	block:BeginBlock()
	block:Line { "uint64_t temp = static_cast<uint64_t>(value);", }
	block:Line { "if(!::x2c::cxxpugi::Write<", attr, ">(temp, node, name)) return false;", }
	block:Line { "return true;" }
	block:EndBlock()
	block:Line { "};", }	
	
	block:Line { "inline bool ", self:LocalName(), "_Read(const pugi::xml_node node, ", self:LocalName(), " &value, const char* name) {", }
	block:BeginBlock()
	block:Line { "uint64_t temp = static_cast<uint64_t>(value);", }
	block:Line { "if(!::x2c::cxxpugi::Read<true, ", attr, ">(temp, node, name)) return false;", }
	block:Line { "value = static_cast<", self:LocalName(), ">(temp);", }
	block:Line { "return true;" }
	block:EndBlock()
	block:Line { "};", }
end

return EnumTypeMt
