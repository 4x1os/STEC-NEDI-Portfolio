--!strict
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes").Detain
local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui
local detainMessage = playerGui:WaitForChild("DetainGui").DetainMessage

function timerTick(duration)
	for timeLeft = duration, 0, -1 do
		detainMessage.DetainTimeLabel.Text = "Time left: "..timeLeft
		task.wait(1)
	end
end

function changeUI(jailer : string, duration : IntValue, reason : string): None
	print(duration)
	print(reason)
	if jailer then
		detainMessage.Visible = true
		detainMessage.DetainReasonLabel.Text = "Reason: "..reason
		detainMessage.DetainUserLabel.Text = "Detained by "..jailer
		local timer = coroutine.create(function()timerTick(duration)end)
		coroutine.resume(timer)
	else 
		detainMessage.Visible = false
	end
end

remotes.ToggleDetainUI.OnClientEvent:Connect(changeUI)
remotes.ToggleInterfaceLock.OnClientEvent:Connect(function(toggle : boolean): None
	print(toggle)
	game:GetService("StarterGui"):SetCore("ResetButtonCallback", toggle)
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, toggle)
end)