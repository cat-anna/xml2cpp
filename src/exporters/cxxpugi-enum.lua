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
	block:DocString(self.description)
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
				block:DocString(v.description)
				if v.value then
					block:Line { v.name, " = ", v.value, ",", }			
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
	
	block:BeginStructure(self:LocalName() .. "_TypeInfo")
	block:MakeAlias("Type", self:LocalName())
	block:BeginBlockLine { "static constexpr char *GetTypeName() {" } 
	block:BlockLine { "return \"", self:GetName(), "\";", }
	block:EndBlockLine { "}", }
	block:BeginBlockLine { "static bool GetValues(std::unordered_map<std::string, uint64_t> &values) {" } 
	if self.values then
		for i,v in ipairs(self.values) do 
			block:Line { "values[\"", v.name, "\"] = static_cast<uint64_t>(", self:LocalName(), "::", v.name, ");", }
		end
		block:Line { "return true;", }
	else
		block:Line { "return false;", }
	end
	block:EndBlockLine { "}", }
	block:EndStructure()
end

return EnumTypeMt
