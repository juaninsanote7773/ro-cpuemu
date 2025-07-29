local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root_directory = ReplicatedStorage.SysRoot.Value

local FILE = {}

local separator = "/"

function FILE.open(path)
	local path_split = string.split(path, separator)
	print(path_split)
	local file
	local parent = root_directory
	for i = 2, #path_split do
		local v = path_split[i]
		if parent then
			print(v)
			file = parent:FindFirstChild(v)
		end
		parent = file
	end
	print(file)
	return require(file)
end

return FILE