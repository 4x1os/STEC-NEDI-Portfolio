--[[
This is me starting to use more moduleScripts and trying to 
compartmentalize each component more. I managed to set up
metatables myself and link fastCast to my weapon system with no
tutorial.
]]

local weapons = {}
weapons.__index = weapons

local fastcast = require(game:GetService("ReplicatedStorage").FastCastRedux)


local CosmeticBullet = Instance.new("Part")
CosmeticBullet.Material = Enum.Material.Neon
CosmeticBullet.Color = Color3.fromRGB(255, 255, 255)
CosmeticBullet.CanCollide = false
CosmeticBullet.Anchored = true
CosmeticBullet.Size = Vector3.new(0.2, 0.2, 2.4)
pcm = require(game:GetService("ReplicatedStorage").PartCache)



function OnRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	if cosmeticBulletObject == nil then return end
	local bulletLength = cosmeticBulletObject.Size.Z / 2 
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

function OnRayTerminated(cast)
	local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
	if cosmeticBullet ~= nil then
		cosmeticBullet:Destroy()
	end
end


function checkHolsters(player, name)
	for i,v in pairs(player:GetChildren()) do
		if v.Name == name then
			v:Destroy()
		end
	end
end

function checkEquipped(player)
	for i,v in pairs(player:GetChildren()) do
		if v.Name == "FireableWeapon" then
			v:Destroy()
		end
	end
end

function weapons.new(bind, data, owner)
	local weapon = setmetatable({}, weapons)
	weapon.bind = bind
	weapon.data = data
	weapon.owner = owner
	weapon.currentAnim = nil
	weapon.firearm = nil
	
	weapon.castparams = RaycastParams.new()
	weapon.castparams.IgnoreWater = true
	weapon.castparams.FilterType = Enum.RaycastFilterType.Blacklist
	weapon.castparams.FilterDescendantsInstances = {
		owner.Character
	}
	
	weapon.caster = fastcast.new()
	weapon.caster.LengthChanged:Connect(OnRayUpdated)
	weapon.caster.CastTerminating:Connect(OnRayTerminated)
	
	weapon.CB = weapon.caster.newBehavior()
	weapon.CB.RaycastParams = weapon.castparams
	weapon.CB.MaxDistance = 1000
	weapon.CB.HighFidelityBehavior = weapon.caster.HighFidelityBehavior.Default
	
	local CosmeticBulletsFolder = workspace:FindFirstChild("CosmeticBulletsFolder") or Instance.new("Folder", workspace)
	local CosmeticPartProvider = pcm.new(CosmeticBullet, 500, CosmeticBulletsFolder)
	weapon.CB.CosmeticBulletProvider = CosmeticPartProvider

	weapon.CB.CosmeticBulletContainer = CosmeticBulletsFolder
	
	local holsteredweapon = data.HolsteredWeapon:Clone()
	holsteredweapon.Parent = owner.Character
	holsteredweapon.Root.Part1 = owner.Character.HumanoidRootPart	
	holsteredweapon.Name = data.Name
	
	return weapon
end

function weapons:Equip()
	checkHolsters(self.owner.Character, self.data.Name)
	self.firearm = self.data.FireableWeapon:Clone()
	self.firearm.Parent = self.owner.Character
	self.firearm.Root.Part0 = self.owner.Character.HumanoidRootPart
	local animator = self.owner.Character.Humanoid.Animator
	local anim = self.data.WeaponIdle:Clone()
	self.currentAnim = animator:LoadAnimation(anim)
	self.currentAnim.Looped = true
	self.currentAnim:Play()
end

function weapons:Unequip()
	if self.currentAnim then
		self.currentAnim:Stop()
	end
	self.currentAnim = nil
	checkEquipped(self.owner.Character)
	self.firearm = nil
	local holsteredweapon = self.data.HolsteredWeapon:Clone()
	holsteredweapon.Name = self.data.Name
	holsteredweapon.Parent = self.owner.Character
	holsteredweapon.Root.Part1 = self.owner.Character.HumanoidRootPart	
end

-- unsafe, fire from server in next push
function weapons:Fire()
	if self.firearm then
		self.caster:Fire(self.firearm.GunPoint.WorldPosition, self.owner.Character.HumanoidRootPart.CFrame.LookVector, 300, self.CB)
	end
end


return weapons
