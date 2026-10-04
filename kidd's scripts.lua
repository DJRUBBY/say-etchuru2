local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =========================================
-- CONFIGURATION & FILE SAVING SYSTEM
-- =========================================
local CONFIG_FILE = "KiddsBeaniesConfig.json"

local MIN_SPEED = 25
local MAX_SPEED = 55
local baseSpeed = 55
local carrySpeed = 45
local targetFOV = 70 
local isEnabled = false
local antiBeeEnabled = false
local baseStatusEnabled = true
local carryStatusEnabled = true
local potionKey = Enum.KeyCode.Q 
local speedToggleKey = Enum.KeyCode.E 

local function saveConfig()
	if not writefile then return end
	local data = {
		baseSpeed = baseSpeed,
		carrySpeed = carrySpeed,
		targetFOV = targetFOV,
		isEnabled = isEnabled,
		antiBeeEnabled = antiBeeEnabled,
		baseStatusEnabled = baseStatusEnabled,
		carryStatusEnabled = carryStatusEnabled,
		potionKey = potionKey.Name,
		speedToggleKey = speedToggleKey.Name
	}
	pcall(function()
		writefile(CONFIG_FILE, HttpService:JSONEncode(data))
	end)
end

local function loadConfig()
	if not readfile or not isfile or not isfile(CONFIG_FILE) then return end
	pcall(function()
		local content = readfile(CONFIG_FILE)
		local data = HttpService:JSONDecode(content)
		if data then
			if data.baseSpeed then baseSpeed = math.clamp(data.baseSpeed, MIN_SPEED, MAX_SPEED) end
			if data.carrySpeed then carrySpeed = math.clamp(data.carrySpeed, MIN_SPEED, MAX_SPEED) end
			if data.targetFOV then targetFOV = math.clamp(data.targetFOV, 60, 120) end
			if data.isEnabled ~= nil then isEnabled = data.isEnabled end
			if data.antiBeeEnabled ~= nil then antiBeeEnabled = data.antiBeeEnabled end
			if data.baseStatusEnabled ~= nil then baseStatusEnabled = data.baseStatusEnabled end
			if data.carryStatusEnabled ~= nil then carryStatusEnabled = data.carryStatusEnabled end
			if data.potionKey then
				pcall(function() potionKey = Enum.KeyCode[data.potionKey] end)
			end
			if data.speedToggleKey then
				pcall(function() speedToggleKey = Enum.KeyCode[data.speedToggleKey] end)
			end
		end
	end)
end

loadConfig()

local customFont = Enum.Font.Cartoon

local targetParent = CoreGui
local success = pcall(function() local _ = CoreGui.Name end)
if not success then
	targetParent = LocalPlayer:WaitForChild("PlayerGui")
end

if targetParent:FindFirstChild("VelocitySpeedGui") then
	targetParent.VelocitySpeedGui:Destroy()
end
if targetParent:FindFirstChild("KiddsPingGui") then
	targetParent.KiddsPingGui:Destroy()
end
if targetParent:FindFirstChild("KiddsTopListGui") then
	targetParent.KiddsTopListGui:Destroy()
end

-- =========================================
-- UI CONSTRUCTION (MAIN GUI)
-- =========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VelocitySpeedGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetParent

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 440)
frame.Position = UDim2.new(1, -295, 0.4, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BackgroundTransparency = 0.5 
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 170, 255)
frameStroke.Thickness = 2.5
frameStroke.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "KIDD'S BEANIE METHOD ASSISTANT"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.BackgroundTransparency = 0.3
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = customFont
title.TextSize = 13
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- =========================================
-- UI CONSTRUCTION (PING GUI - TOP CORNER)
-- =========================================
local pingGui = Instance.new("ScreenGui")
pingGui.Name = "KiddsPingGui"
pingGui.ResetOnSpawn = false
pingGui.Parent = targetParent

local pingFrame = Instance.new("Frame")
pingFrame.Name = "PingFrame"
pingFrame.Size = UDim2.new(0, 160, 0, 45)
pingFrame.Position = UDim2.new(1, -235, 0, -35)
pingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
pingFrame.BackgroundTransparency = 0.5
pingFrame.BorderSizePixel = 0
pingFrame.Active = true
pingFrame.Draggable = true
pingFrame.Parent = pingGui

local pingFrameCorner = Instance.new("UICorner")
pingFrameCorner.CornerRadius = UDim.new(0, 12)
pingFrameCorner.Parent = pingFrame

local pingFrameStroke = Instance.new("UIStroke")
pingFrameStroke.Color = Color3.fromRGB(0, 170, 255)
pingFrameStroke.Thickness = 2.5
pingFrameStroke.Parent = pingFrame

local pingLabel = Instance.new("TextLabel")
pingLabel.Text = "PING: Calculating..."
pingLabel.Size = UDim2.new(1, 0, 1, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pingLabel.Font = customFont
pingLabel.TextSize = 14
pingLabel.Parent = pingFrame

-- =========================================
-- UI CONSTRUCTION (SEPARATE TOP LIST GUI)
-- =========================================
local topListGui = Instance.new("ScreenGui")
topListGui.Name = "KiddsTopListGui"
topListGui.ResetOnSpawn = false
topListGui.Parent = targetParent

local topListFrame = Instance.new("Frame")
topListFrame.Name = "TopListFrame"
topListFrame.Size = UDim2.new(0, 280, 0, 165)
topListFrame.Position = UDim2.new(1, -295, 0.4, -220)
topListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
topListFrame.BackgroundTransparency = 0.5
topListFrame.BorderSizePixel = 0
topListFrame.Active = true
topListFrame.Draggable = true
topListFrame.Parent = topListGui

local topListFrameCorner = Instance.new("UICorner")
topListFrameCorner.CornerRadius = UDim.new(0, 12)
topListFrameCorner.Parent = topListFrame

local topListFrameStroke = Instance.new("UIStroke")
topListFrameStroke.Color = Color3.fromRGB(0, 170, 255)
topListFrameStroke.Thickness = 2.5
topListFrameStroke.Parent = topListFrame

local topListTitle = Instance.new("TextLabel")
topListTitle.Text = "TOP BRAINROTS LEADERBOARD"
topListTitle.Size = UDim2.new(1, 0, 0, 32)
topListTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
topListTitle.BackgroundTransparency = 0.3
topListTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
topListTitle.Font = customFont
topListTitle.TextSize = 12
topListTitle.Parent = topListFrame

local topListTitleCorner = Instance.new("UICorner")
topListTitleCorner.CornerRadius = UDim.new(0, 12)
topListTitleCorner.Parent = topListTitle

local topListContent = Instance.new("ScrollingFrame")
topListContent.Size = UDim2.new(0.88, 0, 0.65, 0)
topListContent.Position = UDim2.new(0.06, 0, 0.28, 0)
topListContent.BackgroundTransparency = 1
topListContent.Visible = true
topListContent.CanvasSize = UDim2.new(0, 0, 0, 0)
topListContent.ScrollBarThickness = 4
topListContent.Parent = topListFrame

-- =========================================
-- CATEGORY NAVIGATION BUTTONS (MAIN GUI)
-- =========================================
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.88, 0, 0, 28)
tabContainer.Position = UDim2.new(0.06, 0, 0.08, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local stealingTabBtn = Instance.new("TextButton")
stealingTabBtn.Text = "STEALING"
stealingTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
stealingTabBtn.Position = UDim2.new(0, 0, 0, 0)
stealingTabBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
stealingTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealingTabBtn.Font = customFont
stealingTabBtn.TextSize = 12
stealingTabBtn.Parent = tabContainer

local stealingCorner = Instance.new("UICorner")
stealingCorner.CornerRadius = UDim.new(0, 6)
stealingCorner.Parent = stealingTabBtn

local visualTabBtn = Instance.new("TextButton")
visualTabBtn.Text = "VISUAL"
visualTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
visualTabBtn.Position = UDim2.new(0.52, 0, 0, 0)
visualTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
visualTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
visualTabBtn.Font = customFont
visualTabBtn.TextSize = 12
visualTabBtn.Parent = tabContainer

local visualCorner = Instance.new("UICorner")
visualCorner.CornerRadius = UDim.new(0, 6)
visualCorner.Parent = visualTabBtn

-- =========================================
-- CONTENT CONTAINERS
-- =========================================
local stealingContent = Instance.new("Frame")
stealingContent.Size = UDim2.new(1, 0, 0.78, 0)
stealingContent.Position = UDim2.new(0, 0, 0.15, 0)
stealingContent.BackgroundTransparency = 1
stealingContent.Visible = true
stealingContent.Parent = frame

local visualContent = Instance.new("Frame")
visualContent.Size = UDim2.new(1, 0, 0.78, 0)
visualContent.Position = UDim2.new(0, 0, 0.15, 0)
visualContent.BackgroundTransparency = 1
visualContent.Visible = false
visualContent.Parent = frame

-- =========================================
-- STEALING TAB ELEMENTS
-- =========================================
local baseLabel = Instance.new("TextLabel")
baseLabel.Text = "Base Speed: " .. tostring(baseSpeed)
baseLabel.Size = UDim2.new(1, 0, 0, 20)
baseLabel.Position = UDim2.new(0, 0, 0.02, 0)
baseLabel.BackgroundTransparency = 1
baseLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
baseLabel.Font = customFont
baseLabel.TextSize = 14
baseLabel.Parent = stealingContent

local baseTrack = Instance.new("Frame")
baseTrack.Size = UDim2.new(0.85, 0, 0, 8)
baseTrack.Position = UDim2.new(0.075, 0, 0.08, 0)
baseTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
baseTrack.BorderSizePixel = 0
baseTrack.Parent = stealingContent

local baseFill = Instance.new("Frame")
baseFill.Size = UDim2.new((baseSpeed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 1, 0)
baseFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
baseFill.BorderSizePixel = 0
baseFill.Parent = baseTrack

local baseKnob = Instance.new("TextButton")
baseKnob.Text = ""
baseKnob.Size = UDim2.new(0, 16, 0, 16)
baseKnob.AnchorPoint = Vector2.new(0.5, 0.5)
baseKnob.Position = UDim2.new((baseSpeed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 0.5, 0)
baseKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
baseKnob.Parent = baseTrack

local baseStatusBtn = Instance.new("TextButton")
baseStatusBtn.Text = baseStatusEnabled and "BASE STATUS: ON" or "BASE STATUS: OFF"
baseStatusBtn.Size = UDim2.new(0.85, 0, 0, 22)
baseStatusBtn.Position = UDim2.new(0.075, 0, 0.14, 0)
baseStatusBtn.BackgroundColor3 = baseStatusEnabled and Color3.fromRGB(40, 170, 80) or Color3.fromRGB(180, 50, 50)
baseStatusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
baseStatusBtn.Font = customFont
baseStatusBtn.TextSize = 12
baseStatusBtn.Parent = stealingContent

local baseStatusCorner = Instance.new("UICorner")
baseStatusCorner.CornerRadius = UDim.new(0, 6)
baseStatusCorner.Parent = baseStatusBtn

local carryLabel = Instance.new("TextLabel")
carryLabel.Text = "Carry Speed: " .. tostring(carrySpeed)
carryLabel.Size = UDim2.new(1, 0, 0, 20)
carryLabel.Position = UDim2.new(0, 0, 0.23, 0)
carryLabel.BackgroundTransparency = 1
carryLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
carryLabel.Font = customFont
carryLabel.TextSize = 14
carryLabel.Parent = stealingContent

local carryTrack = Instance.new("Frame")
carryTrack.Size = UDim2.new(0.85, 0, 0, 8)
carryTrack.Position = UDim2.new(0.075, 0, 0.29, 0)
carryTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
carryTrack.BorderSizePixel = 0
carryTrack.Parent = stealingContent

local carryFill = Instance.new("Frame")
carryFill.Size = UDim2.new((carrySpeed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 1, 0)
carryFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
carryFill.BorderSizePixel = 0
carryFill.Parent = carryTrack

local carryKnob = Instance.new("TextButton")
carryKnob.Text = ""
carryKnob.Size = UDim2.new(0, 16, 0, 16)
carryKnob.AnchorPoint = Vector2.new(0.5, 0.5)
carryKnob.Position = UDim2.new((carrySpeed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 0.5, 0)
carryKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
carryKnob.Parent = carryTrack

local carryStatusBtn = Instance.new("TextButton")
carryStatusBtn.Text = carryStatusEnabled and "CARRY STATUS: ON" or "CARRY STATUS: OFF"
carryStatusBtn.Size = UDim2.new(0.85, 0, 0, 22)
carryStatusBtn.Position = UDim2.new(0.075, 0, 0.35, 0)
carryStatusBtn.BackgroundColor3 = carryStatusEnabled and Color3.fromRGB(40, 170, 80) or Color3.fromRGB(180, 50, 50)
carryStatusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
carryStatusBtn.Font = customFont
carryStatusBtn.TextSize = 12
carryStatusBtn.Parent = stealingContent

local carryStatusCorner = Instance.new("UICorner")
carryStatusCorner.CornerRadius = UDim.new(0, 6)
carryStatusCorner.Parent = carryStatusBtn

local modeIndicator = Instance.new("TextLabel")
modeIndicator.Text = "ACTIVE: BASE"
modeIndicator.Size = UDim2.new(0.85, 0, 0, 24)
modeIndicator.Position = UDim2.new(0.075, 0, 0.44, 0)
modeIndicator.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
modeIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
modeIndicator.Font = customFont
modeIndicator.TextSize = 13
modeIndicator.Parent = stealingContent

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 8)
modeCorner.Parent = modeIndicator

local potionBtn = Instance.new("TextButton")
potionBtn.Text = "USE GIANT POTION"
potionBtn.Size = UDim2.new(0.64, 0, 0, 28)
potionBtn.Position = UDim2.new(0.075, 0, 0.53, 0)
potionBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 180)
potionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
potionBtn.Font = customFont
potionBtn.TextSize = 12
potionBtn.Parent = stealingContent

local potionCorner = Instance.new("UICorner")
potionCorner.CornerRadius = UDim.new(0, 8)
potionCorner.Parent = potionBtn

local keybindBtn = Instance.new("TextButton")
keybindBtn.Text = "[" .. potionKey.Name .. "]"
keybindBtn.Size = UDim2.new(0.19, 0, 0, 28)
keybindBtn.Position = UDim2.new(0.735, 0, 0.53, 0)
keybindBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 120)
keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindBtn.Font = customFont
keybindBtn.TextSize = 12
keybindBtn.Parent = stealingContent

local keybindCorner = Instance.new("UICorner")
keybindCorner.CornerRadius = UDim.new(0, 8)
keybindCorner.Parent = keybindBtn

local toggleBtn = Instance.new("TextButton")
toggleBtn.Text = isEnabled and "SPEED STATUS: ON" or "SPEED STATUS: OFF"
toggleBtn.Size = UDim2.new(0.64, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.075, 0, 0.65, 0)
toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(40, 170, 80) or Color3.fromRGB(180, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = customFont
toggleBtn.TextSize = 12
toggleBtn.Parent = stealingContent

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

local speedKeybindBtn = Instance.new("TextButton")
speedKeybindBtn.Text = "[" .. speedToggleKey.Name .. "]"
speedKeybindBtn.Size = UDim2.new(0.19, 0, 0, 30)
speedKeybindBtn.Position = UDim2.new(0.735, 0, 0.65, 0)
speedKeybindBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(30, 120, 60) or Color3.fromRGB(120, 35, 35)
speedKeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedKeybindBtn.Font = customFont
speedKeybindBtn.TextSize = 12
speedKeybindBtn.Parent = stealingContent

local speedKeybindCorner = Instance.new("UICorner")
speedKeybindCorner.CornerRadius = UDim.new(0, 8)
speedKeybindCorner.Parent = speedKeybindBtn

-- =========================================
-- VISUAL TAB ELEMENTS
-- =========================================
local fovLabel = Instance.new("TextLabel")
fovLabel.Text = "FOV Lock: " .. tostring(targetFOV)
fovLabel.Size = UDim2.new(1, 0, 0, 20)
fovLabel.Position = UDim2.new(0, 0, 0.05, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
fovLabel.Font = customFont
fovLabel.TextSize = 14
fovLabel.Parent = visualContent

local fovTrack = Instance.new("Frame")
fovTrack.Size = UDim2.new(0.85, 0, 0, 8)
fovTrack.Position = UDim2.new(0.075, 0, 0.12, 0)
fovTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
fovTrack.BorderSizePixel = 0
fovTrack.Parent = visualContent

local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new((targetFOV - 60)/(120 - 60), 0, 1, 0)
fovFill.BackgroundColor3 = Color3.fromRGB(100, 220, 255)
fovFill.BorderSizePixel = 0
fovFill.Parent = fovTrack

local fovKnob = Instance.new("TextButton")
fovKnob.Text = ""
fovKnob.Size = UDim2.new(0, 16, 0, 16)
fovKnob.AnchorPoint = Vector2.new(0.5, 0.5)
fovKnob.Position = UDim2.new((targetFOV - 60)/(120 - 60), 0, 0.5, 0)
fovKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovKnob.Parent = fovTrack

local antiBeeBtn = Instance.new("TextButton")
antiBeeBtn.Text = antiBeeEnabled and "ANTI-BEE: ON" or "ANTI-BEE: OFF"
antiBeeBtn.Size = UDim2.new(0.85, 0, 0, 28)
antiBeeBtn.Position = UDim2.new(0.075, 0, 0.22, 0)
antiBeeBtn.BackgroundColor3 = antiBeeEnabled and Color3.fromRGB(40, 170, 80) or Color3.fromRGB(180, 50, 50)
antiBeeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiBeeBtn.Font = customFont
antiBeeBtn.TextSize = 13
antiBeeBtn.Parent = visualContent

local antiBeeCorner = Instance.new("UICorner")
antiBeeCorner.CornerRadius = UDim.new(0, 8)
antiBeeCorner.Parent = antiBeeBtn

for _, el in pairs({baseTrack, baseFill, baseKnob, carryTrack, carryFill, carryKnob, fovTrack, fovFill, fovKnob}) do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = el
end

-- =========================================
-- FOOTER HINT
-- =========================================
local hint = Instance.new("TextLabel")
hint.Text = "https://discord.gg/udZspK5ae"
hint.Size = UDim2.new(1, 0, 0, 20)
hint.Position = UDim2.new(0, 0, 0.93, 0)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(160, 160, 175)
hint.Font = customFont
hint.TextSize = 12
hint.Parent = frame

-- =========================================
-- TAB SWITCHING LOGIC (MAIN GUI)
-- =========================================
local function updateTabs(activeTab)
	stealingContent.Visible = (activeTab == "stealing")
	visualContent.Visible = (activeTab == "visual")
	
	stealingTabBtn.BackgroundColor3 = (activeTab == "stealing") and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(45, 45, 55)
	stealingTabBtn.TextColor3 = (activeTab == "stealing") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
	
	visualTabBtn.BackgroundColor3 = (activeTab == "visual") and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(45, 45, 55)
	visualTabBtn.TextColor3 = (activeTab == "visual") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
end

stealingTabBtn.MouseButton1Click:Connect(function() updateTabs("stealing") end)
visualTabBtn.MouseButton1Click:Connect(function() updateTabs("visual") end)

-- =========================================
-- ROBUST UNIVERSAL BRAINROT SCANNER
-- =========================================
local function parseMoneyValue(txt)
	if not txt then return 0 end
	txt = string.upper(txt)
	local num = tonumber(txt:match("[%d%.]+")) or 0
	if string.find(txt, "QI") then return num * 1e18
	elseif string.find(txt, "QA") then return num * 1e15
	elseif string.find(txt, "T") then return num * 1e12
	elseif string.find(txt, "B") then return num * 1e9
	elseif string.find(txt, "M") then return num * 1e6
	elseif string.find(txt, "K") then return num * 1e3
	end
	return num
end

-- Fixed helper: Only exclude the plot if it explicitly belongs to the local player's user ID or name tag
local function isPlayersOwnPlot(plot)
	local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player") or plot:FindFirstChild("UserId") or plot:FindFirstChild("Creator")
	if ownerVal then
		if ownerVal:IsA("ObjectValue") and ownerVal.Value == LocalPlayer then return true end
		if ownerVal:IsA("IntValue") or ownerVal:IsA("NumberValue") then
			if ownerVal.Value == LocalPlayer.UserId then return true end
		end
		if ownerVal:IsA("StringValue") and ownerVal.Value == LocalPlayer.Name then return true end
	end
	
	-- Check explicitly for "YOUR BASE" label indicator inside this plot
	for _, desc in ipairs(plot:GetDescendants()) do
		if desc:IsA("TextLabel") or desc:IsA("TextBox") then
			local txt = desc.Text
			if txt and string.upper(txt) == "YOUR BASE" then
				return true
			end
		end
	end
	
	return false
end

local function refreshTopList()
	local foundBrainrots = {}
	local checkedNames = {}

	local plotsFolder = workspace:FindFirstChild("Plots")
	
	if plotsFolder then
		for _, plot in ipairs(plotsFolder:GetChildren()) do
			-- Only skip if it's strictly the local player's own base
			if not isPlayersOwnPlot(plot) then
				for _, item in ipairs(plot:GetChildren()) do
					if item:IsA("Model") then
						local name = item.Name
						
						-- Exclude Cash, CashPad, Generic Models, and FriendPanel
						if name ~= "Cash" and name ~= "CashPad" and name ~= "Model" and name ~= "FriendPanel" and not checkedNames[name] then
							local rateText = ""
							
							local mutation = item:GetAttribute("Mutation") or item:GetAttribute("__mutation")
							if mutation and type(mutation) == "string" and mutation ~= "" then
								name = name .. " [" .. mutation .. "]"
							end
							
							for _, descendant in ipairs(item:GetDescendants()) do
								if descendant:IsA("TextLabel") then
									local txt = descendant.Text
									if txt and txt ~= "" and not string.find(txt, "COLLECT ZONE") and not string.find(txt, "Template") then
										rateText = txt
									end
								end
							end
							
							if rateText == "" then
								rateText = "$0/s"
							end
							
							checkedNames[item.Name] = true
							table.insert(foundBrainrots, {
								name = name,
								rate = rateText,
								sortVal = parseMoneyValue(rateText),
								model = item
							})
						end
					end
				end
			end
		end
	end

	table.sort(foundBrainrots, function(a, b)
		return a.sortVal > b.sortVal
	end)

	for _, child in ipairs(topListContent:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local totalCount = #foundBrainrots
	topListContent.CanvasSize = UDim2.new(0, 0, 0, totalCount * 36 + 10)

	for i = 1, totalCount do
		local data = foundBrainrots[i]
		
		local entryFrame = Instance.new("Frame")
		entryFrame.Size = UDim2.new(1, 0, 0, 32)
		entryFrame.Position = UDim2.new(0, 0, 0, (i - 1) * 36)
		entryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		entryFrame.BackgroundTransparency = 0.4
		entryFrame.BorderSizePixel = 0
		entryFrame.Parent = topListContent
		
		local entryCorner = Instance.new("UICorner")
		entryCorner.CornerRadius = UDim.new(0, 6)
		entryCorner.Parent = entryFrame
		
		local rankLabel = Instance.new("TextLabel")
		rankLabel.Text = "#" .. tostring(i)
		rankLabel.Size = UDim2.new(0, 22, 1, 0)
		rankLabel.Position = UDim2.new(0.02, 0, 0, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
		rankLabel.Font = customFont
		rankLabel.TextSize = 11
		rankLabel.Parent = entryFrame
		
		local viewport = Instance.new("ViewportFrame")
		viewport.Size = UDim2.new(0, 26, 0, 26)
		viewport.Position = UDim2.new(0.12, 0, 0.5, -13)
		viewport.BackgroundTransparency = 1
		viewport.BorderSizePixel = 0
		viewport.Parent = entryFrame
		
		if data.model then
			pcall(function()
				local clonedModel = data.model:Clone()
				for _, desc in ipairs(clonedModel:GetDescendants()) do
					if desc:IsA("Script") or desc:IsA("LocalScript") then
						desc:Destroy()
					end
				end
				clonedModel.Parent = viewport
				
				local cf, size = clonedModel:GetBoundingBox()
				local camera = Instance.new("Camera")
				viewport.CurrentCamera = camera
				camera.Parent = viewport
				
				local maxDim = math.max(size.X, size.Y, size.Z)
				if maxDim == 0 then maxDim = 5 end
				camera.CFrame = CFrame.new(cf.Position + (Vector3.new(1, 1, 1).Unit * (maxDim * 1.8)), cf.Position)
			end)
		end
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = data.name
		nameLabel.Size = UDim2.new(0, 110, 1, 0)
		nameLabel.Position = UDim2.new(0.24, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = customFont
		nameLabel.TextSize = 9
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = entryFrame
		
		local rateLabel = Instance.new("TextLabel")
		rateLabel.Text = data.rate
		rateLabel.Size = UDim2.new(0, 80, 1, 0)
		rateLabel.Position = UDim2.new(0.64, 0, 0, 0)
		rateLabel.BackgroundTransparency = 1
		rateLabel.TextColor3 = Color3.fromRGB(40, 220, 100)
		rateLabel.Font = customFont
		rateLabel.TextSize = 10
		rateLabel.TextXAlignment = Enum.TextXAlignment.Right
		rateLabel.Parent = entryFrame
	end
	
	if totalCount == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Text = "No external brainrots found!"
		emptyLabel.Size = UDim2.new(1, 0, 0, 40)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		emptyLabel.Font = customFont
		emptyLabel.TextSize = 12
		emptyLabel.Parent = topListContent
	end
end

-- =========================================
-- FUNCTIONS & KEYBIND LOGIC
-- =========================================
local function useGiantPotion()
	local char = LocalPlayer.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	
	local potion = (backpack and backpack:FindFirstChild("Giant Potion")) or char:FindFirstChild("Giant Potion")
	if potion and humanoid then
		potion.Parent = char
		task.wait(0.02)
		pcall(function() potion:Activate() end)
	end
end

potionBtn.MouseButton1Click:Connect(useGiantPotion)

local waitingForKey = false
local waitingForSpeedKey = false

keybindBtn.MouseButton1Click:Connect(function()
	waitingForKey = true
	keybindBtn.Text = "[...]"
end)

speedKeybindBtn.MouseButton1Click:Connect(function()
	waitingForSpeedKey = true
	speedKeybindBtn.Text = "[...]"
end)

local function toggleSpeedStatus()
	isEnabled = not isEnabled
	toggleBtn.Text = isEnabled and "SPEED STATUS: ON" or "SPEED STATUS: OFF"
	toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(40, 170, 80) or Color3.fromRGB(180, 50, 50)
	speedKeybindBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(30, 120, 60) or Color3.fromRGB(120, 35, 35)
	saveConfig()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if waitingForKey then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			potionKey = input.KeyCode
			keybindBtn.Text = "[" .. potionKey.Name .. "]"
			waitingForKey = false
			saveConfig()
		end
		return
	end
	
	if waitingForSpeedKey then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			speedToggleKey = input.KeyCode
			speedKeybindBtn.Text = "[" .. speedToggleKey.Name .. "]"
			waitingForSpeedKey = false
			saveConfig()
		end
		return
	end
	
	if not gameProcessed then
		if input.KeyCode == potionKey then
			useGiantPotion()
		elseif input.KeyCode == speedToggleKey then
			toggleSpeedStatus()
		end
	end
end)

-- =========================================
-- SLIDER LOGIC
-- =========================================
local draggingBase, draggingCarry, draggingFOV = false, false, false

local function updateSlider(input, typeName)
	local track, fill, knob, label
	local minVal, maxVal
	
	if typeName == "base" then
		track, fill, knob, label = baseTrack, baseFill, baseKnob, baseLabel
		minVal, maxVal = MIN_SPEED, MAX_SPEED
	elseif typeName == "carry" then
		track, fill, knob, label = carryTrack, carryFill, carryKnob, carryLabel
		minVal, maxVal = MIN_SPEED, MAX_SPEED
	elseif typeName == "fov" then
		track, fill, knob, label = fovTrack, fovFill, fovKnob, fovLabel
		minVal, maxVal = 60, 120
	end
	
	local scale = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
	local newVal = math.floor(minVal + (scale * (maxVal - minVal)))
	
	if typeName == "base" then baseSpeed = newVal
	elseif typeName == "carry" then carrySpeed = newVal
	elseif typeName == "fov" then targetFOV = newVal end
	
	fill.Size = UDim2.new(scale, 0, 1, 0)
	knob.Position = UDim2.new(scale, 0, 0.5, 0)
	
	if typeName == "base" then label.Text = "Base Speed: " .. tostring(baseSpeed)
	elseif typeName == "carry" then label.Text = "Carry Speed: " .. tostring(carrySpeed)
	elseif typeName == "fov" then label.Text = "FOV Lock: " .. tostring(targetFOV) end
	
	saveConfig()
end

baseKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingBase = true end end)
baseTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingBase = true; updateSlider(input, "base") end end)

carryKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCarry = true end end)
carryTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCarry = true; updateSlider(input, "carry") end end)

fovKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOV = true end end)
fovTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOV = true; updateSlider(input, "fov") end end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingBase, draggingCarry, draggingFOV = false, false, false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if draggingBase then updateSlider(input, "base") end
		if draggingCarry then updateSlider(input, "carry") end
		if draggingFOV then updateSlider(input, "fov") end
	end
end)

baseStatusBtn.MouseButton1Click:Connect(function()
	baseStatusEnabled = not baseStatusEnabled
	baseStatusBtn.Text = baseStatusEnabled and "BASE STATUS: ON" or "BASE STATUS: OFF"
	baseStatusBtn.BackgroundColor3 = baseStatusEnabled and Color3.fromRGB(40, 170, 80) or Color3.fromRGB(180, 50, 50)
	saveConfig()
end)

carryStatusBtn.MouseButton1Click:Connect(function()
	carryStatusEnabled = not carryStatusEnabled
	carryStatusBtn.Text = carryStatusEnabled and "CARRY STATUS: ON" or "CARRY STATUS: OFF"
	carryStatusBtn.BackgroundColor3 = carryStatusEnabled and Color3.fromRGB(40, 170, 80) or Color3.fromRGB(180, 50, 50)
	saveConfig()
end)

antiBeeBtn.MouseButton1Click:Connect(function()
	antiBeeEnabled = not antiBeeEnabled
	antiBeeBtn.Text = antiBeeEnabled and "ANTI-BEE: ON" or "ANTI-BEE: OFF"
	antiBeeBtn.BackgroundColor3 = antiBeeEnabled and Color3.fromRGB(40, 170, 80) or Color3.fromRGB(180, 50, 50)
	saveConfig()
end)

toggleBtn.MouseButton1Click:Connect(toggleSpeedStatus)

pcall(function()
	baseFill.Size = UDim2.new((baseSpeed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 1, 0)
	baseKnob.Position = UDim2.new((baseSpeed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 0.5, 0)
	baseLabel.Text = "Base Speed: " .. tostring(baseSpeed)

	carryFill.Size = UDim2.new((carrySpeed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 1, 0)
	carryKnob.Position = UDim2.new((carrySpeed - MIN_SPEED)/(MAX_SPEED - MIN_SPEED), 0, 0.5, 0)
	carryLabel.Text = "Carry Speed: " .. tostring(carrySpeed)

	fovFill.Size = UDim2.new((targetFOV - 60)/(120 - 60), 0, 1, 0)
	fovKnob.Position = UDim2.new((targetFOV - 60)/(120 - 60), 0, 0.5, 0)
	fovLabel.Text = "FOV Lock: " .. tostring(targetFOV)
	
	speedKeybindBtn.Text = "[" .. speedToggleKey.Name .. "]"
	speedKeybindBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(30, 120, 60) or Color3.fromRGB(120, 35, 35)
end)

-- =========================================
-- MAIN ENGINE LOOP
-- =========================================
local baselineGameSpeed = 16
local isHoldingItem = false
local pingUpdateTimer = 0
local topListUpdateTimer = 0

RunService.Heartbeat:Connect(function(dt)
	pingUpdateTimer = pingUpdateTimer + dt
	if pingUpdateTimer >= 0.5 then
		pingUpdateTimer = 0
		pcall(function()
			local pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
			pingLabel.Text = "PING: " .. tostring(pingVal) .. " ms"
			
			if pingVal < 100 then
				pingLabel.TextColor3 = Color3.fromRGB(40, 220, 100)
			elseif pingVal < 200 then
				pingLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
			else
				pingLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
			end
		end)
	end

	topListUpdateTimer = topListUpdateTimer + dt
	if topListUpdateTimer >= 2.0 then
		topListUpdateTimer = 0
		pcall(refreshTopList)
	end

	local char = LocalPlayer.Character
	
	pcall(function()
		Camera.FieldOfView = targetFOV
		LocalPlayer.CameraMinZoomDistance = 10
		LocalPlayer.CameraMaxZoomDistance = 400
	end)
	
	if antiBeeEnabled then
		pcall(function()
			for _, fx in ipairs(Lighting:GetChildren()) do
				if fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("DepthOfFieldEffect") then
					fx:Destroy()
				end
			end
		end)
	end
	
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		
		if humanoid then
			local nativeSpeed = humanoid.WalkSpeed
			if nativeSpeed < baselineGameSpeed - 0.5 then
				isHoldingItem = true
			else
				isHoldingItem = false
				baselineGameSpeed = nativeSpeed
			end
		end
		
		if isHoldingItem then
			modeIndicator.Text = "ACTIVE: CARRY"
			modeIndicator.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
		else
			modeIndicator.Text = "ACTIVE: BASE"
			modeIndicator.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
		end
		
		if hrp and not UserInputService:GetFocusedTextBox() then
			local moveVector = Vector3.new()
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
			
			if moveVector.Magnitude > 0 then
				moveVector = moveVector.Unit
				
				local camCF = Camera.CFrame
				local look = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
				local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
				
				local worldDir = (look * -moveVector.Z) + (right * moveVector.X)
				if worldDir.Magnitude > 0 then
					worldDir = worldDir.Unit
					
					if isEnabled then
						local shouldApply = (isHoldingItem and carryStatusEnabled) or (not isHoldingItem and baseStatusEnabled)
						if shouldApply then
							local activeSpeed = isHoldingItem and carrySpeed or baseSpeed
							local targetVel = worldDir * activeSpeed
							
							local currentVel = hrp.AssemblyLinearVelocity
							hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, currentVel.Y, targetVel.Z)
						end
					else
						local currentVel = hrp.AssemblyLinearVelocity
						local nativeMoveSpeed = humanoid and humanoid.WalkSpeed or 16
						local targetVel = worldDir * nativeMoveSpeed
						
						hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, currentVel.Y, targetVel.Z)
					end
				end
			end
		end
	end
end)
