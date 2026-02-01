local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ESPEnabled = false
local ESPObjects = {}

local function getPlayerRole(player)
	if player:FindFirstChild("Role") then
		return player.Role.Value
	end
	return "Netral"
end

local function getColor(role)
	if role == "Seeker" then
		return Color3.fromRGB(255,0,0)
	elseif role == "Hider" then
		return Color3.fromRGB(0,255,0)
	else
		return Color3.fromRGB(0,0,255)
	end
end

local function createESP(model, player)
	if ESPObjects[model] then return end
	if not model:FindFirstChild("HumanoidRootPart") then return end

	local role = getPlayerRole(player)
	local color = getColor(role)

	local highlight = Instance.new("Highlight")
	highlight.Adornee = model
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Enabled = ESPEnabled
	highlight.Parent = model

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,120,0,30)
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
	label.TextColor3 = color
	label.Text = player.Name
	label.Parent = billboard

	ESPObjects[model] = {highlight, billboard, player}
end

local function updateESP()
	for model,data in pairs(ESPObjects) do
		if data[1] and data[2] and data[3] then
			local role = getPlayerRole(data[3])
			local color = getColor(role)
			data[1].FillColor = color
			data[1].OutlineColor = color
			data[2].Enabled = ESPEnabled
			data[1].Enabled = ESPEnabled
			data[2].TextLabel.TextColor3 = color
		end
	end
end

local function toggleESP()
	ESPEnabled = not ESPEnabled
	updateESP()
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

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,80,0,35)
button.Position = UDim2.new(1,-90,1,-120)
button.Text = "ESP"
button.BackgroundColor3 = Color3.fromRGB(0,170,0)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.TextScaled = true
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,10)
corner.Parent = button

button.MouseButton1Click:Connect(function()
	toggleESP()
	if ESPEnabled then
		button.BackgroundColor3 = Color3.fromRGB(0,170,0)
	else
		button.BackgroundColor3 = Color3.fromRGB(170,0,0)
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
