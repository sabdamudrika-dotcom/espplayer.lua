local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local DEVELOPER_USERID = LocalPlayer.UserId
local ESPEnabled = true
local ESPObjects = {}

if not RunService:IsStudio() and LocalPlayer.UserId ~= DEVELOPER_USERID then
	return
end

local function createESP(model, displayName)
	if ESPObjects[model] then return end
	if not model:FindFirstChild("HumanoidRootPart") then return end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = model
	highlight.FillColor = Color3.fromRGB(0,255,0)
	highlight.OutlineColor = Color3.fromRGB(0,255,0)
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Enabled = ESPEnabled
	highlight.Parent = model

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,130,0,40)
	billboard.StudsOffset = Vector3.new(0,3,0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
	billboard.Enabled = ESPEnabled
	billboard.Parent = model

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1,0,1,0)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.TextStrokeTransparency = 0
	text.TextColor3 = Color3.fromRGB(255,255,255)
	text.Text = displayName
	text.Parent = billboard

	ESPObjects[model] = {highlight, billboard}
end

local function toggleESP()
	ESPEnabled = not ESPEnabled
	for _,v in pairs(ESPObjects) do
		v[1].Enabled = ESPEnabled
		v[2].Enabled = ESPEnabled
	end
end

local function setupPlayer(player)
	if player == LocalPlayer then return end
	if player.Character then
		createESP(player.Character, player.Name)
	end
	player.CharacterAdded:Connect(function(char)
		task.wait(1)
		createESP(char, player.Name)
	end)
end

for _,p in pairs(Players:GetPlayers()) do
	setupPlayer(p)
end

Players.PlayerAdded:Connect(setupPlayer)

for _,m in pairs(workspace:GetChildren()) do
	if m:IsA("Model") and m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) then
		createESP(m, m.Name)
	end
end

workspace.ChildAdded:Connect(function(m)
	if m:IsA("Model") and m:FindFirstChild("Humanoid") then
		task.wait(1)
		if not Players:GetPlayerFromCharacter(m) then
			createESP(m, m.Name)
		end
	end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,90,0,42)
button.Position = UDim2.new(1,-110,1,-70)
button.Text = "ESP ON"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0,180,0)
button.BackgroundTransparency = 0.15
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = button

button.MouseButton1Click:Connect(function()
	toggleESP()
	local goal = {}
	if ESPEnabled then
		button.Text = "ESP ON"
		goal.BackgroundColor3 = Color3.fromRGB(0,180,0)
	else
		button.Text = "ESP OFF"
		goal.BackgroundColor3 = Color3.fromRGB(180,0,0)
	end
	TweenService:Create(button, TweenInfo.new(0.2), goal):Play()
end)
