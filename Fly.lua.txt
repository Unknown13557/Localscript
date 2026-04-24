local UserInputService = game:GetService("UserInputService")
local Players                    = game:GetService("Players")
local Camera                    = workspace.CurrentCamera
local LocalPlayer            = Players.LocalPlayer
local Lighting                  = game:GetService("Lighting")

if not LocalPlayer then
	Players.PlayerAdded:Wait()
	LocalPlayer = Players.LocalPlayer
end

local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local TweenService     = game:GetService("TweenService")

local RS               = RunService
local WS               = Workspace
local UIS              = UserInputService
local camera      = workspace.CurrentCamera

local nowe = false

local playerButtons = {}
local selectedButton = nil
local selectedPlayer = nil

local teleportMoveConn = nil
local teleportActive = false

local flySpeed = 18
local speaker = LocalPlayer

local TELEPORT_RATE = 30
local TELEPORT_INTERVAL = 0 / TELEPORT_RATE

local main = Instance.new("ScreenGui")

main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.DisplayOrder = 19000
main.Name = "main"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ResetOnSpawn = false
main.IgnoreGuiInset = true


local Frame                            = Instance.new("Frame")
Frame.Parent                        = main
local TeleportCamera         = Instance.new("TextButton")
local escape                           = Instance.new("Frame")
local toggle                             = Instance.new("TextButton")
local onof                                = Instance.new("TextButton")
local TextLabel                     = Instance.new("TextLabel")
local plus                                = Instance.new("TextButton")
local speed                             = Instance.new("TextLabel")
local mine                              = Instance.new("TextButton")
local minisizebutton                  = Instance.new("TextButton")
local SettingsButton             = Instance.new("TextButton")


Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)

TeleportCamera.Name = "TeleportCamera"
TeleportCamera.Parent = Frame
TeleportCamera.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
TeleportCamera.Size = UDim2.new(0, 44, 0, 28)
TeleportCamera.Font = Enum.Font.SourceSans
TeleportCamera.Text = "TP"
TeleportCamera.TextColor3 = Color3.fromRGB(0, 0, 0)
TeleportCamera.TextSize = 17


escape.Name = "escape"
escape.Parent = Frame
escape.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
escape.Position = UDim2.new(0, 0, 0.50500074, 0)
escape.Size = UDim2.new(0, 44, 0, 28)
escape.BorderSizePixel = 1
escape.BorderColor3 = Color3.fromRGB(0, 0, 0)

toggle.Name = "toggle"
toggle.Parent = escape
toggle.AutoButtonColor = false
toggle.Text = ""
toggle.BackgroundColor3 = Color3.fromRGB(88, 200, 120)
toggle.Size = UDim2.fromOffset(40, 20)
toggle.Position = UDim2.fromOffset(2, 4)
toggle.ZIndex = 2
toggle.ClipsDescendants = true

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggle

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(235, 235, 235)
toggleStroke.Thickness = 1
toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
toggleStroke.Parent = toggle

local flyKnob = Instance.new("TextButton")
flyKnob.Name = "flyKnob"
flyKnob.Parent = toggle
flyKnob.AutoButtonColor = false
flyKnob.Text = ""
flyKnob.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
flyKnob.Size = UDim2.fromOffset(16, 16)
flyKnob.ZIndex = 3

local flyKnobCorner = Instance.new("UICorner")
flyKnobCorner.CornerRadius = UDim.new(1, 0)
flyKnobCorner.Parent = flyKnob

local flyKnobStroke = Instance.new("UIStroke")
flyKnobStroke.Color = Color3.fromRGB(235, 235, 235)
flyKnobStroke.Thickness = 1
flyKnobStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
flyKnobStroke.Parent = flyKnob

flyKnob.Position = UDim2.fromOffset(2, 2)
toggle.BackgroundColor3 = Color3.fromRGB(88,200,120)



onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.701, 0, 0.50500074, 0)
onof.Size = UDim2.new(0, 57, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "FLY"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.BorderSizePixel = 1
onof.TextSize = 21
onof.ZIndex = 50

local function pointerPos(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(input.Position.X, input.Position.Y)
	end

	if UIS.GetMouseLocation then
		return UIS:GetMouseLocation()
	end
	return Vector2.new(0, 0)
end

local function over(inst, pos)
	local p, s = inst.AbsolutePosition, inst.AbsoluteSize
	return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
end

local function attachDrag(target, ignoreButton)

local dragging = false
	local dragStart, startPos

	target.Active = true
	target.Draggable = false

	local function clampToViewport(x, y)
		local cam = WS.CurrentCamera
		if not cam then
			return UDim2.fromOffset(x, y)
		end

		local vp = cam.ViewportSize
		local size = target.AbsoluteSize
		local anchor = target.AnchorPoint

		local minX = size.X * anchor.X
		local maxX = vp.X - size.X * (1 - anchor.X)
		local minY = size.Y * anchor.Y
		local maxY = vp.Y - size.Y * (1 - anchor.Y)

		x = math.clamp(x, minX, math.max(minX, maxX))
		y = math.clamp(y, minY, math.max(minY, maxY))

		return UDim2.fromOffset(x, y)
	end

	target.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			if ignoreButton and over(ignoreButton, pointerPos(input)) then
				return
			end

			dragging = true
			dragStart = input.Position
			startPos = target.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	target.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local delta = input.Position - dragStart
			target.Position = clampToViewport(
				startPos.X.Offset + delta.X,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	task.defer(function()
		local abs = target.AbsolutePosition
		target.Position = clampToViewport(abs.X, abs.Y)
	end)

	local function hookViewportChanged()
		local cam = WS.CurrentCamera
		if not cam then return end

		cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if not dragging then
				local abs = target.AbsolutePosition
				target.Position = clampToViewport(abs.X, abs.Y)
			end
		end)
	end

	if WS.CurrentCamera then
		hookViewportChanged()
	end

	WS:GetPropertyChangedSignal("CurrentCamera"):Connect(hookViewportChanged)
end

attachDrag(Frame, onof)

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 101, 0, 28)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "︻デ═一"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextScaled = true
TextLabel.TextSize = 14
TextLabel.TextWrapped = true
	
plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.237, 0, 0, 0)
plus.Size = UDim2.new(0, 44, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 17
plus.TextWrapped = true

speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speed.Position = UDim2.new(0.474, 0, 0.50500074, 0)
speed.Size = UDim2.new(0, 44, 0, 28)
speed.Font = Enum.Font.SourceSans
speed.Text = "18"
speed.TextColor3 = Color3.fromRGB(0, 0, 0)
speed.TextScaled = true
speed.TextSize = 14
speed.TextWrapped = true

mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.237, 0, 0.50500074, 0)
mine.Size = UDim2.new(0, 44, 0, 28)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 17
mine.TextWrapped = true

minisizebutton.Name = "Close"
minisizebutton.Parent = Frame
minisizebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
minisizebutton.Font = Enum.Font.SourceSans
minisizebutton.Size = UDim2.new(0, 44, 0, 28)
minisizebutton.Text = "-"
minisizebutton.TextSize = 30
minisizebutton.Position =  UDim2.new(0, 0, -0.99000, 27)


SettingsButton.Name = "SettingButton"
SettingsButton.Parent = Frame
SettingsButton.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
SettingsButton.Font = Enum.Font.SourceSans
SettingsButton.Size = UDim2.new(0, 44, 0, 28)
SettingsButton.TextColor3 = Color3.fromRGB(20, 20, 20)
SettingsButton.Text = "⚙"
SettingsButton.TextSize = 23
SettingsButton.Position = UDim2.new(0, 45, -0.99000, 27)


local SettingsGui = Instance.new("ScreenGui")
SettingsGui.Name = "SettingsGui"
SettingsGui.Parent = LocalPlayer.PlayerGui
SettingsGui.IgnoreGuiInset = true
SettingsGui.DisplayOrder = main.DisplayOrder + 5
SettingsGui.Enabled = false
SettingsGui.ResetOnSpawn = false



local DragFrame = Instance.new("Frame")
DragFrame.Parent = SettingsGui
DragFrame.Name = "DragFrame"



DragFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
DragFrame.BackgroundTransparency = 0.8
DragFrame.BorderSizePixel = 0
DragFrame.Active = true

local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(0, 8)
dragCorner.Parent = DragFrame

local dragStroke = Instance.new("UIStroke")
dragStroke.Parent = DragFrame
dragStroke.Color = Color3.fromRGB(255, 255, 255)
dragStroke.Thickness = 1.5
dragStroke.Transparency = 0
dragStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

DragFrame:GetPropertyChangedSignal("Position"):Connect(function()
end)


local PAD = {
	L = 10,
	R = 10,
	T = 35,
	B = 10
}

local padding = Instance.new("UIPadding")
padding.Parent = DragFrame
padding.PaddingLeft   = UDim.new(0, PAD.L)
padding.PaddingRight  = UDim.new(0, PAD.R)
padding.PaddingTop    = UDim.new(0, PAD.T)
padding.PaddingBottom = UDim.new(0, PAD.B)

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = DragFrame
SettingsFrame.Size = UDim2.fromOffset(220, 160)
SettingsFrame.AnchorPoint = Vector2.new(0, 0)

SettingsFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.AutomaticSize = Enum.AutomaticSize.None

Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0,8)


DragFrame.Size = UDim2.fromOffset(
	SettingsFrame.Size.X.Offset + PAD.L + PAD.R,
	SettingsFrame.Size.Y.Offset + PAD.T + PAD.B
)

task.defer(function()
	DragFrame.AnchorPoint = Vector2.new(1, 0)
	DragFrame.Position = UDim2.new(1, 0, 0, 10)
end)


DragFrame.ZIndex = SettingsFrame.ZIndex - 1
attachDrag(DragFrame, nil)


local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Parent = SettingsFrame
Scroll.Position = UDim2.new(0, 4, 0, 4)
Scroll.Size     = UDim2.new(1, -8, 1, -8)

Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 3
Scroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ZIndex = 1
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y


local listLayout = Instance.new("UIListLayout")
listLayout.Parent = Scroll
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder



local UpdateController = {}

UpdateController.Character = nil
UpdateController.Humanoid = nil
UpdateController.HRP = nil



local function BindCharacter(char)

	UpdateController.Character = char

	task.spawn(function()

		local hum = char:WaitForChild("Humanoid")
		local hrp = char:WaitForChild("HumanoidRootPart")

		if UpdateController.Character ~= char then
			return
		end

		UpdateController.Humanoid = hum
		UpdateController.HRP = hrp

	end)

end

if LocalPlayer.Character then
	BindCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(BindCharacter)



UpdateController.HeartbeatParallel = {}
UpdateController.RenderParallel = {}

UpdateController.HeartbeatList = {}
UpdateController.RenderList = {}

UpdateController.HeartbeatOverrideStack = {}
UpdateController.RenderOverrideStack = {}

UpdateController.Events = {}

UpdateController.HBConn = nil
UpdateController.RSConn = nil


function UpdateController:On(eventName,callback)

	self.Events[eventName] = self.Events[eventName] or {}

	local connection = {Callback = callback}

	table.insert(self.Events[eventName],connection)

	function connection:Disconnect()

		local list = UpdateController.Events[eventName]
		if not list then return end

		for i,v in ipairs(list) do
			if v == connection then
				table.remove(list,i)
				break
			end
		end

	end

	return connection

end

function UpdateController:Emit(eventName,data)

	local listeners = self.Events[eventName]
	if not listeners then return end

	for i=1,#listeners do
		listeners[i].Callback(data)
	end

end



local function RemoveFromList(list,name)

	for i=#list,1,-1 do
		if list[i].Name == name then
			table.remove(list,i)
		end
	end

end



local function InsertOverride(stack,config)

	local pr = config.Priority or 0

	for i = #stack,1,-1 do

		local other = stack[i]
		local opr = other.Priority or 0

		if pr >= opr then
			table.insert(stack,i+1,config)
			return
		end

	end

	table.insert(stack,1,config)

end


function UpdateController:ForceDisable(name)

	self.HeartbeatParallel[name] = nil
	self.RenderParallel[name] = nil

	RemoveFromList(self.HeartbeatList,name)
	RemoveFromList(self.RenderList,name)

	RemoveFromList(self.HeartbeatOverrideStack,name)
	RemoveFromList(self.RenderOverrideStack,name)

	self:Emit("ForceDisable",name)

end


function UpdateController:Start()

	if not self.HBConn then

		self.HBConn = RunService.Heartbeat:Connect(function(dt)

			local char = self.Character
			local hum = self.Humanoid
			local hrp = self.HRP

			if not char or not hum or not hrp then return end
			if hum.Health <= 0 then return end

			for i=1,#self.HeartbeatList do

				local data = self.HeartbeatList[i]

				local ok,err = pcall(function()
					data.Callback(dt,char,hum,hrp)
				end)

				if not ok then
					warn("[HB ERROR]",data.Name,err)
				end

			end

			local top = self.HeartbeatOverrideStack[#self.HeartbeatOverrideStack]

			if top then

				local ok,err = pcall(function()
					top.Callback(dt,char,hum,hrp)
				end)

				if not ok then
					warn("[HB OVERRIDE ERROR]",top.Name,err)
				end

			end

		end)

	end

	if not self.RSConn then

		self.RSConn = RunService.RenderStepped:Connect(function(dt)

			local char = self.Character
			local hum = self.Humanoid
			local hrp = self.HRP

			if not char or not hum or not hrp then return end
			if hum.Health <= 0 then return end

			for i=1,#self.RenderList do

				local data = self.RenderList[i]

				local ok,err = pcall(function()
					data.Callback(dt,char,hum,hrp)
				end)

				if not ok then
					warn("[RS ERROR]",data.Name,err)
				end

			end

			local top = self.RenderOverrideStack[#self.RenderOverrideStack]

			if top then

				local ok,err = pcall(function()
					top.Callback(dt,char,hum,hrp)
				end)

				if not ok then
					warn("[RS OVERRIDE ERROR]",top.Name,err)
				end

			end

		end)

	end

end

function UpdateController:AddHeartbeat(name,config)

	if self.HeartbeatParallel[name] then return end

	config.Name = name

	self.HeartbeatParallel[name] = config
	table.insert(self.HeartbeatList,config)

	self:Start()

end

function UpdateController:AddRender(name,config)

	if self.RenderParallel[name] then return end

	config.Name = name

	self.RenderParallel[name] = config
	table.insert(self.RenderList,config)

	self:Start()

end

function UpdateController:PushHeartbeatOverride(name,config)

	RemoveFromList(self.HeartbeatOverrideStack,name)

	config.Name = name
	InsertOverride(self.HeartbeatOverrideStack,config)

	self:Start()

end

function UpdateController:PushRenderOverride(name,config)

	RemoveFromList(self.RenderOverrideStack,name)

	config.Name = name
	InsertOverride(self.RenderOverrideStack,config)

	self:Start()

end



function UpdateController:Shutdown()

	if self.HBConn then
		self.HBConn:Disconnect()
		self.HBConn = nil
	end

	if self.RSConn then
		self.RSConn:Disconnect()
		self.RSConn = nil
	end

	table.clear(self.HeartbeatParallel)
	table.clear(self.RenderParallel)

	table.clear(self.HeartbeatList)
	table.clear(self.RenderList)

	table.clear(self.HeartbeatOverrideStack)
	table.clear(self.RenderOverrideStack)

end



local function SetSlotState(slot,state)

	slot.State = state

	if state then
		slot.Pill.BackgroundColor3 = Color3.fromRGB(120,200,120)
		slot.SlotKnob.Position = UDim2.fromOffset(20,2)
	else
		slot.Pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
		slot.SlotKnob.Position = UDim2.fromOffset(2,2)
	end

end



local function BindSlot(slot,config)

	local name = config.Name
	local type = config.Type

	slot.State = config.Default or false
	SetSlotState(slot,slot.State)

	

	local function Enable()

		if type == "HeartbeatParallel" then
			UpdateController:AddHeartbeat(name,config)

		elseif type == "RenderParallel" then
			UpdateController:AddRender(name,config)

		elseif type == "HeartbeatOverride" then
			UpdateController:PushHeartbeatOverride(name,config)

		elseif type == "RenderOverride" then
			UpdateController:PushRenderOverride(name,config)
		end

	end

	

	local function Disable()
		UpdateController:ForceDisable(name)
	end

	

	if slot.State then
		Enable()
	end

	

	slot.Pill.MouseButton1Click:Connect(function()

		slot.State = not slot.State
		SetSlotState(slot,slot.State)

		if slot.State then
			Enable()
		else
			Disable()
		end

	end)

	

	UpdateController:On("ForceDisable",function(disabledName)

		if disabledName == name then
			if slot.State then
				SetSlotState(slot,false)
			end
		end

	end)

end



local lastApplyTime = 0
local APPLY_INTERVAL = 1/30

local noclipUsers = 0

local sharedNoclipConn = nil
local flyNoclipConn = nil

local flyHasNoclipPriority = false

local function applyNoclipOnce()

	local now = os.clock()

	if now - lastApplyTime < APPLY_INTERVAL then
		return
	end

	lastApplyTime = now

	local char = LocalPlayer.Character
	if not char then return end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.CanCollide then
				part.CanCollide = false
			end
		end
	end

end

local function restoreCollision()

	lastApplyTime = 0

	local char = LocalPlayer.Character
	if not char then return end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if not part.CanCollide then
				part.CanCollide = true
			end
		end
	end

end

local function startSharedNoclip()

	if sharedNoclipConn then return end

	applyNoclipOnce()

	sharedNoclipConn =
	RunService.Heartbeat:Connect(function()
		applyNoclipOnce()
	end)

end

local function stopSharedNoclip()

	if sharedNoclipConn then
		sharedNoclipConn:Disconnect()
		sharedNoclipConn = nil
	end

	if not flyHasNoclipPriority then
		restoreCollision()
	end

end

local function addNoclipUser()

	noclipUsers += 1

	if noclipUsers == 1 then
		startSharedNoclip()
	end

end

local function removeNoclipUser()

	noclipUsers = math.max(0, noclipUsers - 1)

	if noclipUsers == 0 then
		stopSharedNoclip()
	end

end

local function forceResetSharedNoclip()

	noclipUsers = 0
	lastApplyTime = 0

	if sharedNoclipConn then
		sharedNoclipConn:Disconnect()
		sharedNoclipConn = nil
	end

	if not flyHasNoclipPriority then
		restoreCollision()
	end

end

local function updateFlyNoclip(state)

	if state then

		if flyNoclipConn then return end

		flyHasNoclipPriority = true

		applyNoclipOnce()

		flyNoclipConn =
		RunService.Heartbeat:Connect(function()
			applyNoclipOnce()
		end)

	else

		if flyNoclipConn then
			flyNoclipConn:Disconnect()
			flyNoclipConn = nil
		end

		flyHasNoclipPriority = false

		lastApplyTime = 0

		if noclipUsers == 0 then
			restoreCollision()
		else
			startSharedNoclip()
		end

	end

end


local Slots = {}

for i = 1, 23 do

	local slot = Instance.new("Frame")
	slot.Name = "Slot"..i
	slot.Parent = Scroll
	slot.BackgroundColor3 = Color3.fromRGB(60,60,60)
	slot.BorderSizePixel = 0
	slot.Size = UDim2.new(1, -2, 0, 35)
	slot.LayoutOrder = i
	slot.ClipsDescendants = true

	Instance.new("UICorner", slot).CornerRadius = UDim.new(0,8)

	local content = Instance.new("Frame")
	content.Parent = slot
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -12, 1, 0)
	content.Position = UDim2.fromOffset(6, 0)

	local label = Instance.new("TextLabel")
	label.Parent = content
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(0.7, 1)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Color3.fromRGB(220,220,220)
	label.Text = "Slot "..i

	local pill = Instance.new("TextButton")
	pill.Parent = content
	pill.Size = UDim2.fromOffset(36, 18)
	pill.AnchorPoint = Vector2.new(1, 0.5)
	pill.Position = UDim2.fromScale(1, 0.5)
	pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
	pill.Text = ""
	pill.AutoButtonColor = false
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Parent = pill
	knob.Size = UDim2.fromOffset(14, 14)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = Color3.fromRGB(220,220,220)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	Slots[i] = {
		Frame = slot,
		Label = label,
		Pill = pill,
		SlotKnob = knob,
		State = false
	}

end






local onofDefaultTextColor = onof.TextColor3
local onofDefaultBG        = onof.BackgroundColor3
local onofDefaultText      = onof.Text

local flyRainbowConn
local flyHueTime = 0
local function startFlyVisuals()
	onof.BackgroundColor3 = Color3.fromRGB(50,50,50)
	onof.TextStrokeTransparency = 1
	if flyRainbowConn then flyRainbowConn:Disconnect() end
	flyRainbowConn = RS.RenderStepped:Connect(function(dt)
		flyHueTime += dt
		local hue = (flyHueTime * 0.25) % 1
		onof.TextColor3 = Color3.fromHSV(hue, 1, 1)
	end)
end

local function stopFlyVisuals()
	if flyRainbowConn then
		flyRainbowConn:Disconnect()
		flyRainbowConn = nil
	end
	
	onof.BackgroundColor3 = onofDefaultBG
	onof.TextColor3       = onofDefaultTextColor
	onof.Text             = onofDefaultText
	onof.TextStrokeTransparency = 1
end


local tpwalking = false
local tpGen = 0
onof.MouseButton1Down:Connect(function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if nowe == true then
		nowe = false

    hum.PlatformStand = nowe
			
	stopFlyVisuals() 
	  tpwalking = false
        tpGen = tpGen + 1
				
	
    updateFlyNoclip(false)
  local hum = speaker.Character.Humanoid

local states = {
	"Climbing",
	"FallingDown",
	"Flying",
	"Freefall",
	"GettingUp",
	"Jumping",
	"Landed",
	"Physics",
	"PlatformStanding",
	"Ragdoll",
	"Running",
	"RunningNoPhysics",
	"Seated",
	"StrafingNoPhysics",
	"Swimming"
}

for _, v in ipairs(states) do
	hum:SetStateEnabled(Enum.HumanoidStateType[v], true)
end

hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
		else
		nowe = true

        hum.PlatformStand = nowe
				
		startFlyVisuals()

      
      updateFlyNoclip(true)


tpGen = tpGen + 1
tpwalking = true
local gen = tpGen
for i = 1, flySpeed do
	task.spawn(function()
		local myGen = gen
		local hb = RS.Heartbeat	
		local chr = LocalPlayer.Character
		local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
		while tpwalking and (myGen == tpGen) and hb:Wait() and chr and hum and hum.Parent do
			if hum.MoveDirection.Magnitude > 0 then
				chr:TranslateBy(hum.MoveDirection * 2)
			end
		end
	end)
end
		LocalPlayer.Character.Animate.Disabled = true
		local Char = LocalPlayer.Character
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		
		local hum = speaker.Character.Humanoid
local enable = false

local states = {
	"Climbing",
	"FallingDown",
	"Flying",
	"Freefall",
	"GettingUp",
	"Jumping",
	"Landed",
	"Physics",
	"PlatformStanding",
	"Ragdoll",
	"Running",
	"RunningNoPhysics",
	"Seated",
	"StrafingNoPhysics",
	"Swimming"
}

for _, v in ipairs(states) do
	hum:SetStateEnabled(Enum.HumanoidStateType[v], enable)
end

hum:ChangeState(Enum.HumanoidStateType.Swimming)
end

local plr = LocalPlayer
local char = plr.Character
local hum = char:FindFirstChildOfClass("Humanoid")

if not hum then return end

local root = char:WaitForChild("HumanoidRootPart")

local flying = true
local deb = true
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 100
local speed = 0

local att = Instance.new("Attachment", root)

local lv = Instance.new("LinearVelocity", root)
lv.Attachment0 = att
lv.RelativeTo = Enum.ActuatorRelativeTo.World
lv.MaxForce = math.huge

local ao = Instance.new("AlignOrientation", root)
ao.Attachment0 = att
ao.MaxTorque = math.huge
ao.Responsiveness = 300
ao.RigidityEnabled = true
ao.Mode = Enum.OrientationAlignmentMode.OneAttachment

while nowe == true
	and LocalPlayer.Character
	and LocalPlayer.Character:FindFirstChild("Humanoid")
	and LocalPlayer.Character.Humanoid.Health > 0 do

	if hum.RigType == Enum.HumanoidRigType.R6 then
		RS.RenderStepped:Wait()
	else
		task.wait()
	end

	if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
		speed = speed + 2 + (speed / maxspeed)
		if speed > maxspeed then
			speed = maxspeed
		end
	elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
		speed = speed - 2.5
		if speed < 0 then
			speed = 0
		end
	end

	if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
		lv.VectorVelocity =
			((WS.CurrentCamera.CFrame.LookVector * (ctrl.f + ctrl.b))
			+ ((WS.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * .2, 0).Position)
			- WS.CurrentCamera.CFrame.Position)) * speed

		lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}

	elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
		lv.VectorVelocity =
			((WS.CurrentCamera.CFrame.LookVector * (lastctrl.f + lastctrl.b))
			+ ((WS.CurrentCamera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * .2, 0).Position)
			- WS.CurrentCamera.CFrame.Position)) * speed
	else
		lv.VectorVelocity = Vector3.new(0, 0, 0)
	end

	ao.CFrame = WS.CurrentCamera.CFrame
		* CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
end

ctrl = {f = 0, b = 0, l = 0, r = 0}
lastctrl = {f = 0, b = 0, l = 0, r = 0}
speed = 0

lv:Destroy()
ao:Destroy()
att:Destroy()

LocalPlayer.Character.Animate.Disabled = false
tpwalking = false
end)

plus.MouseButton1Down:Connect(function()
	if flySpeed >= 50 then
		speed.Text = "Max speed reached"
		task.wait(1)
		speed.Text = flySpeed
		return
	end

	flySpeed = flySpeed + 1
	speed.Text = flySpeed

	if not nowe then return end

	tpwalking = false
	tpGen = tpGen + 1
	tpwalking = true
	local gen = tpGen

	for i = 1, flySpeed do
		task.spawn(function()
			local myGen = gen
			local hb = RS.Heartbeat
			local chr = LocalPlayer.Character
			local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
			while tpwalking and (myGen == tpGen) and hb:Wait() and chr and hum and hum.Parent do
				if hum.MoveDirection.Magnitude > 0 then
					chr:TranslateBy(hum.MoveDirection*2)
				end
			end
		end)
	end
end)

mine.MouseButton1Down:Connect(function()
	if flySpeed == 1 then
		speed.Text = "cannot be less than 1"
		task.wait(1)
		speed.Text = flySpeed
		return
	end

	flySpeed = flySpeed - 1
	speed.Text = flySpeed

	if not nowe then return end

	tpwalking = false
	tpGen = tpGen + 1
	tpwalking = true
	local gen = tpGen

	for i = 1, flySpeed do
		task.spawn(function()
			local myGen = gen
			local hb = RS.Heartbeat
			local chr = LocalPlayer.Character
			local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
			while tpwalking and (myGen == tpGen) and hb:Wait() and chr and hum and hum.Parent do
				if hum.MoveDirection.Magnitude > 0 then
					chr:TranslateBy(hum.MoveDirection*2)
				end
			end
		end)
	end
end)



local yTeleportBox
local spTeleportBox

pcall(function()

local TeleportY= Slots[20]
TeleportY.Label.Text = "Y Teleport"
TeleportY.Frame.ClipsDescendants = true

local rowTeleportY = Instance.new("Frame")
rowTeleportY.Parent = TeleportY.Frame
rowTeleportY.Size = UDim2.new(1,-12,1,-8)
rowTeleportY.Position = UDim2.fromOffset(4,4)
rowTeleportY.BackgroundTransparency = 1
rowTeleportY.ZIndex = 20

local layoutTeleportY = Instance.new("UIListLayout")
layoutTeleportY.Parent = rowTeleportY
layoutTeleportY.FillDirection = Enum.FillDirection.Horizontal
layoutTeleportY.VerticalAlignment = Enum.VerticalAlignment.Center
layoutTeleportY.Padding = UDim.new(0,4)

local MIN_INPUT_TARGET_VALUE = -1000
local MAX_INPUT_TARGET_VALUE = 50000000

local MIN_SPEED_VALUE = 1
local MAX_SPEED_VALUE = 10000

yTeleportBox = Instance.new("TextBox")
yTeleportBox.Parent = rowTeleportY
yTeleportBox.Size = UDim2.fromOffset(97,28)
yTeleportBox.Text = "500000"
yTeleportBox.PlaceholderText = "Y"
yTeleportBox.ClearTextOnFocus = false
yTeleportBox.Font = Enum.Font.SourceSansBold
yTeleportBox.TextSize = 14
yTeleportBox.TextColor3 = Color3.fromRGB(230,230,230)
yTeleportBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
yTeleportBox.BorderSizePixel = 0
yTeleportBox.ZIndex = 21
Instance.new("UICorner",yTeleportBox).CornerRadius = UDim.new(0,6)

spTeleportBox = Instance.new("TextBox")
spTeleportBox.Parent = rowTeleportY
spTeleportBox.Size = UDim2.fromOffset(97,28)
spTeleportBox.Text = "450"
spTeleportBox.PlaceholderText = "Speed"
spTeleportBox.ClearTextOnFocus = false
spTeleportBox.Font = Enum.Font.SourceSansBold
spTeleportBox.TextSize = 14
spTeleportBox.TextColor3 = Color3.fromRGB(230,230,230)
spTeleportBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
spTeleportBox.BorderSizePixel = 0
spTeleportBox.ZIndex = 21
Instance.new("UICorner",spTeleportBox).CornerRadius = UDim.new(0,6)

local function filterNumber(text)
	text = text:gsub("[^%d%-]","")
	if text == "" then return "" end
	local num = tonumber(text)
	if not num then return "" end
	return tostring(num)
end


yTeleportBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = filterNumber(yTeleportBox.Text)

	if filtered ~= yTeleportBox.Text then
		yTeleportBox.Text = filtered
	end

	local num = tonumber(filtered)

	if num then
		num = math.clamp(num,MIN_INPUT_TARGET_VALUE,MAX_INPUT_TARGET_VALUE)
		yTeleportBox.Text = tostring(num)
	end

end)

spTeleportBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = filterNumber(spTeleportBox.Text)

	if filtered ~= spTeleportBox.Text then
		spTeleportBox.Text = filtered
	end

	local num = tonumber(filtered)

	if num then
		num = math.clamp(num,MIN_SPEED_VALUE,MAX_SPEED_VALUE)
		spTeleportBox.Text = tostring(num)
	end

end)

end)

pcall(function()

local function getDistance()
	if spTeleportBox then
		local n = tonumber(spTeleportBox.Text)
		if n then
			return math.clamp(n, 1, 10000)
		end
	end
	return 450
end


local function teleportOnce()

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local cam = workspace.CurrentCamera
	if not cam then return end

	local dir = cam.CFrame.LookVector
	local dist = getDistance()

	-- ONE SHOT TELEPORT FORWARD
	hrp.CFrame = hrp.CFrame + (dir * dist)

end


TeleportCamera.MouseButton1Click:Connect(function()
	teleportOnce()
end)

end)

local destroyEscapeSystem
local EscapeStop
local EscapeStart

local ESCAPE_HP_LOW = 40
local ESCAPE_HP_HIGH = 80
local MAX_SAFE_Y = 500000000

local escapeEnabled = false
local escapeActive = false
local escapeDebounce = false
local escapeConn = nil
local escapeStep = 1

pcall(function()

local function readEscapeConfig()
	local y = tonumber(yTeleportBox.Text)
	if not y then return nil end
	return y
end

local function getHealthPercent()

	local char = Players.LocalPlayer.Character
	if not char then return 100 end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.MaxHealth <= 0 then
		return 100
	end

	return (hum.Health / hum.MaxHealth) * 100

end

EscapeStop = function()

	if escapeConn then
		escapeConn:Disconnect()
		escapeConn = nil
	end

end

local function getXZOffset()

	local signX = math.random(0,1) == 0 and -1 or 1
	local signZ = math.random(0,1) == 0 and -1 or 1

	local offsetX = signX * math.random(50,100)
	local offsetZ = signZ * math.random(50,100)

	return offsetX,offsetZ

end

EscapeStart = function()

	if escapeConn then return end

	escapeConn = RunService.RenderStepped:Connect(function()

		if not escapeEnabled then return end

		local char = Players.LocalPlayer.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local yBase = readEscapeConfig()
		if not yBase then return end

		local hp = getHealthPercent()

		if hp > ESCAPE_HP_HIGH then
			escapeActive = false
			EscapeStop()
			return
		end

		local pos = hrp.Position

		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero

		if escapeStep == 1 then

			hrp.CFrame = CFrame.new(pos.X,yBase,pos.Z)
			escapeStep = 2

		else

			local m = math.random(2,30)
			local yRandom = math.min(yBase * m,MAX_SAFE_Y)

			local offX,offZ = getXZOffset()

			hrp.CFrame = CFrame.new(
				pos.X + offX,
				yRandom,
				pos.Z + offZ
			)

			escapeStep = 1

		end

	end)

end

RunService.Heartbeat:Connect(function()

	if not escapeEnabled then return end

	local hp = getHealthPercent()

	if hp < ESCAPE_HP_LOW then

		if not escapeActive then
			escapeActive = true
			EscapeStart()
		end

	end

end)

local function syncEscapeUI(state)

	if state then

		toggle.BackgroundColor3 = Color3.fromRGB(88,200,120)

		flyKnob:TweenPosition(
			UDim2.fromOffset(22,2),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.15,
			true
		)

	else

		toggle.BackgroundColor3 = Color3.fromRGB(220,50,50)

		flyKnob:TweenPosition(
			UDim2.fromOffset(2,2),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.15,
			true
		)

	end

end

local function toggleEscape()

	if escapeDebounce then return end
	escapeDebounce = true

	task.delay(0.15,function()
		escapeDebounce = false
	end)

	escapeEnabled = not escapeEnabled
	syncEscapeUI(escapeEnabled)

	if not escapeEnabled then

		escapeActive = false
		EscapeStop()

	else

		local hp = getHealthPercent()

		if hp < ESCAPE_HP_LOW then
			escapeActive = true
			EscapeStart()
		end

	end

end

toggle.Activated:Connect(toggleEscape)
flyKnob.Activated:Connect(toggleEscape)

escapeEnabled = false
syncEscapeUI(false)

Players.LocalPlayer.CharacterAdded:Connect(function()

	EscapeStop()

	if escapeActive then
		EscapeStart()
	end

end)

destroyEscapeSystem = function()

	escapeEnabled = false
	escapeActive = false

	if escapeConn then
		escapeConn:Disconnect()
		escapeConn = nil
	end

end

end)


local HP_DISABLE = 45
local HP_ENABLE = 80

local hpPercent = 100

local function computeHPPercent()

	local char = LocalPlayer.Character
	if not char then
		return 100
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.MaxHealth <= 0 then
		return 100
	end

	return (hum.Health / hum.MaxHealth) * 100

end

RunService.Heartbeat:Connect(function()

	hpPercent = computeHPPercent()

end)

local function updateHPState(state)

	if hpPercent < HP_DISABLE then
		return false
	elseif hpPercent > HP_ENABLE then
		return true
	end

	return state

end

local VirtualFoundation = Slots[1]
VirtualFoundation.Label.Text = "Virtual Floor"
VirtualFoundation.Frame.ClipsDescendants = true

local virtualFloor = nil
local virtualFloorValue = 20

local rowVirtualFloor = Instance.new("Frame")
rowVirtualFloor.Parent = VirtualFoundation.Frame
rowVirtualFloor.Size = UDim2.new(1,-12,1,-8)
rowVirtualFloor.Position = UDim2.fromOffset(120,4)
rowVirtualFloor.BackgroundTransparency = 1
rowVirtualFloor.ZIndex = 20

local layoutVirtualFloor = Instance.new("UIListLayout")
layoutVirtualFloor.Parent = rowVirtualFloor
layoutVirtualFloor.FillDirection = Enum.FillDirection.Horizontal
layoutVirtualFloor.VerticalAlignment = Enum.VerticalAlignment.Center
layoutVirtualFloor.Padding = UDim.new(0,1)

local offsetBox = Instance.new("TextBox")
offsetBox.Parent = rowVirtualFloor
offsetBox.Size = UDim2.fromOffset(40,28)
offsetBox.Text = tostring(virtualFloorValue)
offsetBox.PlaceholderText = "Offset Y"
offsetBox.ClearTextOnFocus = false
offsetBox.Font = Enum.Font.SourceSansBold
offsetBox.TextSize = 14
offsetBox.TextXAlignment = Enum.TextXAlignment.Center
offsetBox.TextColor3 = Color3.fromRGB(230,230,230)
offsetBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
offsetBox.BorderSizePixel = 0
offsetBox.ZIndex = 21
Instance.new("UICorner",offsetBox).CornerRadius = UDim.new(0,6)

local MIN_Y = 1
local MAX_Y = 100000

offsetBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = offsetBox.Text:gsub("%D","")

	if filtered == "" then
		offsetBox.Text = ""
		return
	end

	local num = math.clamp(
		tonumber(filtered),
		MIN_Y,
		MAX_Y
	)

	offsetBox.Text = tostring(num)
	virtualFloorValue = num

end)

local function createFloor()

	if virtualFloor then return end

	virtualFloor = Instance.new("Part")
	virtualFloor.Name = "VirtualFloor"
	virtualFloor.Size = Vector3.new(1, 1, 1)
	virtualFloor.Anchored = true
	virtualFloor.CanCollide = true
	virtualFloor.Transparency = 1
	virtualFloor.Parent = workspace.Terrain

end

local function destroyFloor()

	if virtualFloor then
		virtualFloor:Destroy()
		virtualFloor = nil
	end

end

BindSlot(VirtualFoundation,{
	Name = "VirtualFloor",
	Type = "HeartbeatParallel",

	Default = false,

	AutoClearOnDeath = false,
	AutoResetOnRespawn = false,

	Callback = function(dt,char,hum,hrp)

		if not virtualFloor then
			createFloor()
		end

		local pos = hrp.Position
		local lockedY = virtualFloorValue

		virtualFloor.CFrame =
			CFrame.new(
				pos.X,
				lockedY - (virtualFloor.Size.Y/2),
				pos.Z
			)

		if pos.Y < lockedY then  

    hrp.AssemblyLinearVelocity =  
        Vector3.new(  
            hrp.AssemblyLinearVelocity.X,  
            0, 
            hrp.AssemblyLinearVelocity.Z  
        )  

    local teleHeight = 10
    hrp.CFrame =  
        CFrame.new(pos.X, lockedY + teleHeight, pos.Z) *  
        CFrame.fromMatrix(  
            Vector3.zero,  
            hrp.CFrame.XVector,  
            hrp.CFrame.YVector,  
            hrp.CFrame.ZVector  
        )  

end

	end
})

UpdateController:On("ForceDisable",function(name)

	if name == "VirtualFloor" then
		destroyFloor()
	end

end)

LocalPlayer.CharacterAdded:Connect(function()

	task.defer(function()

		if VirtualFoundation.State then
			createFloor()
		end

	end)

end)



pcall(function()


local ForceField = Slots[2]
ForceField.Label.Text = "Force Field"
ForceField.Label.TextColor3 = Color3.fromRGB(230,50,50)
ForceField.Frame.ClipsDescendants = true

local auraRadius = 1000
local SCAN_OFFSET = 200
local SAMPLE_POINTS = 32

local layers = 5
local auraParts = {}
local dodgeConn

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Blacklist

local rowForceField = Instance.new("Frame")
rowForceField.Parent = ForceField.Frame
rowForceField.Size = UDim2.new(1,-12,1,-8)
rowForceField.Position = UDim2.fromOffset(120,4)
rowForceField.BackgroundTransparency = 1

local layoutForceField = Instance.new("UIListLayout")
layoutForceField.Parent = rowForceField
layoutForceField.FillDirection = Enum.FillDirection.Horizontal
layoutForceField.VerticalAlignment = Enum.VerticalAlignment.Center

local auraForceFieldBox = Instance.new("TextBox")
auraForceFieldBox.Parent = rowForceField
auraForceFieldBox.Size = UDim2.fromOffset(40,28)
auraForceFieldBox.Text = tostring(auraRadius)
auraForceFieldBox.PlaceholderText = "Aura"
auraForceFieldBox.ClearTextOnFocus = false
auraForceFieldBox.Font = Enum.Font.SourceSansBold
auraForceFieldBox.TextSize = 14
auraForceFieldBox.TextXAlignment = Enum.TextXAlignment.Center
auraForceFieldBox.TextColor3 = Color3.fromRGB(200,200,200)
auraForceFieldBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
auraForceFieldBox.BorderSizePixel = 0
Instance.new("UICorner", auraForceFieldBox).CornerRadius = UDim.new(0,6)

auraForceFieldBox:GetPropertyChangedSignal("Text"):Connect(function()

    local filtered = auraForceFieldBox.Text:gsub("%D","")

    if filtered == "" then
        auraForceFieldBox.Text = ""
        return
    end

    local num = math.clamp(tonumber(filtered),1,10000)
    auraForceFieldBox.Text = tostring(num)
    auraRadius = num

end)

local function createAura()

    if #auraParts > 0 then return end

    for i = 1, layers do
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Ball
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Material = Enum.Material.ForceField
        part.Color = Color3.fromRGB(0, 255, 0)
        
        local transparency = math.min(0.2 + (auraRadius / 50) * 0.1, 0.9)
        part.Transparency = transparency
        
        part.Parent = workspace

        table.insert(auraParts, part)
    end

end

local function updateAura(hrp)

    for _, part in pairs(auraParts) do
        
        part.Size = Vector3.new(
            auraRadius * 2,
            auraRadius * 2,
            auraRadius * 2
        )

        part.CFrame = CFrame.new(hrp.Position)
        local transparency = math.min(0.2 + (auraRadius / 30) * 0.1, 0.8)
        part.Transparency = transparency
    end

end

local function scanAndDetect(hrp)

    local enemies = {}
    local touchAura = false
    local pos = hrp.Position

    local parts = workspace:GetPartBoundsInRadius(
        pos,
        auraRadius + SCAN_OFFSET,
        overlapParams
    )

    for _,part in ipairs(parts) do

        local model = part:FindFirstAncestorOfClass("Model")
        if not model then continue end
        if model == LocalPlayer.Character then continue end

        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum then continue end

        local player = game:GetService("Players"):GetPlayerFromCharacter(model)
        if player then
            local enemyHRP = model:FindFirstChild("HumanoidRootPart")
            if enemyHRP then
                table.insert(enemies, enemyHRP)
                
                if (enemyHRP.Position - pos).Magnitude <= auraRadius then
                    touchAura = true
                end
            end
        end
    end

    return enemies, touchAura
end

local function fibonacciSphere(samples)

    if samples < 2 then samples = 2 end

    local points = {}
    local phi = math.pi * (3 - math.sqrt(5))

    for i = 0,samples-1 do

        local y = 1 - (i/(samples-1))*2
        local radius = math.sqrt(1 - y*y)

        local theta = phi * i

        local x = math.cos(theta) * radius
        local z = math.sin(theta) * radius

        table.insert(points,Vector3.new(x,y,z))

    end

    return points

end

local directions = fibonacciSphere(SAMPLE_POINTS)

local function spaceBlocked(pos)

    local parts = workspace:GetPartBoundsInRadius(
        pos,
        3,
        overlapParams
    )

    for _,p in ipairs(parts) do
        if p.CanCollide and p.Transparency < 0.9 then
            return true
        end
    end

    return false

end

local function findEscape(hrp, enemies)

    local origin = hrp.Position
    local escapeDistance = 200

    local bestPos
    local bestScore = -math.huge

    for _, dir in ipairs(directions) do

        local pos = origin + dir * escapeDistance

        if pos.Y <= 2000 and pos.Y < origin.Y then continue end
        if spaceBlocked(pos) then continue end

        local score = 0

        for _, e in ipairs(enemies) do
            score += (e.Position - pos).Magnitude
        end

        if score > bestScore then
            bestScore = score
            bestPos = pos
        end

    end

    return bestPos

end

local function startForceField()

    if dodgeConn then return end

    dodgeConn = RunService.Heartbeat:Connect(function()

        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        overlapParams.FilterDescendantsInstances = {char}

        updateAura(hrp)

        local enemies, touchAura = scanAndDetect(hrp)
        if #enemies == 0 then return end

        if touchAura then
            local escape = findEscape(hrp, enemies)

            if escape then
                hrp:PivotTo(
                    CFrame.new(
                        escape,
                        escape + hrp.CFrame.LookVector
                    )
                )
            end
        end

    end)

end

local function stopForceField()

    if dodgeConn then
        dodgeConn:Disconnect()
        dodgeConn = nil
    end

    for _,p in pairs(auraParts) do
        if p and p.Parent then
            p:Destroy()
        end
    end

    table.clear(auraParts)

end

ForceField.Pill.MouseButton1Click:Connect(function()

    ForceField.State = not ForceField.State

    if ForceField.State then

        ForceField.Pill.BackgroundColor3 = Color3.fromRGB(120,200,120)

        ForceField.SlotKnob:TweenPosition(
            UDim2.fromOffset(20,2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.15,
            true
        )

        createAura()
        startForceField()

    else

        ForceField.Pill.BackgroundColor3 = Color3.fromRGB(80,80,80)

        ForceField.SlotKnob:TweenPosition(
            UDim2.fromOffset(2,2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.15,
            true
        )

        stopForceField()

    end

end)

_G.StopForceFieldLoop = function()

    if dodgeConn then
        dodgeConn:Disconnect()
        dodgeConn = nil
    end

    for _,p in pairs(auraParts) do
        if p and p.Parent then
            p:Destroy()
        end
    end

    table.clear(auraParts)

    if ForceField then
        ForceField.State = false
    end

end
    
end)


pcall(function()

local InstantTeleportY = Slots[4]
InstantTeleportY.Pill.Visible = false
InstantTeleportY.SlotKnob.Visible = false
InstantTeleportY.Label.Visible = false
InstantTeleportY.State = nil
InstantTeleportY.Frame.ClipsDescendants = true

local MIN_INSTANT_TP_Y = 200
local MAX_INSTANT_TP_Y = 20000000

local rowInstantTpY = Instance.new("Frame")
rowInstantTpY.Parent = InstantTeleportY.Frame
rowInstantTpY.Size = UDim2.new(1,-8,1,-8)
rowInstantTpY.Position = UDim2.fromOffset(4,4)
rowInstantTpY.BackgroundTransparency = 1

local layoutInstantTpY = Instance.new("UIListLayout")
layoutInstantTpY.Parent = rowInstantTpY
layoutInstantTpY.FillDirection = Enum.FillDirection.Horizontal
layoutInstantTpY.VerticalAlignment = Enum.VerticalAlignment.Center
layoutInstantTpY.Padding = UDim.new(0,4)

local inputInstantTpYBox = Instance.new("TextBox")
inputInstantTpYBox.Parent = rowInstantTpY
inputInstantTpYBox.Size = UDim2.fromOffset(110,28)
inputInstantTpYBox.Text = "5000000"
inputInstantTpYBox.PlaceholderText = "Input Y"
inputInstantTpYBox.TextColor3 = Color3.fromRGB(230,230,230)
inputInstantTpYBox.PlaceholderColor3 = Color3.fromRGB(160,160,160)
inputInstantTpYBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
inputInstantTpYBox.ClearTextOnFocus = false
inputInstantTpYBox.Font = Enum.Font.SourceSansBold
inputInstantTpYBox.TextSize = 16
inputInstantTpYBox.TextXAlignment = Enum.TextXAlignment.Center
inputInstantTpYBox.TextYAlignment = Enum.TextYAlignment.Center
inputInstantTpYBox.BorderSizePixel = 0
Instance.new("UICorner", inputInstantTpYBox).CornerRadius = UDim.new(0,6)

local upInstantTpYBtn = Instance.new("TextButton")
upInstantTpYBtn.Parent = rowInstantTpY
upInstantTpYBtn.Size = UDim2.fromOffset(40,28)
upInstantTpYBtn.BackgroundColor3 = Color3.fromRGB(80,180,120)
upInstantTpYBtn.Text = ""
upInstantTpYBtn.BorderSizePixel = 0
Instance.new("UICorner", upInstantTpYBtn).CornerRadius = UDim.new(0,6)

local upIcon = Instance.new("ImageLabel")
upIcon.Parent = upInstantTpYBtn
upIcon.BackgroundTransparency = 1
upIcon.Size = UDim2.fromScale(0.85,0.85)
upIcon.Position = UDim2.fromScale(0.075,0.075)
upIcon.Image = "rbxassetid://6031090990"

local downInstantTpYBtn = Instance.new("TextButton")
downInstantTpYBtn.Parent = rowInstantTpY
downInstantTpYBtn.Size = UDim2.fromOffset(40,28)
downInstantTpYBtn.BackgroundColor3 = Color3.fromRGB(180,80,80)
downInstantTpYBtn.Text = ""
downInstantTpYBtn.BorderSizePixel = 0
Instance.new("UICorner", downInstantTpYBtn).CornerRadius = UDim.new(0,6)

local downIcon = Instance.new("ImageLabel")
downIcon.Parent = downInstantTpYBtn
downIcon.BackgroundTransparency = 1
downIcon.Size = UDim2.fromScale(0.85,0.85)
downIcon.Position = UDim2.fromScale(0.075,0.075)
downIcon.Image = "rbxassetid://6031090990"
downIcon.Rotation = 180

inputInstantTpYBox:GetPropertyChangedSignal("Text"):Connect(function()

	local text = inputInstantTpYBox.Text:gsub("%D","")

	if text == "" then
		inputInstantTpYBox.Text = ""
		return
	end

	local num = tonumber(text)
	if not num then
		inputInstantTpYBox.Text = ""
		return
	end

	num = math.clamp(math.floor(num),0,MAX_INSTANT_TP_Y)

	local fixed = tostring(num)
	if inputInstantTpYBox.Text ~= fixed then
		inputInstantTpYBox.Text = fixed
	end
end)

local function applyInstantTpYOffset(direction)

	local value = tonumber(inputInstantTpYBox.Text)
	if not value or value <= 0 then return end

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local currentY = hrp.Position.Y
	local targetY = currentY + (value * direction)

	targetY = math.clamp(targetY,MIN_INSTANT_TP_Y,MAX_INSTANT_TP_Y)

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	hrp.CFrame = CFrame.new(
		hrp.Position.X,
		targetY,
		hrp.Position.Z
	)
end

upInstantTpYBtn.MouseButton1Click:Connect(function()
	applyInstantTpYOffset(1)
end)

downInstantTpYBtn.MouseButton1Click:Connect(function()
	applyInstantTpYOffset(-1)
end)

end)


local LocalInformation = Slots[14]  
LocalInformation.Label.Text = "Information"  
LocalInformation.Frame.ClipsDescendants = true  

local rowLocalInformation = Instance.new("Frame")  
rowLocalInformation.Parent = LocalInformation.Frame  
rowLocalInformation.Size = UDim2.new(1,-12,1,-8)  
rowLocalInformation.Position = UDim2.fromOffset(120,4)  
rowLocalInformation.BackgroundTransparency = 1  
rowLocalInformation.ZIndex = 20  

local layoutLocalInformation = Instance.new("UIListLayout")  
layoutLocalInformation.Parent = rowLocalInformation  
layoutLocalInformation.FillDirection = Enum.FillDirection.Horizontal  
layoutLocalInformation.VerticalAlignment = Enum.VerticalAlignment.Center  
layoutLocalInformation.Padding = UDim.new(0,6)  

local copyLocalInformationBtn = Instance.new("TextButton")  
copyLocalInformationBtn.Parent = rowLocalInformation  
copyLocalInformationBtn.Size = UDim2.fromOffset(40,28)  
copyLocalInformationBtn.Text = "Copy"  
copyLocalInformationBtn.Font = Enum.Font.SourceSansBold  
copyLocalInformationBtn.TextSize = 14  
copyLocalInformationBtn.TextColor3 = Color3.fromRGB(0,0,0)  
copyLocalInformationBtn.BackgroundColor3 = Color3.fromRGB(120,200,120)  
copyLocalInformationBtn.BorderSizePixel = 0  
copyLocalInformationBtn.ZIndex = 21  
Instance.new("UICorner",copyLocalInformationBtn).CornerRadius = UDim.new(0,6)  

local positionLocalInformationGui
local frameLocalInformation
local positionLocalInformationLabel
local speedLocalInformationLabel

local function createGui()

	if positionLocalInformationGui then return end

	positionLocalInformationGui = Instance.new("ScreenGui")
	positionLocalInformationGui.Name = "PositionDisplayGui"
	positionLocalInformationGui.ResetOnSpawn = false
	positionLocalInformationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	frameLocalInformation = Instance.new("Frame")
	frameLocalInformation.Parent = positionLocalInformationGui
	frameLocalInformation.Size = UDim2.fromOffset(180,50)
	frameLocalInformation.Position = UDim2.fromOffset(10,10)
	frameLocalInformation.BackgroundColor3 = Color3.fromRGB(20,20,20)
	frameLocalInformation.BackgroundTransparency = 0.3
	frameLocalInformation.BorderSizePixel = 0
	frameLocalInformation.ZIndex = 9990
	Instance.new("UICorner",frameLocalInformation).CornerRadius = UDim.new(0,8)

	positionLocalInformationLabel = Instance.new("TextLabel")
	positionLocalInformationLabel.Parent = frameLocalInformation
	positionLocalInformationLabel.Size = UDim2.new(1,-10,0,28)
	positionLocalInformationLabel.Position = UDim2.fromOffset(5,0)
	positionLocalInformationLabel.BackgroundTransparency = 1
	positionLocalInformationLabel.Font = Enum.Font.SourceSansBold
	positionLocalInformationLabel.TextSize = 18
	positionLocalInformationLabel.TextColor3 = Color3.fromRGB(0,255,180)
	positionLocalInformationLabel.TextXAlignment = Enum.TextXAlignment.Left
	positionLocalInformationLabel.Text = "X:0 Y:0 Z:0"
	positionLocalInformationLabel.ZIndex = 10000

	speedLocalInformationLabel = Instance.new("TextLabel")
	speedLocalInformationLabel.Parent = frameLocalInformation
	speedLocalInformationLabel.Size = UDim2.new(1,-10,0,28)
	speedLocalInformationLabel.Position = UDim2.fromOffset(5,20)
	speedLocalInformationLabel.BackgroundTransparency = 1
	speedLocalInformationLabel.Font = Enum.Font.SourceSansBold
	speedLocalInformationLabel.TextSize = 16
	speedLocalInformationLabel.TextColor3 = Color3.fromRGB(0,170,255)
	speedLocalInformationLabel.TextXAlignment = Enum.TextXAlignment.Left
	speedLocalInformationLabel.Text = "Speed:0"
	speedLocalInformationLabel.ZIndex = 10000

end

local lastVector  
local lastTime = os.clock()  
local lastPosString = ""  
local threshold = 0.01  

local lastX,lastY,lastZ = nil,nil,nil  

BindSlot(LocalInformation,{
	Name = "LocalInformation",
	Type = "RenderParallel",
	Priority = 0,

	Default = true,

	AutoClearOnDeath = false,
	AutoResetOnRespawn = false,

	Callback = function(_,char,hum,hrp)

		if not hrp then return end

		if not positionLocalInformationGui or not positionLocalInformationGui.Parent then
			createGui()
		end

		local pos = hrp.Position  
		local x = math.floor(pos.X)  
		local y = math.floor(pos.Y)  
		local z = math.floor(pos.Z)  

		if x ~= lastX or y ~= lastY or z ~= lastZ then  

			positionLocalInformationLabel.Text = "X: "..x.." Y: "..y.." Z: "..z  
			lastPosString = x..", "..y..", "..z  

			lastX,lastY,lastZ = x,y,z  
		end  

		local now = os.clock()  
		local delta = now - lastTime  
		if delta <= 0 then return end  

		if lastVector then  

			local dx = pos.X - lastVector.X  
			local dz = pos.Z - lastVector.Z  

			local dist = math.sqrt(dx*dx + dz*dz)  

			if dist < threshold then  
				speedLocalInformationLabel.Text = "Speed: 0"  
			else  

				local speed = dist / delta  
				speedLocalInformationLabel.Text = "Speed: "..math.floor(speed).." studs/s"  

				if speed >= 500 then  
					speedLocalInformationLabel.TextColor3 = Color3.fromRGB(255,0,0)  
				else  
					speedLocalInformationLabel.TextColor3 = Color3.fromRGB(0,170,255)  
				end  
			end  
		end  

		lastVector = pos  
		lastTime = now  
	end
})

copyLocalInformationBtn.MouseButton1Click:Connect(function()

	if lastPosString ~= "" and setclipboard then
		pcall(function()
			setclipboard(lastPosString)
		end)
	end

end)

UpdateController:On("ForceDisable",function(name)

	if name ~= "LocalInformation" then return end

	if positionLocalInformationGui then
		positionLocalInformationGui:Destroy()
		positionLocalInformationGui = nil
	end

end)



local HitboxExpand = Slots[12]
HitboxExpand.Label.Text = "Hitbox Expand"
HitboxExpand.Frame.ClipsDescendants = true

local hitboxSizeValue = 200
local originalStates = {}

local RANGE_LIMIT = 3000

local cachedPlayers = {}
local lastCacheUpdate = 0
local CACHE_INTERVAL = 0.5

local rowHitboxExpand = Instance.new("Frame")
rowHitboxExpand.Parent = HitboxExpand.Frame
rowHitboxExpand.Size = UDim2.new(1,-12,1,-8)
rowHitboxExpand.Position = UDim2.fromOffset(120,4)
rowHitboxExpand.BackgroundTransparency = 1

local layoutHitboxExpand = Instance.new("UIListLayout")
layoutHitboxExpand.Parent = rowHitboxExpand
layoutHitboxExpand.FillDirection = Enum.FillDirection.Horizontal
layoutHitboxExpand.VerticalAlignment = Enum.VerticalAlignment.Center
layoutHitboxExpand.Padding = UDim.new(0,1)

local hitboxSizeBox = Instance.new("TextBox")
hitboxSizeBox.Parent = rowHitboxExpand
hitboxSizeBox.Size = UDim2.fromOffset(40,28)
hitboxSizeBox.Text = tostring(hitboxSizeValue)
hitboxSizeBox.PlaceholderText = "Size"
hitboxSizeBox.ClearTextOnFocus = false
hitboxSizeBox.Font = Enum.Font.SourceSansBold
hitboxSizeBox.TextSize = 14
hitboxSizeBox.TextXAlignment = Enum.TextXAlignment.Center
hitboxSizeBox.TextColor3 = Color3.fromRGB(200,200,200)
hitboxSizeBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
hitboxSizeBox.BorderSizePixel = 0
Instance.new("UICorner",hitboxSizeBox).CornerRadius = UDim.new(0,6)

local MIN_HITBOX = 1
local MAX_HITBOX = 10000

hitboxSizeBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = hitboxSizeBox.Text:gsub("%D","")

	if filtered == "" then
		hitboxSizeBox.Text = ""
		return
	end

	local num = math.clamp(
		tonumber(filtered),
		MIN_HITBOX,
		MAX_HITBOX
	)

	hitboxSizeBox.Text = tostring(num)
	hitboxSizeValue = num

end)

local function getHRP(player)

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")

	if not hrp then return end
	if not hrp:IsA("BasePart") then return end
	if hrp.Parent ~= char then return end

	return hrp

end

function restoreHitbox(player)

	local state = originalStates[player]
	if not state then return end

	local hrp = state.ref

	if hrp and hrp.Parent then
		hrp.Size = state.size
		hrp.Transparency = state.transparency
		hrp.Material = state.material
		hrp.Shape = state.shape
	end

end

local function applyHitbox(player, localHRP)

	if player == LocalPlayer then return end

	local hrp = getHRP(player)
	if not hrp then return end

	local dist = (hrp.Position - localHRP.Position).Magnitude

	if dist > RANGE_LIMIT then

		if originalStates[player] then
			restoreHitbox(player)
			originalStates[player] = nil
		end

		return
	end

	if originalStates[player] and originalStates[player].ref ~= hrp then
		restoreHitbox(player)
		originalStates[player] = nil
	end

	if not originalStates[player] then

		originalStates[player] = {
			ref = hrp,
			size = hrp.Size,
			transparency = hrp.Transparency,
			material = hrp.Material,
			shape = hrp.Shape
		}

	end

	local desired = Vector3.new(hitboxSizeValue,hitboxSizeValue,hitboxSizeValue)

	if hrp.Size ~= desired then

		hrp.Shape = Enum.PartType.Ball
		hrp.Size = desired
		hrp.Material = Enum.Material.Neon
		hrp.Transparency = 0.75

	end

end

local function fullRestore()

	for player in pairs(originalStates) do
		restoreHitbox(player)
	end

	table.clear(originalStates)

end

local function handlePlayer(player)

	if player == LocalPlayer then return end

	player.CharacterAdded:Connect(function()
		originalStates[player] = nil
	end)

	player.CharacterRemoving:Connect(function()
		restoreHitbox(player)
		originalStates[player] = nil
	end)

end

for _,p in ipairs(Players:GetPlayers()) do
	handlePlayer(p)
end

Players.PlayerAdded:Connect(handlePlayer)

Players.PlayerRemoving:Connect(function(player)
	restoreHitbox(player)
	originalStates[player] = nil
end)

BindSlot(HitboxExpand,{
	Name = "HitboxExpand",
	Type = "HeartbeatParallel",

	Default = false,

	AutoClearOnDeath = false,
	AutoResetOnRespawn = false,

	Callback = function(dt,char,hum,hrp)

		if not hrp then return end

		local now = tick()

		if now - lastCacheUpdate > CACHE_INTERVAL then

			lastCacheUpdate = now
			table.clear(cachedPlayers)

			for _,p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					table.insert(cachedPlayers,p)
				end
			end

		end

		for _,player in ipairs(cachedPlayers) do
			applyHitbox(player, hrp)
		end

	end
})

UpdateController:On("ForceDisable",function(name)

	if name == "HitboxExpand" then
		fullRestore()
	end

end)


local JumpForce = Slots[13]
JumpForce.Label.Text = "Jump Force"
JumpForce.Frame.ClipsDescendants = true

local jumpValue = 100

local rowJumpForce = Instance.new("Frame")
rowJumpForce.Parent = JumpForce.Frame
rowJumpForce.Size = UDim2.new(1,-12,1,-8)
rowJumpForce.Position = UDim2.fromOffset(120,4)
rowJumpForce.BackgroundTransparency = 1

local layoutJumpForce = Instance.new("UIListLayout")
layoutJumpForce.Parent = rowJumpForce
layoutJumpForce.FillDirection = Enum.FillDirection.Horizontal
layoutJumpForce.VerticalAlignment = Enum.VerticalAlignment.Center
layoutJumpForce.Padding = UDim.new(0,1)

local jumpBox = Instance.new("TextBox")
jumpBox.Parent = rowJumpForce
jumpBox.Size = UDim2.fromOffset(40,28)
jumpBox.Text = tostring(jumpValue)
jumpBox.PlaceholderText = "Jump"
jumpBox.ClearTextOnFocus = false
jumpBox.Font = Enum.Font.SourceSansBold
jumpBox.TextSize = 14
jumpBox.TextXAlignment = Enum.TextXAlignment.Center
jumpBox.TextColor3 = Color3.fromRGB(200,200,200)
jumpBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
jumpBox.BorderSizePixel = 0
Instance.new("UICorner",jumpBox).CornerRadius = UDim.new(0,6)

local MIN_JUMP = 1
local MAX_JUMP = 10000

local function readJump()
	return jumpValue
end

JumpForce.ReadJumpForce = readJump

jumpBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = jumpBox.Text:gsub("%D","")

	if filtered == "" then
		jumpBox.Text = ""
		return
	end

	local num = tonumber(filtered)
	if not num then return end

	num = math.clamp(num,MIN_JUMP,MAX_JUMP)

	if jumpBox.Text ~= tostring(num) then
		jumpBox.Text = tostring(num)
	end

	jumpValue = num

end)

BindSlot(JumpForce,{
	Name = "JumpForce",
	Type = "HeartbeatParallel",
	Default = false,

	Callback = function(dt,char,hum,hrp)

		if not hum.Jump then return end

		local vel = hrp.AssemblyLinearVelocity

		hrp.AssemblyLinearVelocity = Vector3.new(
			vel.X,
			jumpValue,
			vel.Z
		)

	end
})


local SpeedForce = Slots[18]
SpeedForce.Label.Text = "Speed Force"
SpeedForce.Frame.ClipsDescendants = true

local accel = 1
local speedValue = 300

local rowSpeedForce = Instance.new("Frame")
rowSpeedForce.Parent = SpeedForce.Frame
rowSpeedForce.Size = UDim2.new(1,-12,1,-8)
rowSpeedForce.Position = UDim2.fromOffset(120,4)
rowSpeedForce.BackgroundTransparency = 1

local layoutSpeedForce = Instance.new("UIListLayout")
layoutSpeedForce.Parent = rowSpeedForce
layoutSpeedForce.FillDirection = Enum.FillDirection.Horizontal
layoutSpeedForce.VerticalAlignment = Enum.VerticalAlignment.Center

local SpeedForceBox = Instance.new("TextBox")
SpeedForceBox.Parent = rowSpeedForce
SpeedForceBox.Size = UDim2.fromOffset(40,28)
SpeedForceBox.Text = tostring(speedValue)
SpeedForceBox.PlaceholderText = "Speed"
SpeedForceBox.ClearTextOnFocus = false
SpeedForceBox.Font = Enum.Font.SourceSansBold
SpeedForceBox.TextSize = 14
SpeedForceBox.TextXAlignment = Enum.TextXAlignment.Center
SpeedForceBox.TextColor3 = Color3.fromRGB(200,200,200)
SpeedForceBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
SpeedForceBox.BorderSizePixel = 0
Instance.new("UICorner",SpeedForceBox).CornerRadius = UDim.new(0,6)

local MIN_SPEED = 1
local MAX_SPEED = 10000

SpeedForceBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = SpeedForceBox.Text:gsub("%D","")

	if filtered == "" then
		SpeedForceBox.Text = ""
		return
	end

	local num = tonumber(filtered)
	if not num then return end

	num = math.clamp(num,MIN_SPEED,MAX_SPEED)

	if SpeedForceBox.Text ~= tostring(num) then
		SpeedForceBox.Text = tostring(num)
	end

	speedValue = num

end)

BindSlot(SpeedForce,{
	Name = "SpeedForce",
	Type = "HeartbeatParallel",
	Default = false,

	Callback = function(dt,char,hum,hrp)

		local dir = hum.MoveDirection
		local vel = hrp.AssemblyLinearVelocity

		if dir.Magnitude > 0 then

			local targetX = dir.X * speedValue
			local targetZ = dir.Z * speedValue

			hrp.AssemblyLinearVelocity = Vector3.new(
				vel.X + (targetX - vel.X)*accel,
				vel.Y,
				vel.Z + (targetZ - vel.Z)*accel
			)

		else
			hrp.AssemblyLinearVelocity = Vector3.new(
				vel.X*0.8,
				vel.Y,
				vel.Z*0.8
			)

		end

	end
})

UpdateController:On("ForceDisable",function(name)

	if name ~= "SpeedForce" then return end

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local vel = hrp.AssemblyLinearVelocity

	hrp.AssemblyLinearVelocity = Vector3.new(
		0,
		vel.Y,
		0
	)

end)





local selectedPlayer = nil
local selectedButton = nil
local playerButtons = {}

pcall(function()

local PlayerList= Slots[5]
PlayerList.Label.Text = "Player List"
PlayerList.Label.TextColor3 = Color3.fromRGB(230,50,50)
PlayerList.State = false
PlayerList.Frame.ClipsDescendants = false
PlayerList.Pill.Visible = false
PlayerList.SlotKnob.Visible = false

PlayerList.Label.Size = UDim2.new(1, -30, 1, 0)
PlayerList.Label.TextXAlignment = Enum.TextXAlignment.Left

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local arrowIcon = Instance.new("ImageLabel")
arrowIcon.Parent = PlayerList.Frame
arrowIcon.Size = UDim2.fromOffset(18,18)
arrowIcon.AnchorPoint = Vector2.new(1,0.5)
arrowIcon.Position = UDim2.new(1,-8,0.5,0)
arrowIcon.BackgroundTransparency = 1
arrowIcon.Image = "rbxassetid://6034818372"
arrowIcon.Rotation = -90
arrowIcon.ScaleType = Enum.ScaleType.Fit
arrowIcon.ZIndex = 50

local clickArea = Instance.new("TextButton")
clickArea.Parent = PlayerList.Frame
clickArea.Size = UDim2.new(1,0,1,0)
clickArea.BackgroundTransparency = 1
clickArea.Text = ""
clickArea.AutoButtonColor = false
clickArea.ZIndex = 40

local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Parent = SettingsGui
PlayerListFrame.Size = UDim2.fromOffset(180,205)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.Visible = false
PlayerListFrame.ZIndex = 200
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0,8)

local stroke = Instance.new("UIStroke")
stroke.Parent = PlayerListFrame
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Thickness = 1.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Parent = PlayerListFrame
PlayerScroll.Position = UDim2.new(0,6,0,6)
PlayerScroll.Size = UDim2.new(1,-12,1,-12)
PlayerScroll.CanvasSize = UDim2.new(0,0,0,0)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ZIndex = 201

local layout = Instance.new("UIListLayout")
layout.Parent = PlayerScroll
layout.Padding = UDim.new(0,4)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
PlayerScroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 4)
end)

local function selectPlayer(plr, btn)

if selectedButton then    
	selectedButton.BackgroundColor3 = Color3.fromRGB(60,60,60)    
end    

selectedPlayer = plr    
selectedButton = btn    

btn.BackgroundColor3 = Color3.fromRGB(90,120,255)

end

local function addPlayer(plr)

if plr == LocalPlayer then return end    
if playerButtons[plr] then return end    

local btn = Instance.new("TextButton")    
btn.Size = UDim2.new(1,-4,0,28)    
btn.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"    
btn.Font = Enum.Font.SourceSansBold    
btn.TextSize = 14    
btn.BackgroundColor3 = Color3.fromRGB(60,60,60)    
btn.TextColor3 = Color3.fromRGB(230,230,230)    
btn.BorderSizePixel = 0    
btn.Parent = PlayerScroll    
btn.ZIndex = 202    

Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)    

btn.MouseButton1Click:Connect(function()    
	selectPlayer(plr, btn)    
end)    

playerButtons[plr] = btn

end

local function removePlayer(plr)

if selectedPlayer == plr then    
	selectedPlayer = nil    
	selectedButton = nil    
end    

if playerButtons[plr] then    
	playerButtons[plr]:Destroy()    
	playerButtons[plr] = nil    
end

end

for _, plr in ipairs(Players:GetPlayers()) do
addPlayer(plr)
end

local playerAddedConn = Players.PlayerAdded:Connect(addPlayer)
local playerRemovingConn = Players.PlayerRemoving:Connect(removePlayer)

local NEAR_DISTANCE = 5000
local nearestConn = nil

local function getNearestPlayer()

local char = LocalPlayer.Character    
if not char then return nil end    

local hrp = char:FindFirstChild("HumanoidRootPart")    
if not hrp then return nil end    

local nearest = nil    
local bestDist = NEAR_DISTANCE    

for plr,btn in pairs(playerButtons) do    

	local char2 = plr.Character    
	local hrp2 = char2 and char2:FindFirstChild("HumanoidRootPart")    

	if hrp2 then    

		local dist =    
		(hrp.Position - hrp2.Position).Magnitude    

		if dist < bestDist then    
			bestDist = dist    
			nearest = plr    
		end    

	end    

end    

return nearest

end

local function updateNearestHighlight()

local nearest = getNearestPlayer()    

for plr,btn in pairs(playerButtons) do    

	if plr == nearest then    

		btn.TextColor3 =    
		Color3.fromRGB(255,40,40)    

		btn.LayoutOrder = -100    

	else    

		btn.TextColor3 =    
		Color3.fromRGB(230,230,230)    

		btn.LayoutOrder = 0    

	end    

end

end

local function startNearestLoop()

if nearestConn then return end    

nearestConn =    
RunService.Heartbeat:Connect(updateNearestHighlight)

end

local function stopNearestLoop()

if nearestConn then    
	nearestConn:Disconnect()    
	nearestConn = nil    
end

end

local function updatePlayerListPosition()

local abs = DragFrame.AbsolutePosition    
local Y_OFFSET = 58    

local x = abs.X - PlayerListFrame.Size.X.Offset - 1    
local y = abs.Y + Y_OFFSET    

if x < 0 then    
	x = abs.X + DragFrame.AbsoluteSize.X + 1    
end    

PlayerListFrame.Position = UDim2.fromOffset(x, y)

end

local dragConn = DragFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updatePlayerListPosition)

clickArea.MouseButton1Click:Connect(function()

PlayerList.State = not PlayerList.State    

if PlayerList.State then    

	updatePlayerListPosition()    
	PlayerListFrame.Visible = true    
	arrowIcon.Rotation = 90    

	startNearestLoop()    

else    

	PlayerListFrame.Visible = false    
	arrowIcon.Rotation = -90    

	stopNearestLoop()    

end

end)

local function ShutdownPlayerList()

PlayerListFrame.Visible = false    

if playerAddedConn then    
	playerAddedConn:Disconnect()    
	playerAddedConn = nil    
end    

if playerRemovingConn then    
	playerRemovingConn:Disconnect()    
	playerRemovingConn = nil    
end    

if dragConn then    
	dragConn:Disconnect()    
	dragConn = nil    
end    

stopNearestLoop()    

for plr,_ in pairs(playerButtons) do    
	removePlayer(plr)    
end    

selectedPlayer = nil    
selectedButton = nil    

if PlayerList then    
	PlayerList.State = false    
end

end

_G.StopPlayerListLoop = function()

if ShutdownPlayerList then    
	ShutdownPlayerList()    
end

end

end)

local TeleportPlayer = Slots[10]
TeleportPlayer.Label.Text = "Teleport Player"
TeleportPlayer.Frame.ClipsDescendants = true

local rowTeleportPlayer = Instance.new("Frame")
rowTeleportPlayer.Parent = TeleportPlayer.Frame
rowTeleportPlayer.Size = UDim2.new(1,-12,1,-8)
rowTeleportPlayer.Position = UDim2.fromOffset(120,4)
rowTeleportPlayer.BackgroundTransparency = 1
rowTeleportPlayer.ZIndex = 20

local layoutTeleportPlayer = Instance.new("UIListLayout")
layoutTeleportPlayer.Parent = rowTeleportPlayer
layoutTeleportPlayer.FillDirection = Enum.FillDirection.Horizontal
layoutTeleportPlayer.VerticalAlignment = Enum.VerticalAlignment.Center
layoutTeleportPlayer.Padding = UDim.new(0,1)

local teleportSpeedBox = Instance.new("TextBox")
teleportSpeedBox.Parent = rowTeleportPlayer
teleportSpeedBox.Size = UDim2.fromOffset(40,28)
teleportSpeedBox.Text = "350"
teleportSpeedBox.PlaceholderText = "Speed"
teleportSpeedBox.ClearTextOnFocus = false
teleportSpeedBox.Font = Enum.Font.SourceSansBold
teleportSpeedBox.TextSize = 14
teleportSpeedBox.TextXAlignment = Enum.TextXAlignment.Center
teleportSpeedBox.TextColor3 = Color3.fromRGB(200,200,200)
teleportSpeedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
teleportSpeedBox.BorderSizePixel = 0
teleportSpeedBox.ZIndex = 21
Instance.new("UICorner",teleportSpeedBox).CornerRadius = UDim.new(0,6)

local MIN_TELEPORT_PLAYER_SPEED = 1
local MAX_TELEPORT_PLAYER_SPEED = 10000

local teleportSpeed = 350

teleportSpeedBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = teleportSpeedBox.Text:gsub("%D","")

	if filtered == "" then
		teleportSpeedBox.Text = ""
		return
	end

	local num = math.clamp(
		tonumber(filtered),
		MIN_TELEPORT_PLAYER_SPEED,
		MAX_TELEPORT_PLAYER_SPEED
	)

	teleportSpeed = num
	teleportSpeedBox.Text = tostring(num)

end)

local lastTeleportTime = 0

local function getStepDistance()

	local speed = math.max(0, teleportSpeed)

	return speed / TELEPORT_RATE

end

local function resetPhysics(hrp)

	local vel = hrp.AssemblyLinearVelocity

	hrp.AssemblyLinearVelocity = Vector3.new(
		vel.X,
		0,
		vel.Z
	)

	hrp.AssemblyAngularVelocity = Vector3.zero

end

local function forceMoveToPlayer(hrp,targetCF,stepDist)

	local pos = hrp.Position
	local targetPos = targetCF.Position

	local delta = targetPos - pos
	local dist = delta.Magnitude

	if dist <= stepDist then

		local snapPos = Vector3.new(
			targetPos.X,
			targetPos.Y + 0.1,
			targetPos.Z
		)

		hrp.CFrame =
		CFrame.new(snapPos) *
		targetCF.Rotation

		resetPhysics(hrp)

		return
	end

	local newPos =
	pos + delta.Unit * stepDist

	hrp.CFrame =
	CFrame.new(newPos) *
	targetCF.Rotation

	resetPhysics(hrp)

end

local teleportPlayerEnabled = true
local teleportPlayerUsingNoclip = false

local function stopTeleportPlayerNoclip()

	if teleportPlayerUsingNoclip then
		teleportPlayerUsingNoclip = false
		removeNoclipUser()
	end

end

BindSlot(TeleportPlayer,{

	Name = "TeleportPlayer",
	Type = "HeartbeatOverride",
	Priority = 5,
	Default = false,

	AutoClearOnDeath = false,
	AutoResetOnRespawn = false,

	OnToggle = function(state)

		if not state then
			stopTeleportPlayerNoclip()
		end

	end,

	Callback = function(dt,char,hum,hrp)

		if not TeleportPlayer.State then
			stopTeleportPlayerNoclip()
			return
		end

		local now = os.clock()

		if now - lastTeleportTime < TELEPORT_INTERVAL then
			return
		end

		lastTeleportTime = now

		teleportPlayerEnabled =
		updateHPState(teleportPlayerEnabled)

		if not teleportPlayerEnabled then
			stopTeleportPlayerNoclip()
			return
		end

		if not selectedPlayer or not selectedPlayer.Parent then
			selectedPlayer = nil
			stopTeleportPlayerNoclip()
			return
		end

		local targetChar = selectedPlayer.Character
		if not targetChar then return end

		local targetHRP =
		targetChar:FindFirstChild("HumanoidRootPart")
		if not targetHRP then return end

		if not teleportPlayerUsingNoclip then
			teleportPlayerUsingNoclip = true
			addNoclipUser()
		end

		local stepDist = getStepDistance()

		forceMoveToPlayer(
			hrp,
			targetHRP.CFrame,
			stepDist
		)

	end
})

UpdateController:On("ForceDisable",function(name)

	if name == "TeleportPlayer" then

		stopTeleportPlayerNoclip()

		if TeleportPlayer then
			TeleportPlayer.State = false
		end

	end

end)

Players.PlayerRemoving:Connect(function(plr)

	if selectedPlayer == plr then
		selectedPlayer = nil
	end

end)



pcall(function()
local TeleportBackstab = Slots[11]
TeleportBackstab.Label.Text = "TP Backstab"
TeleportBackstab.Frame.ClipsDescendants = true

local rowTeleportBackstab = Instance.new("Frame")
rowTeleportBackstab.Parent = TeleportBackstab.Frame
rowTeleportBackstab.Size = UDim2.new(1,-12,1,-8)
rowTeleportBackstab.Position = UDim2.fromOffset(120,4)
rowTeleportBackstab.BackgroundTransparency = 1
rowTeleportBackstab.ZIndex = 20

local layoutTeleportBackstab = Instance.new("UIListLayout")
layoutTeleportBackstab.Parent = rowTeleportBackstab
layoutTeleportBackstab.FillDirection = Enum.FillDirection.Horizontal
layoutTeleportBackstab.VerticalAlignment = Enum.VerticalAlignment.Center
layoutTeleportBackstab.Padding = UDim.new(0,1)

local radiusBackstabBox = Instance.new("TextBox")
radiusBackstabBox.Parent = rowTeleportBackstab
radiusBackstabBox.Size = UDim2.fromOffset(40,28)
radiusBackstabBox.Text = "500"
radiusBackstabBox.PlaceholderText = "Radius"
radiusBackstabBox.ClearTextOnFocus = false
radiusBackstabBox.Font = Enum.Font.SourceSansBold
radiusBackstabBox.TextSize = 14
radiusBackstabBox.TextColor3 = Color3.fromRGB(200,200,200)
radiusBackstabBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
radiusBackstabBox.BorderSizePixel = 0
radiusBackstabBox.ZIndex = 21
Instance.new("UICorner",radiusBackstabBox).CornerRadius = UDim.new(0,6)

local MIN_BACKSTAB_RADIUS = 1
local MAX_BACKSTAB_RADIUS = 10000

local backstabRadius = 500

radiusBackstabBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = radiusBackstabBox.Text:gsub("%D","")

	if filtered == "" then
		radiusBackstabBox.Text = ""
		return
	end

	local num = math.clamp(
		tonumber(filtered),
		MIN_BACKSTAB_RADIUS,
		MAX_BACKSTAB_RADIUS
	)

	backstabRadius = num
	radiusBackstabBox.Text = tostring(num)

end)

local lastBackstabTeleportTime = 0

local function readTeleportSpeed()

	if teleportSpeed then
		return math.clamp(
			teleportSpeed,
			1,
			10000
		)
	end

	return 350

end

local function getBackstabStep()

	local speed = readTeleportSpeed()

	return speed / TELEPORT_RATE

end

local function getBackstabCF(targetHRP,radius)

	local offset = radius * 0.707

	local pos =
	(targetHRP.CFrame * CFrame.new(
		0,
		offset,
		offset
	)).Position

	return
	CFrame.new(pos) *
	targetHRP.CFrame.Rotation

end

local function forceBackstabMove(hrp,targetHRP,stepDist,radius)

	local targetCF =
	getBackstabCF(targetHRP,radius)

	local pos = hrp.Position
	local targetPos = targetCF.Position

	local delta = targetPos - pos
	local dist = delta.Magnitude

	if dist <= 0.05 then
		return
	end

	local step = math.min(dist,stepDist)

	local newPos =
	pos + delta.Unit * step

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	hrp.CFrame =
	CFrame.new(newPos) *
	targetCF.Rotation

end

local backstabEnabled = true
local backstabUsingNoclip = false

local function stopBackstabNoclip()

	if backstabUsingNoclip then
		backstabUsingNoclip = false
		removeNoclipUser()
	end

end

BindSlot(TeleportBackstab,{

	Name = "TeleportBackstab",
	Type = "HeartbeatOverride",
	Priority = 6,
	Default = false,

	AutoClearOnDeath = false,
	AutoResetOnRespawn = false,

	OnToggle = function(state)

		if not state then
			stopBackstabNoclip()
		end

	end,

	Callback = function(dt,char,hum,hrp)

		if not TeleportBackstab.State then
			stopBackstabNoclip()
			return
		end

		local now = os.clock()

		if now - lastBackstabTeleportTime < TELEPORT_INTERVAL then
			return
		end

		lastBackstabTeleportTime = now

		backstabEnabled =
		updateHPState(backstabEnabled)

		if not backstabEnabled then
			stopBackstabNoclip()
			return
		end

		if not selectedPlayer or not selectedPlayer.Parent then
			selectedPlayer = nil
			stopBackstabNoclip()
			return
		end

		local targetChar = selectedPlayer.Character
		if not targetChar then return end

		local targetHRP =
		targetChar:FindFirstChild("HumanoidRootPart")
		if not targetHRP then return end

		if not backstabUsingNoclip then
			backstabUsingNoclip = true
			addNoclipUser()
		end

		local stepDist =
		getBackstabStep()

		forceBackstabMove(
			hrp,
			targetHRP,
			stepDist,
			backstabRadius
		)

	end
})

UpdateController:On("ForceDisable",function(name)

	if name == "TeleportBackstab" then

		stopBackstabNoclip()

		if TeleportBackstab then
			TeleportBackstab.State = false
		end

	end

end)

Players.PlayerRemoving:Connect(function(plr)

	if selectedPlayer == plr then
		selectedPlayer = nil
	end

end)

end)

pcall(function()

local Waypoint = Slots[15]
Waypoint.Label.Text = "Waypoint"
Waypoint.Frame.ClipsDescendants = true

local rowWaypoint = Instance.new("Frame")
rowWaypoint.Parent = Waypoint.Frame
rowWaypoint.Size = UDim2.new(1,-12,1,-8)
rowWaypoint.Position = UDim2.fromOffset(4,4)
rowWaypoint.BackgroundTransparency = 1
rowWaypoint.ZIndex = 20

local layoutWaypoint = Instance.new("UIListLayout")
layoutWaypoint.Parent = rowWaypoint
layoutWaypoint.FillDirection = Enum.FillDirection.Horizontal
layoutWaypoint.VerticalAlignment = Enum.VerticalAlignment.Center
layoutWaypoint.Padding = UDim.new(0,6)

local wpBox = Instance.new("TextBox")
wpBox.Parent = rowWaypoint
wpBox.Size = UDim2.fromOffset(110,28)
wpBox.Text = "-16482, 528, 524"
wpBox.PlaceholderText = "X, Y, Z"
wpBox.ClearTextOnFocus = false
wpBox.Font = Enum.Font.SourceSansBold
wpBox.TextSize = 14
wpBox.TextColor3 = Color3.fromRGB(200,200,200)
wpBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
wpBox.BorderSizePixel = 0
wpBox.ZIndex = 21

Instance.new("UICorner",wpBox).CornerRadius = UDim.new(0,6)

local saveBtn = Instance.new("TextButton")
saveBtn.Parent = rowWaypoint
saveBtn.Size = UDim2.fromOffset(40,28)
saveBtn.Text = "Save"
saveBtn.Font = Enum.Font.SourceSansBold
saveBtn.TextSize = 14
saveBtn.TextColor3 = Color3.fromRGB(0,0,0)
saveBtn.BackgroundColor3 = Color3.fromRGB(120,200,120)
saveBtn.BorderSizePixel = 0
saveBtn.ZIndex = 21

Instance.new("UICorner",saveBtn).CornerRadius = UDim.new(0,6)

local lastWaypointTeleportTime = 0

local MIN_INPUT_TARGET_VALUE = -2100000000
local MAX_INPUT_TARGET_VALUE = 2100000000

local waypointCF = nil
local waypointEnabled = true
local waypointUsingNoclip = false

local function readWaypointSpeed()

	if teleportSpeed then
		return math.clamp(
			teleportSpeed,
			1,
			10000
		)
	end

	return 350

end

local function getWaypointStep()

	local speed = readWaypointSpeed()

	return speed / TELEPORT_RATE

end

local function formatPos(v)

	return string.format(
		"%d,%d,%d",
		math.floor(v.X),
		math.floor(v.Y),
		math.floor(v.Z)
	)

end

local function parseWP(text)

	text = text:gsub("%s+","")

	local x,y,z =
	text:match("^(-?%d+%.?%d*),(-?%d+%.?%d*),(-?%d+%.?%d*)$")

	if not x then return end

	x = math.clamp(tonumber(x),MIN_INPUT_TARGET_VALUE,MAX_INPUT_TARGET_VALUE)
	y = math.clamp(tonumber(y),MIN_INPUT_TARGET_VALUE,MAX_INPUT_TARGET_VALUE)
	z = math.clamp(tonumber(z),MIN_INPUT_TARGET_VALUE,MAX_INPUT_TARGET_VALUE)

	return CFrame.new(x,y,z)

end

local WPBOX_OK = Color3.fromRGB(40,40,40)
local WPBOX_ERR = Color3.fromRGB(120,40,40)

wpBox:GetPropertyChangedSignal("Text"):Connect(function()

	if wpBox.Text == "" then
		wpBox.BackgroundColor3 = WPBOX_OK
		return
	end

	local cf = parseWP(wpBox.Text)

	if not cf then
		wpBox.BackgroundColor3 = WPBOX_ERR
		return
	end

	wpBox.BackgroundColor3 = WPBOX_OK
	waypointCF = cf

end)

do
	local cf = parseWP(wpBox.Text)
	if cf then
		waypointCF = cf
	end
end

saveBtn.MouseButton1Click:Connect(function()

	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	waypointCF = hrp.CFrame
	wpBox.Text = formatPos(hrp.Position)

end)

local function lockWPBox(state)

	wpBox.TextEditable = not state
	wpBox.Active = not state
	wpBox.Selectable = not state

	if state then
		wpBox.TextColor3 = Color3.fromRGB(150,150,150)
	else
		wpBox.TextColor3 = Color3.fromRGB(230,230,230)
	end

end

local function forceMoveToWaypoint(hrp,targetCF,stepDist)

	local pos = hrp.Position
	local target = targetCF.Position

	local dx = target.X - pos.X
	local dy = target.Y - pos.Y
	local dz = target.Z - pos.Z

	local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
	if dist < 0.05 then return end

	local scale = stepDist / dist
	if scale > 1 then scale = 1 end

	local newPos = Vector3.new(
		pos.X + dx * scale,
		pos.Y + dy * scale,
		pos.Z + dz * scale
	)

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	hrp.CFrame =
		CFrame.new(newPos) *
		hrp.CFrame.Rotation

end

local function stopWaypointNoclip()

	if waypointUsingNoclip then
		waypointUsingNoclip = false
		removeNoclipUser()
	end

end

BindSlot(Waypoint,{

	Name = "WaypointTeleport",
	Type = "HeartbeatOverride",
	Priority = 7,
	Default = false,

	AutoClearOnDeath = false,
	AutoResetOnRespawn = false,

	OnToggle = function(state)

		lockWPBox(state)

		if not state then
			stopWaypointNoclip()
		end

	end,

	Callback = function(dt,char,hum,hrp)

		if not Waypoint.State then
			stopWaypointNoclip()
			return
		end

		local now = os.clock()

		if now - lastWaypointTeleportTime < TELEPORT_INTERVAL then
			return
		end

		lastWaypointTeleportTime = now

		waypointEnabled =
		updateHPState(waypointEnabled)

		if not waypointEnabled then
			stopWaypointNoclip()
			return
		end

		if not waypointCF then
			return
		end

		if not waypointUsingNoclip then
			waypointUsingNoclip = true
			addNoclipUser()
		end

		local stepDist = getWaypointStep()

		forceMoveToWaypoint(
			hrp,
			waypointCF,
			stepDist
		)

	end
})

UpdateController:On("ForceDisable",function(name)

	if name == "WaypointTeleport" then

		stopWaypointNoclip()

		if Waypoint then
			Waypoint.State = false
		end

	end

end)

end)


pcall(function()


local TeleportPlayerInstant = Slots[16]
TeleportPlayerInstant.Label.Text = "TP Player Instant "
TeleportPlayerInstant.Label.TextColor3 = Color3.fromRGB(230,50,50)
TeleportPlayerInstant.Frame.ClipsDescendants = true

local rowTPInstant = Instance.new("Frame")
rowTPInstant.Parent = TeleportPlayerInstant.Frame
rowTPInstant.Size = UDim2.new(1,-12,1,-8)
rowTPInstant.Position = UDim2.fromOffset(120,4)
rowTPInstant.BackgroundTransparency = 1
rowTPInstant.ZIndex = 20

local layoutTPInstant = Instance.new("UIListLayout")
layoutTPInstant.Parent = rowTPInstant
layoutTPInstant.FillDirection = Enum.FillDirection.Horizontal
layoutTPInstant.VerticalAlignment = Enum.VerticalAlignment.Center
layoutTPInstant.Padding = UDim.new(0,1)

local radiusInstantTpBox = Instance.new("TextBox")
radiusInstantTpBox.Parent = rowTPInstant
radiusInstantTpBox.Size = UDim2.fromOffset(40,28)
radiusInstantTpBox.Text = "1"
radiusInstantTpBox.PlaceholderText = "Radius"
radiusInstantTpBox.ClearTextOnFocus = false
radiusInstantTpBox.Font = Enum.Font.SourceSansBold
radiusInstantTpBox.TextSize = 14
radiusInstantTpBox.TextXAlignment = Enum.TextXAlignment.Center
radiusInstantTpBox.TextColor3 = Color3.fromRGB(200,200,200)
radiusInstantTpBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
radiusInstantTpBox.BorderSizePixel = 0
radiusInstantTpBox.ZIndex = 21
Instance.new("UICorner",radiusInstantTpBox).CornerRadius = UDim.new(0,6)

local MIN_RADIUS = 1
local MAX_RADIUS = 10000
local instantRadius = 1

radiusInstantTpBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = radiusInstantTpBox.Text:gsub("%D","")

	if filtered == "" then
		radiusInstantTpBox.Text = ""
		return
	end

	local num = math.clamp(
		tonumber(filtered),
		MIN_RADIUS,
		MAX_RADIUS
	)

	instantRadius = num
	radiusInstantTpBox.Text = tostring(num)

end)

local renderConn
local instantTPEnabled = true

local function getInstantBackstabCF(targetHRP)

	local offset = instantRadius * 0.707

	local pos =
		targetHRP.Position
		- targetHRP.CFrame.LookVector * offset
		+ Vector3.new(0,offset,0)

	return
	CFrame.new(pos) *
	targetHRP.CFrame.Rotation

end

local function doTeleport()

	instantTPEnabled =
	updateHPState(instantTPEnabled)

	if not instantTPEnabled then
		return
	end

	if not selectedPlayer or not selectedPlayer.Parent then
		selectedPlayer = nil
		return
	end

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local targetChar = selectedPlayer.Character
	if not targetChar then return end

	local targetHRP =
	targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end

	local backstabCF =
	getInstantBackstabCF(targetHRP)

	local behindPos =
	backstabCF.Position

	if (hrp.Position - behindPos).Magnitude < 0.05 then
		return
	end

	hrp.AssemblyLinearVelocity =
	Vector3.zero

	hrp.AssemblyAngularVelocity =
	Vector3.zero

	hrp.CFrame =
	backstabCF

end

local function enableTP()

	if renderConn then
		return
	end

	renderConn =
	RunService.RenderStepped:Connect(function()

		if TeleportPlayerInstant.State then
			doTeleport()
		end

	end)

end

local function disableTP()

	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end

end

local function setToggle(state)

	TeleportPlayerInstant.State = state

	if state then

		TeleportPlayerInstant.Pill.BackgroundColor3 =
		Color3.fromRGB(120,200,120)

		TeleportPlayerInstant.SlotKnob.Position =
		UDim2.fromOffset(20,2)

		enableTP()

	else

		TeleportPlayerInstant.Pill.BackgroundColor3 =
		Color3.fromRGB(80,80,80)

		TeleportPlayerInstant.SlotKnob.Position =
		UDim2.fromOffset(2,2)

		disableTP()

	end

end

TeleportPlayerInstant.Pill.MouseButton1Click:Connect(function()
	setToggle(not TeleportPlayerInstant.State)
end)

setToggle(false)

_G.StopTPInstantLoop = function()

	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end

	if TeleportPlayerInstant then
		TeleportPlayerInstant.State = false
	end

end

Players.PlayerRemoving:Connect(function(plr)

	if selectedPlayer == plr then
		selectedPlayer = nil
	end

end)


end)



pcall(function()

local AntiEscape = Slots[6]
AntiEscape.Label.Text = "Anti Safe Mode"
AntiEscape.Frame.ClipsDescendants = true

local dynamicFloor = nil
local dynamicCeiling = nil

local CEILING_OFFSET = 300
local FLOOR_OFFSET = -5

local ceilingLockEnabled = true

local function startDynamicHeight()

	if dynamicFloor then return end

	dynamicFloor = Instance.new("Part")
	dynamicFloor.Size = Vector3.new(1,1,1)
	dynamicFloor.Anchored = true
	dynamicFloor.CanCollide = true
	dynamicFloor.Transparency = 1
	dynamicFloor.Name = "DynamicFloor"
	dynamicFloor.Parent = workspace

	dynamicCeiling = Instance.new("Part")
	dynamicCeiling.Size = Vector3.new(1,1,1)
	dynamicCeiling.Anchored = true
	dynamicCeiling.CanCollide = true
	dynamicCeiling.Transparency = 1
	dynamicCeiling.Name = "DynamicCeiling"
	dynamicCeiling.Parent = workspace

end

local function stopDynamicHeight()

	if dynamicFloor then
		dynamicFloor:Destroy()
		dynamicFloor = nil
	end

	if dynamicCeiling then
		dynamicCeiling:Destroy()
		dynamicCeiling = nil
	end

end

local function updateDynamicHeight()

	if not AntiEscape.State then
		stopDynamicHeight()
		return
	end

	if not dynamicFloor then
		startDynamicHeight()
	end

	if not selectedPlayer then return end

	local myChar = LocalPlayer.Character
	if not myChar then return end

	local myHRP = myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end

	local targetChar = selectedPlayer.Character
	if not targetChar then return end

	local targetHRP =
	targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end

	local targetY = targetHRP.Position.Y
	local pos = myHRP.Position

	local floorY = targetY + FLOOR_OFFSET

	dynamicFloor.CFrame =
	CFrame.new(pos.X,floorY,pos.Z)

	if pos.Y < floorY then

		local newY = math.max(floorY + 10,pos.Y)

		myHRP.AssemblyLinearVelocity =
		Vector3.new(0,0,0)

		myHRP.CFrame =
		CFrame.new(pos.X,newY,pos.Z) *
		myHRP.CFrame.Rotation

	end

	local ceilingY = targetY + CEILING_OFFSET

	dynamicCeiling.CFrame =
	CFrame.new(pos.X,ceilingY,pos.Z)

	ceilingLockEnabled =
	updateHPState(ceilingLockEnabled)

	if ceilingLockEnabled then

		if pos.Y > ceilingY - 0.1 then

			local newY =
			math.min(ceilingY - 10,pos.Y)

			myHRP.AssemblyLinearVelocity =
			Vector3.new(0,0,0)

			myHRP.CFrame =
			CFrame.new(pos.X,newY,pos.Z) *
			myHRP.CFrame.Rotation

		end

	end

end

BindSlot(AntiEscape,{
	Name = "AntiEscape",
	Type = "HeartbeatParallel",

	Callback = function()
		updateDynamicHeight()
	end
})

UpdateController:On("ForceDisable",function(name)

	if name == "AntiEscape" then
		stopDynamicHeight()
	end

end)

end)


local SpectatorPlayer = Slots[7]
SpectatorPlayer.Label.Text = "Spectator Player"
SpectatorPlayer.Frame.ClipsDescendants = true

local currentSpectatedPlayer = nil
local targetHumanoid = nil

local characterConn = nil
local removeConn = nil
local respawnConn = nil
local targetChangeConn = nil

local spectatorAllowed = true

local function resetCamera()

	local char = LocalPlayer.Character
	if not char then return end

	local hum = char:FindFirstChild("Humanoid")
	if not hum then return end

	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = hum

end

local function clearTarget()

	targetHumanoid = nil
	currentSpectatedPlayer = nil

	if characterConn then
		characterConn:Disconnect()
		characterConn = nil
	end

	if removeConn then
		removeConn:Disconnect()
		removeConn = nil
	end

end

local function disableSpectator()

	clearTarget()

	if respawnConn then
		respawnConn:Disconnect()
		respawnConn = nil
	end

	if targetChangeConn then
		targetChangeConn:Disconnect()
		targetChangeConn = nil
	end

	resetCamera()

	if SpectatorPlayer.State then

		SpectatorPlayer.State = false

		SpectatorPlayer.Pill.BackgroundColor3 =
		Color3.fromRGB(80,80,80)

		SpectatorPlayer.SlotKnob:TweenPosition(
			UDim2.fromOffset(2,2),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.15,
			true
		)

	end

end

local function attachCamera(char)

	if not char then return end

	local humanoid =
	char:FindFirstChild("Humanoid")
	if not humanoid then return end

	targetHumanoid = humanoid

	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = humanoid

end

local function bindPlayer(player)

	if player == currentSpectatedPlayer then
		return
	end

	clearTarget()

	currentSpectatedPlayer = player

	if not player then
		disableSpectator()
		return
	end

	if player.Character then
		attachCamera(player.Character)
	end

	characterConn =
	player.CharacterAdded:Connect(function(char)

		task.delay(0.1,function()

			if SpectatorPlayer.State then
				attachCamera(char)
			end

		end)

	end)

	removeConn =
	player.AncestryChanged:Connect(function(_,parent)

		if not parent then
			disableSpectator()
		end

	end)

end

local function enableSpectator()

	bindPlayer(selectedPlayer)

	targetChangeConn =
	RunService.Heartbeat:Connect(function()

		if not SpectatorPlayer.State then return end

		spectatorAllowed =
		updateHPState(spectatorAllowed)

		if not spectatorAllowed then
			disableSpectator()
			return
		end

		if selectedPlayer ~= currentSpectatedPlayer then
			bindPlayer(selectedPlayer)
		end

	end)

	respawnConn =
	LocalPlayer.CharacterAdded:Connect(function()

		disableSpectator()

	end)

end

SpectatorPlayer.Pill.MouseButton1Click:Connect(function()

	spectatorAllowed =
	updateHPState(spectatorAllowed)

	if not spectatorAllowed then
		return
	end

	SpectatorPlayer.State =
	not SpectatorPlayer.State

	if SpectatorPlayer.State then

		SpectatorPlayer.Pill.BackgroundColor3 =
		Color3.fromRGB(120,200,120)

		SpectatorPlayer.SlotKnob:TweenPosition(
			UDim2.fromOffset(20,2),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.15,
			true
		)

		enableSpectator()

	else

		SpectatorPlayer.Pill.BackgroundColor3 =
		Color3.fromRGB(80,80,80)

		SpectatorPlayer.SlotKnob:TweenPosition(
			UDim2.fromOffset(2,2),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.15,
			true
		)

		disableSpectator()

	end

end)

UpdateController:On("ForceDisable",function(name)

	if name == "SpectatorPlayer" then
		disableSpectator()
	end

end)




local espCache = {}    
local espLoopConn = nil    
    
local UPDATE_RATE = 0.12    
local nextUpdate = 0    

local PlayerESP= Slots[19]   
PlayerESP.Label.Text = "ESP Player"    
PlayerESP.Frame.ClipsDescendants = true    
    
local function createBillboard()    
    local billboard = Instance.new("BillboardGui")    
    billboard.Name = "PlayerESP"    
    billboard.Size = UDim2.new(0,360,0,70)    
    billboard.StudsOffset = Vector3.new(0,2.6,0) 
    billboard.AlwaysOnTop = true    
    
    local label = Instance.new("TextLabel")    
    label.Name = "Loading..."    
    label.Parent = billboard    
    label.Size = UDim2.new(1,0,1,0)    
    label.BackgroundTransparency = 1    
    label.RichText = true    
    label.Font = Enum.Font.SourceSansBold    
    label.TextSize = 20    
    label.TextStrokeTransparency = 0    
    label.TextStrokeColor3 = Color3.fromRGB(10,10,10)    
    
    return billboard, label    
end    
    
local function getHealthColor(percent)    
    if percent < 30 then    
        return Color3.fromRGB(255,0,0)    
    elseif percent < 70 then    
        return Color3.fromRGB(255,200,0)    
    else    
        return Color3.fromRGB(0,255,0)    
    end    
end    
    
local function attachESP(player)    
    if player == LocalPlayer then return end    
    if espCache[player] then return end    
    
    local billboard, label = createBillboard()    
    espCache[player] = {    
        gui = billboard,    
        label = label,    
        lastText = ""    
    }    
end    
    
local function removeESP(player)    
    local data = espCache[player]    
    if not data then return end    
    if data.gui then    
        data.gui:Destroy()    
    end    
    espCache[player] = nil    
end    
    
local function updateESP()    
    local now = tick()    
    if now < nextUpdate then return end    
    nextUpdate = now + UPDATE_RATE    
    
    local myChar = LocalPlayer.Character    
    if not myChar then return end    
    
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")    
    if not myHRP then return end    
    
    camera = workspace.CurrentCamera    
    
    for player, data in pairs(espCache) do    
        local char = player.Character    
        if not char then continue end    
    
        local hrp = char:FindFirstChild("HumanoidRootPart")    
        if not hrp then continue end    
    
        if data.gui.Parent ~= hrp then    
            data.gui.Parent = hrp  
        end    
    
        local label = data.label    
        local camCF = camera.CFrame
        local dir = hrp.Position - camCF.Position

        if dir.Magnitude == 0 then continue end

        local dot = camCF.LookVector:Dot(dir.Unit)

        if dot <= 0 then
    	continue
    end
    
        local distance = (myHRP.Position - hrp.Position).Magnitude    
    
        if char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then    
            local txt = player.Name.." [ DEAD ]"    
            if txt ~= data.lastText then    
                data.lastText = txt    
                label.Text = txt    
                label.TextColor3 = Color3.fromRGB(255, 0, 0)    
            end    
            continue    
        end    
    
        local health = char.Humanoid.Health    
        local maxHealth = char.Humanoid.MaxHealth    
        if maxHealth <= 0 then continue end    
    
        local percent = (health/maxHealth)*100    
        local newText = string.format("<b>%s [ %.0fm ]</b>\n[ %.0f/%.0f ]", player.Name, distance, health, maxHealth)    
    
        if newText ~= data.lastText then    
            data.lastText = newText    
            label.Text = newText    
            label.TextColor3 = getHealthColor(percent)    
        end    
    end    
end    
    
local function enableESP()    
    for _,player in ipairs(Players:GetPlayers()) do    
        attachESP(player)    
    end    
    
    if not espLoopConn then    
        espLoopConn = RunService.Heartbeat:Connect(updateESP)    
    end    
end    
    
local function disableESP()    
    if espLoopConn then    
        espLoopConn:Disconnect()    
        espLoopConn = nil    
    end    
    
    for player in pairs(espCache) do    
        removeESP(player)    
    end    
end    
    
Players.PlayerAdded:Connect(function(player)    
    if PlayerESP.State then    
        attachESP(player)    
    end    
end)    
    
Players.PlayerRemoving:Connect(removeESP)    
    
local function setToggle(state)    
    PlayerESP.State = state    
    if state then    
        PlayerESP.Pill.BackgroundColor3 = Color3.fromRGB(120,200,120)    
        PlayerESP.SlotKnob.Position = UDim2.fromOffset(20,2)    
        enableESP()    
    else    
        PlayerESP.Pill.BackgroundColor3 = Color3.fromRGB(80,80,80)    
        PlayerESP.SlotKnob.Position = UDim2.fromOffset(2,2)    
        disableESP()    
    end    
end    
    
PlayerESP.Pill.MouseButton1Click:Connect(function()    
    setToggle(not PlayerESP.State)    
end)    
    
setToggle(false)   
    
_G.StopESPPlayerLoop = function()    
    if espLoopConn then    
        espLoopConn:Disconnect()    
        espLoopConn = nil    
    end    
    
    for player, data in pairs(espCache) do    
        if data.gui then    
            data.gui:Destroy()    
        end    
    end    
    
    table.clear(espCache)    
    
    if PlayerESP then    
        PlayerESP.State = false    
    end    
end


local overrideStep = 1

pcall(function()

local ForceEscape = Slots[17]
ForceEscape.Label.Text = "Force Escape"
ForceEscape.Label.TextColor3 = Color3.fromRGB(230,50,50)
ForceEscape.Frame.ClipsDescendants = true

local function getForceEscapeXZ()

	local signX = math.random(0,1)==0 and -1 or 1
	local signZ = math.random(0,1)==0 and -1 or 1

	local offX = signX * math.random(50,100)
	local offZ = signZ * math.random(50,100)

	return offX,offZ

end

BindSlot(ForceEscape,{

	Name = "ForceEscape",
	Type = "HeartbeatOverride",
	Priority = 10,
	Default = false,

	OnToggle = function(state)

		if state then
			overrideStep = 1
		end

	end,

	Callback = function(dt,char,hum,hrp)

		if not ForceEscape.State then
			return
		end

		local yBase = tonumber(yTeleportBox.Text)
		if not yBase then return end

		local pos = hrp.Position

		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero

		if overrideStep == 1 then

			hrp.CFrame = CFrame.new(pos.X,yBase,pos.Z)
			overrideStep = 2

		else

			local m = math.random(2,30)
			local yRandom = math.min(yBase*m,MAX_SAFE_Y)

			local offX,offZ = getForceEscapeXZ()

			hrp.CFrame = CFrame.new(
				pos.X + offX,
				yRandom,
				pos.Z + offZ
			)

			overrideStep = 1

		end

	end

})

UpdateController:On("ForceDisable",function(name)

	if name == "ForceEscape" then

		if ForceEscape then
			ForceEscape.State = false
		end

	end

end)

end)



pcall(function()

local System = Slots[21]
System.Label.Text = "System"
System.State = false
System.Frame.ClipsDescendants = true
System.Pill.Visible = false

local rowSystem = Instance.new("Frame")
rowSystem.Parent = System.Frame
rowSystem.Size = UDim2.new(1,-12,1,-8)
rowSystem.Position = UDim2.fromOffset(4,4)
rowSystem.BackgroundTransparency = 1
rowSystem.ZIndex = 20

local layoutSystem = Instance.new("UIListLayout")
layoutSystem.Parent = rowSystem
layoutSystem.FillDirection = Enum.FillDirection.Horizontal
layoutSystem.VerticalAlignment = Enum.VerticalAlignment.Center
layoutSystem.Padding = UDim.new(0,4)

local function attachConfirmLogic(btn,normal,hover,down,action)

	local CONFIRM_BG = Color3.fromRGB(0,0,0)
	local CONFIRM_TXT = Color3.fromRGB(255,255,255)

	local lastClick = 0
	local confirming = false

	local function resetVisual()
		btn.BackgroundColor3 = normal
		btn.TextColor3 = Color3.fromRGB(240,240,240)
		confirming = false
	end

	btn.BackgroundColor3 = normal
	btn.TextColor3 = Color3.fromRGB(240,240,240)

	btn.MouseEnter:Connect(function()
		if not confirming then
			btn.BackgroundColor3 = hover
		end
	end)

	btn.MouseLeave:Connect(function()
		if not confirming then
			btn.BackgroundColor3 = normal
		end
	end)

	btn.MouseButton1Down:Connect(function()
		if not confirming then
			btn.BackgroundColor3 = down
		end
	end)

	btn.MouseButton1Click:Connect(function()

		local now = tick()

		if now - lastClick <= 1 then
			lastClick = 0
			resetVisual()
			action()
			return
		end

		lastClick = now
		confirming = true
		btn.BackgroundColor3 = CONFIRM_BG
		btn.TextColor3 = CONFIRM_TXT

		task.delay(1,function()
			if tick() - lastClick >= 1 then
				resetVisual()
			end
		end)

	end)

end

local resetBtn = Instance.new("TextButton")
resetBtn.Parent = rowSystem
resetBtn.Size = UDim2.fromOffset(97,28)
resetBtn.Text = "Reset"
resetBtn.AutoButtonColor = false
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextSize = 14
resetBtn.BorderSizePixel = 0
resetBtn.ZIndex = 21

Instance.new("UICorner",resetBtn).CornerRadius = UDim.new(0,6)

attachConfirmLogic(
	resetBtn,
	Color3.fromRGB(70,180,120),
	Color3.fromRGB(90,200,140),
	Color3.fromRGB(50,150,100),
	function()

		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if hum then
			hum.Health = 0
		end

	end
)

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Parent = rowSystem
rejoinBtn.Size = UDim2.fromOffset(97,28)
rejoinBtn.Text = "Rejoin"
rejoinBtn.AutoButtonColor = false
rejoinBtn.Font = Enum.Font.SourceSansBold
rejoinBtn.TextSize = 14
rejoinBtn.BorderSizePixel = 0
rejoinBtn.ZIndex = 21

Instance.new("UICorner",rejoinBtn).CornerRadius = UDim.new(0,6)

attachConfirmLogic(
	rejoinBtn,
	Color3.fromRGB(80,140,200),
	Color3.fromRGB(100,160,220),
	Color3.fromRGB(60,120,180),
	function()

		game:GetService("TeleportService")
		:Teleport(game.PlaceId,LocalPlayer)

	end
)
end)


pcall(function()

local Server = Slots[22]
Server.Label.Text = "Server"
Server.State = false
Server.Frame.ClipsDescendants = true
Server.Pill.Visible = false

local rowServer = Instance.new("Frame")
rowServer.Parent = Server.Frame
rowServer.Size = UDim2.new(1,-12,1,-8)
rowServer.Position = UDim2.fromOffset(4,4)
rowServer.BackgroundTransparency = 1
rowServer.ZIndex = 20

local layoutServer = Instance.new("UIListLayout")
layoutServer.Parent = rowServer
layoutServer.FillDirection = Enum.FillDirection.Horizontal
layoutServer.VerticalAlignment = Enum.VerticalAlignment.Center
layoutServer.Padding = UDim.new(0,4)

local function attachConfirmLogic(btn,normal,hover,down,action)

	local CONFIRM_BG = Color3.fromRGB(0,0,0)
	local CONFIRM_TXT = Color3.fromRGB(255,255,255)

	local lastClick = 0
	local confirming = false

	local function resetVisual()
		btn.BackgroundColor3 = normal
		btn.TextColor3 = Color3.fromRGB(240,240,240)
		confirming = false
	end

	btn.BackgroundColor3 = normal
	btn.TextColor3 = Color3.fromRGB(240,240,240)

	btn.MouseEnter:Connect(function()
		if not confirming then
			btn.BackgroundColor3 = hover
		end
	end)

	btn.MouseLeave:Connect(function()
		if not confirming then
			btn.BackgroundColor3 = normal
		end
	end)

	btn.MouseButton1Down:Connect(function()
		if not confirming then
			btn.BackgroundColor3 = down
		end
	end)

	btn.MouseButton1Click:Connect(function()

		local now = tick()

		if now - lastClick <= 1 then
			lastClick = 0
			resetVisual()
			action()
			return
		end

		lastClick = now
		confirming = true
		btn.BackgroundColor3 = CONFIRM_BG
		btn.TextColor3 = CONFIRM_TXT

		task.delay(1,function()
			if tick() - lastClick >= 1 then
				resetVisual()
			end
		end)

	end)

end

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local PlaceID = game.PlaceId
local JobID = game.JobId

local visitedServers = {}

local function serverHop()

	local cursor = ""

	while true do

		local url =
		"https://games.roblox.com/v1/games/"..
		PlaceID..
		"/servers/Public?sortOrder=Asc&limit=100&cursor="..
		cursor

		local success,data = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if success and data and data.data then

			for _,server in pairs(data.data) do

				if server.playing < server.maxPlayers
				and server.id ~= JobID
				and not visitedServers[server.id] then

					visitedServers[server.id] = true

					TeleportService:TeleportToPlaceInstance(
						PlaceID,
						server.id,
						LocalPlayer
					)

					task.wait(3)

				end

			end

			cursor = data.nextPageCursor or ""

		end

		task.wait(1)

	end

end

local hopBtn = Instance.new("TextButton")
hopBtn.Parent = rowServer
hopBtn.Size = UDim2.fromOffset(97,28)
hopBtn.Text = "Hop"
hopBtn.AutoButtonColor = false
hopBtn.Font = Enum.Font.SourceSansBold
hopBtn.TextSize = 14
hopBtn.BorderSizePixel = 0
hopBtn.ZIndex = 21

Instance.new("UICorner",hopBtn).CornerRadius = UDim.new(0,6)

attachConfirmLogic(
	hopBtn,
	Color3.fromRGB(130,80,200), 
	Color3.fromRGB(150,100,220), 
	Color3.fromRGB(100,60,170), 
	function()

		task.spawn(serverHop)

	end
)

local leaveBtn = Instance.new("TextButton")
leaveBtn.Parent = rowServer
leaveBtn.Size = UDim2.fromOffset(97,28)
leaveBtn.Text = "Leave"
leaveBtn.AutoButtonColor = false
leaveBtn.Font = Enum.Font.SourceSansBold
leaveBtn.TextSize = 14
leaveBtn.BorderSizePixel = 0
leaveBtn.ZIndex = 21

Instance.new("UICorner",leaveBtn).CornerRadius = UDim.new(0,6)

attachConfirmLogic(
	leaveBtn,
	Color3.fromRGB(200,80,80),
	Color3.fromRGB(220,100,100),
	Color3.fromRGB(170,60,60),
	function()

		game:Shutdown()

	end
)


end)



local CamTarget
_G.CamRayResult = nil
_G.CamRayPosition = nil

pcall(function()

local FreeCam = Slots[8]
FreeCam.Label.Text = "Free Cam"
FreeCam.Label.TextColor3 = Color3.fromRGB(230,50,50)
FreeCam.Frame.ClipsDescendants = true

local rowFreecam = Instance.new("Frame")
rowFreecam.Parent = FreeCam.Frame
rowFreecam.Size = UDim2.new(1,-12,1,-8)
rowFreecam.Position = UDim2.fromOffset(76,4)
rowFreecam.BackgroundTransparency = 1
rowFreecam.ZIndex = 20

local layoutFreecam = Instance.new("UIListLayout")
layoutFreecam.Parent = rowFreecam
layoutFreecam.FillDirection = Enum.FillDirection.Horizontal
layoutFreecam.VerticalAlignment = Enum.VerticalAlignment.Center
layoutFreecam.Padding = UDim.new(0,2)

local tpCamBtn = Instance.new("TextButton")
tpCamBtn.Parent = rowFreecam
tpCamBtn.Size = UDim2.fromOffset(40,28)
tpCamBtn.Text = "TP"
tpCamBtn.Font = Enum.Font.SourceSansBold
tpCamBtn.TextSize = 14
tpCamBtn.TextColor3 = Color3.fromRGB(240,240,240)
tpCamBtn.BackgroundColor3 = Color3.fromRGB(70,180,120)
tpCamBtn.BorderSizePixel = 0
tpCamBtn.ZIndex = 21
Instance.new("UICorner",tpCamBtn).CornerRadius = UDim.new(0,6)

local freecamSpeedBox = Instance.new("TextBox")
freecamSpeedBox.Parent = rowFreecam
freecamSpeedBox.Size = UDim2.fromOffset(40,28)
freecamSpeedBox.Text = "200"
freecamSpeedBox.PlaceholderText = "Speed"
freecamSpeedBox.ClearTextOnFocus = false
freecamSpeedBox.Font = Enum.Font.SourceSansBold
freecamSpeedBox.TextSize = 14
freecamSpeedBox.TextXAlignment = Enum.TextXAlignment.Center
freecamSpeedBox.TextColor3 = Color3.fromRGB(200,200,200)
freecamSpeedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
freecamSpeedBox.BorderSizePixel = 0
freecamSpeedBox.ZIndex = 21
Instance.new("UICorner",freecamSpeedBox).CornerRadius = UDim.new(0,6)

local MIN_FREECAM_SPEED = 1
local MAX_FREECAM_SPEED = 1000000
local freecamSpeed = 50

freecamSpeedBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = freecamSpeedBox.Text:gsub("%D","")

	if filtered == "" then
		freecamSpeedBox.Text = ""
		return
	end

	local num = math.clamp(
		tonumber(filtered),
		MIN_FREECAM_SPEED,
		MAX_FREECAM_SPEED
	)

	freecamSpeed = num
	freecamSpeedBox.Text = tostring(num)

end)

local cam = camera

local ROT_PER_PIXEL_MOUSE = math.rad(1)
local ROT_PER_PIXEL_TOUCH = math.rad(1)

local yaw = 0
local pitch = 0

local keysDown = {}

local rotateTouch
local lastTouchPos
local moveTouch
local moveOrigin

local renderConn
local controls
local characterConn

local ringStroke
local dotFrame
local coordLabel
local distanceLabel

local validKeys = {
"Enum.KeyCode.W",
"Enum.KeyCode.A",
"Enum.KeyCode.S",
"Enum.KeyCode.D"
}

local function clearMovement()

	keysDown["Enum.KeyCode.W"] = false
	keysDown["Enum.KeyCode.A"] = false
	keysDown["Enum.KeyCode.S"] = false
	keysDown["Enum.KeyCode.D"] = false

	moveTouch = nil
	moveOrigin = nil
	rotateTouch = nil

end

local function disableCharacter()

	local playerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")

	if playerModule then

		local controlModule = require(playerModule):GetControls()

		if controlModule then
			controls = controlModule
			controlModule:Disable()
		end

	end

end

local function enableCharacter()

	if controls then
		controls:Enable()
	end

end

local function createCamTarget()

	if CamTarget then return end

	local gui = Instance.new("ScreenGui")
	gui.Name = "CamTargetGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(20,20)
	holder.Position = UDim2.new(0.5,0,0.5,0)
	holder.AnchorPoint = Vector2.new(0.5,0.5)
	holder.BackgroundTransparency = 1
	holder.Parent = gui

	local ring = Instance.new("Frame")
	ring.Size = UDim2.fromOffset(18,18)
	ring.Position = UDim2.new(0.5,0,0.5,0)
	ring.AnchorPoint = Vector2.new(0.5,0.5)
	ring.BackgroundTransparency = 1
	ring.Parent = holder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1,0)
	corner.Parent = ring

	ringStroke = Instance.new("UIStroke")
	ringStroke.Thickness = 1.5
	ringStroke.Color = Color3.fromRGB(255,255,255)
	ringStroke.Parent = ring

	dotFrame = Instance.new("Frame")
	dotFrame.Size = UDim2.fromOffset(4,4)
	dotFrame.Position = UDim2.new(0.5,0,0.5,0)
	dotFrame.AnchorPoint = Vector2.new(0.5,0.5)
	dotFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
	dotFrame.BorderSizePixel = 0
	dotFrame.Parent = holder

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1,0)
	dotCorner.Parent = dotFrame

	coordLabel = Instance.new("TextLabel")
	coordLabel.Size = UDim2.fromOffset(400,20)
	coordLabel.Position = UDim2.new(0.5,0,0.5,-14)
	coordLabel.AnchorPoint = Vector2.new(0.5,1)
	coordLabel.BackgroundTransparency = 1
	coordLabel.Font = Enum.Font.SourceSansBold
	coordLabel.TextSize = 16
	coordLabel.TextXAlignment = Enum.TextXAlignment.Center
	coordLabel.TextYAlignment = Enum.TextYAlignment.Center
	coordLabel.TextColor3 = Color3.fromRGB(255,255,255)
	coordLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	coordLabel.TextStrokeTransparency = 0.5
	coordLabel.Text = "(0 , 0 , 0)"
	coordLabel.Parent = gui

	distanceLabel = Instance.new("TextLabel")
	distanceLabel.Size = UDim2.fromOffset(200,18)
	distanceLabel.Position = UDim2.new(0.5,0,0.5,14)
	distanceLabel.AnchorPoint = Vector2.new(0.5,0)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Font = Enum.Font.SourceSansBold
	distanceLabel.TextSize = 15
	distanceLabel.TextColor3 = Color3.fromRGB(255,255,255)
	distanceLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	distanceLabel.TextStrokeTransparency = 0.5
	distanceLabel.Text = "Distance: 0"
	distanceLabel.Parent = gui

	CamTarget = gui

end

local function destroyCamTarget()

	if CamTarget then
		CamTarget:Destroy()
		CamTarget = nil
	end

end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local function updateCrosshair()

	local char = LocalPlayer.Character
	if not char then return end

	rayParams.FilterDescendantsInstances = {char}

	local result = workspace:Raycast(
		cam.CFrame.Position,
		cam.CFrame.LookVector * 100,
		rayParams
	)

	_G.CamRayResult = result

	local pos

	if result then
		pos = result.Position
	else
		pos = cam.CFrame.Position + cam.CFrame.LookVector * 100
	end

	_G.CamRayPosition = pos

	if coordLabel then
		coordLabel.Text = string.format("( %.0f , %.0f , %.0f )",pos.X,pos.Y,pos.Z)
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")

	if hrp and distanceLabel then
		local dist = (hrp.Position - pos).Magnitude
		distanceLabel.Text = "Distance: "..math.floor(dist)
	end

	if result then

		local hit = result.Instance
		local model = hit:FindFirstAncestorOfClass("Model")

		if model and Players:GetPlayerFromCharacter(model) then
			ringStroke.Color = Color3.fromRGB(255,60,60)
			dotFrame.BackgroundColor3 = Color3.fromRGB(255,60,60)
		else
			ringStroke.Color = Color3.fromRGB(255,220,0)
			dotFrame.BackgroundColor3 = Color3.fromRGB(255,220,0)
		end

	else

		ringStroke.Color = Color3.fromRGB(255,255,255)
		dotFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)

	end

end

local function renderStepped()

	local speed = freecamSpeed / 10

	local pos = cam.CFrame.Position
	local move = Vector3.zero

	if keysDown["Enum.KeyCode.W"] then
		move += cam.CFrame.LookVector
	end

	if keysDown["Enum.KeyCode.S"] then
		move -= cam.CFrame.LookVector
	end

	if keysDown["Enum.KeyCode.A"] then
		move -= cam.CFrame.RightVector
	end

	if keysDown["Enum.KeyCode.D"] then
		move += cam.CFrame.RightVector
	end

	if move.Magnitude > 0 then
		pos += move.Unit * speed
	end

	cam.CFrame =
	CFrame.new(pos)
	* CFrame.Angles(0,yaw,0)
	* CFrame.Angles(pitch,0,0)

	updateCrosshair()

end


local function startFreecam()

	if renderConn then return end

	local cf = cam.CFrame
	local _,y,_ = cf:ToEulerAnglesYXZ()

	yaw = y
	pitch = 0

	cam.CameraType = Enum.CameraType.Scriptable

	disableCharacter()

	createCamTarget()

	renderConn = RS.RenderStepped:Connect(renderStepped)

end

local function stopFreecam()

	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end

	destroyCamTarget()

	cam.CameraType = Enum.CameraType.Custom

	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			cam.CameraSubject = hum
		end
	end

	enableCharacter()

	clearMovement()

	yaw = 0
	pitch = 0

	rotateTouch = nil
	lastTouchPos = nil

	if FreeCam then
		FreeCam.State = false
		FreeCam.Pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
		FreeCam.SlotKnob.Position = UDim2.fromOffset(2,2)
	end

end

FreeCam.Pill.MouseButton1Click:Connect(function()

	FreeCam.State = not FreeCam.State

	if FreeCam.State then

		FreeCam.Pill.BackgroundColor3 = Color3.fromRGB(120,200,120)
		FreeCam.SlotKnob.Position = UDim2.fromOffset(20,2)

		startFreecam()

	else

		stopFreecam()

	end

end)

tpCamBtn.MouseButton1Click:Connect(function()

	if not FreeCam.State then
		return
	end

	local cf = cam.CFrame
	cam.CFrame = cf + (cf.LookVector * 1000)

end)

UIS.InputBegan:Connect(function(input)

	for i,key in pairs(validKeys) do
		if key == tostring(input.KeyCode) then
			keysDown[key] = true
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end

	if input.UserInputType == Enum.UserInputType.Touch then

		if input.Position.X > cam.ViewportSize.X/2 then

			rotateTouch = input
			lastTouchPos = input.Position

		elseif input.Position.X < cam.ViewportSize.X*0.35 then

			moveTouch = input
			moveOrigin = input.Position

		end

	end

end)

UIS.InputEnded:Connect(function(input)

	for key,v in pairs(keysDown) do
		if key == tostring(input.KeyCode) then
			keysDown[key] = false
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end

	if input == rotateTouch then
		rotateTouch = nil
	end

	if input == moveTouch then
		clearMovement()
	end

end)

UIS.InputChanged:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseMovement then

		if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then

			local delta = UIS:GetMouseDelta()

			yaw -= delta.X * ROT_PER_PIXEL_MOUSE
			pitch -= delta.Y * ROT_PER_PIXEL_MOUSE

			pitch = math.clamp(pitch,-math.rad(89),math.rad(89))

		end

	end

end)

UIS.TouchMoved:Connect(function(input)

	if input == rotateTouch then

		local delta = input.Position - lastTouchPos
		lastTouchPos = input.Position

		yaw -= delta.X * ROT_PER_PIXEL_TOUCH
		pitch -= delta.Y * ROT_PER_PIXEL_TOUCH

		pitch = math.clamp(pitch,-math.rad(89),math.rad(89))

	end

	if input == moveTouch then

		local dx = input.Position.X - moveOrigin.X
		local dy = input.Position.Y - moveOrigin.Y

		if dy < -10 then
			keysDown["Enum.KeyCode.W"] = true
			keysDown["Enum.KeyCode.S"] = false
		elseif dy > 10 then
			keysDown["Enum.KeyCode.W"] = false
			keysDown["Enum.KeyCode.S"] = true
		else
			keysDown["Enum.KeyCode.W"] = false
			keysDown["Enum.KeyCode.S"] = false
		end

		if dx < -10 then
			keysDown["Enum.KeyCode.A"] = true
			keysDown["Enum.KeyCode.D"] = false
		elseif dx > 10 then
			keysDown["Enum.KeyCode.A"] = false
			keysDown["Enum.KeyCode.D"] = true
		else
			keysDown["Enum.KeyCode.A"] = false
			keysDown["Enum.KeyCode.D"] = false
		end

	end

end)

characterConn = LocalPlayer.CharacterAdded:Connect(function()

	if FreeCam.State then
		stopFreecam()
	end

end)

_G.DestroyFreeCam = function()

	stopFreecam()

	if characterConn then
		characterConn:Disconnect()
		characterConn = nil
	end

end

end)





pcall(function()

local RayTarget = Slots[9]
RayTarget.Label.Text = "Ray Target"
RayTarget.Frame.ClipsDescendants = true

local rowRay = Instance.new("Frame")
rowRay.Parent = RayTarget.Frame
rowRay.Size = UDim2.new(1,-12,1,-8)
rowRay.Position = UDim2.fromOffset(4,4)
rowRay.BackgroundTransparency = 1
rowRay.ZIndex = 20

local layoutRay = Instance.new("UIListLayout")
layoutRay.Parent = rowRay
layoutRay.FillDirection = Enum.FillDirection.Horizontal
layoutRay.VerticalAlignment = Enum.VerticalAlignment.Center
layoutRay.Padding = UDim.new(0,2)


local modeBtn = Instance.new("TextButton")
modeBtn.Parent = rowRay
modeBtn.Size = UDim2.fromOffset(70,28)
modeBtn.Text = "Tween Mode"
modeBtn.Font = Enum.Font.SourceSansBold
modeBtn.TextSize = 14
modeBtn.TextColor3 = Color3.fromRGB(240,240,240)
modeBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
modeBtn.BorderSizePixel = 0
modeBtn.ZIndex = 21
Instance.new("UICorner",modeBtn).CornerRadius = UDim.new(0,6)

local copyBtn = Instance.new("TextButton")
copyBtn.Parent = rowRay
copyBtn.Size = UDim2.fromOffset(40,28)
copyBtn.Text = "Copy"
copyBtn.Font = Enum.Font.SourceSansBold
copyBtn.TextSize = 14
copyBtn.TextColor3 = Color3.fromRGB(240,240,240)
copyBtn.BackgroundColor3 = Color3.fromRGB(70,180,120)
copyBtn.BorderSizePixel = 0
copyBtn.ZIndex = 21
Instance.new("UICorner",copyBtn).CornerRadius = UDim.new(0,6)

local tpBtn = Instance.new("TextButton")
tpBtn.Parent = rowRay
tpBtn.Size = UDim2.fromOffset(40,28)
tpBtn.Text = "TP"
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 14
tpBtn.TextColor3 = Color3.fromRGB(240,240,240)
tpBtn.BackgroundColor3 = Color3.fromRGB(200,80,80)
tpBtn.BorderSizePixel = 0
tpBtn.ZIndex = 21
Instance.new("UICorner",tpBtn).CornerRadius = UDim.new(0,6)


local tweenMode = true
local rayTargetUsingNoclip = false

local function getRayPos()
	return _G.CamRayPosition
end

local function stopRayTargetNoclip()
	if rayTargetUsingNoclip then
		rayTargetUsingNoclip = false
		removeNoclipUser()
	end
end

modeBtn.MouseButton1Click:Connect(function()

	tweenMode = not tweenMode

	if tweenMode then
		modeBtn.Text = "Tween Mode"
		modeBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	else
		modeBtn.Text = "TP Mode"
		modeBtn.BackgroundColor3 = Color3.fromRGB(200,80,80)
	end

end)

copyBtn.MouseButton1Click:Connect(function()

	local pos = getRayPos()
	if not pos then return end

	local txt = string.format(
		"%.0f , %.0f , %.0f",
		pos.X,pos.Y,pos.Z
	)

	if setclipboard then
		setclipboard(txt)
	end

end)

local RAY_RATE = 30
local RAY_INTERVAL = 0 / RAY_RATE
local lastRayTime = 0

local function getStepDist()

	local speed = tonumber(teleportSpeedBox and teleportSpeedBox.Text) or 350
	return speed / RAY_RATE

end

local function resetPhysics(hrp)

	local vel = hrp.AssemblyLinearVelocity

	hrp.AssemblyLinearVelocity = Vector3.new(
		vel.X,
		0,
		vel.Z
	)

	hrp.AssemblyAngularVelocity = Vector3.zero

end

local function forceMoveToRay(hrp,pos,stepDist)

	local current = hrp.Position
	local delta = pos - current
	local dist = delta.Magnitude

	if dist <= stepDist then

		hrp.CFrame = CFrame.new(
			pos.X,
			pos.Y + 0.1,
			pos.Z
		)

		resetPhysics(hrp)
		return

	end

	local newPos = current + delta.Unit * stepDist

	hrp.CFrame = CFrame.new(newPos)

	resetPhysics(hrp)

end


tpBtn.MouseButton1Click:Connect(function()

	local pos = getRayPos()
	if not pos then return end

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	hrp.CFrame = CFrame.new(pos)

end)


local rayTargetEnabled = true

BindSlot(RayTarget,{
	Name = "RayTarget",
	Type = "HeartbeatParallel",
	Default = false,

	Callback = function(dt,char,hum,hrp)

		if not RayTarget.State then
			stopRayTargetNoclip()
			return
		end

		local now = os.clock()

		if now - lastRayTime < RAY_INTERVAL then
			return
		end

		lastRayTime = now

		rayTargetEnabled =
		updateHPState(rayTargetEnabled)

		if not rayTargetEnabled then
			stopRayTargetNoclip()
			return
		end

		local pos = getRayPos()
		if not pos then return end

		if tweenMode then

			if not rayTargetUsingNoclip then
				rayTargetUsingNoclip = true
				addNoclipUser()
			end

			local step = getStepDist()

			forceMoveToRay(
				hrp,
				pos,
				step
			)

		else

			stopRayTargetNoclip()

			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero

			hrp.CFrame = CFrame.new(pos)

		end

	end
})

UpdateController:On("ForceDisable",function(name)

	if name == "RayTarget" then

		stopRayTargetNoclip()

		if RayTarget then
			RayTarget.State = false
		end

	end

end)

LocalPlayer.CharacterAdded:Connect(function()

	stopRayTargetNoclip()

	if RayTarget and RayTarget.State then

		RayTarget.State = false

		RayTarget.Pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
		RayTarget.SlotKnob.Position = UDim2.fromOffset(2,2)

	end

end)

end)


pcall(function()

local CatchPlayer = Slots[3]
CatchPlayer.Label.Text = "Catch Player"
CatchPlayer.Label.Visible = false
CatchPlayer.Frame.ClipsDescendants = true

local rowCatch = Instance.new("Frame")
rowCatch.Parent = CatchPlayer.Frame
rowCatch.Size = UDim2.new(1,-12,1,-8)
rowCatch.Position = UDim2.fromOffset(4,4)
rowCatch.BackgroundTransparency = 1
rowCatch.ZIndex = 20

local layoutCatch = Instance.new("UIListLayout")
layoutCatch.Parent = rowCatch
layoutCatch.FillDirection = Enum.FillDirection.Horizontal
layoutCatch.VerticalAlignment = Enum.VerticalAlignment.Center
layoutCatch.Padding = UDim.new(0,4)

local tpBtn = Instance.new("TextButton")
tpBtn.Parent = rowCatch
tpBtn.Size = UDim2.fromOffset(111, 28)
tpBtn.Text = "Teleport Marker"
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 14
tpBtn.TextColor3 = Color3.fromRGB(240,240,240)
tpBtn.BackgroundColor3 = Color3.fromRGB(80,140,200)
tpBtn.BorderSizePixel = 0
tpBtn.ZIndex = 21
Instance.new("UICorner",tpBtn).CornerRadius = UDim.new(0,6)

local stepBox = Instance.new("TextBox")
stepBox.Parent = rowCatch
stepBox.Size = UDim2.fromOffset(40,28)
stepBox.Text = "200"
stepBox.PlaceholderText = "Step"
stepBox.ClearTextOnFocus = false
stepBox.Font = Enum.Font.SourceSansBold
stepBox.TextSize = 14
stepBox.TextXAlignment = Enum.TextXAlignment.Center
stepBox.TextColor3 = Color3.fromRGB(200,200,200)
stepBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
stepBox.BorderSizePixel = 0
stepBox.ZIndex = 21
Instance.new("UICorner",stepBox).CornerRadius = UDim.new(0,6)

local range = 2000
local maxStep = 200

local MIN_STEP = 1
local MAX_STEP = 10000


stepBox:GetPropertyChangedSignal("Text"):Connect(function()

	local filtered = stepBox.Text:gsub("%D","")

	if filtered == "" then
		stepBox.Text = ""
		return
	end

	local num = math.clamp(
		tonumber(filtered),
		MIN_STEP,
		MAX_STEP
	)

	maxStep = num
	stepBox.Text = tostring(num)

end)


local SCAN_DELAY = 1/30
local MARKER_DELAY = 0.5
local MAX_MARKERS = 5

local scanTick = 0
local markerTick = 0

local conn
local tracked = {}
local markers = {}

local function updateMarkerColors()

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local closestIndex = nil
	local shortest = math.huge

	for i = 1,#markers do
		local m = markers[i]
		if m.part then
			local dist = (m.part.Position - hrp.Position).Magnitude
			if dist < shortest then
				shortest = dist
				closestIndex = i
			end
		end
	end

	for i = 1,#markers do
		local m = markers[i]
		if m.part then
			if i == closestIndex then
				m.part.Color = Color3.fromRGB(255,0,0)
				m.part.Material = Enum.Material.Neon
			else
				m.part.Color = Color3.fromRGB(255,255,255)
				m.part.Material = Enum.Material.Neon
			end
		end
	end

end

local function createMarker(pos,playerName)

	local p = Instance.new("Part")
	p.Size = Vector3.new(2,2,2)
	p.Shape = Enum.PartType.Ball
	p.Material = Enum.Material.Neon
	p.Anchored = true
	p.CanCollide = false
	p.Position = pos
	p.Parent = workspace

	local bill = Instance.new("BillboardGui")
	bill.Size = UDim2.new(0,120,0,40)
	bill.StudsOffset = Vector3.new(0,2,0)
	bill.AlwaysOnTop = true
	bill.Parent = p

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(255,255,255)
	txt.TextStrokeTransparency = 0
	txt.Font = Enum.Font.SourceSansBold
	txt.TextScaled = false
	txt.TextSize = 17
	txt.Parent = bill

	txt.Text = playerName

	table.insert(markers,{
		part = p,
		time = tick()
	})

	if #markers > MAX_MARKERS then
		local oldest = table.remove(markers,1)
		if oldest and oldest.part then
			oldest.part:Destroy()
		end
	end

	updateMarkerColors()

end

local function stop()

	if conn then
		conn:Disconnect()
		conn = nil
	end

	for _,m in pairs(markers) do
		if m.part then m.part:Destroy() end
	end

	table.clear(markers)
	table.clear(tracked)

end

local function start()

	if conn then return end

	conn = RunService.Heartbeat:Connect(function()

		local now = tick()

		local char = LocalPlayer.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		if now - scanTick >= SCAN_DELAY then
			scanTick = now

			for _,plr in pairs(Players:GetPlayers()) do

				if plr ~= LocalPlayer then

					local tChar = plr.Character
					local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
					local data = tracked[plr]

					if tHRP then

						local dist = (tHRP.Position - hrp.Position).Magnitude

						if dist <= range then

							if not data then

								local hum = tChar:FindFirstChildOfClass("Humanoid")

								local died = false
								local connD

								if hum then
									connD = hum.Died:Connect(function()
										died = true
									end)
								end

								tracked[plr] = {
									pos = tHRP.Position,
									died = function() return died end,
									conn = connD
								}

							else
								data.pos = tHRP.Position
							end

						else

							if data then

								local isDead = data.died and data.died()

								if not isDead then
									createMarker(data.pos,plr.Name)
								end

								if data.conn then
									data.conn:Disconnect()
								end

								tracked[plr] = nil

							end

						end

					else

						if data then

							if data.conn then
								data.conn:Disconnect()
							end

							tracked[plr] = nil

						end

					end

				end

			end

		end

		if now - markerTick >= MARKER_DELAY then
			markerTick = now

			for i = #markers,1,-1 do

				local m = markers[i]

				if not m.part or now - m.time >= 500 then
					if m.part then m.part:Destroy() end
					table.remove(markers,i)
				end

			end

			updateMarkerColors()

		end

	end)

end

tpBtn.MouseButton1Click:Connect(function()

	if #markers == 0 then return end

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local target
	local shortest = math.huge

	for i = 1,#markers do
		local m = markers[i]
		if m.part then
			local dist = (m.part.Position - hrp.Position).Magnitude
			if dist < shortest then
				shortest = dist
				target = m.part.Position
			end
		end
	end

	if not target then return end

	local pos = hrp.Position
	local dir = target - pos
	local dist = dir.Magnitude

	if dist <= 0 then return end

	local step = math.min(dist,maxStep)
	local newPos = pos + dir.Unit * step

	hrp.CFrame = CFrame.new(newPos)

end)

CatchPlayer.Pill.MouseButton1Click:Connect(function()

	CatchPlayer.State = not CatchPlayer.State

	if CatchPlayer.State then
		CatchPlayer.Pill.BackgroundColor3 = Color3.fromRGB(120,200,120)
		CatchPlayer.SlotKnob.Position = UDim2.fromOffset(20,2)
		start()
	else
		CatchPlayer.Pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
		CatchPlayer.SlotKnob.Position = UDim2.fromOffset(2,2)
		stop()
	end

end)

_G.ResetCatchPlayer = function()

	if conn then
		conn:Disconnect()
		conn = nil
	end

	for _,m in pairs(markers) do
		if m.part then m.part:Destroy() end
	end

	table.clear(markers)
	table.clear(tracked)

	if CatchPlayer then
		CatchPlayer.State = false
		CatchPlayer.Pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
		CatchPlayer.SlotKnob.Position = UDim2.fromOffset(2,2)
	end

end

end)


pcall(function()

local LeaveV = Slots[23]
LeaveV.Frame.ClipsDescendants = true

-- ẩn UI mặc định
LeaveV.Pill.Visible = false
LeaveV.SlotKnob.Visible = false
LeaveV.Label.Visible = false

local row = Instance.new("Frame")
row.Parent = LeaveV.Frame
row.Size = UDim2.new(1,-12,1,-8)
row.Position = UDim2.fromOffset(4,4)
row.BackgroundTransparency = 1
row.ZIndex = 20

local layout = Instance.new("UIListLayout")
layout.Parent = row
layout.FillDirection = Enum.FillDirection.Horizontal
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0,4)

local btn = Instance.new("TextButton")
btn.Parent = row
btn.Size = UDim2.fromOffset(198, 28)
btn.Text = "Leave V Portal"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 14
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.BackgroundColor3 = Color3.fromRGB(80,140,255)
btn.BorderSizePixel = 0
btn.ZIndex = 21
Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

local RANGE_XZ = 700
local BASE_Y = 100000
local STEP_Y = 10000
local MAX_Y = 200000

local function inVPortalZone(pos)

	if math.abs(pos.X) > RANGE_XZ then return false end
	if math.abs(pos.Z) > RANGE_XZ then return false end

	if pos.Y < BASE_Y or pos.Y > MAX_Y then
		return false
	end

	return true

end

local function getSnapY(y)

	local level = math.floor((y - BASE_Y) / STEP_Y + 0.5)
	local snapped = BASE_Y + level * STEP_Y

	return snapped + 200

end

btn.MouseButton1Click:Connect(function()

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local pos = hrp.Position

	if not inVPortalZone(pos) then
		return
	end

	local targetY = getSnapY(pos.Y)

	hrp.CFrame = CFrame.new(0, targetY, 0)

end)

end)


SettingsButton.MouseButton1Click:Connect(function()

	local existingPopup = LocalPlayer.PlayerGui:FindFirstChild("ExitConfirmGui")

	if existingPopup then
		existingPopup:Destroy()
		return
	end


	if SettingsGui and SettingsGui.Parent then
		SettingsGui.Enabled = not SettingsGui.Enabled
	end
end)



local MiniGui = nil
local MiniFrame = nil
local wasSettingsOpen = false

Frame.AnchorPoint = Vector2.new(0,0)

minisizebutton.MouseButton1Click:Connect(function()

	wasSettingsOpen = SettingsGui and SettingsGui.Enabled or false

	Frame.Visible = false
	DragFrame.Visible = false

	if SettingsGui then
		SettingsGui.Enabled = false
	end

	if not MiniGui then
		MiniGui = Instance.new("ScreenGui")
		MiniGui.Name = "MiniGui"
		MiniGui.ResetOnSpawn = false
		MiniGui.IgnoreGuiInset = true
		MiniGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		MiniGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

		MiniFrame = Instance.new("Frame")
		MiniFrame.Parent = MiniGui
		MiniFrame.Size = UDim2.fromOffset(80, 32)
		MiniFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
		MiniFrame.ZIndex = 99999999
		MiniFrame.AnchorPoint = Vector2.new(0,0)

      local stroke = Instance.new("UIStroke")
      stroke.Parent = MiniFrame
      stroke.Thickness = 2
      stroke.Color = Color3.fromRGB(0, 255, 120)
      stroke.Transparency = 0

		local corner = Instance.new("UICorner", MiniFrame)
		corner.CornerRadius = UDim.new(0,3)

		local label = Instance.new("TextLabel")
      label.Parent = MiniFrame
      label.Size = UDim2.fromScale(1, 1)
      label.BackgroundTransparency = 1
      label.Text = "MENU"
      label.TextColor3 = Color3.fromRGB(0, 255, 120)
      label.TextScaled = false
      label.TextSize = 19
      label.Font = Enum.Font.SourceSansBold
      label.TextXAlignment = Enum.TextXAlignment.Center
      label.TextYAlignment = Enum.TextYAlignment.Center

		attachDrag(MiniFrame, nil)

		local dragging = false
		local moved = false

		MiniFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

				dragging = true
				moved = false
				local startPos = input.Position

				local conn
				conn = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						conn:Disconnect()

						if not moved then
							Frame.Visible = true
							DragFrame.Visible = true

							if SettingsGui then
								SettingsGui.Enabled = wasSettingsOpen
							end

							MiniGui.Enabled = false
						end
					end
				end)

				task.spawn(function()
					while dragging do
						if (input.Position - startPos).Magnitude > 10 then
							moved = true
							break
						end
						task.wait()
					end
				end)
			end
		end)
	end

	MiniFrame.Position = Frame.Position
	MiniGui.Enabled = true
end)



local function shutdownAndUnload()

	nowe = false
	tpwalking = false

	flyHasNoclipPriority = false
	noclipUsers = 0

	if flyNoclipConn then
		flyNoclipConn:Disconnect()
		flyNoclipConn = nil
	end

	if sharedNoclipConn then
		sharedNoclipConn:Disconnect()
		sharedNoclipConn = nil
	end

	if restoreCollision then
		restoreCollision()
	end

	if typeof(stopFlyVisuals) == "function" then
		stopFlyVisuals()
	end

	if destroyEscapeSystem then
		destroyEscapeSystem()
		destroyEscapeSystem = nil
	end

	if _G.StopTPInstantLoop then
		pcall(_G.StopTPInstantLoop)
	end

	if _G.StopForceFieldLoop then
		pcall(_G.StopForceFieldLoop)
		_G.StopForceFieldLoop = nil
	end

	if _G.StopESPPlayerLoop then
		pcall(_G.StopESPPlayerLoop)
	end

	if _G.StopPlayerListLoop then
		_G.StopPlayerListLoop()
	end

	if _G.DestroyFreeCam then
		pcall(_G.DestroyFreeCam)
	end

	if _G.ResetCatchPlayer then
		pcall(_G.ResetCatchPlayer)
	end

	if Slots then
		for _,slot in pairs(Slots) do
			if slot then
				slot.State = false

				if slot.Pill then
					slot.Pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
				end

				if slot.SlotKnob then
					slot.SlotKnob.Position = UDim2.fromOffset(2,2)
				end
			end
		end
	end

	if UpdateController then

		for name in pairs(UpdateController.HeartbeatParallel or {}) do
			UpdateController:ForceDisable(name)
		end

		for name in pairs(UpdateController.RenderParallel or {}) do
			UpdateController:ForceDisable(name)
		end

		for _,data in ipairs(UpdateController.HeartbeatOverrideStack or {}) do
			if data and data.Name then
				UpdateController:ForceDisable(data.Name)
			end
		end

		for _,data in ipairs(UpdateController.RenderOverrideStack or {}) do
			if data and data.Name then
				UpdateController:ForceDisable(data.Name)
			end
		end

	end

	if SpectatorPlayer then
		disableSpectator()
	end

	pcall(function()
		if positionLocalInformationGui then
			positionLocalInformationGui:Destroy()
			positionLocalInformationGui = nil
		end
	end)

	if UpdateController then

		if UpdateController.HBConn then
			UpdateController.HBConn:Disconnect()
			UpdateController.HBConn = nil
		end

		if UpdateController.RSConn then
			UpdateController.RSConn:Disconnect()
			UpdateController.RSConn = nil
		end

		UpdateController.HeartbeatParallel = {}
		UpdateController.RenderParallel = {}
		UpdateController.HeartbeatOverrideStack = {}
		UpdateController.RenderOverrideStack = {}

		UpdateController = nil
	end

	task.defer(function()

		local char = LocalPlayer.Character
		if not char then return end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then
			hum = char:WaitForChild("Humanoid",3)
		end

		if hum then
			hum.AutoRotate = true
			hum.PlatformStand = false

			for _,state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
				pcall(function()
					hum:SetStateEnabled(state,true)
				end)
			end

			hum:ChangeState(Enum.HumanoidStateType.Running)

			for _,track in ipairs(hum:GetPlayingAnimationTracks()) do
				pcall(function()
					track:AdjustSpeed(1)
				end)
			end
		end

		local anim = char:FindFirstChild("Animate")
		if not anim then
			anim = char:WaitForChild("Animate",3)
		end

		if anim then
			anim.Disabled = false
		end

	end)

	if MiniGui then
		MiniGui:Destroy()
		MiniGui = nil
	end

	if main then
		main:Destroy()
		main = nil
	end

	if SettingsGui then
		SettingsGui:Destroy()
		SettingsGui = nil
	end

end

getgenv().Shutdown = function()
	if shutdownAndUnload then
		shutdownAndUnload()
	end
end




local function resetFlySystem()

	nowe = false
	tpwalking = false

	stopFlyVisuals()

	flyHasNoclipPriority = false

	if flyNoclipConn then
		flyNoclipConn:Disconnect()
		flyNoclipConn = nil
	end

	updateSharedNoclip()

	lastClick = 0

end


LocalPlayer.CharacterRemoving:Connect(function()

	resetFlySystem()

end)


LocalPlayer.CharacterAdded:Connect(function(char)

	local HRP = char:WaitForChild("HumanoidRootPart",5)
	if not HRP then return end

	RunService.Heartbeat:Wait()

	resetFlySystem()

	task.wait(0.1)

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.AutoRotate = true
	end

	local anim = char:FindFirstChild("Animate")
	if anim then
		anim.Disabled = false
	end

end)
