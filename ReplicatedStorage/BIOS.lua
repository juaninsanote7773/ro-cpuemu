local ReplicatedStorage = game:GetService("ReplicatedStorage")

--local RAMSTOR = ReplicatedStorage["RAM-Storage"]
local RAM = require(ReplicatedStorage["RAM"])
local CPUREG = ReplicatedStorage["CPU-Register"]
local DISPLAY = require(ReplicatedStorage.DISPLAY)

local BIOS = {}

function BIOS.showchar(c)
	DISPLAY.show_char(c, "BIOS")
end


function BIOS.clear()
	DISPLAY.bios_clear()
end

local found_input = false

function BIOS.start()
	BIOS.showchar("---------------------------\n")
	BIOS.showchar("# RO BIOS v 1.0		  #\n")
	BIOS.showchar("---------------------------\n")
	--print("starting")
	--find boot sector
	while true do
		task.wait(1)
		if RAM[512] == "0x55aa" then
			--print("found")
			BIOS.showchar("\nBooting from Hard Disk...")
			break
		end
	end
end

ReplicatedStorage.Input.OnServerEvent:Connect(function(p, keycode)
	--print("FOUNDDD")
	if tonumber(keycode.Value) then
		CPUREG.ah.Value = tostring(keycode.Value)
		CPUREG.al.Value = string.char(CPUREG.ah.Value)
		found_input = true
	end
end)

function BIOS.interrupt(code)
	if code == "0x16" then
		found_input = false
		while found_input == false do
			task.wait()
		end
	end
end

function BIOS.output_debug(deb_mode, printing)
	if deb_mode == true then
		BIOS.showchar("\n<b>debug</b> # "..printing)
	end
end

return BIOS
