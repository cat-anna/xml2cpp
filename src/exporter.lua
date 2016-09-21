
local Exporter = { }
x2c.Classes.Exporter = Exporter

function Exporter:Init(Config)
	self.Config = Config
	self.Types = { }
end

function Exporter:Write()
  error("Not implemented!")
end

function Exporter:RegisterType(tinfo)
	self.Types[#self.Types + 1] = tinfo
end

---------------------------------------

function Exporter:InitTypeExporterInfo(data)
  error("Not implemented!")
end

function Exporter:InitTypeExporterMemberInfo(data)
  error("Not implemented!")
end

---------------------------------------

function Exporter:MakeStructure(data)
  error("Not implemented!")
end

function Exporter:MakeAlias(data)
  error("Not implemented!")
end

function Exporter:MakeEnum(data)
  error("Not implemented!")
end

function Exporter:MakeContainer(data)
  error("Not implemented!")
end

---------------------------------------

require "exporters/cxx-common"
require "exporters/cxxpugi"
