

Writter = {}
local Writter_mt = { __index = Writter }

function Writter.open()
    local new_inst = {}   
    setmetatable( new_inst, Writter_mt )
	new_inst.block = 0
	new_inst.ImplLines = { }
	new_inst.DefLines = { }
	new_inst.enabled = true
    return new_inst
end

function Writter:EnableOutput(value)
	self.enabled = value
end

function Writter:BeginBlock()
	self.block = self.block + 1
end

function Writter:EndBlock()
	self.block = self.block - 1
	if self.block < 0 then
		self.block = 0
	end
end

function Writter:Ident()
	return string.rep("\t", self.block)
end

function Writter:DefBlockLine(parts)
	self:BeginBlock()
	self:DefLine(parts)
	self:EndBlock()
end

function Writter:DefLine(parts)
	if not self.enabled then
		return
	end

	local line = { }
	self.DefLines[#self.DefLines + 1] = line
	
	local put = function(v)
		line[#line + 1] = v
	end
	
	put(self:Ident())
	if type(parts) == "table" then
		for i,v in ipairs(parts) do
			put(v)
		end
		return
	end
	if type(parts) == "string" then
		put(parts)
		return
	end
end

function Writter:ImplLine(parts)
	if not self.enabled then
		return
	end

	local line = { }
	self.ImplLines[#self.ImplLines + 1] = line
	
	local put = function(v)
		line[#line + 1] = v
	end
	
	put(self:Ident())
	for i,v in ipairs(parts) do
		put(v)
	end
end

function Writter:Write(filename)
	local f = io.open(filename, "w")
	if not f then
		print("ERROR: unable to open file " .. filename .. " for writting")
		return false
	end
	
	for i,v in ipairs(self.DefLines) do
		local line = table.concat(v, "")
		f:write(line, "\n")
	end
	
	f:write("\n")
		
	for i,v in ipairs(self.ImplLines) do
		local line = table.concat(v, "")
		f:write(line, "\n")
	end
	
	f:close()
	return true
end
