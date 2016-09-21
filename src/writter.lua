
local FileBlock = inheritsFrom(nil)

function FileBlock:Init(Writter)
	self.Writter = Writter
	self.Block = 0
	self.Enabled = true
	self.Lines = { }
end

function FileBlock:Ident()
    return string.rep(self.Writter.Ident, self.Block)
end

function FileBlock:SetLinePrefix(LinePrefix)
	self.LinePrefix = LinePrefix
end

function FileBlock:BeginBlock()
	self.Block = self.Block + 1
end

function FileBlock:EndBlock()
	self.Block = self.Block - 1
	if self.Block < 0 then
		self.Block = 0
	end
end

function FileBlock:BlockLine(parts)
	self:BeginBlock()
	self:Line(parts)
	self:EndBlock()
end

function FileBlock:BeginBlockLine(parts)
	self:Line(parts)
	self:BeginBlock()
end

function FileBlock:EndBlockLine(parts)
	self:EndBlock()
	self:Line(parts)
end

function FileBlock:Line(parts)
	if not self.Enabled then
		return
	end

	local line = { }
	self.Lines[#self.Lines + 1] = line
	
	local put = function(v)
		if not v then
			v = "[nil]"
		end
		line[#line + 1] = v
	end
	
	put(self:Ident())
	if self.LinePrefix then
		put(self.LinePrefix)
	end
	
	if type(parts) == "table" then
		for i,v in ipairs(parts) do
			put(v)
		end
	elseif type(parts) == "string" then
		put(parts)
	end
	
	put("\n")
end

function FileBlock:Write(f)
	for i,v in ipairs(self.Lines) do
		local line = table.concat(v, "")
		f:write(line)
	end
end

---------------------------------------

local Writter = {}

x2c.Classes.Writter = Writter

function Writter:Init(FileName)
	self.Ident = "\t"
	self.FileBlocks = { }
	
	self.ImplLines = { }
	self.DefLines = { }
	self.enabled = true
    self.FileName = FileName
end

function Writter:AddFileBlock()
	local b = FileBlock:Create(self)
	if self.BlockExt then
		for k,v in pairs(self.BlockExt) do
			b[k] = v
		end
	end
	
	self.FileBlocks[#self.FileBlocks + 1] = b
	return b
end

---------------------------------------

function Writter:WriteFileHeader()
	error("Not implemented")
end

---------------------------------------

function Writter:Close()
	local f = io.open(self.FileName, "w")
	if not f then
		error("Unable to open file " .. filename .. " for writting")
	end
	
	for i,block in ipairs(self.FileBlocks) do
		block:Write(f)
	end
	f:close()
	return true
end
