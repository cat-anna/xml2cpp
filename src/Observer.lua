

local Observer = { }
x2c.Observer = Observer

---------------------------------------

local ProtoPoints = {
    "pre_struct_declartion",
    "post_struct_declartion",
    "pre_struct_definition",
    "post_struct_definition",
    "struct_import",
    "struct_entry",
    "struct_exit",
    "pre_struct_members",
    "post_struct_members",
}

local function PreprocessGenPoints(points)
    local ret = { }
    for _,v in ipairs(points) do
        ret[v] = v
    end
    return ret;
end

local GenPoints = PreprocessGenPoints(ProtoPoints)
Observer.GenPoints = GenPoints

---------------------------------------
