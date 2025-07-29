local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local RAM = require(ReplicatedStorage.RAM)
local CPUINST = require(ReplicatedStorage.CPUINST)
local ASM = require(ReplicatedStorage.ASM)
local CLANG = require(ReplicatedStorage.CLANG)
local DISPLAY = require(ReplicatedStorage.DISPLAY)
local PROCESS = require(ReplicatedStorage.PROCESS)
local BIOS = require(ReplicatedStorage.BIOS)
local FILE = require(ReplicatedStorage.FILE)

RAM.generate()
--ASM.compile()
DISPLAY.generate_pix()

local debug_mode = false

local asm_script = {
	--"jmp $" if someone gets to bring this back, it will be monumental
	"times 500 db 0", --for the next 497 data adresses, define "byte" zero (why such a specific number? because i was too lazy to insert the $$ pointer, i mean i could but eh)
	"db 0x55aa", --define the current "byte" as the boot signature, for the BIOS to then lookup and find.
	"push $", --misc, just testing stuff with the stack and calls
	"call printf"
}

local asm_script2 = 
	[[

biosclear
mov @0x55 3
mov eax 3

jmp prettycoollabel
	
label:
push 'Hello'
call printf
pop 'Hello'
push 'World!'
call printf
pop 'World!'
	
prettycoollabel:
push 'a'
pop 'a'
cmp @0x55 eax
je label

]]


local asm_script3 = {
	--"biosclear",
	"mov eax 1",
	"mov ebx 1350",
	"mov @0x25F ''",
	"jmp label",
	"label:",
		"push 'a'",
		"inc eax",
		"int 0x16",
		"cat ecx al",
		"push al",
		"call printf",
		"pop al",
	--	"biosclear 'a'",

		"cmp eax ebx",
		"jl label",
}



local c_script = {
	"int a = 3",
	".biosclear()",
	"void main()",
	"{",
		"@0x1A = 0", --the compiler rn:
		"@0x1B = 0", --the compiler rn:
		"@0x1A = 1",
		"@0x1B = 1",

		--[[
		"@0x25A = '%s'",
		"printf(@0x25A)",
		"@0x25A = '\nOS'",
		"@0x25B = '%s'",
		"@0x25C = 'KERNEL'",

		"printf(@0x25A)",
		"printf(@0x25B)",
		"printf(@0x25C)",
		]]


		"while (@0x1A == @0x1B)",
		"{",
		
			"printf('\n')",

			"printf('sysuser')",
			"printf('%s')",
			"printf('#')",
			"printf('%s')",
			
			"waitinp()",
			
			"printf(al)",
			--"strcat(@0x25F al)",
			
			"if (ah == 99)",
			"{",
				"printf('\n')",
				"printf('CLEARING')",
				".biosclear()",
			"}",
			"if (ah != 99)",
			"{",
				"printf('\n')",
				"waitinp()",
			"}",
			
			--[["if (ah == 119)",
			"{",
				"printf('\n')",

				"printf('Upselect')",
			"}",
			"if (ah < 83)",
			"{",
				"printf('\n')",

				"printf('Downselect')",
			"}",]]
			
			
		"}",
	"}"
}



local clock_tick = 0


function clear_ram()
	for i,v in pairs(ReplicatedStorage["RAM-Storage"]:GetChildren()) do
		v.data.Value = ""
		v.data_type.Value = 1
	end
	ReplicatedStorage["RAM-LastSpace"].Value = 1
end

function perform_inst(func, param1, param2, param3, out)
	if func and param1 and param2 and param3 then
		BIOS.output_debug(debug_mode,func.." "..param1.." "..param2.." "..param3)
	end
	if func == "0x01" then
		return CPUINST.load(param2)
	end
	if func == "0x02" then
		CPUINST.add(param1, param2)
	end
	if func == "0x03" then
		CPUINST.db(param2)
	end
	if func == "0x04" then
		return CPUINST.set(param1, param2)
	end
	if func == "0x05" then
		return CPUINST.cmp(param1, param2)
	end
	if func == "0x06" then
		return CPUINST.jmp(param2)
	end
	if func == "0x07" then
		print("calling")
		return CPUINST.call(param2)
	end
	if func == "0x09" then
		return BIOS.clear()
	end
	if func == "0x0A" then
		return CPUINST.push(param2, param3)
	end
	if func == "0x0B" then
		return CPUINST.pop(param2)
	end
	if func == "0x0C" then
		return CPUINST.je(param2)
	end
	if func == "0x0D" then
		return CPUINST.jl(param2)
	end
	if func == "0x0E" then
		return CPUINST.jg(param2)
	end
	if func == "0x0F" then
		return CPUINST.inc(param2)
	end
	if func == "0x10" then
		return CPUINST.dec(param2)
	end
	if func == "0x11" then
		return BIOS.interrupt(param2)
	end
	if func == "0x12" then
		return CPUINST.cat(param1, param2)
	end
	if func == "0x13" then
		return CPUINST.jne(param2)
	end
	return "nooutput"
end

local BIOSSTARTED = false

function iterate_ram()
	local last_out = 0
	local RAMSTOR = ReplicatedStorage["RAM-Storage"]
	
	local last_func = ""
	
	local last_data = 0
	local last_data_type = 0
	local last_data_memadd = 0	
	
	local time_count = 0
	local time_funcFound = false
	
	local i = 0
	local last_definition = 0
	local current_label = 0
	local label_processing = 0
	while i < #RAMSTOR:GetChildren() do
		task.wait()
		i += 1
		--print(CPUINST.to_hex(i))
		local data = RAMSTOR:FindFirstChild(CPUINST.to_hex(i))
		local value = data.data.Value
		local data_type = data.data_type.Value	
				
		--handle BIOS default functions
		
		--print(data_type.." DATA TYPE "..value.." VALUE")

		if data_type == 4 then
		--	print(value.." THIS IS THE VALUE HEEY LOOK AT MEEEE ")
			if tonumber(value) then
				label_processing = value
				--print(value.." "..current_label)
			end
		end
		
		if tonumber(label_processing) ~= tonumber(current_label) then
			--print("LABEL_NOTEQUAL: "..label_processing.." "..current_label)
			BIOS.output_debug(debug_mode, "LB_NOTEQUAL: "..label_processing.." "..current_label)
			continue
		end
		
		if last_func == "0x09" then
		--	print("BIOS clear")
			perform_inst("0x09")
		end
		
		if data_type ~= 0 then
			if last_func then
				if last_func == "0x08" then
					--print("THEN HOW DOES THIS NOT WORK "..value)
					time_count = tonumber(value)
					--print(time_count)
				else		
					local proceed = true
					--print(last_func.. " "..last_data.. " "..value.. " DECOMPFUNC")

					if value == "" then
						proceed = false			
					end
					
					--print("aaa0")
					
					if proceed == true then
						local output = perform_inst(last_func, last_data, value, data_type, last_out)

						if table.find(ASM.jumps, last_func) and output ~= nil then
						--	print("JUMPING TO: "..output)
						--	print(output.." THIS IS THE OUTPUUUUT LOOOK")
							i = tonumber(output) --num initialization
							local data = RAMSTOR:FindFirstChild(CPUINST.to_hex(i)).data.Value
							
							--print(data.." THIS IS THE JUMP DATA")
							if i <= 0 then
								i = 1
							end
							current_label = output
							last_func = ""
							last_data = ""
							last_data_memadd = ""
							value = ""
						--	print(i.." THIS IS THE IIII")
						end

						--print("aaa1")

						if output ~= "nooutput" and output ~= "FLAG_FAIL" and output ~= nil then
							--print("aaa2")

							--print(output.." "..last_func)
						--	print(i.." "..last_data_memadd)

							last_out = output
							last_func = ""
							last_data = ""
							last_data_memadd = ""
							value = ""
						end
					end
				end
			end
		end
		
		if time_count > 0 and last_func ~= "0x08" and data_type ~= 0 then
			for i = 1, time_count do
--				print(last_func)
				local output = perform_inst(last_func, last_data, value)
			end
			time_count = 0
		end
		
		--print(value.." "..data_type)
		if data_type ~= 0 and value ~= ""  then
	--		print(value)
			last_data = value
			last_data_type = data_type
			last_data_memadd = i
		end
		

		if data_type == 0 and value ~= "" then
			last_func = value
			if time_count > 0 then
				time_funcFound = true
			end
		end
		time_funcFound = false
	end
end

local clock_steps = 1500

RunService.Heartbeat:Connect(function(dt)
	clock_steps += dt*60
	if clock_steps >= 1500 then
		dt = 0
		if BIOSSTARTED == false then
			--print("a")
			BIOSSTARTED = true
			BIOS.start()
		end
		--iterate_ram()
	end
end)


--[[local compiled = FILE.open("C:/Root/bootsector.bin")
compiled = compiled.file_data
PROCESS.start_comp(compiled)
iterate_ram()
clear_ram()

task.wait()
]]

--[[
local compiled3 = FILE.open("C:/System32/kernel.bin")  ########
compiled3 = compiled3.file_data                        THOSE BINARIES ARE IN THE RBXL FILE
PROCESS.start_comp(compiled3)
]]

--[[

local compiled = ASM.compile(asm_script)
PROCESS.start_comp(compiled)

task.wait()
iterate_ram()


local compiled3 = CLANG.compile(c_script)
PROCESS.start_comp(compiled3)

task.wait()
iterate_ram()

]]

local compiled = ASM.compile(asm_script2)
PROCESS.start_comp(compiled)

task.wait(1)
iterate_ram()


--local compiled3 = CLANG.compile(c_script)
--PROCESS.start_comp(compiled3)

--task.wait()
--iterate_ram()