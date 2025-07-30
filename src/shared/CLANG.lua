--[[
	C language!
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CPUINST = require(ReplicatedStorage.CPUINST)
local ASM = require(ReplicatedStorage.ASM)
local RAM = require(ReplicatedStorage.RAM)
--local RAMSTOR = ReplicatedStorage["RAM-Storage"]

local CLANG = {}

local translated = {}

local compiled = {}

local func_translate = {
	{"printf", "call printf"},
	{".biosclear", "biosclear 'a'"},
	{"waitinp", "int 0x16"},
	{"strcat", "cat '' ''"}
}

local func_conditional = {"je", "jl", "jg", "jne"}
local conditional_checks = {"==", "<", ">", "!="}

function CLANG.compile(c_script)
	if type(c_script) == "string" then
		c_script = string.split(c_script, '\n')
	end
	print(c_script)
	compiled = {}
	translated = {}
	local functions = {}
	local variable_routes = {}
	local len = 0
	
	local all_defs = {}
	local code_depth = 0

	--local 
	for i,v in pairs(c_script) do
		local line = v:gsub("%(", " ( "):gsub("%)", " ) ")
		local split = string.split(line, " ")
		
		local translate_line = ""
		
		local last_split = ""
		local defining = false
		local var_defining
		local data_type
		local defining_function = false
		
		local defining_loop = false
		local loop_type = 0
		
		local memadd = 0
		local main_def = 0
		
		local conditional_type = 0
		
		local defining_conditional = false
		local add_buffer = ""
				
		--token processor
		for itoken, word in split do
			len += 1

			memadd = RAM.RAM_LASTSPACE+len-1
			
			--declaring variables
			--print(memadd)


			if word == "=" then
				var_defining, data_type = CPUINST.check_datatype(last_split)
				print(var_defining.." "..data_type)

				if data_type == 3 then
					memadd = var_defining
					print(memadd)
				end

				defining = true

				translate_line = "mov "..memadd .." "
				table.insert(variable_routes, {var_defining, memadd})
				print(variable_routes)
			end
			if defining == true and last_split == "=" then
				translate_line = translate_line..word
				print(translate_line)
			end
			
			
			--conditionals and loops

			if word == "while" then
				defining_loop = true
				loop_type = 1
			end
			
			
			if word == "if" then
				defining_conditional = true
			end
			
			if word == "==" then
				conditional_type = 1
			end
			
			if word == "<" then
				conditional_type = 2
			end
			
			if word == ">" then
				conditional_type = 3
			end
			
			if word == "!=" then
				conditional_type = 4
			end
			
--			print(word.." :dying_rose:")

			if defining_loop == true and last_split == "(" then
				translate_line = "cmp "..word
			end
			
			if defining_conditional == true and last_split == "(" then
				translate_line = "cmp "..word
			--	print(translate_line.." THIS IS THE TRANSLATE LINE :dying_rose:")
			end
			if conditional_type ~= 0 and table.find(conditional_checks, last_split) and word ~= ")" then
				translate_line = translate_line.." "..word
				print(translate_line.." THIS IS THE TRANSLATE LINE")
			end
				
			--function defs

			local func

			if word == "void" then
				print("def func")
				defining_function = true
			end
			
			if word == "(" and defining_function == true then
				func = split[itoken-1]
				word = func
				data_type = 4
				if word == "main" then
					main_def = #translated
					table.insert(translated, "jmp main")
				end
				table.insert(functions, func)
				print(word.." "..data_type)
				translate_line = word..":"
			end
			
			
			--LB_END PROBABLY NEEDED LATER
			--if word == "}" then
			--	translate_line = "LB_END"
			--end
			
			if word == "{" then
				code_depth += 1
			end
			 
			if word == "}" then
				for _, definition in pairs(all_defs) do
					if definition[1] == code_depth then
						table.insert(translated, definition[4])
						table.insert(translated, definition[3].." "..definition[2])
					end
				end
				
				code_depth -= 1
			end
			
			--calls
			
			local call
			
			if word == "(" and defining_function == false and defining_conditional == false and defining_loop == false then
				call = split[itoken-1] 
				
				local params = {}
				for i_2 = itoken+1, #split do
					if split[i_2] ~= ")" then
						table.insert(params, split[i_2])
					else
						break
					end
				end
				
				local found_translateline = false

				for _, translate in pairs(func_translate) do
					if translate[1] == call then
						found_translateline = true
						translate_line = translate[2]
					end
				end
				
				if found_translateline == false then
					for _, func in pairs(functions) do
						print(func.." this is a function")
						if call == func then
							translate_line = "jmp "..call
						end
					end
				end
				
				local push_lines = {}
				for _, param in pairs(params) do
					table.insert(push_lines, "push "..param)
					add_buffer = "pop "..param
				end
				for _, push_line in pairs(push_lines) do
					table.insert(translated, push_line)
				end
			end
			

			--[[
			local call_param
			local split_2 = string.split(word, "(")
			if #split_2 > 1 then
				split_2[2] = string.split(split_2[2], ")")[1]

				local first_split = split_2[1]
				local second_split = split_2[2]

				for _, translate in pairs(func_translate) do
					if translate[1] == first_split then
						translate_line = translate[2]
					end
				end

				translate_line = translate_line.." "..second_split
				print(translate_line)
			end
			]]

			--print(split_2)
			
			if data_type == 4 then
				defining_function = false
			end
			
			print(data_type)
			last_split = word
		end
		table.insert(translated, translate_line)
		table.insert(translated, add_buffer)
		add_buffer = ""
		if defining_loop == true then
			table.insert(translated, func_conditional[conditional_type].." ".."loop_"..i)
			table.insert(translated, "loop_"..i..":")
			table.insert(all_defs, {code_depth, "loop_"..i, func_conditional[conditional_type], translate_line})
		end
		if defining_conditional == true then
			table.insert(translated, func_conditional[conditional_type].." ".."if_"..i)
			table.insert(translated, "if_"..i..":")
		end
	end

	print(translated)
	--print(variable_routes)
	
	compiled = ASM.compile(translated)
	print(compiled)
	
	return compiled
end

return CLANG
