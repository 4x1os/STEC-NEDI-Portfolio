--!strict
local jail = {}
local jailed = {}
local jailTimers : {
	[Model] : number
} = {}


local remotes = game:GetService("ReplicatedStorage").Remotes.Detain
local pos = require(script.JailPositions)
local function calculateTimeout(duration : number | nil) : number
	if not duration then
		return 0
	elseif duration <= 0 then
		return 30 -- default timeout
	else 
		return duration		
	end
	
end

local function teleportToJail(primaryPart : BasePart)
	primaryPart.CFrame = workspace.DetainRoom.TeleportPart.CFrame
end

function jail.tick()
	game:GetService("RunService").Heartbeat:Connect(function(dt)
		for person, timer in jailTimers do
			jailTimers[person] -= dt
			if jailTimers[person] <= 0 then
				jail.unjailPerson(person)
			end
		end
	end)
end

function jail.unjailPerson(person : Model)
	if game.Players:GetPlayerFromCharacter(person) then
		remotes.ToggleInterfaceLock:FireClient(game.Players:GetPlayerFromCharacter(person), true)
	else 
		person:MoveTo(Vector3.new(288.578, 11.204, -339.649))
	end
	jailTimers[person] = nil
	task.wait(0.1)
	game.Players:GetPlayerFromCharacter(person):LoadCharacter()
end


function jail.addPerson(person: Model, jailerName: string, duration : number, reason : string)
	print(duration, reason)
	local timeout = calculateTimeout(duration)
	local personRoot = person.PrimaryPart :: BasePart

	table.insert(jailed, person)
	if timeout > 0 then
		jailTimers[person] = timeout
	end	
	
	if game.Players:GetPlayerFromCharacter(person) then
		--personRoot:SetNetworkOwner(nil)
		remotes.ToggleInterfaceLock:FireClient(game.Players:GetPlayerFromCharacter(person), false)
		teleportToJail(personRoot)

		task.wait(0.1)
		--personRoot:SetNetworkOwner(game.Players:GetPlayerFromCharacter(person))		
		remotes.ToggleDetainUI:FireClient(game.Players:GetPlayerFromCharacter(person), jailerName, timeout, reason)
	else 
		teleportToJail(personRoot)
	end

end

return jail