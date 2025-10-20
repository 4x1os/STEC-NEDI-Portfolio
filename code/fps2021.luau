--[[
Script from 2021.
This is my first attempt making an FPS system. I used a tutorial for it, 
but it came out suprisingly well.

FPS includes a reload, fire, and walk system. 

There's a lot of comments because this was when I was first trying to learn.
]]

--| Services
local rs = game:GetService("ReplicatedStorage")


--| Modules and Assets

local modules = rs:WaitForChild("Modules")
local weapons = rs:WaitForChild("Weapons")
local remotes = rs:WaitForChild("Remotes")

local weapon_handler = require(modules.FPSModule) --fps module
local velocity = require(modules.Velocity):Init(true) --velocity, update this using another framework

--InputService, remember to extract the inputs commands and remove velocity
local inputs = velocity:GetService("InputService")

local cur_weapon = nil --Current weapon and a number to enum converter
local enum_binds = {
	[1] = "One";
	[2] = "Two";
	[3] = "Three";
	[4] = "Four";
}

--requests weapon data through the server, i suggest moving the weapons and modules to serverstorage
local weapons, ammo_data = remotes.New:InvokeServer()
local weapon = weapon_handler.new(weapons)

weapon.AmmoData = ammo_data

-- clearing viewmodels we could have kept in the camera because of script errors and stuff
local viewmodels = workspace.Camera:GetChildren()

for i,v in pairs(viewmodels) do
	if v.Name == "viewmodel" then
		v:Destroy()
	end
end

-- equip code, this filters through 
for i,v in pairs(weapons) do
	-- cooldown for spammy bois
	local working

	-- we will bind this per-weapon
	local function equip()
		if working then return end -- essentially a quick cooldown

		working = true

		-- if the weapon isn't the weapon we want, then leave it)
		if weapon.CurrentWeapon ~= v then

			if weapon.Equipped then
				weapon:remove()
			end
			
			weapon:equip(v)
			weapon.CurrentWeapon = v
			-- v is a string now, so remove .Name			
		else
			-- if it's the same, just remove it
			spawn(function()
				weapon:remove()
			end)
			weapon.CurrentWeapon = nil

		end
		working = false
	end

	-- Change this to contextaction or just update the module, get rid of velocity.
	inputs.BindOnBegan(nil,enum_binds[i],equip,"Equip : "..i)
	inputs.BindOnBegan("MouseButton2",nil,function() weapon:aim(true) end,"AimDownSights")
	inputs.BindOnEnded("MouseButton2",nil,function() weapon:aim(false) end,"AimDownSights")
	
	inputs.BindOnBegan("MouseButton1",nil,function() weapon:fire(true) end,"Fire")
	inputs.BindOnEnded("MouseButton1",nil,function() weapon:fire(false) end,"Fire")
	inputs.BindOnBegan(nil, "R", function() weapon:reload() end, "Reload")

end

local function update(dt)
	weapon:update(dt)
	remotes.TiltAt:FireServer(math.asin(workspace.Camera.CFrame.LookVector.y));
end


-- marking the gun as unequippable
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Died:Connect(function() weapon:remove() weapon.Disabled = true end)


--tick stuff
game:GetService("RunService").RenderStepped:Connect(update)
