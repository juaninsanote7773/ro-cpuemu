local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RAM = {}

local size_bytes = 32000 --1kb

--local inst_set = {"load", "add", "set", "cmp", "JA", "JL", "JE", "jmp", "out", "in"}

function RAM.generate()
	for i = 1, size_bytes do
		local clone = ReplicatedStorage["RAM-Adress"]:Clone()
		clone.Parent = ReplicatedStorage["RAM-Storage"]
		clone.Name = string.format("0x%02X", i)
		--clone.Name = i
		clone.data.Value = ""
		clone.data_type.Value = 1
		
		--if i < #inst_set then
		--	clone.data.Value = inst_set[i]
		--end
	end
end

return RAM
