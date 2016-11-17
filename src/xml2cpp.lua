#!/usr/bin/lua

--[[

%%pre-namespace-entry
namespace x2c::n1::n2 {
%%post-namespace-entry



	%%pre-enum-definition
	enum Enum {
		a, b, c,
	};
	%%post-enum-definition

%%pre-namespace-exit
}
%%post-namespace-exit

]]


x2c = {
	inputfiles = { },
	outputfile = nil,

	settings = {
		gen_all = false,
	},

    Exporters = { },

	imports = { },
	importsByName = { },
	importsByLevel = { },

	Classes = { },

    exports = { },

	info = {
		Name = "xml2cpp",
		LongName = "xml2cpp v0.1",
	}
}

require "utils"
require "basetype"
require "import"
require "state"
require "namespace"
require "structure"
require "enum"
require "alias"
require "container"
require "writter"
require "exporter"
require "arguments"

x2c.ParseArguments(arg)

--local basedir = "d:\\Programowanie\\Projekty\\!gry\\MoonGlare\\MazeGame\\"
--x2c.inputfiles[#x2c.inputfiles + 1] =  basedir .. "MoonGlare\\Source\\Shared\\x2c\\Math.x2c"
--x2c.outputfile = {
--  exporter = "cxxpugi",
--  FileName = basedir .. "bin_vs2015\\Engine\\obj\\x32\\Debug\\Math.x2c.h",
--}

if not x2c.outputfile then
	x2c.outputfile = "x2c.h"
end

x2c.CheckStartingState()

---------------

local exporterClass = x2c.Exporters[x2c.outputfile.exporter]
if not exporterClass then
    error("Unknown exporter")
end

local Exporter = exporterClass:Create(x2c.outputfile)
x2c.Exporter = Exporter

x2c.ImportInputFiles()

Exporter:Write()
