repeat wait() until game:IsLoaded()
local replicatedStorage = game:GetService("ReplicatedStorage")
local Client, Utl = (replicatedStorage:WaitForChild("ClientSetup")):InvokeServer()
local localplayer = game:GetService("Players").LocalPlayer
_G.Utl = require(Utl)
local v59 = require(Client).new(localplayer)
v59:SetUp()
local clientDecompiled = decompile(Client)
local utlDecompiled = decompile(Utl)
if isfile('stuff/client.txt') and readfile('stuff/client.txt') == clientDecompiled then
    warn('no new update | Client')
else
    warn('new update! | Client')
end
if isfile('stuff/utl.txt') and readfile('stuff/utl.txt') == utlDecompiled then
    warn('no new update | Utl')
else
    warn('new update! | Utl')
end
writefile('stuff/client.txt', clientDecompiled)
writefile('stuff/utl.txt', utlDecompiled)