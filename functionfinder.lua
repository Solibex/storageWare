-- check workspace for functions!1
writefile('testing.LOL', '')
for _, v in getgc(false) do
	if type(v) == 'function' and (getfenv(v).script.Name == 'Client' or getfenv(v).script.Name == 'Utilities') and (debug.getinfo(v).name ~= '') then
		appendfile('testing.LOL', debug.getinfo(v).name..' | '..getfenv(v).script.Name..'\n')
	end
end