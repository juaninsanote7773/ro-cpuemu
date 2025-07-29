local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DISPLAY = {}

local width = 64
local aspect_ratio = 4/3
local height = width/aspect_ratio

local display_part = workspace.display

function DISPLAY.bios_clear()
	display_part.SurfaceGui.BIOS.Text = ""
end

function DISPLAY.show_char(char, char_type)
	if char_type == "BIOS" then
		display_part.SurfaceGui.BIOS.Text = display_part.SurfaceGui.BIOS.Text..char
	end
end

function DISPLAY.generate_pix()
	for i,v in pairs(display_part.SurfaceGui.Frame:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	display_part.SurfaceGui.Frame.UIGridLayout.CellSize = UDim2.fromScale(1/width, 1/height)
	display_part.SurfaceGui.Frame.Size = UDim2.fromScale(1, 1/aspect_ratio)
	display_part.SurfaceGui.BIOS.Size = UDim2.fromScale(1, 1/aspect_ratio)
	for x = 1, width do
		for y = 1, height do
			local pixel = ReplicatedStorage["pix-temp"]:Clone()
			pixel.Parent = display_part.SurfaceGui.Frame
			pixel.Name = x.." "..y
			pixel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end
	end
end

return DISPLAY
