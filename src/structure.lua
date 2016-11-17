
local Assert = x2c.Assert
local GenPoints = x2c.Observer.GenPoints

_______________________

local function make_structure(data)
    x2c.Exporter:InitTypeExporterInfo(data, "Structure")

	if data.fields then
		for i,v in ipairs(data.fields) do
			Assert.type_nonnamespace(v.type, Structure, "Structure member cannot be of type " , v.type)

            local member = string.format("%s%s%s",
                data.config.structure_field_prefix or "",
                v.name,
                data.config.structure_field_postfix or ""
            )
            v.decoratedname = member

            x2c.Exporter:InitTypeExporterMemberInfo(v, "Structure")

            setmetatable(v.exportsettings, {
                __index = function (self, value)
                    local r = rawget(self, value)
                    if r then
                        return r
                    end
                    return data.exportsettings[value]
                end,
                __newindex = function(self, name, value)
                    error(Structure, "Attempt to modify structure member ", v.name)
                end
            } )
		end
	end
    data.object_type = "Structure"
	local s = x2c.Exporter:MakeStructure(data)
	x2c.RegisterType(s, x2c.CurrentNamespace)
	return s
end

_______________________

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

	make_structure(data)
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

	make_structure(data)
end

function StructureMeta.prefix(value)
	Assert.String(value)
	x2c.CurrentNamespace.config.structure_prefix = value
end

function StructureMeta.postfix(value)
	Assert.String(value)
	x2c.CurrentNamespace.config.structure_postfix = value
end

_______________________________________

x2c.Structure = x2c.MakeGenerator()
local Structure = x2c.Structure

function Structure.Init()

end

function Structure.Generate(Block, Type, Observer)

    if Type.imported then
        Observer:Execute(GenPoints.pre_struct_declartion, Block, Type)
        block:DocString(Type.description)
        block:MakeAlias(Type:LocalName(), Type.location)
        Observer:Execute(GenPoints.struct_import, Block, Type)
        Observer:Execute(GenPoints.post_struct_declartion, Block, Type)
        return
    end

    Observer:Execute(GenPoints.pre_struct_declartion, Block, Type)
    Block:DefineStructure(Type:LocalName())
    Observer:Execute(GenPoints.post_struct_declartion, Block, Type)

    Observer:Execute(GenPoints.pre_struct_definition, Block, Type)

        Block:DocString(Type.description)
        Block:BeginStructure(Type:LocalName())

            Observer:Execute(GenPoints.struct_entry, Block, Type)


            Observer:Execute(GenPoints.pre_struct_members, Block, Type)
            Observer:Execute(GenPoints.post_struct_members, Block, Type)


            Observer:Execute(GenPoints.struct_exit, Block, Type)

    	block:EndStructure()

    Observer:Execute(GenPoints.post_struct_definition, Block, Type)
--[[

%%pre_struct_declartion
struct name;
%%post_struct_declartion

%%pre_struct_definition
/** doc */
struct name {
    %%struct_entry/%%struct_import

    %%pre_struct_members
    int members;
    %%post_struct_members

    %%struct_exit
};
%%post_struct_definition

]]
end

_______________________________________

local StructureFieldMeta = { }

function StructureFieldMeta.prefix(value)
	Assert.String(value)
	x2c.CurrentNamespace.config.structure_field_prefix = value
end

function StructureFieldMeta.postfix(value)
	Assert.String(value)
	x2c.CurrentNamespace.config.structure_field_postfix = value
end

_______________________

x2c.MakeMetaSubObject(StructureMeta, StructureFieldMeta, "field")
x2c.MakeMetaObject(StructureMeta, "Structure")
