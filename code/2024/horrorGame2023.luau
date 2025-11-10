--[[
This was written in 2023. I was working on making a sample horror game.
The features included "redshifting", which allows you to see and not see certain paths
when selected.

I also added a Camera sway system, flashlight system, battery system, and some "UI"
features. You should also check out the .rbxl files as well if you're able.
]]

local rs = game:GetService("ReplicatedStorage")
local plrs = game:GetService("Players")
local ts = game:GetService("TweenService")

local events = script.Events
local modules = script.Modules
local sfx = script.Assets.SFX
local assets = rs.Assets

local plrdata = require(modules.PlayerData)
local clock = require(modules.Clock)
local batterydata = plrdata.BatteryData
local camera = workspace.CurrentCamera


local plr = plrs.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

local gui = plr:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)


-- Interactive events

function overheat()
	char.Humanoid:TakeDamage(50)
	script.Assets.SFX.OverheatDamage:Play()
end


function checkintensity()
	if batterydata.Intensity < 4 then
		return true
	else
		return false
	end
end

function updateintensity(factor)
	if factor == true then
		batterydata.Intensity += 1
		if batterydata.Intensity > 3 then
			clock.new(true,2,"Overheat",overheat)
			script.Assets.SFX.Overheat:Play()
		else
			clock.delete("Overheat")
			script.Assets.SFX.Overheat:Stop()
		end
	else
		if batterydata.Intensity > 0 then
			batterydata.Intensity -= 1
		end
		if batterydata.Intensity <= 3 then
			clock.delete("Overheat")
			script.Assets.SFX.Overheat:Stop()
		end
	end
	events.UpdateUI:Fire('Intensity')
end

function sub()
	
	if batterydata.Battery <= 0 then
		
		gui.Effects.Vignette.BackgroundTransparency = 0
		wait(1)
		plr:Kick("CONNECTION LOST TO USER")		
		
	else 
		batterydata.Battery -= 1
		events.UpdateUI:Fire('Battery')
		if batterydata.Battery <= 5 then
			batterydata.WarningLevel = 4
		elseif batterydata.Battery <= 15 then
			batterydata.WarningLevel = 3
		elseif batterydata.Battery <= 30 then
			batterydata.WarningLevel = 2
		elseif batterydata.Battery <= 50 then		
			batterydata.WarningLevel = 1
		else
			batterydata.WarningLevel = 0
		end
	end
end

-- I made this module myself, it just controls the tick rate of things
clock.new(true, 1, "BatteryDrain", sub) 



function flashlight()
	if batterydata.Flashlight == false then
		if checkintensity() == false then return end
		local hrp = char.HumanoidRootPart
		local flashpart = assets.FlashlightPart:Clone()
		local fm = {Lerp = false, LerpSpeed = 0.6, TweenSpeed = 0.11}
		
		flashpart.Parent = camera
		flashpart.CFrame = camera.CFrame - hrp.CFrame.LookVector - Vector3.new(0,50,0)
		
		sfx.FlashlightToggle:Play()

		game:GetService("RunService").RenderStepped:Connect(function(DT)
			if flashlight then
				if not fm.Lerp then
					game.TweenService:Create(flashpart, TweenInfo.new(fm.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false), {CFrame = camera.CFrame- hrp.CFrame.LookVector}):Play()
				else
					flashpart.CFrame = flashpart.CFrame:Lerp(flashpart.CFrame - hrp.CFrame.LookVector, fm.LerpSpeed)
				end
			end
		end)
		
		updateintensity(true)
		batterydata.Flashlight = true
	else
		if workspace.Camera:FindFirstChild("FlashlightPart") then
			workspace.Camera.FlashlightPart:Destroy()
			sfx.FlashlightToggle:Play()
			
			
			updateintensity(false)
			batterydata.Flashlight = false
		end			
	end
end

function infared(): None 
	local tl = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	if batterydata.Infared == false then
		if checkintensity() == false then return end
		for i, v in pairs(workspace.Infared:GetChildren()) do
			v.Touched:Connect(function() end)
			local touching = v:GetTouchingParts()
			for i=1,#touching do
				if touching[i] == char.HumanoidRootPart then
					return 
				end
			end
		end

		for i,v in pairs(workspace.Infared:GetChildren()) do
			game.TweenService:Create(v, tl, {Transparency = 0}):Play()
			v.CanCollide = true
		end

		for i,v in pairs(workspace.Invisible:GetChildren()) do
			game.TweenService:Create(v, tl, {Transparency = 1}):Play()
			v.CanCollide = false
		end
		
		game.Lighting.ColorCorrection.Enabled = true
		
		local lt = plrdata.LightingData.Infared
		ts:Create(game.Lighting.ColorCorrection, ti, {Brightness = lt[1]}):Play()
		ts:Create(game.Lighting.ColorCorrection, ti, {Contrast = lt[2]}):Play()
		ts:Create(game.Lighting.ColorCorrection, ti, {Saturation = lt[3]}):Play()
		ts:Create(game.Lighting.ColorCorrection, ti, {TintColor = lt[4]}):Play()
		
		sfx.InfaredToggle:Play()
		updateintensity(true)
		batterydata.Infared = true
	else
		-- Call UI here 
		for i, v in pairs(workspace.Invisible:GetChildren()) do
			v.Touched:Connect(function() end)
			local touching = v:GetTouchingParts()
			for i=1,#touching do
				if touching[i] == char.HumanoidRootPart then
					return 
				end
			end
		end

		for i,v in pairs(workspace.Invisible:GetChildren()) do
			game.TweenService:Create(v, tl, {Transparency = 0}):Play()
			v.CanCollide = true
		end

		for i,v in pairs(workspace.Infared:GetChildren()) do
			game.TweenService:Create(v, tl, {Transparency = 1}):Play()
			v.CanCollide = false
		end
		
		sfx.InfaredToggle:Play()
		updateintensity(false)
		batterydata.Infared = false
		
		ts:Create(game.Lighting.ColorCorrection, ti, {Brightness = 0}):Play()
		ts:Create(game.Lighting.ColorCorrection, ti, {Contrast = 0}):Play()
		ts:Create(game.Lighting.ColorCorrection, ti, {Saturation = 0}):Play()
		local k = ts:Create(game.Lighting.ColorCorrection, ti, {TintColor = Color3.fromRGB(255,255,255)})
		k:Play()
		k.Completed:Wait()
		game.Lighting.ColorCorrection.Enabled = false
		
	end
end

function sprint(): None
	if batterydata.Sprint == false then
		if checkintensity() == false then return end
		rs.Remotes.ChangeSpeed:FireServer(true)
		updateintensity(true)
		batterydata.Sprint = true
		
	else
		rs.Remotes.ChangeSpeed:FireServer(false)
		updateintensity(false)
		batterydata.Sprint = false
	end
end

char.Humanoid.Died:Connect(function()
	wait(3)
	plr:Kick("SUBJECT INCAPACITATED")
end)

events.OnTouch.Event:Connect(function(effect : string, active: boolean): None
	if effect == "Drainer" then
		updateintensity(active)
	end
end)

rs.Remotes.KillPlayer.OnClientEvent:Connect(function()
	gui.Jumpscare.Visible = true
	char.Humanoid.Health = 0
end)

rs.Remotes.RefillHealth.OnClientEvent:Connect(function()
	batterydata.Battery = math.min(100, batterydata.Battery + 20)
end)


inpfuncs = {["Flashlight"] = flashlight, ["Infared"] = infared, ["Sprint"] = sprint}
events.InputTrigger.Event:Connect(function(inputName)
	inpfuncs[inputName]()
end)