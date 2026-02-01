local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ESPEnabled = false
local NoClipEnabled = false
local GodEnabled = false
local ESPObjects = {}

local function getPlayerRole(player)
	if player:FindFirstChild("Role") then
		return player.Role.Value
	end
	return "Netral"
end

local function getColor(player)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		local role = getPlayerRole(player)
		if role == "Seeker" then
			return Color3.fromRGB(255,0,0)
		elseif role == "Hider" then
			return Color3.fromRGB(0,255,0)
		end
	end
	return Color3.fromRGB(0,0,255)
end

local function createESP(model, player)
	if ESPObjects[model] then return end
	if not model:FindFirstChild("HumanoidRootPart") then return end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = model
	highlight.FillColor = getColor(player)
	highlight.OutlineColor = getColor(player)
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Enabled = ESPEnabled
	highlight.Parent = model

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,80,0,20)
	billboard.StudsOffset = Vector3.new(0,3,0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
	billboard.Enabled = ESPEnabled
	billboard.Parent = model

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextStrokeTransparency = 0
	label.TextColor3 = getColor(player)
	label.Text = player.Name
	label.TextSize = 14
	label.Parent = billboard

	ESPObjects[model] = {highlight, billboard, player}
end

local function updateESP()
	for model,data in pairs(ESPObjects) do
		if data[1] and data[2] and data[3] then
			data[1].Enabled = ESPEnabled
			data[2].Enabled = ESPEnabled
			local c = getColor(data[3])
			data[1].FillColor = c
			data[1].OutlineColor = c
			data[2].TextLabel.TextColor3 = c
		end
	end
end

local function setupPlayer(player)
	if player.Character then
		createESP(player.Character, player)
	end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		createESP(char, player)
	end)
end

for _,p in pairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then
		setupPlayer(p)
	end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then
		setupPlayer(p)
	end
end)

workspace.ChildAdded:Connect(function(obj)
	if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
		local fakePlayer = {Name=obj.Name, Role=Instance.new("StringValue")}
		fakePlayer.Role.Value = "Netral"
		createESP(obj,fakePlayer)
	end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,150,0,60)
frame.Position = UDim2.new(0,50,0,50)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.BackgroundTransparency = 0.3
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0,140,0,18)
espButton.Position = UDim2.new(0,5,0,5)
espButton.Text = "ESP"
espButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
espButton.TextColor3 = Color3.fromRGB(255,255,255)
espButton.Parent = frame

local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(0,140,0,18)
noclipButton.Position = UDim2.new(0,5,0,22)
noclipButton.Text = "NoClip"
noclipButton.BackgroundColor3 = Color3.fromRGB(0,0,170)
noclipButton.TextColor3 = Color3.fromRGB(255,255,255)
noclipButton.Parent = frame

local godButton = Instance.new("TextButton")
godButton.Size = UDim2.new(0,140,0,18)
godButton.Position = UDim2.new(0,5,0,39)
godButton.Text = "GodMode"
godButton.BackgroundColor3 = Color3.fromRGB(170,0,0)
godButton.TextColor3 = Color3.fromRGB(255,255,255)
godButton.Parent = frame

espButton.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	updateESP()
end)

noclipButton.MouseButton1Click:Connect(function()
	NoClipEnabled = not NoClipEnabled
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local part = LocalPlayer.Character.HumanoidRootPart
		if NoClipEnabled then
			for _,c in pairs(LocalPlayer.Character:GetDescendants()) do
				if c:IsA("BasePart") then
					c.CanCollide = false
				end
			end
		else
			for _,c in pairs(LocalPlayer.Character:GetDescendants()) do
				if c:IsA("BasePart") then
					c.CanCollide = true
				end
			end
		end
	end
end)

godButton.MouseButton1Click:Connect(function()
	GodEnabled = not GodEnabled
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.MaxHealth = math.huge
		if GodEnabled then
			LocalPlayer.Character.Humanoid.Health = math.huge
		else
			LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
		end
	end
end)

spawn(function()
	while true do
		task.wait(0.5)
		if ESPEnabled then
			updateESP()
		end
	end
end)
