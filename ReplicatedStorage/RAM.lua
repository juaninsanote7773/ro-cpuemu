local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RAM = {}

RAM.RAMSTOR = {}

local RAM_SIZE = 16384 --16kb

--local inst_set = {"load", "add", "set", "cmp", "JA", "JL", "JE", "jmp", "out", "in"}

function RAM.write(i, value)
	RAM.RAMSTOR[i] = value
end

function RAM.read(i)
	return RAM.RAMSTOR[i]
end

function RAM.generate()
	for i = 1, RAM_SIZE do
		--[[local clone = ReplicatedStorage["RAM-Adress"]:Clone()
		clone.Parent = ReplicatedStorage["RAM-Storage"]
		clone.Name = string.format("0x%02X", i)
		--clone.Name = i
		clone.data.Value = ""
		clone.data_type.Value = 1
		
		--if i < #inst_set then
		--	clone.data.Value = inst_set[i]
		--end]]
		
		table.insert(RAM.RAMSTOR, "")
	end
end

return RAM
