
-----------------------

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
		if s.type then
			if s.type:Type() == "Type" and s.type.integral then
				writter:DefLine {
					"enum class ",
					s:LocalName(),
					" : ",
					s.type:LocalName(),
					" {",
				}
			else
				error("Enums accept only internal integral types as type")
				return
			end
		else
			writter:DefLine {
				"enum class ",
				s:LocalName(),
				" {",
			}
		end
		
		local nconf = s.namespace.config

		writter:BeginBlock()
		if s.values then
			for i,v in ipairs(s.values) do 
				local value = s.value_values[v]
				if value then
					writter:DefLine {
						s.value_members[v],
						" = ",
						value,
						",",
					}			
				else
					writter:DefLine {
						s.value_members[v],
						",",
					}
				end
			end			
		end
		
		writter:EndBlock()
		writter:DefLine { "};", }
	end
	
	writter:DefLine { 
		"inline bool ", 
		s:LocalName(), 
		"_Write(pugi::xml_node node, ", 
		s:LocalName(), 
		" value, const char* name) {"
	}
	writter:BeginBlock()
	writter:DefLine { "auto item = node.child(name);" }
	writter:DefLine { "if(!item) item = node.append_child(name);" }
	writter:DefLine { "item.text() = static_cast<unsigned long long>(value);" }
	writter:DefLine { "return true;" }
	writter:EndBlock()
	writter:DefLine { "};", }	
	
	writter:DefLine { 
		"inline bool ", 
		s:LocalName(), 
		"_Read(const pugi::xml_node node, ", 
		s:LocalName(), 
		" &value, const char* name) {"
	}
	writter:BeginBlock()
	writter:DefLine { "auto item = node.child(name);" }
	writter:DefLine { "if(!item) return false;" }
	writter:DefLine { "value = static_cast<", s:LocalName(), ">(item.text().as_ullong());" }
	writter:DefLine { "return true;" }
	writter:EndBlock()
	writter:DefLine { "};", }	
	
	writter:DefLine { }	
end

-----------------------

local Enum_t, Enum_t_mt = x2c.MakeTypeClass()

function Enum_t_mt.__call(self, arg)
	error("Cannot call enum type")
	return nil
end

local function make_enum(data)

	if data.values then
		data.value_members = { }
		data.value_values = { }
		data.raw_values = data.values
		data.values = { }
		for i,v in ipairs(data.raw_values) do 
		
			local name, value = (unpack or table.unpack)(v:split("="))
			name = name:trim()
			if value then
				value = value:trim()
			end
		
			local member = string.format("%s%s%s", 
				data.config.enum_value_prefix or "", 
				name,
				data.config.enum_value_postfix or ""
			)
			data.value_members[name] = member
			data.values[i] = name
			data.value_values[name] = value
		end	
	end

	setmetatable(data, Enum_t_mt)
	return data
end

-----------------------

function Enum_t:GetDefault()
	return self.default
end

function Enum_t:GetDefaultValue()
	return self.default_value
end

function Enum_t:GenResetToDefault(member, name, writter)
	local def = self:GetDefaultValue()
	if def == nil then
		writter:DefLine {
			"// for ",
			member,
			" of type ",
			self:GlobalName(),
			" default value is not set",
		}
	else
		writter:DefLine {
			member,
			" = ",
			self:GlobalName(),
			"::",
			def,
			";",
		}
	end
end

-----------------------

local EnumMeta = { }

function EnumMeta.new(data)
	if not data.name then
		error("Cannot define nameless enum")
		return false
	end
	
	if x2c.CurrentNamespace:Exists(data.name) then
		return x2c.CurrentNamespace:Get(data.name) 
	end		
	
	data.imported = false
	data.namespace = x2c.CurrentNamespace
	data.config = table.shallow_clone(data.namespace.config);
	data.object_type = "Enum"
	
	data.local_name = string.format("%s%s%s", 
		data.config.enum_prefix or "", 
		data.name,
		data.config.enum_postfix or ""
	)
	
	if data.default then
		data.default_value = string.format("%s%s%s", 
			data.config.enum_value_prefix or "", 
			data.default,
			data.config.enum_value_postfix or ""
		)
	end
	
	local e = make_enum(data)	
	info("Defined enum ", e:LocalName(), " in namespace ", e.namespace:DisplayName())
	
	x2c.CurrentNamespace:Add(e)
	WriteImpl(e, x2c.output)
end

function EnumMeta.import(data)
	if not data.name then
		error("Cannot define nameless enum")
		return false
	end
	
	if not data.location then
		error("Location must be specified while importing enum")
		return false
	end	
	
		
	if x2c.CurrentNamespace:Exists(data.name) then
		return x2c.CurrentNamespace:Get(data.name) 
	end		
	
	data.imported = true
	data.namespace = x2c.CurrentNamespace
	data.config = table.shallow_clone(data.namespace.config);
	
	data.enum_name = string.format("%s%s%s", 
		data.config.enum_prefix or "", 
		data.name,
		data.config.enum_postfix or ""
	)
	
	data.default_value = data.default
	
	info("Imported enum ", data.enum_name, " in namespace ", data.namespace:DisplayName(), " from ", data.location)

	local e = make_enum(data)
	x2c.CurrentNamespace:Add(e)
	WriteImpl(e, x2c.output)
end

function EnumMeta.prefix(value)
	if type(value) ~= "string" then
		error("Invalid enum prefix value")
	end
	x2c.CurrentNamespace.config.enum_prefix = value
end

function EnumMeta.postfix(value)
	if type(value) ~= "string" then
		error("Invalid enum postfix value")
	end
	x2c.CurrentNamespace.config.enum_postfix = value
end

-----------------------
local EnumMetaValue = { }

function EnumMetaValue.prefix(value)
	if type(value) ~= "string" then
		error("Invalid enum value prefix value")
	end
	x2c.CurrentNamespace.config.enum_value_prefix = value
end

function EnumMetaValue.postfix(value)
	if type(value) ~= "string" then
		error("Invalid enum value postfix value")
	end
	x2c.CurrentNamespace.config.enum_value_postfix = value
end

-----------------------
x2c.MakeMetaSubObject(EnumMeta, EnumMetaValue, "value")
x2c.MakeMetaObject(EnumMeta, "Enum")
