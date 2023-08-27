local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local promptservice = game:GetService('ProximityPromptService')
shared.callbacks = {}
shared.resetfix = {}
shared.hooked = {
    noslidecd = false
}
local players = game:GetService('Players')
local storages = workspace:WaitForChild('Storages')
local mobs = workspace.Mobs
local char = players.LocalPlayer.Character
local root = char:WaitForChild('HumanoidRootPart')
players.LocalPlayer.CharacterAdded:Connect(function(character)
	char = character
	root = character:WaitForChild('HumanoidRootPart')
	print('reset fix')
	for i,v in pairs(shared.resetfix) do
		shared.resetfix[i]()
	end
end)
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    -- Set Center to true if you want the menu to appear in the center
    -- Set AutoShow to true if you want the menu to appear when it is created
    -- Position and Size are also valid options here
    -- but you do not need to define them unless you are changing them :)

    Title = 'storageware',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a prefrence.
local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Groupbox and Tabbox inherit the same functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(name))
local stuffbox = Tabs.Main:AddLeftGroupbox('stuff')
local espbox = Tabs.Main:AddRightGroupbox('esp')

-- We can also get our Main tab via the following code:
-- local LeftGroupBox = Window.Tabs.Main:AddLeftGroupbox('Groupbox')

-- Tabboxes are a tiny bit different, but here's a basic example:
--[[

local TabBox = Tabs.Main:AddLeftTabbox() -- Add Tabbox on left side

local Tab1 = TabBox:AddTab('Tab 1')
local Tab2 = TabBox:AddTab('Tab 2')

-- You can now call AddToggle, etc on the tabs you added to the Tabbox
]]

-- Groupbox:AddToggle
-- Arguments: Index, Options
-- credit to sowd, modified
if not fireproximityprompt then
	getgenv().fireproximityprompt = function(Obj)
		if Obj.ClassName == "ProximityPrompt" then 
			Obj:InputHoldBegin()
			Obj:InputHoldEnd()
		else 
			error("userdata<ProximityPrompt> expected")
		end
	end
	Library:Notify("exploit isn't supported, you need to look at the prompt")
else
	print('fireproximityprompt good')
end
function esp(part, color)
	if part:FindFirstChild('pluh') then return end
    if (root.Position - part:GetPivot().Position).Magnitude > Options.itemesp_distance.Value then
       if Options.itemesp_distance.Value ~= 0 then
            return
        end
    end
    if part:FindFirstChild('pluh') then return end
    local a = Instance.new("BillboardGui",part) -- pretty much explains everything
    a.Name = "pluh"
    a.Size = UDim2.new(1,0, 1,0)
    a.AlwaysOnTop = true
    local b = Instance.new("Frame",a)
    b.Size = UDim2.new(1,0, 1,0)
    b.BackgroundTransparency = 0.80
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.new(0, 255, 0)
    local d = Instance.new('UICorner', b)
    d.CornerRadius = UDim.new(1, 0)
    local c = Instance.new('TextLabel',b)
    c.Size = UDim2.new(1,0,1,0)
    c.BorderSizePixel = 0
    c.TextSize = 20
    c.Font = Enum.Font.RobotoMono
    c.TextColor3 = Color3.new(0, 255, 0)
    c.Text = part.Name
	c.Position = UDim2.fromScale(0, -0.5)
    c.BackgroundTransparency = 1
end
stuffbox:AddToggle('instant_prompt', {
    Text = 'instant prompt',
    Default = false, -- Default value (true / false)
    Tooltip = 'instantly pick up items, etc..', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['instant_prompt'] == nil then
                do
                    local thread = task.spawn(function()
                        local connection = promptservice.PromptButtonHoldBegan:Connect(function(prompt)
                            prompt.HoldDuration = 0
                        end)
                        print('instant_prompt start')
                        shared.callbacks['instant_prompt'] = function() connection:Disconnect() print('instant_prompt cancel') end
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
    Default = false, -- Default value (true / false)
    Tooltip = 'remove slide cooldown', -- Information shown when you hover over the toggle

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
                        print('noslidecd start')
                        shared.callbacks['noslidecd'] = function() if shared.mathshit - time() > 0 then Library:Notify(('wait %.2fs until you could slide normally again'):format(mathshit - time())) end print('noslidecd cancel') end
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
    Default = false, -- Default value (true / false)
    Tooltip = 'esp for item', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['item_esp'] == nil then
                do
                    local thread = task.spawn(function()
                        local shit = {}
                        for _,v in ipairs(storages:GetChildren()) do
                            local connection = v.DescendantAdded:Connect(function(part)
								-- issues with or condition 
                                if (part.Parent.Name == 'Loot') then
                                    esp(part)
                                end
                                if (part.Parent.Name == 'Items') then
                                    esp(part)
                                end
								if (part.Name == 'Golden Skull') then
									esp(part) -- added for golden skull
								end
                            end)
                            table.insert(shit, connection)
                        end
                        print('item_esp start')
                        shared.callbacks['item_esp'] = function()
                            for _,v in ipairs(shit) do
                                v:Disconnect()
                            end
                            print('item_esp cancel')
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
    Default = false, -- Default value (true / false)
    Tooltip = 'esp for mobs', -- Information shown when you hover over the toggle

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
                                    if part:FindFirstChild('pluh') then return end
                                    local a = Instance.new("BillboardGui",part) -- pretty much explains everything
                                    a.Name = "pluh"
                                    a.Size = UDim2.new(1,0, 1,0)
                                    a.AlwaysOnTop = true
                                    local b = Instance.new("Frame",a)
                                    b.Size = UDim2.new(1,0, 1,0)
                                    b.BackgroundTransparency = 0.50
                                    b.BorderSizePixel = 0
                                    b.BackgroundColor3 = Color3.new(255, 0, 0)
                                    local d = Instance.new('UICorner', b)
                                    d.CornerRadius = UDim.new(1, 0)
                                    local c = Instance.new('TextLabel',b)
                                    c.Size = UDim2.new(1,0,1,0)
                                    c.BorderSizePixel = 0
                                    c.TextSize = 20
									c.Position = UDim2.fromScale(0, -0.5)
                                    c.Font = Enum.Font.RobotoMono
                                    c.TextColor3 = Color3.new(255, 0, 0)
                                    c.Text = part.Name
                                    c.BackgroundTransparency = 1
                                end
                            end)
							local connection2 = mobs.ChildAdded:Connect(function(part)
									if part:FindFirstChild('pluh') then return end
                                	if (root.Position - part:GetPivot().Position).Magnitude > Options.mobesp_distance.Value then
                                        if Options.mobesp_distance.Value ~= 0 then
                                            return
                                        end
                                    end
                                    if part:FindFirstChild('pluh') then return end
                                    local a = Instance.new("BillboardGui",part) -- pretty much explains everything
                                    a.Name = "pluh"
                                    a.Size = UDim2.new(1,0, 1,0)
                                    a.AlwaysOnTop = true
                                    local b = Instance.new("Frame",a)
                                    b.Size = UDim2.new(1,0, 1,0)
                                    b.BackgroundTransparency = 0.50
                                    b.BorderSizePixel = 0
                                    b.BackgroundColor3 = Color3.new(255, 0, 0)
                                    local d = Instance.new('UICorner', b)
                                    d.CornerRadius = UDim.new(1, 0)
                                    local c = Instance.new('TextLabel',b)
                                    c.Size = UDim2.new(1,0,1,0)
                                    c.BorderSizePixel = 0
                                    c.TextSize = 20
									c.Position = UDim2.fromScale(0, -0.5)
                                    c.Font = Enum.Font.RobotoMono
                                    c.TextColor3 = Color3.new(255, 0, 0)
                                    c.Text = part.Name
                                    c.BackgroundTransparency = 1
                            end)
                            table.insert(shit, connection)
							table.insert(shit, connection2)
                        end
                        print('mob_esp start')
                        shared.callbacks['mob_esp'] = function()
                            for _,v in ipairs(shit) do
                                v:Disconnect()
                            end
                            print('mob_esp cancel')
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
    Default = false, -- Default value (true / false)
    Tooltip = 'esp for npc', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['npc_esp'] == nil then
                do
                    local thread = task.spawn(function()
                        local shit = {}
                        local connection = workspace.DescendantAdded:Connect(function(part)
                                if (part.Parent.Name == 'NPC') then
                                    if (root.Position - part:GetPivot().Position).Magnitude > Options.npcesp_distance.Value then
                                        if Options.npcesp_distance.Value ~= 0 then
                                            return
                                        end
                                    end
                                    if part:FindFirstChild('pluh') then return end
                                    local a = Instance.new("BillboardGui",part) -- pretty much explains everything
                                    a.Name = "pluh"
                                    a.Size = UDim2.new(1,0, 1,0)
                                    a.AlwaysOnTop = true
                                    local b = Instance.new("Frame",a)
                                    b.Size = UDim2.new(1,0, 1,0)
                                    b.BackgroundTransparency = 0.50
                                    b.BorderSizePixel = 0
                                    b.BackgroundColor3 = Color3.new(0,0,255)
                                    local d = Instance.new('UICorner', b)
                                    d.CornerRadius = UDim.new(1, 0)
                                    local c = Instance.new('TextLabel',b)
                                    c.Size = UDim2.new(1,0,1,0)
                                    c.BorderSizePixel = 0
                                    c.TextSize = 20
                                    c.Font = Enum.Font.RobotoMono
                                    c.TextColor3 = Color3.new(0,0,255)
                                    c.Text = part.Name
									c.Position = UDim2.fromScale(0, -0.5)
                                    c.BackgroundTransparency = 1
                                end
                            end)
                        print('npc_esp start')
                        shared.callbacks['npc_esp'] = function()
                            connection:Disconnect()
                            print('npc_esp cancel')
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
    Default = false, -- Default value (true / false)
    Tooltip = 'disclaimer: might be laggy.', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['third_person'] == nil then
                do
                    local thread = task.spawn(function()
                        local shit = {}
                        for i=1, 2 do
							print(i)
							local loop =task.spawn(function()
								while task.wait() and getgenv().thirdperson do
									players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
									players.LocalPlayer.CameraMinZoomDistance = 20
									players.LocalPlayer.CameraMaxZoomDistance = 20
								end
							end)
							table.insert(shit, connection)
						end
                        print('third_person start')
                        shared.callbacks['third_person'] = function()
                            connection:Disconnect()
                            print('third_person cancel')
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
    Default = false, -- Default value (true / false)
    Tooltip = 'pick up item nearby (recommended to do it manually)', -- Information shown when you hover over the toggle

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
								if (root.Position - v:GetPivot().Position).Magnitude > 50 then
                                    continue
                                end
                                local prompt = v:FindFirstChild('ProximityPrompt', true) or v:FindFirstChild('Prompt', true)
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end)
                    print('autopickup start')
                    shared.callbacks['autopickup'] = function()
                        for _,v in ipairs(shit) do
                            v:Disconnect()
                        end
						task.cancel(thread)
                        print('autopick cancel')
                    end
                end
            end
        elseif Value == false and shared.callbacks['autopickup'] then
            shared.callbacks['autopickup']()
            shared.callbacks['autopickup'] = nil
        end
    end
})
stuffbox:AddToggle('autoopen', {
    Text = 'auto open door',
    Default = false, -- Default value (true / false)
    Tooltip = 'open door nearby (instantly)', -- Information shown when you hover over the toggle

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
                    print('autoopen start')
                    shared.callbacks['autoopen'] = function()
                        task.cancel(thread)
                        print('autopick cancel')
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
    Default = false, -- Default value (true / false)
    Tooltip = 'removes laser hitbox', -- Information shown when you hover over the toggle

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
									print('destroyed laser')
                                end
                            end)
                            table.insert(shit, connection)
                        end
                        print('nolaser start')
                        shared.callbacks['nolaser'] = function()
							for _,v in ipairs(shit) do
								v:Disconnect()
							end
							print('nolaser cancel')
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
    Default = false, -- Default value (true / false)
    Tooltip = 'removes dart trap (the string trap) hitbox', -- Information shown when you hover over the toggle

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
									print('destroyed wire')
                                end
                            end)
                            table.insert(shit, connection)
                        end
                        print('nodart start')
                        shared.callbacks['nodart'] = function()
							for _,v in ipairs(shit) do
								v:Disconnect()
							end
							print('nodart cancel')
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
stuffbox:AddLabel('Open safe'):AddKeyPicker('opensafe', {
    -- SyncToggleState only works with toggles.
    -- It allows you to make a keybind which has its state synced with its parent toggle

    -- Example: Keybind which you use to toggle flyhack, etc.
    -- Changing the toggle disables the keybind state and toggling the keybind switches the toggle state

    Default = 'Delete', -- String as the name of the keybind (MB1, MB2 for mouse buttons)
    SyncToggleState = false,


    -- You can define custom Modes but I have never had a use for it.
    Mode = 'Toggle', -- Modes: Always, Toggle, Hold

    Text = 'Open safe', -- Text to display in the keybind menu
    NoUI = false, -- Set to true if you want to hide from the Keybind menu,

    -- Occurs when the keybind is clicked, Value is `true`/`false`
    Callback = function(Value)
        players.LocalPlayer.PlayerGui.HUD.Bank.Visible = Value
    end,

    -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
    ChangedCallback = function(New)
        print('[cb] Keybind changed!', New)
    end
})
stuffbox:AddLabel('teleport to base'):AddKeyPicker('teleportbase', {
    -- SyncToggleState only works with toggles.
    -- It allows you to make a keybind which has its state synced with its parent toggle

    -- Example: Keybind which you use to toggle flyhack, etc.
    -- Changing the toggle disables the keybind state and toggling the keybind switches the toggle state

    Default = 'Home', -- String as the name of the keybind (MB1, MB2 for mouse buttons)
    SyncToggleState = false,


    -- You can define custom Modes but I have never had a use for it.
    Mode = 'Toggle', -- Modes: Always, Toggle, Hold

    Text = 'Teleport to base', -- Text to display in the keybind menu
    NoUI = true, -- Set to true if you want to hide from the Keybind menu,

    -- Occurs when the keybind is clicked, Value is `true`/`false`
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

    -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
    ChangedCallback = function(New)
        print('[cb] Keybind changed!', New)
    end
})
-- Library functions
-- Sets the watermark visibility
Library:SetWatermarkVisibility(true)

-- Example of dynamically-updating watermark with common traits (fps and ping)
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

Library.KeybindFrame.Visible = true; -- todo: add a function for this

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    for i,v in pairs(shared.callbacks) do
        shared.callbacks[i]()
        shared.callbacks[i] = nil
    end
    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('storageware')
SaveManager:SetFolder('storageware/THE-STORAGE')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()