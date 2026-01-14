--// ADMIN PANEL LOCAL SCRIPT
--// Nome do painel: Admin

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Atualiza character ao respawn
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end)

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 230)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundColor3 = Color3.fromRGB(20,20,20)
Title.Text = "Admin"
Title.TextColor3 = Color3.fromRGB(0,255,0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Parent = Frame

--// DRAG
local dragging, dragInput, dragStart, startPos

Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
	end
end)

Title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--// FUNÇÃO BOTÃO
local function createButton(text, posY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9,0,0,35)
	btn.Position = UDim2.new(0.05,0,0,posY)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = text .. ": OFF"
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.Parent = Frame
	Instance.new("UICorner", btn)
	return btn
end

local speedBtn = createButton("Speed", 50)
local flyBtn = createButton("Fly", 95)
local espBtn = createButton("ESP", 140)
local noclipBtn = createButton("Noclip", 185)

--// SPEED
local speedOn = false
speedBtn.MouseButton1Click:Connect(function()
	speedOn = not speedOn
	humanoid.WalkSpeed = speedOn and 50 or 16
	speedBtn.Text = "Speed: " .. (speedOn and "ON" or "OFF")
end)

--// FLY
local flyOn = false
local bodyGyro, bodyVelocity

flyBtn.MouseButton1Click:Connect(function()
	flyOn = not flyOn
	flyBtn.Text = "Fly: " .. (flyOn and "ON" or "OFF")

	if flyOn then
		bodyGyro = Instance.new("BodyGyro", character.HumanoidRootPart)
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
		bodyGyro.CFrame = character.HumanoidRootPart.CFrame

		bodyVelocity = Instance.new("BodyVelocity", character.HumanoidRootPart)
		bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)

		RunService.RenderStepped:Connect(function()
			if flyOn then
				bodyGyro.CFrame = workspace.CurrentCamera.CFrame
				bodyVelocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * 60
			end
		end)
	else
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVelocity then bodyVelocity:Destroy() end
	end
end)

--// ESP VERDE
local espOn = false
local espObjects = {}

local function addESP(plr)
	if plr ~= player and plr.Character then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(0,255,0)
		highlight.OutlineColor = Color3.fromRGB(0,255,0)
		highlight.Adornee = plr.Character
		highlight.Parent = plr.Character
		espObjects[plr] = highlight
	end
end

espBtn.MouseButton1Click:Connect(function()
	espOn = not espOn
	espBtn.Text = "ESP: " .. (espOn and "ON" or "OFF")

	if espOn then
		for _,plr in pairs(Players:GetPlayers()) do
			addESP(plr)
		end
	else
		for _,h in pairs(espObjects) do
			if h then h:Destroy() end
		end
		espObjects = {}
	end
end)

--// NOCLIP
local noclipOn = false
noclipBtn.MouseButton1Click:Connect(function()
	noclipOn = not noclipOn
	noclipBtn.Text = "Noclip: " .. (noclipOn and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
	if noclipOn and character then
		for _,v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)
