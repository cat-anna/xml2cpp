
local x2c = _G["x2c"]

function x2c.RegisterType(newtype, namespace)
	local cf = x2c.CurrentFie
	
	local tinfo = {
		value = newtype,
		namespace = namespace,
	}
	
	cf.types[#cf.types + 1] = tinfo
	if cf.Generate then
		x2c.Exporter:RegisterType(tinfo)
	end
	
	namespace:Add(newtype)
end

function x2c.CheckStartingState()
    if #x2c.inputfiles == 0 then
        print("No input files")
        x2c.PrintHelp()
        os.exit(1)
    end
end
