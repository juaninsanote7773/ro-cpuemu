--[[ASM code functionality, also is kind of like a base for other languages yet to implement, since its
basically machine code.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CPUINST = require(ReplicatedStorage.CPUINST)
local PROCESS = require(ReplicatedStorage.PROCESS)
local RAM = require(ReplicatedStorage.RAM)

local ASM = {}

local compiled = {}

local opcodes = {	
				{"biosclear", 9},
				{"load", 1},
				{"add", 2},
				{"db", 3},
				{"mov", 4},
				{"cmp", 5},
				{"jmp", 6},
				{"call", 7}, 
				{"times", 8}, 
				{"push", 10},
				{"pop", 11},
				{"je", 12},
				{"jl", 13},
				{"jg", 14},
				{"jne", 19},
				{"inc", 15},
				{"dec", 16},
				{"int", 17},
				{"cat", 18},
				{"org", 20}
}

ASM.jumps = {"0x06", "0x0C", "0x0D", "0x0E", "0x13"}

function ASM.check_refs(asm_script)
	local references = {}

	for i,v in asm_script do
		local split_line = string.split(v, " ")
		for i_w = 1, #split_line do
			local data_type = 0
			local word = split_line[i_w]

			--labels, used for jmp

			local str = string.split(word, ":")
			if str[2] then
				data_type = 4
				word = str[1]
				table.insert(references, {word, CPUINST.to_hex(RAM.RAM_LASTSPACE+i)})
			end
		end
	end
	
	return references
end

function ASM.compile(asm_script)
	if type(asm_script) == "string" then
		asm_script = string.split(asm_script, '\n')
	end
	
	local last_split
	
	local last_data_type
	
	local references = ASM.check_refs(asm_script)
	
	compiled = {}
	
	local pointer_self = false
	local origin_point = false
	

	for i,v in asm_script do
		local split_line = string.split(v, " ")
		for i_w = 1, #split_line do
			pointer_self = false
			local defined_opcode = false

			local data_type = 0
			local word = split_line[i_w]
			
			if i_w == 1 then
				--instructions
				data_type = 0
			end
			
			--numbers

			if tonumber(word) then
				data_type = 1
			end
			
			if word == "org" then
				origin_point = true
				data_type = 0
				defined_opcode = true
			end
			if last_split == "org" then
				origin_point = word
				data_type = 3
			end
			
			--strings
			
			local str = string.split(word, "'")
			if str[2] then
				data_type = 2
				word = str[2]
				if word == "%s" then
					word = " "
				end
			end
			
			--mem adresses

			if word == "$" then
				data_type = 3
				word = CPUINST.to_hex(RAM.RAM_LASTSPACE+#compiled)
				print(word.." SELF POINTER")
				--print(word)
				pointer_self = true
			end
			
			local str = string.split(word, "@")
			if str[2] then
				data_type = 3
				word = str[2]
			end
			
			--labels, used for jmp
			
			local str = string.split(word, ":")
			if str[2] then
				data_type = 4
				for _, v2 in pairs(references) do
					if v2[1] == str[1] then
						word = v2[2]
					end
				end
			end
			
			if table.find(ASM.jumps, last_split) then
				for i,v in pairs(references) do
					if v[1] == word then
						word = v[2]
						data_type = 3
					end
				end
			end
			
			
			--LB_END MIGHT BE NEEDED LATER
			--if word == "LB_END" then
			--	data_type = 4
			--end
			
			if data_type == 0 then
				for _, v2 in pairs(opcodes) do
					if v2[1] == word then
						defined_opcode = true
						word = CPUINST.to_hex(v2[2])
						print(word)
					end
				end
			end
			
			if data_type == 0 and defined_opcode == false then
				data_type = 2
			end

			if table.find(CPUINST.cpu_register, word) then
				--print("aaaaaa")
				data_type = 3
			end
			
			--print(data_type.." "..word)
			
			table.insert(compiled, {word, data_type})
			last_split = word
			last_data_type = data_type
		end
	end
	print(compiled)
	
	return compiled
end


return ASM
