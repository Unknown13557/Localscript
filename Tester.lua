local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Gui
local gui = Instance.new("ScreenGui")
gui.Name = "TestGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

if syn and syn.protect_gui then
	syn.protect_gui(gui)
end

-- Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(210, 120)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

-- Stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 2
stroke.Transparency = 0
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = frame

-- Close
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(22, 22)
close.Position = UDim2.new(1, -24, 0, 2)
close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "X"
close.Parent = frame
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Control panel
local ctrl = Instance.new("Frame")
ctrl.Size = UDim2.new(1, -12, 0, 58)
ctrl.Position = UDim2.new(0, 6, 1, 15)
ctrl.BackgroundTransparency = 1
ctrl.Parent = frame

-- Helper tạo TextBox
local function mkBox(x, y, placeholder)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.fromOffset(46, 22)
	tb.Position = UDim2.new(0, x, 0, y)
	tb.BackgroundColor3 = Color3.fromRGB(245,245,245)
	tb.TextColor3 = Color3.fromRGB(20,20,20)
	tb.PlaceholderText = placeholder
	tb.Text = ""
	tb.ClearTextOnFocus = false
	tb.Parent = ctrl
	return tb
end

-- BỘ LỌC INPUT
local function bindInt3(tb)
	tb:GetPropertyChangedSignal("Text"):Connect(function()
		local s = tb.Text
		local cleaned = s:gsub("%D",""):sub(1,3)
		if cleaned ~= s then
			local pos = tb.CursorPosition
			tb.Text = cleaned
			tb.CursorPosition = math.clamp(pos - (#s-#cleaned), 1, #cleaned + 1)
		end
	end)
end

local function bindTransparency2(tb)
	tb:GetPropertyChangedSignal("Text"):Connect(function()
		local s = tb.Text
		local out, dot = {}, false
		for i = 1, #s do
			local ch = s:sub(i,i)
			if ch:match("%d") then
				out[#out+1] = ch
			elseif ch == "." and not dot then
				out[#out+1] = "."
				dot = true
			end
		end
		local raw = table.concat(out)
		local before, after = raw:match("^(%d*)%.?(%d*)$")
		before = (before or ""):sub(1,1)
		after  = (after  or ""):sub(1,2)

		local final
		if dot or raw:find("%.") then
			if before == "" then before = "0" end
			final = before .. "." .. after
		else
			final = before
		end

		if final ~= s then
			local pos = tb.CursorPosition
			tb.Text = final
			tb.CursorPosition = math.clamp(pos, 1, #final + 1)
		end
	end)
end

-- BG Inputs
local rBox = mkBox(0,   2,  "R")
local gBox = mkBox(50,  2,  "G")
local bBox = mkBox(100, 2,  "B")
local tBox = mkBox(150, 2,  "T")

bindInt3(rBox)
bindInt3(gBox)
bindInt3(bBox)
bindTransparency2(tBox)

local applyBG = Instance.new("TextButton")
applyBG.Size = UDim2.fromOffset(50, 22)
applyBG.Position = UDim2.new(0, 200, 0, 2)
applyBG.BackgroundColor3 = Color3.fromRGB(40, 180, 255)
applyBG.TextColor3 = Color3.new(1,1,1)
applyBG.Text = "BG"
applyBG.Parent = ctrl

-- Stroke Inputs
local srBox = mkBox(0,   30, "SR")
local sgBox = mkBox(50,  30, "SG")
local sbBox = mkBox(100, 30, "SB")
local stBox = mkBox(150, 30, "ST")

bindInt3(srBox)
bindInt3(sgBox)
bindInt3(sbBox)
bindTransparency2(stBox)

local applyST = Instance.new("TextButton")
applyST.Size = UDim2.fromOffset(50, 22)
applyST.Position = UDim2.new(0, 200, 0, 30)
applyST.BackgroundColor3 = Color3.fromRGB(120, 120, 255)
applyST.TextColor3 = Color3.new(1,1,1)
applyST.Text = "Stroke"
applyST.Parent = ctrl

-- Parse and Apply
local function clamp(n,a,b)
	if not n then return a end
	return math.clamp(n,a,b)
end

local function parseBG()
	local r = tonumber(rBox.Text) or 120
	local g = tonumber(gBox.Text) or 0
	local b = tonumber(bBox.Text) or 200
	local t = tonumber(tBox.Text) or 0.25
	frame.BackgroundColor3 = Color3.fromRGB(clamp(r,0,255), clamp(g,0,255), clamp(b,0,255))
	frame.BackgroundTransparency = clamp(t,0,1)
end

local function parseStroke()
	local r = tonumber(srBox.Text) or 180
	local g = tonumber(sgBox.Text) or 80
	local b = tonumber(sbBox.Text) or 255
	local t = tonumber(stBox.Text) or 0
	stroke.Color = Color3.fromRGB(clamp(r,0,255), clamp(g,0,255), clamp(b,0,255))
	stroke.Transparency = clamp(t,0,1)
end

applyBG.MouseButton1Click:Connect(parseBG)
applyST.MouseButton1Click:Connect(parseStroke)

-- Size Inputs
local wBox = mkBox(0, 58, "W")
local hBox = mkBox(50, 58, "H")

bindInt3(wBox)
bindInt3(hBox)

local applySZ = Instance.new("TextButton")
applySZ.Size = UDim2.fromOffset(100, 22)
applySZ.Position = UDim2.new(0, 100, 0, 58)
applySZ.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
applySZ.TextColor3 = Color3.new(1,1,1)
applySZ.Text = "Size"
applySZ.Parent = ctrl

local function parseSize()
	local w = tonumber(wBox.Text) or frame.AbsoluteSize.X
	local h = tonumber(hBox.Text) or frame.AbsoluteSize.Y
	frame.Size = UDim2.fromOffset(math.clamp(w, 50, 1000), math.clamp(h, 50, 1000))
end

applySZ.MouseButton1Click:Connect(parseSize)
-- Drag mượt, giới hạn biên
local RESPECT_COREGUI = false
local TOP_MARGIN = 2
local function pointerPos(input)
	return (input.UserInputType == Enum.UserInputType.Touch)
		and Vector2.new(input.Position.X, input.Position.Y)
		or UserInputService:GetMouseLocation()
end
local function over(inst,pos)
	if not (inst and inst.Parent) then return false end
	local p,s=inst.AbsolutePosition,inst.AbsoluteSize
	return pos.X>=p.X and pos.X<=p.X+s.X and pos.Y>=p.Y and pos.Y<=p.Y+s.Y
end
local function overAny(list,pos)
	for _,inst in ipairs(list) do
		if inst and over(inst,pos) then return true end
	end
	return false
end

local dragging=false
local dragStart,startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		local pos=pointerPos(input)
		if overAny({ctrl,close},pos) then return end
		dragging,dragStart,startPos=true,input.Position,frame.Position
		input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then dragging=false end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
		local delta=input.Position-dragStart
		local newX,newY=startPos.X.Offset+delta.X,startPos.Y.Offset+delta.Y
		local cam=workspace.CurrentCamera
		if cam then
			local vp=cam.ViewportSize
			local topInset=GuiService:GetGuiInset().Y
			local minY=(RESPECT_COREGUI and (topInset+TOP_MARGIN) or TOP_MARGIN)
			newX=math.clamp(newX,0,vp.X-frame.AbsoluteSize.X)
			newY=math.clamp(newY,minY,vp.Y-frame.AbsoluteSize.Y)
		end
		frame.Position=UDim2.fromOffset(newX,newY)
	end
end)
