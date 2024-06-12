repeat task.wait() until game:IsLoaded()
local timeFormat = function(value)
	return '[ timeformat fail ] - '..value
end
local players = game:GetService("Players")
local hud = players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('HUD')
local clock_gui = hud:WaitForChild('Clock')
clock_gui.Visible = true

local clock_time = workspace:WaitForChild('ClockTime')

for i,v in getgc(false) do
	if type(v) == 'function' and getfenv(v).script.Name == 'Utilities' and debug.getinfo(v).name == 'timeFormat' then
		timeFormat = v
	end
end

clock_time.Changed:Connect(function(value)
	clock_gui.Text = timeFormat(value)
end)