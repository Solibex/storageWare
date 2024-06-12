local players = game:GetService('Players')
local replicated_storage = game:GetService('ReplicatedStorage')

local local_player = players.LocalPlayer

local client_table, ult_table

function notify(title, text, duration)
	if client_table then
        client_table:Noti({
            Title = title or "none",
            Text = text or "none", 
            Duration = duration or 1
        })
    else
        print(title, text, duration)
    end
end

for _,v in getgc(true) do
    if type(v) == 'table' and rawget(v, 'Player') then
        client_table = v
    end
	if type(v) == 'table' and rawget(v, 'timeFormat') then
		ult_table = v
	end
end

if client_table and ult_table  then
    
end