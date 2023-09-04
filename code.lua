local promptservice = game:GetService('ProximityPromptService')
local players = game:GetService('Players')

if getgenv().debug then
    rconsolename('debug menu')
    rconsoleprint('We are running on build ALPHA')
end

shared.callbacks = {}
shared.resetfix = {}
shared.hooked = {
    noslidecd = false
}

local storages = workspace:WaitForChild('Storages')
local mobs = workspace:WaitForChild('Mobs')

local char = players.LocalPlayer.Character
local root = char:WaitForChild('HumanoidRootPart')

players.LocalPlayer.CharacterAdded:Connect(function(character)
	char = character
	root = character:WaitForChild('HumanoidRootPart')
	rconsoleprint('reset fix')
	for i,v in pairs(shared.resetfix) do
		shared.resetfix[i]()
	end
end)

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'storageware',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local stuffbox = Tabs.Main:AddLeftGroupbox('stuff')
local espbox = Tabs.Main:AddRightGroupbox('esp')

if not fireproximityprompt or identifyexecutor() == "Electron" then
	getgenv().fireproximityprompt = function(Obj)
		if Obj.ClassName == "ProximityPrompt" then 
			Obj:InputHoldBegin()
			Obj:InputHoldEnd()
		else 
			error("userdata<ProximityPrompt> expected")
		end
	end
	Library:Notify("fireproximityprompt bad, prompt required to be looked")
else
	rconsoleprint('fireproximityprompt good')
end
function esp(part, color)
	if part:FindFirstChild('pluh') then return end
    local a = Instance.new("BillboardGui",part)
    a.Name = "pluh"
    a.Size = UDim2.new(1,0, 1,0)
    a.AlwaysOnTop = true
    local b = Instance.new("Frame",a)
    b.Size = UDim2.new(1,0, 1,0)
    b.BackgroundTransparency = 0.80
    b.BorderSizePixel = 0
    b.BackgroundColor3 = color
    local d = Instance.new('UICorner', b)
    d.CornerRadius = UDim.new(1, 0)
    local c = Instance.new('TextLabel',b)
    c.Size = UDim2.new(1,0,1,0)
    c.BorderSizePixel = 0
    c.TextSize = 20
    c.Font = Enum.Font.RobotoMono
    c.TextColor3 = color
    c.Text = part.Name
	c.Position = UDim2.fromScale(0, -0.5)
    c.BackgroundTransparency = 1
end
stuffbox:AddToggle('instant_prompt', {
    Text = 'instant prompt',
    Default = false, 
    Tooltip = 'instantly pick up items, etc..', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['instant_prompt'] == nil then
                do
                    local thread = task.spawn(function()
                        local connection = promptservice.PromptButtonHoldBegan:Connect(function(prompt)
                            prompt.HoldDuration = 0
                        end)
                        rconsoleprint('instant_prompt start')
                        shared.callbacks['instant_prompt'] = function() connection:Disconnect() rconsoleprint('instant_prompt cancel') end
                    end)
                end
            end
        elseif Value == false and shared.callbacks['instant_prompt'] then
            shared.callbacks['instant_prompt']()
            shared.callbacks['instant_prompt'] = nil
        end
    end
})
stuffbox:AddToggle('noslidecd', {
    Text = 'no slide cooldown',
    Default = false, 
    Tooltip = 'remove slide cooldown', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['noslidecd'] == nil then
                do
                    local thread = task.spawn(function()
                        shared.mathshit = time()
                        shared.hooked.noslidecd = true
                        if shared.hooked.noslidecd == false then
                            local Old Old = hookfunction(time, function(...)
                                if Toggles.noslidecd.Value and not checkcaller() then
                                    shared.mathshit += 1.76
                                    return shared.mathshit
                                else
                                    return Old(...)
                                end
                            end)
                        end
                        rconsoleprint('noslidecd start')
                        shared.callbacks['noslidecd'] = function() if shared.mathshit - time() > 0 then Library:Notify(('wait %.2fs until you could slide normally again'):format(mathshit - time())) end rconsoleprint('noslidecd cancel') end
                    end)
                end
            end
        elseif Value == false and shared.callbacks['noslidecd'] then
            shared.callbacks['noslidecd']()
            shared.callbacks['noslidecd'] = nil
        end
    end
})
espbox:AddToggle('item_esp', {
    Text = 'item esp',
    Default = false, 
    Tooltip = 'esp for item', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['item_esp'] == nil then
                do
                    local thread = task.spawn(function()
                        local shit = {}
                        for _,v in ipairs(storages:GetChildren()) do
                            local connection = v.DescendantAdded:Connect(function(part)
								
                                if (part.Parent.Name == 'Loot') then
                                    esp(part, Color3.new(0, 255, 0))
                                end
                                if (part.Parent.Name == 'Items') then
                                    esp(part, Color3.new(0, 255, 0))
                                end
								if (part.Name == 'Golden Skull') then
									esp(part, Color3.new(0, 255, 0))
								end
                            end)
                            table.insert(shit, connection)
                        end
                        rconsoleprint('item_esp start')
                        shared.callbacks['item_esp'] = function()
                            for _,v in ipairs(shit) do
                                v:Disconnect()
                            end
                            rconsoleprint('item_esp cancel')
                        end
                    end)
                end
            end
        elseif Value == false and shared.callbacks['item_esp'] then
            shared.callbacks['item_esp']()
            shared.callbacks['item_esp'] = nil
        end
    end
})

espbox:AddSlider('itemesp_distance', {
    Text = 'item esp distance',
    Default = 0,
    Min = 0,
    Max = 2000,
    Rounding = 1,
    Compact = false,
})
espbox:AddToggle('mob_esp', {
    Text = 'mob esp',
    Default = false, 
    Tooltip = 'esp for mobs', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['mob_esp'] == nil then
                do
                    local thread = task.spawn(function()
                        local shit = {}
                        for _,v in ipairs(storages:GetChildren()) do
                            local connection = v.DescendantAdded:Connect(function(part)
								if part:FindFirstChild('pluh') then return end
                                if (part.Parent.Name == 'Mobs') then
                                    if (root.Position - part:GetPivot().Position).Magnitude > Options.mobesp_distance.Value then
                                        if Options.mobesp_distance.Value ~= 0 then
                                            return
                                        end
                                    end
                                    esp(part, Color3.new(255, 0, 0))
                                end
                            end)
							local connection2 = mobs.ChildAdded:Connect(function(part)
									if part:FindFirstChild('pluh') then return end
                                	if (root.Position - part:GetPivot().Position).Magnitude > Options.mobesp_distance.Value then
                                        if Options.mobesp_distance.Value ~= 0 then
                                            return
                                        end
                                    end
                                    esp(part, Color3.new(255, 0, 0))
                            end)
                            table.insert(shit, connection)
							table.insert(shit, connection2)
                        end
                        rconsoleprint('mob_esp start')
                        shared.callbacks['mob_esp'] = function()
                            for _,v in ipairs(shit) do
                                v:Disconnect()
                            end
                            rconsoleprint('mob_esp cancel')
                        end
                    end)
                end
            end
        elseif Value == false and shared.callbacks['mob_esp'] then
            shared.callbacks['mob_esp']()
            shared.callbacks['mob_esp'] = nil
        end
    end
})
espbox:AddSlider('mobesp_distance', {
    Text = 'mob esp distance',
    Default = 0,
    Min = 0,
    Max = 2000,
    Rounding = 1,
    Compact = false,
})
espbox:AddToggle('npc_esp', {
    Text = 'npc esp',
    Default = false, 
    Tooltip = 'esp for npc', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['npc_esp'] == nil then
                do
                    local thread = task.spawn(function()
                        local shit = {}
                        local connection = workspace.DescendantAdded:Connect(function(part)
                            if part.Parent.Name ~= 'NPC' then return end
                            if (root.Position - part:GetPivot().Position).Magnitude > Options.npcesp_distance.Value then
                                if Options.npcesp_distance.Value ~= 0 then
                                    return
                                end
                            end
                            esp(part,Color3.new(0,0,255))
                        end)
                        rconsoleprint('npc_esp start')
                        shared.callbacks['npc_esp'] = function()
                            connection:Disconnect()
                            rconsoleprint('npc_esp cancel')
                        end
                    end)
                end
            end
        elseif Value == false and shared.callbacks['npc_esp'] then
            shared.callbacks['npc_esp']()
            shared.callbacks['npc_esp'] = nil
        end
    end
})
espbox:AddSlider('npcesp_distance', {
    Text = 'npc esp distance',
    Default = 0,
    Min = 0,
    Max = 2000,
    Rounding = 1,
    Compact = false,
})
espbox:AddToggle('third_person', {
    Text = 'third person',
    Default = false, 
    Tooltip = 'disclaimer: might be laggy.', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['third_person'] == nil then
                do
                    local thread = task.spawn(function()
                        local shit = {}
                        local connection = players.LocalPlayer:GetPropertyChangedSignal('CameraMinZoomDistance'):Connect(function()
                            players.LocalPlayer.CameraMinZoomDistance = 20
                        end)
                        local connection2 = players.LocalPlayer:GetPropertyChangedSignal('CameraMaxZoomDistance'):Connect(function()
                            players.LocalPlayer.CameraMaxZoomDistance = 20
                        end)
                        players.LocalPlayer.CameraMinZoomDistance = 20
                        players.LocalPlayer.CameraMaxZoomDistance = 20
                        table.insert(shit, connection)
                        table.insert(shit, connection2)
                        rconsoleprint('third_person start')
                        shared.callbacks['third_person'] = function()
                            for _,v in ipairs(shit) do
                                v:Disconnect()
                            end
                            rconsoleprint('third_person cancel')
                        end
                    end)
                end
            end
        elseif Value == false and shared.callbacks['third_person'] then
            shared.callbacks['third_person']()
            shared.callbacks['third_person'] = nil
        end
    end
})
stuffbox:AddToggle('autopickup', {
    Text = 'auto pick up',
    Default = false, 
    Tooltip = 'pick up item nearby (recommended to do it manually)', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['autopickup'] == nil then
                do
                    local shit = {}
                    local cum = {}
                    local thread = task.spawn(function()
                        for _,v in ipairs(storages:GetChildren()) do
                            local connection = v.DescendantAdded:Connect(function(part)
                                if (part.Parent.Name == 'Loot') or (part.Parent.Name == 'Items') or (part.Name == "Golden Skull") then
                                    table.insert(cum, part)
                                end
                            end)
                            local connection2 = v.DescendantRemoving:Connect(function(part)
                                for i,v in ipairs(cum) do
                                    if v == part then
                                        table.remove(cum, i)
                                    end
                                end
                            end)
                            table.insert(shit, connection)
                            table.insert(shit, connection2)
                        end
                        while task.wait() do
                            for _,v in ipairs(cum) do
								if (root.Position - v:GetPivot().Position).Magnitude > 100 then
                                    continue
                                end
                                rconsoleprint('Attempting to pick up '..v.Name..' at '..(root.Position - v:GetPivot().Position).Magnitude))
                                local prompt = v:FindFirstChild('ProximityPrompt', true) or v:FindFirstChild('Prompt', true)
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end)
                    rconsoleprint('autopickup start')
                    shared.callbacks['autopickup'] = function()
                        for _,v in ipairs(shit) do
                            v:Disconnect()
                        end
						task.cancel(thread)
                        rconsoleprint('autopick cancel')
                    end
                end
            end
        elseif Value == false and shared.callbacks['autopickup'] then
            shared.callbacks['autopickup']()
            shared.callbacks['autopickup'] = nil
        end
    end
})
stuffbox:AddLabel('not recommended\ndue to annoying and uselessness')
stuffbox:AddToggle('autoopen', {
    Text = 'auto open door',
    Default = false, 
    Tooltip = 'open door nearby (instantly)', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['autoopen'] == nil then
                do
                    local cum = {}
                    local thread = task.spawn(function()
                        for _,v in ipairs(storages:GetChildren()) do
                            for _,prompt in ipairs(v:GetDescendants()) do
								if prompt.Name == 'Handle' and prompt:IsA('BasePart') then
									table.insert(cum, prompt)
								end
							end
                        end
                        while task.wait() do
                            for _,v in ipairs(cum) do
								if (root.Position - v:GetPivot().Position).Magnitude > 75 then
                                    continue
                                end
                                local prompt = v:FindFirstChild('ProximityPrompt', true)
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end)
                    rconsoleprint('autoopen start')
                    shared.callbacks['autoopen'] = function()
                        task.cancel(thread)
                        rconsoleprint('autopick cancel')
                    end
                end
            end
        elseif Value == false and shared.callbacks['autoopen'] then
            shared.callbacks['autoopen']()
            shared.callbacks['autoopen'] = nil
        end
    end
})

stuffbox:AddToggle('nolaser', {
    Text = 'no laser',
    Default = false, 
    Tooltip = 'removes laser hitbox', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['nolaser'] == nil then
                do
                    local thread = task.spawn(function()
						local shit = {}
                        for _,v in ipairs(storages:GetChildren()) do
                            local connection = v.DescendantAdded:Connect(function(part)
                                if (part.Parent.Name == 'Kill') then
                                    part.Parent:Destroy()
                                end
                            end)
                            table.insert(shit, connection)
                        end
                        rconsoleprint('nolaser start')
                        shared.callbacks['nolaser'] = function()
							for _,v in ipairs(shit) do
								v:Disconnect()
							end
                            task.cancel(thread)
							rconsoleprint('nolaser cancel')
						end
                    end)
                end
            end
        elseif Value == false and shared.callbacks['nolaser'] then
            shared.callbacks['nolaser']()
            shared.callbacks['nolaser'] = nil
        end
    end
})
stuffbox:AddToggle('nodart', {
    Text = 'no dart trap',
    Default = false, 
    Tooltip = 'removes dart trap (the string trap) hitbox', 

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['nodart'] == nil then
                do
                    local thread = task.spawn(function()
						local shit = {}
                        for _,v in ipairs(storages:GetChildren()) do
                            local connection = v.DescendantAdded:Connect(function(part)
                                if (part.Parent.Name == 'Wire') then
                                    part.Parent:Destroy()
                                end
                            end)
                            table.insert(shit, connection)
                        end
                        rconsoleprint('nodart start')
                        shared.callbacks['nodart'] = function()
							for _,v in ipairs(shit) do
								v:Disconnect()
							end
							rconsoleprint('nodart cancel')
						end
                    end)
                end
            end
        elseif Value == false and shared.callbacks['nodart'] then
            shared.callbacks['nodart']()
            shared.callbacks['nodart'] = nil
        end
    end
})
stuffbox:AddLabel('open safe'):AddKeyPicker('opensafe', {

    Default = 'Delete', 
    SyncToggleState = false,
    
    Mode = 'Toggle', 

    Text = 'Open safe', 
    NoUI = false, 

    
    Callback = function(Value)
        players.LocalPlayer.PlayerGui.HUD.Bank.Visible = Value
    end,

    ChangedCallback = function(New)
        rconsoleprint('[cb] Keybind changed!', New)
    end
})
stuffbox:AddLabel('teleport to base'):AddKeyPicker('teleportbase', {
    Default = 'Home', 
    SyncToggleState = false,
    
    Mode = 'Toggle', 

    Text = 'Teleport to base', 
    NoUI = true,
    
    Callback = function(Value)
		local founded = false
        for _,v in ipairs(storages:GetChildren()) do
			if v:GetAttribute("Owner") and v:GetAttribute("Owner") == players.LocalPlayer.Name then
				Library:Notify('Teleporting')
				root:PivotTo(v:GetPivot())
				founded = true
			end
		end
		if founded == false then Library:Notify('no base detected') end
    end,

    ChangedCallback = function(New)
        rconsoleprint('[cb] Keybind changed!', New)
    end
})


Library:SetWatermarkVisibility(true)


local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('storageware | %s | %s fps | %s ms'):format(
		identifyexecutor(),
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = true; 

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    for i,v in pairs(shared.callbacks) do
        shared.callbacks[i]()
        shared.callbacks[i] = nil
    end
    rconsoleprint('Unloaded!')
    Library.Unloaded = true
end)


local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')


MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('storageware')

SaveManager:SetFolder('storageware/THE-STORAGE')
SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()