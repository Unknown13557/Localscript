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
--    Bản v2: thêm nhánh InvokeServer + chế độ dò remote (xem ghi chú [THÊM]).
------------------------------------------------------------
local MT = getrawmetatable(game)
local OldNameCall = MT.__namecall
setreadonly(MT, false)
MT.__namecall = newcclosure(function(self, ...)
	local Method = getnamecallmethod()
	local n = select("#", ...)
	local Args = { ... }

	-- [THÊM] Chế độ dò: đặt getgenv().AimDebug = true rồi dùng skill lỗi,
	-- console sẽ in ra method, tên remote và kiểu các tham số.
	if getgenv().AimDebug and (Method == "FireServer" or Method == "InvokeServer") then
		local types = {}
		for i = 1, n do
			types[i] = typeof(Args[i])
		end
		print(Method, self.Name, table.concat(types, ", "))
	end

	if
		(
			(Method == "FireServer" and self.Name == "RemoteEvent")
			-- [THÊM] nhánh InvokeServer, giả định remote tên "RemoteFunction"
			or (Method == "InvokeServer" and self.Name == "RemoteFunction")
		)
		and AimPos
		and tostring(AimPos.X) ~= "nan"
		and Settings["Auto Aimbot"]
	then
		if n == 1 and typeof(Args[1]) == "Vector3" then
			Args[1] = AimPos.Position
		end
		if n == 1 and typeof(Args[1]) == "CFrame" then
			Args[1] = AimPos
		end
	end
	-- [SỬA] truyền đủ n tham số để không làm rớt tham số nil ở các lời gọi khác
	return OldNameCall(self, table.unpack(Args, 1, n))
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
