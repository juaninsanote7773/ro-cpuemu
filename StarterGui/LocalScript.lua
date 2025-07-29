local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

UserInputService.InputBegan:Connect(function(input)
	ReplicatedStorage.Input:FireServer(input.KeyCode)
end)