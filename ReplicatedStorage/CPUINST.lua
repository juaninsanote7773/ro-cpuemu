--alu logic

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RAMSTOR = ReplicatedStorage["RAM-Storage"]
local CPUREG = ReplicatedStorage["CPU-Register"]
local BIOS = require(ReplicatedStorage.BIOS)

local CPUINST = {}

local stack = {}

local EFLAGS = {
	["ZF"] = 0,
	["CF"] = 0,
	["SF"] = 0,
	["OF"] = 0,
	["PF"] = 0
}

--inst_set = {"load", "add", "set", "cmp", "jmpif", "jmp", "out", "in", "db"}
CPUINST.cpu_register = {"eax", "ebx", "ecx", "edx", "ax", "ah", "al", "bx", "cx", "dx", "esp"}
CPUINST.cpu_instructions = {"load", "add", "db", "mov", "cmp", "jmp", "je", "jne", "jl", "jg", "call", "biosclear", "push", "pop"}

function CPUINST.check_add(word)
	if word == CPUINST.to_hex(word) then
		print(word.." 1add")
		return 1
	end
	if table.find(CPUINST.cpu_register, word) then
		print(word.." 2add")
		return 2
	end
	return 0
end

function clear_EFLAGS()
	for i = 1, #EFLAGS do
		EFLAGS[i] = 0
	end
end

function CPUINST.to_decimal(word)
	return tonumber(word, 16)
end

function CPUINST.to_hex(word)
	if tonumber(word) then
		return string.format("0x%02X", tonumber(word))
	else
		return "FLAG_FAIL"
	end
end

function CPUINST.check_datatype(word)
	local data_type = 0
	
	if tonumber(word) then
		data_type = 1
		return word, data_type
	end
	
	local str = string.split(word, "'")
	if str[2] then
		data_type = 2
		word = str[2]
		return word, data_type
	end

	--mem adresses

	if word == "@" then
		data_type = 3
		word = ReplicatedStorage["RAM-LastSpace"].Value
		print(word)
		return word, data_type
	end

	local str = string.split(word, "@")
	if str[2] then
		data_type = 3
		word = str[2]
		return word, data_type
	end

	if table.find(CPUINST.cpu_register, word) then
		data_type = 3
		return word, data_type
	end

	--labels, used for jmp

	local str = string.split(word, ":")
	if str[2] then
		data_type = 4
		word = str[1]
		return word, data_type
	end
	
	return word, data_type
end

function CPUINST.load(address)
	local add = RAMSTOR:FindFirstChild(address)
	return add.data.Value
end

function CPUINST.add(val1, val2)
	local trueval_2 = val2
	
	if table.find(CPUINST.cpu_register, val2) then
		trueval_2 = ReplicatedStorage["CPU-Register"]:FindFirstChild(val2).Value
		trueval_2 = tonumber(trueval_2)
	end
	
	val2 = trueval_2
	
	if not table.find(CPUINST.cpu_register, val1) then
		if not table.find(CPUINST.cpu_register, val2) then
			local trueval_1 = RAMSTOR:FindFirstChild(val1).data.Value
			trueval_1 = tonumber(trueval_1)
			if tostring(val2) or tostring(trueval_1) then
				return
			end
			CPUINST.set(val1, trueval_1+val2)
			return "done"
		end
	else
		print("a")
		local trueval_1 = ReplicatedStorage["CPU-Register"]:FindFirstChild(val1).Value
		trueval_1 = tonumber(trueval_1)
		print(val2.. " "..trueval_1)
		if not tonumber(val2) then
			print("tostring ")
			return
		end
		CPUINST.set(val1, trueval_1+val2)
		return "done"
	end
end

function CPUINST.inc(val)
	print("INCREMENTING "..val)
	if CPUINST.check_add(val) == 1 then
		local RAMADD = RAMSTOR:FindFirstChild(val)
		RAMADD.data.Value += 1
		return "success"
	end
	if CPUINST.check_add(val) == 2 then
		local REGADD = CPUREG:FindFirstChild(val)
		REGADD.Value += 1
		print(REGADD.Value.." THIS IS THE REGADD")
		return "success"
	end
	if CPUINST.check_add(val) == 0 then
		return "FLAG_FAIL"
	end
end


function CPUINST.dec(val)
	if CPUINST.check_add(val) == 1 then
		local RAMADD = RAMSTOR:FindFirstChild(val)
		RAMADD.data.Value -= 1
		return "success"
	end
	if CPUINST.check_add(val) == 2 then
		local REGADD = CPUREG:FindFirstChild(val)
		REGADD.Value -= 1
		return "success"
	end
	if CPUINST.check_add(val) == 0 then
		return "FLAG_FAIL"
	end
end

function CPUINST.db(val)
	print("is this function ever called?")
	CPUINST.set(RAMSTOR.Parent["RAM-LastSpace"].Value, val)
end

function CPUINST.set(address, val, data_type)	
	if tonumber(address) then
		address = CPUINST.to_hex(address)
	end
	if RAMSTOR:FindFirstChild(address) == nil and CPUREG:FindFirstChild(address) == nil then
		return "FLAG_FAIL"
	end
	if not table.find(CPUINST.cpu_register, address) then
		local add = RAMSTOR:FindFirstChild(address)
		if not add then
			return "FLAG_FAIL"
		end
		
		add.data.Value = val
--		print(add.data.Value.." THIS IS THE VALUE ON "..address)
		--print(val)
		if not data_type then
			local word, data_type = CPUINST.check_datatype(tostring(val))
			add.data_type.Value = data_type
		else
			add.data_type.Value = data_type
		end

		RAMSTOR.Parent["RAM-LastSpace"].Value += 1
		
		return "success"
	else
		--print("a")
		local add = ReplicatedStorage["CPU-Register"]:FindFirstChild(address)
		add.Value = val
		
		return "success"
	end
end

function CPUINST.cat(val1, val2)
	if val1 == "" and val2 == "" then
		val1 = stack[#stack-1]
		val2 = stack[#stack]
	end
	
	print("CONCATENATING "..val1.." "..val2)
	local address_val1 = val1
	local address1 = CPUINST.check_add(val1)
	local address2 = CPUINST.check_add(val2)

	if address1 == 1 then
		val1 = RAMSTOR:FindFirstChild(val1).data.Value
	end
	if address1 == 2 then
		val1 = CPUREG:FindFirstChild(val1).Value
	end
	if address1 == 0 then
		return "FLAG_FAIL"
	end
	
	
	if address2 == 1 then
		val2 = RAMSTOR:FindFirstChild(val2).data.Value
	end
	if address2 == 2 then
		val2 = CPUREG:FindFirstChild(val2).Value
	end
	
	CPUINST.set(address_val1, val1..val2)
end

function CPUINST.cmp(val1, val2)
	clear_EFLAGS()
	print("COMPARE")
	print(val1.." "..val2.." COMPARE")
	if CPUINST.check_add(val1) == 1 then
		val1 = CPUINST.load(val1)
		print("ITS 1111 FOR THE FIRST")
	end
	if CPUINST.check_add(val1) == 2 then
		val1 = CPUREG:FindFirstChild(val1).Value
	end
	
	if CPUINST.check_add(val2) == 1 then
		val2 = CPUINST.load(val2)
		print("ITS 1111 FOR THE SECOND")
	end
	if CPUINST.check_add(val2) == 2 then
		val2 = CPUREG:FindFirstChild(val2).Value
	end
	
	print(val1.." VALUES "..val2)
	
	if not tonumber(val1) or not tonumber(val2) then
		print("not tonumber "..val1.." "..val2)
		if not tonumber(val1) and not tonumber(val2) then
			if val1 == val2 then
				EFLAGS["ZF"] = 1
				return 1
			end
		else
			return "FLAG_FAIL"
		end
		return
	end
	
	local diff = tonumber(val1)-tonumber(val2)
	print(diff.." THIS IS THE DIFF WHILE COMPARING "..val1.." AND "..val2)
		
	if diff < 0 then
		print(diff.." THIS IS THE DIFF")
		EFLAGS["SF"] = 1
		return 0
	end
	if diff == 0 then
		EFLAGS["ZF"] = 1
		return 1
	end
	if diff > 0 then
		EFLAGS["ZF"] = 0
		EFLAGS["SF"] = 0
		return 2
	end
end


function CPUINST.je(memadd)
	print(EFLAGS)
	if EFLAGS["ZF"] == 1 then
		print("its a staaaarmaaaaaaaaaaan")
		return CPUINST.jmp(memadd)
	end
end

function CPUINST.jne(memadd)
	print(EFLAGS)
	if EFLAGS["ZF"] == 0 then

		print("ZF IS ZERO LTS GO=OOOOOOOOOOOOOOO")
		print(memadd.." THIS IS THE MEMADDDDD")
		return CPUINST.jmp(memadd)
	end
end

function CPUINST.jl(memadd)
	if EFLAGS["SF"] == 1 then
		print("SF IS ONE LTS GO=OOOOOOOOOOOOOOO")
		print(memadd.." THIS IS THE MEMADDDDD")
		return CPUINST.jmp(memadd)
	end
end

function CPUINST.jg(memadd)
	if EFLAGS["ZF"] == 0 and EFLAGS["SF"] == 0 then
		return CPUINST.jmp(memadd)
	end
end

function CPUINST.jmp(memadd)
--	print(memadd)
	if not CPUINST.to_decimal(memadd) then
		return
	end
	return CPUINST.to_hex(CPUINST.to_decimal(memadd))
end

function CPUINST.out(char, data_type)
	if data_type == 3 then
		if RAMSTOR:FindFirstChild(char) then
			char = RAMSTOR:FindFirstChild(char).data.Value
		end
	end
	if table.find(CPUINST.cpu_register, char) then
		
		char = CPUREG:FindFirstChild(char).Value
	end
	BIOS.showchar(char)
end

function CPUINST.call(func)
	local RAM_LOC = RAMSTOR:FindFirstChild(CPUINST.to_hex(CPUREG.esp.Value))
	local DATA_VALUE = RAM_LOC.data.Value
	print(DATA_VALUE)
	if func == "printf" then
		return CPUINST.out(DATA_VALUE)
	end
end

function CPUINST.push(value, data_type)
	local adress = CPUINST.check_add(value)
	if adress ~= 0 then
		if not table.find(CPUINST.cpu_register, value) then
			
			value = RAMSTOR:FindFirstChild(value).data.Value
		else
			value = CPUREG:FindFirstChild(value).Value
		end
	end
	print("a pretty neat value: "..value)
	
	CPUINST.db(value)
	CPUREG.esp.Value = ReplicatedStorage["RAM-LastSpace"].Value-1
	table.insert(stack, {value, CPUINST.to_hex(CPUREG.esp.Value)})
end


function CPUINST.pop(value)
	CPUREG.esp.Value += 1
	for i,v in pairs(stack) do
		--print(v)
		if v[1] == value then
			local RAM_LOC = RAMSTOR:FindFirstChild(v[2])
			RAM_LOC.data.Value = ""
			RAM_LOC.data_type.Value = 1
			table.remove(stack, i)
		end
	end
end


function CPUINST.inp(val)
	ReplicatedStorage["RAM-Storage"]:FindFirstChild(ReplicatedStorage["RAM-LastSpace"].Value).data.Value = val
end

return CPUINST
