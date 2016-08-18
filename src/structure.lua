
local Assert = x2c.Assert

-----------------------

local function Write_ResetToDefault(data, writter, exportsettings, default)
	writter:DefLine { 
		"inline void ", 
		data:LocalName(), 
		"_SetDefault(", 
		data:LocalName(), 
		" &value) {"
	}
	writter:BeginBlock()
	for i,v in ipairs(data.fields) do 
		v.type:GenResetToDefault("value." .. v.decoratedname, "\"" .. v.name .. "\"", writter, v.exportsettings, v.default)
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
	for i,v in ipairs(data.fields) do 
		v.type:GenWrite("value." .. v.decoratedname, "\"" .. v.name .. "\"", writter, v.exportsettings)
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
	for i,v in ipairs(data.fields) do 
		v.type:GenRead("value." .. v.decoratedname, "\"" .. v.name .. "\"", writter, v.exportsettings)
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
			for i,v in ipairs(s.fields) do 
				writter:DefLine {
					v.type:GlobalName(),
					" ",
					v.decoratedname,
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

	data.exportsettings = data.pugi or { }
	
	if data.fields then
		for i,v in ipairs(data.fields) do 
			Assert.type_nonnamespace(v.type, Structure, "Structure member cannot be of type " , v.type)
		
			if not v.pugi then
				v.pugi = { }
			end
			
			v.exportsettings = v.pugi

			local member = string.format("%s%s%s", 
				data.config.structure_field_prefix or "", 
				v.name,
				data.config.structure_field_postfix or ""
			)
			v.decoratedname = member
			
			setmetatable(v.exportsettings, { 
				__index = function (self, value)
					local r = rawget(self, value)
					if r then
						return r
					end
					return data.exportsettings[value]
				end,
				__newindex = function() 
					error(Structure, "Attempt to modify structure member ", v.name)
				end
			} )
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

function Struc:GenResetToDefault(member, name, writter, exportsettings, default)
	--if not default then
	--	writter:DefLine {
	--		self:GlobalName(),
	--		"_SetDefault(", member, ");",
	--	}
	--else
	default = default or { }
		for i,v in ipairs(self.fields) do 
			v.type:GenResetToDefault(member .. "." .. v.decoratedname, "\"" .. v.name .. "\"", writter, v.exportsettings, default[v.name])
		end	
	--end
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
		
	data.classname = string.format("%s%s%s", 
		data.config.structure_prefix or "", 
		data.name,
		data.config.structure_postfix or ""
	)
	data.decoratedname = data.classname
	
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
