--!strict
local Detain = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local remotes = replicatedStorage:WaitForChild("Remotes").Detain
--local settings = require(script.Parent.DetainManager.Settings)
local runService = game:GetService("RunService")
local Arrest = require(script.Arrest)
local Jail = require(script.Jail)


local function handleArrest(plr : Player, prisoner : Model | nil): Model | nil
	if Arrest.getPlayerArrest(plr) then
		Arrest.unarrestUser(plr)
	end

	if not prisoner then return nil end

	Arrest.arrestUser(plr, prisoner)
	return prisoner
end

local function handleJail(plr : Player, duration : number, reason : string)
	if Arrest.getPlayerArrest(plr)~= nil then
		local prisoner = Arrest.getPlayerArrest(plr) :: Model
		Arrest.unarrestUser(plr)
		Jail.addPerson(prisoner, plr.Name, duration, reason)
		print(duration, reason)
	end
end

function Detain.init()
	Jail.tick()
	
	remotes.ArrestUser.OnServerInvoke = handleArrest
	remotes.JailUser.OnServerEvent:Connect(handleJail)
end


return Detain
