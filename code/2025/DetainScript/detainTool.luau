--!strict

local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:WaitForChild("Remotes").Detain

local detainTool = script.Parent
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local detainUI = player:WaitForChild("PlayerGui"):WaitForChild("DetainGui")

local highlightedTarget = nil

local userHighlight = Instance.new("Highlight")
userHighlight.FillColor = Color3.fromRGB(190, 241, 255)
userHighlight.FillTransparency = 0.7
userHighlight.OutlineColor = Color3.fromRGB(255,255,255)
userHighlight.OutlineTransparency = 0
userHighlight.Parent = script

local toolActive = false

local function onUI(): boolean
	local uiview = player.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
	for _, ui in pairs(uiview) do 
		if ui:IsA("Frame") and ui.Visible and ui.BackgroundTransparency ~= 1 then
			print(ui)
			return true
		end
	end
	return false
end

local function highlightTarget()
	local curTarget = mouse.Target
	if (curTarget and curTarget.Parent:FindFirstChild("Humanoid")
	and curTarget.Parent.HumanoidRootPart.Anchored == false and toolActive) then
		userHighlight.Adornee = curTarget.Parent
		highlightedTarget = curTarget.Parent
	else
		userHighlight.Adornee = nil
		highlightedTarget = nil
	end	
end


local function toolActivated(): None 
	if onUI() then return end
	local detainedUser = remotes.ArrestUser:InvokeServer(highlightedTarget)
	if detainedUser then
		detainUI.DetainPanel.Visible = true
		detainUI.DetainPanel.UserLabel.Text = detainedUser.Name
	else 
		detainUI.DetainPanel.Visible = false
	end
end

local function submitDetain()
	local durationValue = tonumber(detainUI.DetainPanel.DetainForm.DurationInput.Text)
	local reasonValue = detainUI.DetainPanel.DetainForm.ReasonInput.Text
	if not durationValue then durationValue = 0 end

	remotes.JailUser:FireServer(durationValue, reasonValue)

	detainUI.DetainPanel.Visible = false
	detainUI.DetainPanel.DetainForm.DurationInput.Text = ""
	detainUI.DetainPanel.DetainForm.ReasonInput.Text = ""
end


detainUI.DetainPanel.DetainForm.DetainFormSubmit.MouseButton1Click:Connect(submitDetain)
runService.Heartbeat:Connect(highlightTarget)

detainTool.Activated:Connect(toolActivated)


detainTool.Equipped:Connect(function()
	toolActive = true
end)

detainTool.Unequipped:Connect(function()
	toolActive = false
	remotes.ArrestUser:InvokeServer()
	detainUI.showDetainPanel(false)
end)