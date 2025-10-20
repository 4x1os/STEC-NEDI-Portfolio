--[[
2024 - more recent project, and worked on more scripts. I'm showing this one
alongside the weapons module to show that I've been improving on OOP and writing
a little bit more clean code.

This one's about a robbery game. If you check the place code,
I also managed to make an isometric camera system, and
start working on some pathfinding AI.

I've currently figured out a raycast detection system for stealth,
breaching mechanics, shooting, and AI detection, patrol, and
search system.

Definitely needs a rewrite, but I'm putting this project on pause because I have
school and job hunting to do.
]]

-- services
local user_input_service = game:GetService("UserInputService")
local replicated_storage = game:GetService("ReplicatedStorage")
local run_service = game:GetService("RunService")
local proximity_prompt = game:GetService("ProximityPromptService")

-- modules
local weapon_module = replicated_storage:WaitForChild("WeaponsModule")

-- objects
local weapons = replicated_storage.Weapons
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()





local uis = game:GetService('UserInputService')
local rs = game:GetService("ReplicatedStorage")
local rts = game:GetService("RunService")
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local weapons = rs.Weapons
local wpModule = require(script.weapons)
local proxprompt = game:GetService("ProximityPromptService")

-- moving to serverside
-- local primary = wpModule.new(1,weapons.Weapon1,plr)
-- local secondary = wpModule.new(2,weapons.Weapon2,plr)

local equipped = 0
uis.InputBegan:Connect(function(input, gP)
	if not gP then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.One then
				if equipped ~= 1 then
					primary:Unequip()
					secondary:Unequip()
					primary:Equip()
					equipped = 1
				else
					primary:Unequip()
					equipped = 0
				end 
			elseif input.KeyCode == Enum.KeyCode.Two then
				if equipped ~= 2 then
					primary:Unequip()
					secondary:Unequip()
					secondary:Equip()
					equipped = 2
				else
					secondary:Unequip()
					equipped = 0
				end
			elseif input.KeyCode == Enum.KeyCode.F then
				local uiResp = rs.ScanForInteractions:InvokeServer()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if equipped == 1 then
				primary:Fire()
			elseif equipped == 2 then
				secondary:Fire()
			end
		end
	end
end)
local selectiveBoard = nil
local actions = {}
proxprompt.PromptTriggered:Connect(function(prompt)
	if selectiveBoard then
		selectiveBoard:Destroy()
		selectiveBoard = nil
		for i,v in pairs(actions) do
			v:Disconnect()
		end
	end
	
	selectiveBoard = rs.BillboardGui:Clone()
	selectiveBoard.Adornee = prompt.Parent
	selectiveBoard.Parent = plr.PlayerGui
	
	table.insert(actions, selectiveBoard.Lockpick.MouseButton1Click:Connect(function()
		prompt.Enabled = false
		if selectiveBoard then
			selectiveBoard:Destroy()
			selectiveBoard = nil
			for i,v in pairs(actions) do
				v:Disconnect()
			end
		end	
		plr.Character.Humanoid.WalkSpeed = 0
		local result = rs.CallTimer:InvokeServer(5, prompt.Parent, "Lockpicking...")	
		plr.Character.Humanoid.WalkSpeed = 16
	end))
	table.insert(actions, selectiveBoard.Drill.MouseButton1Click:Connect(function()
		prompt.Enabled = false
		if selectiveBoard then
			selectiveBoard:Destroy()
			selectiveBoard = nil
			for i,v in pairs(actions) do
				v:Disconnect()
			end
		end	
		plr.Character.Humanoid.WalkSpeed = 0
		local result = rs.CallTimer:InvokeServer(10, prompt.Parent, "Drilling...")	
		plr.Character.Humanoid.WalkSpeed = 16
	end))
end)