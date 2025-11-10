local teamHandler = {}
local teamRanks = {}
local uiAssets = game:GetService("ReplicatedStorage").Assets.Leaderboard
local groupService = game:GetService("GroupService")
local remotes = game:GetService("ReplicatedStorage").Remotes.TeamService

local function createTeamUI(team : Team)
	local teamFrame = uiAssets.Template.DefaultFrame:Clone()
	teamFrame.TagName.Text = team:GetAttribute("TagName")
	teamFrame.TagName.BackgroundColor3 = team:GetAttribute("TagColor")
	teamFrame.TeamTitle.Text = team.Name
	teamFrame.Name = team.Name
	teamFrame.Parent = uiAssets.Transcribed
end

local function getLeaderboard(plr : Player): {[string] : {[string] : number}}
	local teams = game.Teams:GetTeams()
	local data = {}
	for _, team in pairs(teams) do
		data[team.Name] = {}
		for _, plr in pairs(team:GetPlayers()) do
			if plr.Team == team then
				data[team.Name][plr.Name] = teamRanks[plr.UserId]
			end
		end
	end
	return data
end

local function sortPriority(teams : {Team}) : ({[number] : Team}, {number})
	local teamData = {}
	local teamPriority = {}
	for _, team in teams do
		teamData[team:GetAttribute("GroupPriority")] = team
		table.insert(teamPriority, team:GetAttribute("GroupPriority"))
	end
	table.sort(teamPriority)
	return teamData, teamPriority
end

local function getAssignableTeams(plr : Player) : {Team} 
	if not plr then return end
	local teams = game.Teams:GetTeams()
	local teamSelectable = {}
	for _, team in pairs(teams) do
		if plr:IsInGroup(team:GetAttribute("GroupID")) then
			table.insert(teamSelectable, team)
		end
	end
	table.insert(teamSelectable, game.Teams.Civilian)
	return teamSelectable
end

local function addToTeam(plr: Player, team : Team) 
	if not plr then return end
	plr.TeamColor = team.TeamColor
	if team:GetAttribute("GroupID") == 0 then
		teamRanks[plr.UserId] = "Civilian"
		return
	end
	teamRanks[plr.UserId] = plr:GetRoleInGroup(team:GetAttribute("GroupID"))
end

local function assignTeams(plr : Player, teamData : {[number] : Team}, keys : {number}) 
	if not plr then return end
	for _, order in keys do
		if plr:IsInGroup(teamData[order]:GetAttribute("GroupID")) then
			addToTeam(plr, teamData[order])
			return
		end
	end
	addToTeam(plr, teamData[999])
	return
end

local function removePlayer(userId : number)
	teamRanks[userId] = nil
end

local function changePlayerTeam(plr : Player, team: Team)
	if not plr:IsInGroup(team:GetAttribute("GroupID")) and team.Name ~= "Civilian" then return end
	addToTeam(plr, team)
	plr:LoadCharacter()
end

local function addLabel(char : Model)
	local plr = game.Players:GetPlayerFromCharacter(char)
	char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	char.Humanoid.DisplayName = ""
	local nameTag = game:GetService("ServerStorage").Assets.NametagGui:Clone()
	nameTag.NameLabel.Text = plr.Name
	nameTag.RankLabel.Text = teamRanks[plr.UserId]
	nameTag.RankLabel.TextColor3 = plr.Team:GetAttribute("TagColor")
	nameTag.JobLabel.Text = plr.Team.Name
	nameTag.Parent = char
	nameTag.Adornee = char.Head
end

local function onTeamChange(plr : Player)
	addToTeam(plr, plr.Team)
end

function teamHandler.init()
	for _, team in pairs(game.Teams:GetChildren()) do
		createTeamUI(team)
	end
	local teamData, keys = sortPriority(game.Teams:GetChildren())
	game.Players.PlayerAdded:Connect(function(plr)
		assignTeams(plr, teamData, keys)
		remotes.InitClient:FireClient(plr)
		plr.CharacterAdded:Connect(addLabel)
		plr:LoadCharacter()
		plr.Team.Changed:Connect(onTeamChange)
	end)
	game.Players.PlayerRemoving:Connect(function(plr)
		removePlayer(plr.UserId)
	end)
	remotes.GetLeaderboard.OnServerInvoke = getLeaderboard
	remotes.GetTeams.OnServerInvoke = getAssignableTeams
	remotes.ChangeTeam.OnServerEvent:Connect(changePlayerTeam)
end

return teamHandler