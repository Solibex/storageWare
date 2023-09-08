-- Krnl Monaco v2rconsolename('debug getgc table')
writefile('testing.LOL', '')
for i,v in getgc(false) do
	if type(v) == 'function' and (getfenv(v).script.Name == 'Client' or getfenv(v).script.Name == 'Utilities') then
		appendfile('testing.LOL', debug.getinfo(v).name..' | '..getfenv(v).script.Name..'\n')
	end
end