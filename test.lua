rconsolename('debug getgc table')
for i,v in getgc(false) do
	if type(v) == 'function' and getfenv(v).script.Name == 'Client' and debug.getinfo(v).name == 'Recoil' then
		hookfunction(v,function()
			return wait(9e9)
		end)
		print('hooking recoil')
	end
end