
local Assert = x2c.Assert

-----------------------

local function Write_ResetToDefault(data, writter)
	writter:DefLine { 
		"inline void ", 
		data:LocalName(), 
		"_SetDefault(", 
		data:LocalName(), 
		" &value) {"
	}
	writter:BeginBlock()
	for k,v in pairs(data.fields) do 
		v:GenResetToDefault("value." .. data.fieldMembers[k], "\"" .. k .. "\"", writter)
	end	
	writter:EndBlock()	
	writter:DefLine "}"
end

local function Write_Write(data, writter)
	writter:DefLine { 
		"inline bool ", 
		data:LocalName(), 
		"_Write(pugi::xml_node in_node, const ", 
		data:LocalName(), 
		" &value, const char* name) {"
	}
	writter:BeginBlock()
	writter:DefLine "pugi::xml_node node;" 
	writter:DefLine "if(name == nullptr)" 
	writter:DefBlockLine "node = in_node;"
	writter:DefLine "else {" 
	writter:BeginBlock()	
	writter:DefLine "node = in_node.child(name);" 
	writter:DefLine "if(!node) node = in_node.append_child(name);" 
	writter:EndBlock()	
	writter:DefLine "}" 
	writter:DefLine "if(!node) return false;" 
	for k,v in pairs(data.fields) do 
		v:GenWrite("value." .. data.fieldMembers[k], "\"" .. k .. "\"", writter, data.exportsettings)
	end	
	writter:DefLine "return true;" 
	writter:EndBlock()	
	writter:DefLine "}" 
end

local function Write_Read(data, writter)
	writter:DefLine { 
		"inline bool ", 
		data:LocalName(), 
		"_Read(const pugi::xml_node in_node, ", 
		data:LocalName(), 
		" &value, const char* name) {"
	}	
	writter:BeginBlock()
	writter:DefLine "pugi::xml_node node = name == nullptr ? in_node : in_node.child(name);" 
	writter:DefLine "if(!node) return false;" 
	for k,v in pairs(data.fields) do 
		v:GenRead("value." .. data.fieldMembers[k], "\"" .. k .. "\"", writter, data.exportsettings)
	end	
	writter:DefLine "return true;" 
	writter:EndBlock()	
	writter:DefLine "}" 
end

local function WriteImpl(s, writter)

	if s.imported then
		writter:DefLine { 
			"using ", 
			s:LocalName(), 
			" = ", 
			s.location, 
			";" 
		}
	else
		writter:DefLine { 
			"struct ", 
			s:LocalName(), 
			";", 
		}
		writter:DefLine { 
			"inline bool ", 
			s:LocalName(), 
			"_Write(pugi::xml_node in_node, const ", 
			s:LocalName(), 
			" &value, const char* name);"
		}
		writter:DefLine { 
			"inline bool ", 
			s:LocalName(), 
			"_Read(const pugi::xml_node in_node, ", 
			s:LocalName(), 
			" &value, const char* name);"
		}	
		writter:DefLine { 
			"inline void ", 
			s:LocalName(), 
			"_SetDefault(", 
			s:LocalName(), 
			" &value);"
		}	

		writter:DefLine {
			"struct ",
			s:LocalName(),
			" {",
		}
		
		local nconf = s.namespace.config
		
		writter:BeginBlock()
		if s.fields then
			for k,v in pairs(s.fields) do 
				writter:DefLine {
					v:GlobalName(),
					" ",
					s.fieldMembers[k],
					";",
				}
			end	
		end
		
		writter:DefLine { }
		
		writter:DefLine "bool Read(const pugi::xml_node node, const char *name = nullptr) {" 
		writter:DefBlockLine { 
			"return ", 
			s:GlobalName(),
			"_Read(node, *this, name);",
		}
		writter:DefLine "}"
		writter:DefLine "bool Write(pugi::xml_node node, const char *name = nullptr) const {" 
		writter:DefBlockLine { 
			"return ", 
			s:GlobalName(),
			"_Write(node, *this, name);",
		}
		writter:DefLine "}"
		writter:DefLine "void ResetToDefault() {"
		writter:DefBlockLine { 
			"return ", 
			s:GlobalName(),
			"_SetDefault(*this);",
		}
		writter:DefLine "}"
		
		writter:DefLine "bool WriteFile(const std::string& filename) const {"
		writter:BeginBlock()
		writter:DefLine "pugi::xml_document doc;"
		writter:DefLine {"auto root = doc.append_child(\"", s:GetName(), "\");" }
		writter:DefLine "if(!Write(root)) return false;"
		writter:DefLine "return doc.save_file(filename.c_str());"
		writter:EndBlock()
		writter:DefLine "}"		
		writter:DefLine "bool ReadFile(const std::string& filename) {"
		writter:BeginBlock()
		writter:DefLine "pugi::xml_document doc;"
		writter:DefLine "doc.load_file(filename.c_str());"
		writter:DefLine {"return Read(doc.child(\"", s:GetName(), "\"));" }
		writter:EndBlock()
		writter:DefLine "}"				

		writter:EndBlock()
		writter:DefLine "};"
	end
	
	Write_Write(s, writter)
	Write_Read(s, writter)
	Write_ResetToDefault(s, writter)
		
	writter:DefLine { }	
end

-----------------------

local Struc, Struc_mt = x2c.MakeTypeClass()

function Struc_mt.__newindex()
	error("Attempt to modify structure type")
end

function Struc_mt.__call(self, arg)
	error("Cannot call structure type")
	return nil
end

local function make_structure(data)
	if data.fields then
		data.fieldMembers = { }
		for k,v in pairs(data.fields) do 
		
			Assert.type_nonnamespace(v, Structure, "Structure member cannot be of type " , v)
		
			local member = string.format("%s%s%s", 
				data.config.structure_field_prefix or "", 
				k,
				data.config.structure_field_postfix or ""
			)
			data.fieldMembers[k] = member
		end	
	end

	data.object_type = "Structure"
	
	setmetatable(data, Struc_mt)
	return data
end

-----------------------

function Struc:LocalName()
	return self.classname
end

function Struc:GlobalName()
	return self.namespace:GlobalName() .. "::" .. self.classname
end

function Struc:GetName()
	return self.name
end

function Struc:DisplayName()
	return self:GlobalName()
end

function Struc:GenResetToDefault(member, name, writter)
	writter:DefLine {
		self:GlobalName(),
		"_SetDefault(", member, ");",
	}
end

-----------------------
local StructureMeta = { }

function StructureMeta.new(data)
	if not data.name then
		error("Cannot define nameless structure")
		return false
	end
	
	if x2c.CurrentNamespace:Exists(data.name) then
		error(StructureMeta, "Attempt to redefine ", x2c.CurrentNamespace:Get(data.name))
	end		
	
	data.imported = false
	data.namespace = x2c.CurrentNamespace
	data.config = table.shallow_clone(data.namespace.config)
	
	data.exportsettings = data.pugi or { }
	data.require = data.require or "all"
	data.exportsettings.require = data.require ~= "none"
	
	data.classname = string.format("%s%s%s", 
		data.config.structure_prefix or "", 
		data.name,
		data.config.structure_postfix or ""
	)
	
	info("Defined structure ", data.classname, " in namespace ", data.namespace:DisplayName())
	
	local s = make_structure(data)
	x2c.CurrentNamespace:Add(s)
	WriteImpl(s, x2c.output)
end

function StructureMeta.import(data)
	if not data.name then
		error("Cannot define nameless structure")
		return false
	end
	if not data.location then
		error("Location must be specified while importing structure")
		return false
	end	
	
	if x2c.CurrentNamespace:Exists(data.name) then
		error(StructureMeta, "Attempt to redefine ", x2c.CurrentNamespace:Get(data.name))
	end		
	
	data.imported = true
	data.namespace = x2c.CurrentNamespace
	data.config = table.shallow_clone(data.namespace.config)
	
	data.exportsettings = data.pugi or { }
	data.require = data.require or "all"
	data.exportsettings.require = data.require ~= "none"
	
	data.classname = string.format("%s%s%s", 
		data.config.structure_prefix or "", 
		data.name,
		data.config.structure_postfix or ""
	)
	info("Imported structure ", data.classname, " in namespace ", data.namespace:DisplayName(), " from ", data.location)

	local s = make_structure(data)
	x2c.CurrentNamespace:Add(s)
	WriteImpl(s, x2c.output)
end

function StructureMeta.prefix(value)
	if type(value) ~= "string" then
		error("Invalid structure prefix value")
	end
	x2c.CurrentNamespace.config.structure_prefix = value
end

function StructureMeta.postfix(value)
	if type(value) ~= "string" then
		error("Invalid structure postfix value")
	end
	x2c.CurrentNamespace.config.structure_postfix = value
end

-----------------------
local StructureFieldMeta = { }

function StructureFieldMeta.prefix(value)
	if type(value) ~= "string" then
		error("Invalid structure field prefix value")
	end
	x2c.CurrentNamespace.config.structure_field_prefix = value
end

function StructureFieldMeta.postfix(value)
	if type(value) ~= "string" then
		error("Invalid structure field postfix value")
	end
	x2c.CurrentNamespace.config.structure_field_postfix = value
end

-----------------------
x2c.MakeMetaSubObject(StructureMeta, StructureFieldMeta, "field")
x2c.MakeMetaObject(StructureMeta, "Structure")
