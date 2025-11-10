local player = game.Players.LocalPlayer
local uiAssets = game:GetService("ReplicatedStorage"):WaitForChild("Assets")
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes").TeamService

local playerUI = player:WaitForChild("PlayerGui")
local leaderboard = playerUI:WaitForChild("Leaderboard")
local teamUI = playerUI:WaitForChild("TeamChange")

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

local function clearLeaderboard() 
	for i, v in pairs(leaderboard.MainFrame.ScrollingFrame:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

local function addPlayer(plr : string, rank : string) 
	local plrUI = uiAssets.Leaderboard.Template.PlayerFrame:Clone()
	plrUI.RankLabel.Text = rank
	plrUI.NameLabel.Text = plr
	plrUI.Parent = leaderboard.MainFrame.ScrollingFrame
end

local function addTeam(id, data)
	local header = uiAssets.Leaderboard.Transcribed[id]:Clone()
	header.Parent = leaderboard.MainFrame.ScrollingFrame
	local teamCount = 0
	for plr, rank in data do
		addPlayer(plr, rank)
		teamCount += 1
	end
	if teamCount <= 0 then
		header:Destroy()
	end
end

function loadUI()
	clearLeaderboard()
	local playerData = remotes.GetLeaderboard:InvokeServer()
	for id, team in playerData do
		addTeam(id, team)
	end	
end

function toggleLeaderboard(action, state, object)
	if state == Enum.UserInputState.Begin then
		loadUI()
		leaderboard.Enabled = true
	else 
		leaderboard.Enabled = false
	end 
end

local teamChangeUI = playerUI:WaitForChild("TeamChange")

local function loadCard(tag : string, name : string, teamContext : Team)
	local card = uiAssets.Teams.TeamFrame:Clone()
	card.TagLabel.Text = tag
	card.TeamLabel.Text = name
	card.Frame.TextButton.MouseButton1Click:Connect(function()
		remotes.ChangeTeam:FireServer(teamContext)
		teamUI.Enabled = false
	end)
	card.Parent = teamUI:WaitForChild("Frame").ScrollingFrame
end

local function loadTeams()
	local info = remotes:WaitForChild("GetTeams"):InvokeServer()
	for _, team in info do
		loadCard(team:GetAttribute("TagName"), team.Name, team)
	end	
end


playerUI:WaitForChild("Settings").SettingsButton.MouseButton1Click:Connect(function()
	teamUI.Enabled = not teamUI.Enabled
end)

remotes.InitClient.OnClientEvent:Connect(loadTeams)

local contextActionService = game:GetService("ContextActionService")
contextActionService:BindAction("Open Leaderboard", toggleLeaderboard, false, Enum.KeyCode.Tab)	

