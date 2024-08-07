repeat task.wait() until game:IsLoaded()
local replicatedStorage = game:GetService("ReplicatedStorage")
local Client, Utl = (replicatedStorage:WaitForChild("ClientSetup")):InvokeServer()
local clientDecompiled = decompile(Client)
local utlDecompiled = decompile(Utl)
local effectsDecompiled = decompile(Utl:WaitForChild('Effects'))
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
if isfile('stuff/effects.txt') and readfile('stuff/effects.txt') == effectsDecompiled then
    warn('no new update | Effects')
else
    warn('new update! | Effects')
end
writefile('stuff/client.txt', clientDecompiled)
writefile('stuff/utl.txt', utlDecompiled)
writefile('stuff/effects.txt', effectsDecompiled)