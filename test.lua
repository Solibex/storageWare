repeat task.wait() until game:IsLoaded()
local timeFormat = function(value)
	return '[ timeformat fail ] - '..value
end
local players = game:GetService("Players")
local hud = players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('HUD')
local clockGui = hud:WaitForChild('Clock')
clockGui.Visible = true
local clockTime = workspace:WaitForChild('ClockTime')

for i,v in getgc(false) do
	if type(v) == 'function' and getfenv(v).script.Name == 'Utilities' and debug.getinfo(v).name == 'timeFormat' then
		timeFormat = v
	end
end

clockTime.Changed:Connect(function(value)
	clockGui.Text = timeFormat(value)
end)