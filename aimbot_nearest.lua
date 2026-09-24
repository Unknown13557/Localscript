-- Trích từ 3nn_main_lua.txt: chỉ phần aimbot chế độ "Target nearest Player".
-- Code giữ nguyên như bản gốc, chỉ rút gọn danh sách toggle trong hook (ghi chú bên dưới).
-- Cần executor có: getrawmetatable, setreadonly, getnamecallmethod, newcclosure, getgenv.

------------------------------------------------------------
-- 0. Biến nền (gốc: dòng 138 và dòng 3932)
------------------------------------------------------------
local t = game.Players.LocalPlayer                                   -- dòng 138
local G = require(game:GetService("ReplicatedStorage").Mouse)        -- dòng 3932

-- Settings gốc là bảng lưu ra file; ở đây chỉ giữ các khóa mà aimbot dùng
Settings = {
	["Auto Aimbot"] = true,
	["Auto Aimbot Gun"] = true,
	["Select Method Aimbot"] = "Target nearest Player",
}

------------------------------------------------------------
-- 1. Chọn mục tiêu gần nhất (gốc: dòng 18716)
------------------------------------------------------------
function ClosestPartaimbot()
	local b, s = 1 / 0
	for X, g in pairs(game.Workspace.Characters:GetChildren()) do
		if g:IsA("Model") then
			if
				g.Name ~= t.Name
				and (
					game.Players.LocalPlayer.Team == game.Teams.Marines
						and game.Players[g.Name].Team ~= game.Teams.Marines
					or game.Players.LocalPlayer.Team ~= game.Teams.Marines
				)
			then
				X = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - g.HumanoidRootPart.Position).Magnitude
				if X < b then
					b, s = X, g
				end
			end
		end
	end
	return s
end

------------------------------------------------------------
-- 2. Cập nhật AimPos mỗi frame (gốc: dòng ~19548, trong RenderStepped)
------------------------------------------------------------
game:GetService("RunService").RenderStepped:Connect(function()
	pcall(function()
		if Settings["Auto Aimbot"] then
			local T = ClosestPartaimbot()
			if T and (T:FindFirstChild("HumanoidRootPart")) then
				G.Hit = T.HumanoidRootPart.CFrame
				G.Target = T
				getgenv().AimPos = CFrame.new(
					T.HumanoidRootPart.Position,
					T.HumanoidRootPart.Position + T.HumanoidRootPart.Velocity / 0.5
				)
			end
		end
	end)
end)

------------------------------------------------------------
-- 3. Hook __namecall: thay tham số vị trí của FireServer (gốc: dòng ~19533)
--    Bản gốc có một danh sách dài toggle trong điều kiện `or`
--    (Auto Trial, Auto Sea Event...); ở đây chỉ giữ Auto Aimbot.
------------------------------------------------------------
local MT = getrawmetatable(game)
local OldNameCall = MT.__namecall
setreadonly(MT, false)
MT.__namecall = newcclosure(function(self, ...)
	local Method = getnamecallmethod()
	local Args = { ... }
	if
		Method == "FireServer"
		and self.Name == "RemoteEvent"
		and AimPos
		and tostring(AimPos.X) ~= "nan"
		and Settings["Auto Aimbot"]
	then
		if #Args == 1 and typeof(Args[1]) == "Vector3" then
			Args[1] = AimPos.Position
		end
		if #Args == 1 and typeof(Args[1]) == "CFrame" then
			Args[1] = AimPos
		end
	end
	return OldNameCall(self, unpack(Args))
end)
setreadonly(MT, true)

------------------------------------------------------------
-- 4. Auto Aimbot Gun: đè GetTargetPosition (gốc: dòng ~18775)
------------------------------------------------------------
local b = require(game:GetService("ReplicatedStorage").Modules.CombatUtil).GetTargetPosition
require(game:GetService("ReplicatedStorage").Modules.CombatUtil).GetTargetPosition = function(s, X, g, f, R)
	if Settings["Auto Aimbot Gun"] then
		local m = ClosestPartaimbot()
		if m and (m:FindFirstChild("HumanoidRootPart")) then
			return m.HumanoidRootPart.Position
		end
	end
	return b(s, X, g, f, R)
end
