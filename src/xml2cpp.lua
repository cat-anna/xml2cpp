#!/usr/bin/lua



x2c = { 
	inputfiles = { },
	outputfile = nil,
	
	settings = {
		gen_all = false,
	},
	
	imports = { }
}

require "utils"
require "basetype"
require "namespace"
require "structure"
require "types"
require "enum"
require "alias"
require "container"
require "writter"


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
			x2c.outputfile = args[i]
			return 1
		end,
	},
	["--input"] = {
		ArgHelp = "<FILE>",
		Help = "Add file to process",
		func = function(i, args)
			x2c.inputfiles[#x2c.inputfiles + 1] = args[i]
			if not x2c.outputfile then
				x2c.outputfile = args[i] .. ".h"
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
	["--static"] = {
		Help = "Define all functions as static",
		func = function(i, args)
			error(args[i - 1], " is not yet supported")
		end,	
	},
	["--no-inline"] = {
		Help = "Do not make all functions inline",
		func = function(i, args)
			error(args[i - 1], " is not yet supported")
		end,	
	},	
}

local i = 1
while i <= #arg do
	local v = arg[i]
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

	i = i + cmd.func(i, arg)
end

if not x2c.outputfile then
	x2c.outputfile = "x2c.h"
end

x2c.output = Writter.open()

local ImportMeta = { }
local ImportLevel = 0
local FileStack = { }

function ImportMeta.__call(self, importfn)

	print("import ", importfn)
	local fn = importfn:match("([^/\\]+)$") or importfn

	if x2c.imports[fn] then
		return
	end
	
	local prev
	if ImportLevel > 0 then
		prev = FileStack[ImportLevel]
	end
	
	local ffull
	
	if prev then
		ffull = prev.path .. importfn
		
	else 
		ffull = importfn
	end

	fpath = ffull:match("(.*[/\\])") 
	x2c.imports[fn] = { }

	info(string.format("Processing file %s (%s)", fn, ffull))

	local f, err = loadfile(ffull)

	if not f then
		error("Failed to load file ", fn, "\n", err)
	end

	ImportLevel = ImportLevel + 1
	FileStack[ImportLevel] = { import = importfn, name = fn, path = fpath, ffull = ffull }
	
	if not x2c.settings.gen_all then
		x2c.output:EnableOutput(ImportLevel == 1)
	end
	namespace ""
	f()
	namespace ""

	FileStack[ImportLevel] = nil
	ImportLevel = ImportLevel - 1
	
	if not x2c.settings.gen_all then
		x2c.output:EnableOutput(ImportLevel == 1)
	end
end

x2c.MakeMetaObject(ImportMeta, "Import")

---------------

if #x2c.inputfiles == 0 then
	print("No input files")
	PrintHelp()
	os.exit(1)
end

for i,v in ipairs(x2c.inputfiles) do
	Import(v)
end

x2c.output:Write(x2c.outputfile)
