
local Assert = x2c.Assert

-------------------------------

local function Write_Table(T, writter)
	local element = T.element_type
	
	writter:DefLine {
		"using ", T:LocalName(), " = std::vector<", element:GlobalName(), ">;"
	}
	
	writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_Write(pugi::xml_node in_node, const ", 
		T:LocalName(), 
		" &value, const char* name) {"
	}
	writter:BeginBlock()
	writter:DefLine "pugi::xml_node parent;" 
	writter:DefLine "if(name == nullptr)" 
	writter:DefBlockLine "parent = in_node;"
	writter:DefLine "else {" 
	writter:BeginBlock()	
	writter:DefLine "parent = in_node.child(name);" 
	writter:DefLine "if(!parent) parent = in_node.append_child(name);" 
	writter:EndBlock()	
	writter:DefLine "}" 
	writter:DefLine "if(!parent) return false;" 
	writter:DefLine "while(parent.remove_child(parent.first_child()));" 
	writter:DefLine "for(const auto& it: value) {" 
	writter:BeginBlock()	
	writter:DefLine "auto node = parent.append_child(\"item\");"
	element:GenWrite("it", nil, writter)
	writter:EndBlock()	
	writter:DefLine "}" 
	writter:DefLine "auto count_att = parent.attribute(\"count\");" 
	writter:DefLine "if(!count_att) count_att = parent.append_attribute(\"count\");"
	writter:DefLine "count_att = value.size();"
	writter:DefLine "return true;" 
	writter:EndBlock()	
	writter:DefLine "}" 

	writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_Read(const pugi::xml_node in_node, ", 
		T:LocalName(), 
		" &value, const char* name) {"
	}	
	writter:BeginBlock()
	writter:DefLine "pugi::xml_node parent = name == nullptr ? in_node : in_node.child(name);" 
	writter:DefLine "if(!parent) return false;" 
	writter:DefLine "value.clear();"
	writter:DefLine "auto count_att = parent.attribute(\"count\");" 
	writter:DefLine "if(count_att) value.reserve(count_att.as_uint());"
	writter:DefLine "for(auto node = parent.child(\"item\"); node; node = node.next_sibling(\"item\")) {" 
	writter:BeginBlock()
	writter:DefLine { element:GlobalName(), " tableitem;" }
	element:GenRead("tableitem", nil, writter)
	writter:DefLine "value.push_back(std::move(tableitem));"
	writter:EndBlock()
	writter:DefLine "}" 
	writter:DefLine "return true;" 
	writter:EndBlock()	
	writter:DefLine "}" 
	writter:DefLine ""
	
	writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_SetDefault(",
		T:LocalName(), 
		" &value) {"
	}
	writter:BeginBlock()
	writter:DefLine "value.clear();"
	writter:EndBlock()	
	writter:DefLine "}" 
	
	writter:DefLine ""
end

local function Write_List(T, writter)
	local element = T.element_type
	
	writter:DefLine {
		"using ", T:LocalName(), " = std::list<", element:GlobalName(), ">;"
	}
	
	writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_Write(pugi::xml_node in_node, const ", 
		T:LocalName(), 
		" &value, const char* name) {"
	}
	writter:BeginBlock()
	writter:DefLine "pugi::xml_node parent;" 
	writter:DefLine "if(name == nullptr)" 
	writter:DefBlockLine "parent = in_node;"
	writter:DefLine "else {" 
	writter:BeginBlock()	
	writter:DefLine "parent = in_node.child(name);" 
	writter:DefLine "if(!parent) parent = in_node.append_child(name);" 
	writter:EndBlock()	
	writter:DefLine "}" 
	writter:DefLine "if(!parent) return false;" 
	writter:DefLine "while(parent.remove_child(parent.first_child()));" 
	writter:DefLine "for(const auto& it: value) {" 
	writter:BeginBlock()	
	writter:DefLine "auto node = parent.append_child(\"item\");"
	element:GenWrite("it", "\"item\"", writter)
	writter:EndBlock()	
	writter:DefLine "}" 
	writter:DefLine "auto count_att = parent.attribute(\"count\");" 
	writter:DefLine "if(!count_att) count_att = parent.append_attribute(\"count\") "
	writter:DefLine "count_att = value.size();"
	writter:DefLine "return true;" 
	writter:EndBlock()	
	writter:DefLine "}" 

	writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_Read(const pugi::xml_node in_node, ", 
		T:LocalName(), 
		" &value, const char* name) {"
	}	
	writter:BeginBlock()
	writter:DefLine "pugi::xml_node parent = name == nullptr ? in_node : in_node.child(name);" 
	writter:DefLine "if(!parent) return false;" 
	writter:DefLine "value.clear();"
	writter:DefLine "for(auto node = parent.first_child(\"item\"); it; it = it.next_sibling(\"item\") {" 
	writter:BeginBlock()
	writter:DefLine { element:GlobalName(), " item;" }
	element:GenRead("item", "\"item\"", writter)
	writter:DefLine "value.push_back(std::move(item));"
	writter:EndBlock()
	writter:DefLine "}" 
	writter:DefLine "return true;" 
	writter:EndBlock()	
	writter:DefLine "}" 
	
		writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_SetDefault(",
		T:LocalName(), 
		" &value) {"
	}
	writter:BeginBlock()
	writter:DefLine "value.clear();"
	writter:EndBlock()	
	writter:DefLine "}" 
	
	writter:DefLine ""
end

local function Write_Map(T, writter)
	local element = T.element_type
	local key = T.key_type	
	
	writter:DefLine {
		"using ", T:LocalName(), " = std::unordered_map<", key:GlobalName(), ", ", element:GlobalName(), ">;"
	}
	
	writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_Write(pugi::xml_node in_node, const ", 
		T:LocalName(), 
		" &value, const char* name) {"
	}
	writter:BeginBlock()
	writter:DefLine "pugi::xml_node parent;" 
	writter:DefLine "if(name == nullptr)" 
	writter:DefBlockLine "parent = in_node;"
	writter:DefLine "else {" 
	writter:BeginBlock()	
	writter:DefLine "parent = in_node.child(name);" 
	writter:DefLine "if(!parent) parent = in_node.append_child(name);" 
	writter:EndBlock()	
	writter:DefLine "}" 
	writter:DefLine "if(!parent) return false;" 
	writter:DefLine "while(parent.remove_child(parent.first_child()));" 
	writter:DefLine "for(const auto& it: value) {" 
	writter:BeginBlock()	
	writter:DefLine "auto node = parent.append_child(\"item\");"
	key:GenWrite("it.first", "\"first\"", writter)
	element:GenWrite("it.second", "\"second\"", writter)
	writter:EndBlock()	
	writter:DefLine "}" 
	writter:DefLine "auto count_att = parent.attribute(\"count\");" 
	writter:DefLine "if(!count_att) count_att = parent.append_attribute(\"count\");"
	writter:DefLine "count_att = value.size();"
	writter:DefLine "return true;" 
	writter:EndBlock()	
	writter:DefLine "}" 

	writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_Read(const pugi::xml_node in_node, ", 
		T:LocalName(), 
		" &value, const char* name) {"
	}	
	writter:BeginBlock()
	writter:DefLine "pugi::xml_node parent = name == nullptr ? in_node : in_node.child(name);" 
	writter:DefLine "if(!parent) return false;" 
	writter:DefLine "value.clear();"
	writter:DefLine "auto count_att = parent.attribute(\"count\");" 
	writter:DefLine "if(!count_att) value.reserve(count_att.as_uint());"
	writter:DefLine "for(auto node = parent.first_child(\"item\"); node; node = node.next_sibling(\"item\") {" 
	writter:BeginBlock()
	writter:DefLine { key:GlobalName(), " first;" }
	writter:DefLine { element:GlobalName(), " second;" }
	key:GenRead("first", "\"first\"", writter)
	element:GenRead("second", "\"second\"", writter)
	writter:DefLine "value.insert(std::make_pair(std::move(first), std::move(second)));"
	writter:EndBlock()
	writter:DefLine "}" 
	writter:DefLine "return true;" 
	writter:EndBlock()	
	writter:DefLine "}" 
	
	writter:DefLine { 
		"inline bool ", 
		T:LocalName(), 
		"_SetDefault(",
		T:LocalName(), 
		" &value) {"
	}
	writter:BeginBlock()
	writter:DefLine "value.clear();"
	writter:EndBlock()	
	writter:DefLine "}" 
	
	writter:DefLine ""
end

-------------------------------

local ContainerType, ContainerType_mt = x2c.MakeTypeClass()

function ContainerType:GenResetToDefault(member, name, writter)
	writter:DefLine {
		member,
		".clear();",
	}
end

local function make_container(data)
	data.object_type = "Container"
	setmetatable(data, ContainerType_mt)
	return data
end

-------------------------------

Container = { }
Container_mt = { }

function Container_mt.__newindex()
	error("Attempt to modify Container metaobject!")
end

function Container_mt.__index(self, key)
	local f = rawget(self, key)
	if not f then
		error("Container: there is no such container - ", key)
		return
	end
	
	return f
end

function Container.table(ElementType, TypeName)
	Assert.type_nonnamespace(ElementType, Container, " Table element cannot be of type ", ElementType)
	
	local name = TypeName or ElementType:LocalName() .. "Vector"
	if x2c.CurrentNamespace:Exists(name) then
		return x2c.CurrentNamespace:Get(name) 
	end		
	
	local data = { }
	data.element_type = ElementType
	data.name = name
	data.namespace = x2c.CurrentNamespace
	data.config = table.shallow_clone(data.namespace.config);
	
	data = make_container(data)
	
	Write_Table(data, x2c.output)
	info("Defined table ", data:LocalName(), " in namespace ", data.namespace:DisplayName())
	x2c.CurrentNamespace:Add(data)
	return data
end

function Container.list(ElementType, TypeName)
	Assert.type_nonnamespace(ElementType, Container, " List element cannot be of type ", ElementType)
	
	local name = TypeName or ElementType:LocalName() .. "List"
	if x2c.CurrentNamespace:Exists(name) then
		return x2c.CurrentNamespace:Get(name) 
	end	
	
	local data = { }
	data.element_type = ElementType
	data.name = name
	data.namespace = x2c.CurrentNamespace
	data.config = table.shallow_clone(data.namespace.config);
	
	data = make_container(data)
	Write_List(data, x2c.output)
	info("Defined list ", data:LocalName(), " in namespace ", data.namespace:DisplayName())
	x2c.CurrentNamespace:Add(data)
	return data
end

function Container.map(KeyType, ElementType, TypeName)
	Assert.type_nonnamespace(KeyType, Container, " Map key cannot be of type ", KeyType)
	Assert.type_nonnamespace(ElementType, Container, " Map value cannot be of type ", ElementType)
				
	local name = TypeName or KeyType:LocalName() .. ElementType:LocalName() .. "Map"
	if x2c.CurrentNamespace:Exists(name) then
		return x2c.CurrentNamespace:Get(name) 
	end		
	
	local data = { }
	data.key_type = KeyType
	data.element_type = ElementType
	data.name = name
	data.namespace = x2c.CurrentNamespace
	data.config = table.shallow_clone(data.namespace.config);
	
	data = make_container(data)
	Write_Map(data, x2c.output)	
	info("Defined map ", data:LocalName(), " in namespace ", data.namespace:DisplayName())
	x2c.CurrentNamespace:Add(data)
	return data
end

setmetatable(Container, Container_mt)
