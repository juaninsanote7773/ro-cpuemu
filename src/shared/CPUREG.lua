local CPUREG = {}
CPUREG = {	
	["eax"] = 0,
	["ebx"] = 0,
	["ecx"] = 0,
	["edx"] = 0,
	["ax"] = 0,
	["ah"] = 0,
	["al"] = 0,
	["bx"] = 0,
	["bh"] = 0,
	["bl"] = 0,
	["cx"] = 0,
	["ch"] = 0,
	["cl"] = 0,
	["dx"] = 0,
	["dh"] = 0,
	["dl"] = 0,
	["esi"] = 0,
	["edi"] = 0,
	["esp"] = 0,
	["ebp"] = 0,
	["eip"] = 0
}

function CPUREG.write(add, value)
	CPUREG[add] = value
end

function CPUREG.read(add)
	--print(CPUREG[add].." THIS IS THE VALUE FROM THE REGISTER")
	return CPUREG[add]
end

return CPUREG
