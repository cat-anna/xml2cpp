local Assert = x2c.Assert
---------------------------------------

local StrucType, StrucTypeMt = x2c.MakeTypeClass()

function StrucType:LocalName()
	return self.classname
end

function StrucType:GlobalName()
	return self.namespace:GlobalName() .. "::" .. self.classname
end

---------------------------------------

function StrucType:WriteDefault(block, exportsettings, default)
	block:Line { "inline void ", self:LocalName(), "_SetDefault(", self:LocalName(), " &value) {" }
	block:BeginBlock()
	for i,v in ipairs(self.fields) do 
		v.type:GenResetToDefault("value." .. v.decoratedname, "\"" .. v.name .. "\"", block, v.exportsettings, v.default)
	end	
	block:EndBlock()	
	block:Line "}"
end

function StrucType:WriteWrite(block)
	block:Line { 
		"inline bool ", 
		self:LocalName(), 
		"_Write(pugi::xml_node in_node, const ", 
		self:LocalName(), 
		" &value, const char* name) {"
	}
	block:BeginBlock()
	block:Line "pugi::xml_node node;" 
	block:Line "if(name == nullptr)" 
	block:BlockLine "node = in_node;"
	block:Line "else {" 
	block:BeginBlock()	
	block:Line "node = in_node.child(name);" 
	block:Line "if(!node) node = in_node.append_child(name);" 
	block:EndBlock()	
	block:Line "}" 
	block:Line "if(!node) return false;" 
	for i,v in ipairs(self.fields) do 
		v.type:GenWrite("value." .. v.decoratedname, "\"" .. v.name .. "\"", block, v.exportsettings)
	end	
	block:Line "return true;" 
	block:EndBlock()	
	block:Line "}" 
end

function StrucType:WriteRead(block)
	block:Line { "inline bool ", self:LocalName(), "_Read(const pugi::xml_node in_node, ", self:LocalName(), " &value, const char* name) {", }	
	block:BeginBlock()
	block:Line "pugi::xml_node node = name == nullptr ? in_node : in_node.child(name);" 
	block:Line "if(!node) return false;" 
	for i,v in ipairs(self.fields) do 
		v.type:GenRead("value." .. v.decoratedname, "\"" .. v.name .. "\"", block, v.exportsettings, v.default)
	end	
	block:Line "return true;" 
	block:EndBlock()	
	block:Line "}" 
end

function StrucType:WriteClass(block)
	block:DocString(self.description)
	block:DefineStructure(self:LocalName())
	block:Line { "inline bool ", self:LocalName(), "_Write(pugi::xml_node in_node, const ", self:LocalName(), " &value, const char* name);", }
	block:Line { "inline bool ", self:LocalName(), "_Read(const pugi::xml_node in_node, ", self:LocalName(), " &value, const char* name);", }	
	block:Line { "inline void ", self:LocalName(), "_SetDefault(", self:LocalName(), " &value);", }	
	
	block:BeginStructure(self:LocalName())
	
	local nconf = self.namespace.config
	
	if self.fields then
		for i,v in ipairs(self.fields) do 
			block:DocString(v.description)
			block:Line { v.type:GlobalName(), " ", v.decoratedname, ";", }
		end	
	end
	
	block:Line { }
	
	block:Line "bool Read(const pugi::xml_node node, const char *name = nullptr) {" 
	block:BlockLine { 
		"return ", 
		self:GlobalName(),
		"_Read(node, *this, name);",
	}
	block:Line "}"
	block:Line "bool Write(pugi::xml_node node, const char *name = nullptr) const {" 
	block:BlockLine { "return ", self:GlobalName(), "_Write(node, *this, name);", }
	block:Line "}"
	block:Line "void ResetToDefault() {"
	block:BlockLine { "return ", self:GlobalName(), "_SetDefault(*this);", }
	block:Line "}"
	
	block:Line "bool WriteFile(const std::string& filename) const {"
	block:BeginBlock()
	block:Line "pugi::xml_document doc;"
	block:Line {"auto root = doc.append_child(\"", self:GetName(), "\");" }
	block:Line "if(!Write(root)) return false;"
	block:Line "return doc.save_file(filename.c_str());"
	block:EndBlock()
	block:Line "}"		
	block:Line "bool ReadFile(const std::string& filename) {"
	block:BeginBlock()
	block:Line "pugi::xml_document doc;"
	block:Line "doc.load_file(filename.c_str());"
	block:Line {"return Read(doc.child(\"", self:GetName(), "\"));" }
	block:EndBlock()
	block:Line "}"		
	
	block:EndStructure()
end

function StrucType:WriteImplementation(block)
	if self.imported then
		block:DocString(self.description)
		block:MakeAlias(self:LocalName(), self.location)
	else
		self:WriteClass(block)
	end
	
	self:WriteRead(block)
	self:WriteWrite(block)
	self:WriteDefault(block)
end

---------------------------------------

function StrucType:GenResetToDefault(member, name, writter, exportsettings, default)
	default = default or { }
	for i,v in ipairs(self.fields) do 
		v.type:GenResetToDefault(member .. "." .. v.decoratedname, "\"" .. v.name .. "\"", writter, v.exportsettings, default[v.name])
	end	
end

return StrucTypeMt
