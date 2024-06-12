local players = game:GetService("Players")

repeat task.wait() until game:IsLoaded()
local timeFormat = function(value)
	return '[ timeformat fail ] - '..value
end
local local_player = players.LocalPlayer
local player_gui = local_player.PlayerGui

local hud = player_gui:WaitForChild('HUD')
local clock_gui = hud:WaitForChild('Clock')
clock_gui.Visible = true

local clock_time = workspace:WaitForChild('ClockTime')

if getgc and #getgc(false) > 0 then
	for i,v in getgc(false) do
		if type(v) == 'function' and getfenv(v).script.Name == 'Utilities' and debug.getinfo(v).name == 'timeFormat' then
			timeFormat = v
		end
	end
end

clock_time.Changed:Connect(function(value)
	clock_gui.Text = timeFormat(value)
end)