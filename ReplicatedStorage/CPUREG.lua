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
	["cx"] = 0,
	["dx"] = 0,
	["esp"] = 0
}

function CPUREG.write(add, value)
	CPUREG[add] = value
end

function CPUREG.read(add)
	--print(CPUREG[add].." THIS IS THE VALUE FROM THE REGISTER")
	return CPUREG[add]
end

return CPUREG
