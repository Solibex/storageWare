rconsolename('debug getgc table')
writefile('testing.LOL', '')
for i,v in getgc(false) do
	if type(v) == 'function' and getfenv(v).script.Name == 'Client' and debug.getinfo(v).name == "isColliding" then
		hookfunction(v, function() return false end)
	end
end
-- Krnl Monaco v2-- Krnl Monaco v2rconsolename('debug getgc table')
local players = game:GetService("Players")
local hud = players.LocalPlayer.PlayerGui:WaitForChild('HUD')
local timeFormat
for i,v in getgc(false) do
	if type(v) == 'function' and getfenv(v).script.Name == 'Utilities' and debug.getinfo(v).name == 'timeFormat' then
		timeFormat = v
	end
end
workspace.ClockTime.Changed:Connect(function(value)
	hud.Clock.Text = timeFormat(workspace.ClockTime.Value)
end)