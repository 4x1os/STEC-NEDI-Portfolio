--!strict
local arrestData = {}
local temp_arrest = {}
local Arrests = {}

export type Character = Model & {
	PrimaryPart : BasePart,
	Humanoid : Humanoid
}

local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes").Detain


function Arrests.arrestUser(plr: Player, prisoner: Model)
	if not prisoner:FindFirstChild("Humanoid"):IsA("Humanoid") then return end
	local plrChar = plr.Character :: Model
	local plrHRP = plrChar.PrimaryPart :: BasePart
	
	
	local prisonerHRP = prisoner.PrimaryPart :: BasePart
	local prisonerHumanoid = prisoner:FindFirstChild("Humanoid") :: Humanoid
	prisonerHRP.CFrame = plrHRP.CFrame * CFrame.new(0, 0.01, -2)
	
	local cuffBind = Instance.new("WeldConstraint")	
	cuffBind.Parent = plrChar
	cuffBind.Part0 = plrChar.PrimaryPart
	cuffBind.Part1 = prisoner.PrimaryPart	
	cuffBind.Name = "ArrestWeld"
	
	prisonerHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
	prisonerHumanoid.PlatformStand = true
	prisonerHumanoid.WalkSpeed = 0
	prisonerHumanoid.JumpPower = 0
	prisonerHumanoid.AutoRotate = false

	for _, parts in pairs(prisoner:GetDescendants()) do
		if parts:IsA("Part") then
			parts.Massless = true
			parts.CanCollide = false
		end
	end	
	
	local prisonerUser = game.Players:GetPlayerFromCharacter(prisoner)
	if prisonerUser then
		remotes.ToggleInterfaceLock:FireClient(prisonerUser, false)
	end
	arrestData[plr.UserId] = prisoner
end


function Arrests.unarrestUser(plr: Player)
	local char = plr.Character :: Model
	local prisoner = arrestData[plr.UserId]
	local prisonerHumanoid = prisoner:FindFirstChild("Humanoid") :: Humanoid
	local prisonerHRP = prisoner:FindFirstChild("HumanoidRootPart") :: BasePart
	if char:FindFirstChild("ArrestWeld") then
		local weld = char:FindFirstChild("ArrestWeld") :: WeldConstraint
		weld.Part0 = nil
		weld.Part1 = nil
		weld:Destroy()
	end
	

	prisonerHumanoid.PlatformStand = false
	prisonerHumanoid.WalkSpeed = 16
	prisonerHumanoid.JumpPower = 50
	prisonerHumanoid.AutoRotate = true
	prisonerHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	task.wait(0.05)
	prisonerHumanoid:ChangeState(Enum.HumanoidStateType.Running)

	for _, parts in pairs(prisoner:GetDescendants()) do
		if parts:IsA("Part") then
			parts.Massless = false
			parts.CanCollide = true
		end
	end			
	
	local prisonerUser = game.Players:GetPlayerFromCharacter(prisoner)
	if prisonerUser then
		local prisonerRoot = prisoner.PrimaryPart :: Part
		local root = char.PrimaryPart :: Part
		remotes.ToggleInterfaceLock:FireClient(prisonerUser, true)
	end
	
	arrestData[plr.UserId] = nil
	return
end


function Arrests.getPlayerArrest(player: Player): Model | nil
	return arrestData[player.UserId]
end



return Arrests