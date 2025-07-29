local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CPUINST = require(ReplicatedStorage.CPUINST)

local RAM = require(ReplicatedStorage.RAM)

local PROCESS = {}

function PROCESS.start_comp(compiled)
	local origin = 0
	local def_origin = false
	for i,v in pairs(compiled) do
		local data = v[1]
		local data_type = v[2]
		
		if data == "0x14" then
			def_origin = true
			continue
		end
		
		if def_origin == true then
			def_origin = false
			origin = tonumber(data)
			print(origin.." THIS IS THE ORIGIN")
			continue
		end
		
		if data_type == 0 then
			CPUINST.set(ReplicatedStorage["RAM-LastSpace"].Value+origin, data, data_type)
		end
		if data_type == 1 then
			CPUINST.set(ReplicatedStorage["RAM-LastSpace"].Value+origin, data, data_type)
		end
		if data_type == 2 then
			CPUINST.set(ReplicatedStorage["RAM-LastSpace"].Value+origin, data, data_type)
		end
		if data_type == 3 then
			CPUINST.set(ReplicatedStorage["RAM-LastSpace"].Value+origin, data, data_type)
		end
		if data_type == 4 then
			CPUINST.set(ReplicatedStorage["RAM-LastSpace"].Value+origin, data, data_type)
		end
		
	end
	print(RAM.RAMSTOR)

end

return PROCESS
