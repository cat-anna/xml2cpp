local x2c = _G["x2c"]

local Options 
local function PrintHelp()
	print "Xml2Cpp ver 0.1"
	print ""
	print "Usage:"
	print("\t" .. arg[0] .. " OPTIONS FILES")
	print ""
	print "Options:"
	for k,v in pairs(Options) do
		print(string.format("\t%-10s %-10s %s", k, v.ArgHelp or "", v.Help))
	end
	
	print ""
	os.exit(0)
end

Options = {
	["--output"] = {
		ArgHelp = "<FILE>",
		Help = "Set output filename",
		func = function(i, args)
			x2c.outputfile = {
				FileName = args[i],
				exporter = "cxxpugi",
			}			
			return 1
		end,
	},
	["--input"] = {
		ArgHelp = "<FILE>",
		Help = "Add file to process",
		func = function(i, args)
			x2c.inputfiles[#x2c.inputfiles + 1] = args[i]
			if not x2c.outputfile then
				x2c.outputfile = {
					FileName = args[i] .. ".h",
					exporter = "cxxpugi",
				}					
			end
			return 1
		end,	
	},
	["--all"] = {
		Help = "Export all types defined from dependant files",
		func = function(i, args)
			x2c.settings.gen_all = true
			return 0
		end,	
	},
	["--help"] = {
		Help = "Print this help",
		func = function(i, args)
			PrintHelp()
			os.exit(0)
		end,	
	},
--	["--static"] = {
--		Help = "Define all functions as static",
--		func = function(i, args)
--			error(args[i - 1], " is not yet supported")
--		end,	
--	},
--	["--no-inline"] = {
--		Help = "Do not make all functions inline",
--		func = function(i, args)
--			error(args[i - 1], " is not yet supported")
--		end,	
--	},	
}

function x2c.ParseArguments(arglist)
    local i = 1
    while i <= #arglist do
        local v = arglist[i]
        local cmd

        if v:sub(1, 2) == "--" then
            cmd = Options[v]
            
            if not cmd then
                error("Unknown option ", v)
            end
        end

        if not cmd then
            cmd = Options["--input"]
        else
            i = i + 1
        end

        i = i + cmd.func(i, arglist)
    end
end
