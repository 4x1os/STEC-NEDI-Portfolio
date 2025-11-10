--[[
This is me handling combat system. Most recent one I've tried making.
Forgot to separate client and server actions so it's also going through a rewrite.

Currently able to sprint, parry, block, and swing. Hit detection
works for both NPCs and players.
]]


-- To handle player input

-- services
local user_input_service = game:GetService("UserInputService")
local replicated_storage = game:GetService("ReplicatedStorage")
local context_action_service = game:GetService("ContextActionService")
local tween_service = game:GetService("TweenService")


local remotes = replicated_storage.Remotes
local modules = replicated_storage.Modules
local assets = replicated_storage.Assets

-- modules

local cur_track = nil
local block_track = nil

-- local variables
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char.Humanoid
local cur_weapon = nil
local idle_track = nil
local block_track = nil
local camera = workspace.CurrentCamera

-- local functions

local function equip(actionName,inputState,inputObject)
	if inputState ~= Enum.UserInputState.Begin then return end
	
	local action = remotes.CallWeapon:InvokeServer("Equip")
	if action == "Equip" then
		cur_weapon = char.BatModel
		if idle_track == nil and block_track == nil then
			idle_track = hum.Animator:LoadAnimation(cur_weapon.IdleAnimation)
			block_track = hum.Animator:LoadAnimation(cur_weapon.BlockAnimation)
		end
		idle_track:Play()
	elseif action == "Unequip" then
		idle_track:Stop()
		cur_weapon = nil
	end
end

local function swing(actionName,inputState,inputObject)
	if inputState ~= Enum.UserInputState.Begin then return end
	
	local action = remotes.CallWeapon:InvokeServer("Swing")
	if action == "Fight" then
		
		local swing = hum.Animator:LoadAnimation(cur_weapon.SwingAnimation)
		swing:Play()
		local audio = cur_weapon.swingSFX
		audio:Play()
		
		local hit = script.CallHitbox:Invoke()
		if hit ~= nil then
			local result = remotes.ProcessHitbox:InvokeServer(hit)
			if result == "Hit" then
				local audioHIt = cur_weapon.hitSFX
				audioHIt:Play()				
			elseif result == "Blocked" then
				local blockedaudio = cur_weapon.blockedSFX
				blockedaudio:Play()
			end
		end
	end
	
end
local function block(actionName,inputState,inputObject)
	if inputState == Enum.UserInputState.Begin then

		local action = remotes.CallWeapon:InvokeServer("Block")
		if action == "Block" then
			block_track:Play()
			local audioBLK = char.BatModel.blockSFX
			audioBLK:Play()
		end
	elseif inputState == Enum.UserInputState.End then
		local action = remotes.CallWeapon:InvokeServer("EndBlock")
		if action == "EndBlock" then
			block_track:Stop()
		end
	end
end

local function run(actionName,inputState,inputObject)
	if inputState == Enum.UserInputState.Begin then
		remotes.CS:FireServer("Run")
	elseif inputState == Enum.UserInputState.End then
		remotes.CS:FireServer("Walk")
	end
end


local tween_info = TweenInfo.new(1)
local run_tween = tween_service:Create(camera, tween_info, {FieldOfView = 90})
local walk_tween = tween_service:Create(camera, tween_info, {FieldOfView = 70})
local run_animation = char.Animations.RunAnimation
local animator = hum.Animator

local run_track = animator:LoadAnimation(run_animation)


replicated_storage.Remotes.ChangeAnimation.OnClientEvent:Connect(function(anim)
	if anim == "Run" then
		run_track:Play()
		run_tween:Play()
	else 
		run_track:Stop()
		walk_tween:Play()
	end
end)

context_action_service:BindAction("Swing", swing, false, Enum.UserInputType.MouseButton1)
context_action_service:BindAction("Block", block, false, Enum.KeyCode.F)
context_action_service:BindAction("Equip", equip, false, Enum.KeyCode.One)
context_action_service:BindAction("Run", run, false, Enum.KeyCode.LeftShift)
