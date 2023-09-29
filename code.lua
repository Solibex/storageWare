getgenv().debugConsole = true
local promptservice = game:GetService('ProximityPromptService')
local replicatedstorage = game:GetService('ReplicatedStorage')
local players = game:GetService('Players')
local cachedBase
if rconsoleclose then
	rconsoleclose()
end
function newprint(x) rconsoleprint(x..'\n') end
function empty() end
if getgenv().debugConsole then
	rconsolename('debug menu')
	newprint('We are running on build ALPHA')
end
local hue = 0
local delta = 0.005
shared.callbacks = {}
shared.resetfix = {}
shared.hooked = {
	noslidecd = nil
}
shared.client = nil
shared.utl = nil
for i,v in getgc(true) do
    if type(v) == 'table' and rawget(v, 'Player') then
        shared.client = v
    end
	if type(v) == 'table' and rawget(v, 'timeFormat') then
		shared.utl = v
	end
end
if not shared.client then
	rconsolewarn('No client was detected!')
	return
end
if not shared.utl then
	rconsolewarn('No utl was detected!')
	return
end
task.spawn(function()
	shared.client:Noti({
    	Title = "[✅] success",
		Text = "hooked into the client!", 
		Duration = 1
	})
	wait(1)
	local funi = os.date(tick())
	shared.client:Noti({
    	Title = "[✅] success",
		Text = shared.utl.timeFormat((funi.hour * 600) + (funi.min * 60) + (funi.sec)), 
		Duration = 1
	})
end)
local shoplib = require(replicatedstorage.Modules.ShopLib)

local storages = workspace:WaitForChild('Storages')
local mobs = workspace:WaitForChild('Mobs')

local char = players.LocalPlayer.Character or players.LocalPlayer.CharacterAdded:Wait();
local root = char:WaitForChild('HumanoidRootPart')

players.LocalPlayer.CharacterAdded:Connect(function(character)
	char = character
	root = character:WaitForChild('HumanoidRootPart')
	for index,func in pairs(shared.resetfix) do
		newprint('reset fix run | '..index)
		func()
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

local executor = identifyexecutor() or "shit executor"

local stuffbox = Tabs.Main:AddLeftGroupbox('stuff')
local espbox = Tabs.Main:AddRightGroupbox('esp')

if not fireproximityprompt or executor == "Electron" then -- electron has dummy function
	getgenv().fireproximityprompt = function(Obj)
		if Obj.ClassName == "ProximityPrompt" then 
			Obj:InputHoldBegin()
			Obj:InputHoldEnd()
		else 
			error("userdata<ProximityPrompt> expected")
		end
	end
	shared.client:Noti({
    	Title = "[❌] bad",
		Text = 'fireproximityprompt is bad, requires to be looked', 
		Duration = 1
	})
end
local npcs_shops = {}

for i, v in pairs(shoplib) do
	if rawget(v, 'ToolTypes') then
		continue
	end

	table.insert(npcs_shops, i)
end

function esp(part, color, distance, customName)
	if part:FindFirstChild('pluh') then return end
	local a = Instance.new("BillboardGui",part)
	a.Name = "pluh"
	a.Size = UDim2.new(1,0, 1,0)
	a.AlwaysOnTop = true
	a.MaxDistance = distance
	local b = Instance.new("Frame",a)
	b.Size = UDim2.new(1,0, 1,0)
	b.BackgroundTransparency = 0.80
	b.BorderSizePixel = 0
	b.BackgroundColor3 = color
	local c = Instance.new('TextLabel',b)
	c.Size = UDim2.new(1,0,1,0)
	c.BorderSizePixel = 0
	c.TextSize = 20
	c.Font = Enum.Font.RobotoMono
	c.TextColor3 = color
	c.Text = customName or part.Name
	c.Position = UDim2.fromScale(0, -0.5)
	c.BackgroundTransparency = 1
	local d = Instance.new('UICorner', b)
	d.CornerRadius = UDim.new(1, 0)
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

						newprint('instant_prompt start')

						shared.callbacks['instant_prompt'] = function()
							connection:Disconnect() 
							newprint('instant_prompt cancel') 
						end
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
						while task.wait() and Toggles.noslidecd.Value do
							rawset(shared.client, 'SlideCD', -1)
						end
						newprint('noslidecd start')
					end)
					shared.callbacks['noslidecd'] = function()
						task.cancel(thread)
						rawset(shared.client, 'SlideCD', time())
						newprint('noslidecd cancel')
					end
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
					local shit = {}
					local thread = task.spawn(function()
						for _,v in ipairs(storages:GetChildren()) do
							local connection = v.DescendantAdded:Connect(function(part)
								if (part.Parent.Name == 'Loot') then
                                    esp(part, Color3.new(0, 255, 0), Options.itemesp_distance.Value)
                                end
                                if (part.Parent.Name == 'Items') then
                                    esp(part, Color3.new(0, 255, 0), Options.itemesp_distance.Value)
                                end
								if (part.Name == 'Golden Skull') then
									esp(part, Color3.new(0, 255, 0), Options.itemesp_distance.Value)
								end
							end)
							table.insert(shit, connection)
						end
						newprint('item_esp start')
					end)
					shared.callbacks['item_esp'] = function()
						for _,v in ipairs(shit) do
							v:Disconnect()
						end
						newprint('item_esp cancel')
						task.cancel(thread)
					end
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
					local shit = {}
					local thread = task.spawn(function()
						for _,v in ipairs(storages:GetChildren()) do
							table.insert(shit, v.DescendantAdded:Connect(function(part)
								if part.Parent.Name ~= 'Mobs' then return end
								esp(part, Color3.new(255, 0, 0), Options.mobesp_distance.Value)
							end))
							table.insert(shit, mobs.ChildAdded:Connect(function(part)
								esp(part, Color3.new(255, 0, 0), Options.mobesp_distance.Value)
							end))
						end
						newprint('mob_esp start')
					end)
					shared.callbacks['mob_esp'] = function()
						for _,v in ipairs(shit) do
							v:Disconnect()
						end
						newprint('mob_esp cancel')
						task.cancel(thread)
					end
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
					local connection
					local thread = task.spawn(function()
						connection = workspace.DescendantAdded:Connect(function(part)
							if part.Parent.Name ~= 'NPC' then return end
							esp(part,Color3.new(0,0,255), Options.npcesp_distance.Value)
						end)
						newprint('npc_esp start')
					end)
					shared.callbacks['npc_esp'] = function()
						if connection then
							connection:Disconnect()
						end
						newprint('npc_esp cancel')
						task.cancel(thread)
					end
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
espbox:AddToggle('locked_esp', {
	Text = 'locked esp',
	Default = false, 
	Tooltip = 'esp for locked storages', 

	Callback = function(Value)
		if Value == true then
			if shared.callbacks['locked_esp'] == nil then
				do
					local shit = {}
					local thread = task.spawn(function()
						for _,v in ipairs(storages:GetChildren()) do
							if v:GetAttribute('Locked') and v:FindFirstChild('Door') and v.Door:FindFirstChild('Lock') then
								esp(v.Door.Lock,Color3.fromRGB(255, 172, 28), Options.lockedesp_distance.Value, 'Locked')
							end
							v:GetAttributeChangedSignal('Locked'):Connect(function()
								if not v:GetAttribute('Locked') then return end
								repeat wait() until v:FindFirstChild('Door') and v.Door:FindFirstChild('Lock')
								esp(v,Color3.fromRGB(255, 172, 28), Options.lockedesp_distance.Value, 'Locked')
								newprint('updated lock')
							end)
						end
						newprint('locked_esp start')
					end)
					shared.callbacks['locked_esp'] = function()
						newprint('locked_esp cancel')
						task.cancel(thread)
					end
				end
			end
		elseif Value == false and shared.callbacks['locked_esp'] then
			shared.callbacks['locked_esp']()
			shared.callbacks['locked_esp'] = nil
		end
	end
})
espbox:AddSlider('lockedesp_distance', {
	Text = 'locked esp distance',
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
					local shit = {}
					local thread = task.spawn(function()
						for _=1, 2 do
							local loop = task.spawn(function()
								while task.wait() do
									players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
									players.LocalPlayer.CameraMinZoomDistance = 20
									players.LocalPlayer.CameraMaxZoomDistance = 20
								end
							end)
							table.insert(shit, loop)
						end
						newprint('third_person start')
					end)
					shared.callbacks['third_person'] = function()
						for _,v in ipairs(shit) do
							task.cancel(v)
						end
						task.cancel(thread)

						newprint('third_person cancel')
					end
				end
			end
		elseif Value == false and shared.callbacks['third_person'] then
			shared.callbacks['third_person']()
			shared.callbacks['third_person'] = nil
		end
	end
}):AddKeyPicker('thirdperson', {

	Default = 'V', 
	SyncToggleState = true,
	
	Mode = 'Toggle', 

	Text = 'third person', 
	NoUI = false, 

	Callback = empty,

	ChangedCallback = empty
})
stuffbox:AddToggle('autopickup', {
	Text = 'auto pick up',
	Default = false, 
	Tooltip = 'pick up item nearby (recommended to do it manually if you want to look legit?)', 

	Callback = function(Value)
		if Value == true then
			if shared.callbacks['autopickup'] == nil then
				do
					local shit = {}
					local cum = {}

					local thread = task.spawn(function()
						for _,storage in ipairs(storages:GetChildren()) do
							table.insert(shit, storage.DescendantAdded:Connect(function(part)
								if (part.Parent.Name == 'Loot') or (part.Parent.Name == 'Items') or (part.Name == "Golden Skull") then
									table.insert(cum, part)
									part:SetAttribute('autopickup_registered', true)
									newprint(part.Name..' '..part.Parent.Name..' registered value-'..tostring(part:GetAttribute('autopickup_registered')))
								end
							end))

							table.insert(shit, storage.DescendantRemoving:Connect(function(part)
								if part:GetAttribute('autopickup_registered') then
									table.remove(cum, table.find(cum, part))
								end
							end))
						end
						while task.wait() do
							for _,v in ipairs(cum) do
								if (root.Position - v:GetPivot().Position).Magnitude >= 20 then
									continue
								end
								local prompt = v:FindFirstChild('ProximityPrompt', true) or v:FindFirstChild('Prompt', true)
								if prompt then
									fireproximityprompt(prompt)
								end
							end
						end
					end)

					newprint('autopickup start')

					shared.callbacks['autopickup'] = function()
						task.cancel(thread)
						for _,v in ipairs(shit) do
							v:Disconnect()
						end

						newprint('autopick cancel')
					end
				end
			end
		elseif Value == false and shared.callbacks['autopickup'] then
			shared.callbacks['autopickup']()
			shared.callbacks['autopickup'] = nil
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
					local shit = {}

					local thread = task.spawn(function()
						for _,storage in ipairs(storages:GetChildren()) do
							table.insert(shit, storage.DescendantAdded:Connect(function(part)
								if (part.Parent.Name == 'Kill') then
									part.Parent:Destroy()
								end
							end))
						end

						newprint('nolaser start')
					end)

					shared.callbacks['nolaser'] = function()
						for _,v in ipairs(shit) do
							v:Disconnect()
						end
						task.cancel(thread)
						newprint('nolaser cancel')
					end
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
					local shit = {}

					local thread = task.spawn(function()
						for _,v in ipairs(storages:GetChildren()) do
							table.insert(shit, v.DescendantAdded:Connect(function(part)
								if (part.Parent.Name == 'Wire') then
									part.Parent:Destroy()
								end
							end))
						end
						newprint('nodart start')
					end)

					shared.callbacks['nodart'] = function()
						for _,v in ipairs(shit) do
							v:Disconnect()
						end
						newprint('nodart cancel')
						task.cancel(thread)
					end
				end
			end
		elseif Value == false and shared.callbacks['nodart'] then
			shared.callbacks['nodart']()
			shared.callbacks['nodart'] = nil
		end
	end
})
local used = {}
stuffbox:AddDropdown('open_npc_shop', {
    Values = npcs_shops,
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'open npc shop',
    Tooltip = 'lets you open and buy any item with no limit', -- Information shown when you hover over the dropdown

    Callback = function(Value)
		local selected
		for _,v in ipairs(workspace:GetDescendants()) do
			if table.find(used, v) then continue end
			selected = v
			print(v.Name)
			table.insert(used, v)
			break
		end
		local old = rawget(shared.utl.Channel, 'new')
		if old then
			rawset(shared.utl.Channel, 'new', function()
				return {Duration = empty, Start = function()
					shared.client:Noti({
						Title = "[✅] success",
						Text = "opened shop gui, reverting to old", 
						Duration = 1
					})
				end, Cancel = empty}
			end)
			shared.client:OpenShopGui({selected, Value})
			rawset(shared.utl.Channel, 'new', old)
		else
			shared.client:Noti({
				Title = "[❌] error",
				Text = "failed to obtain channel.new", 
				Duration = 1
			})
		end
    end
})

espbox:AddToggle('rainbowchar', {
    Text = 'character rainbow',
    Default = false, -- Default value (true / false)
    Tooltip = 'make your entire character rainbow', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['rainbowchar'] == nil then
                do
                    local thread = task.spawn(function()
						local rainbowresetfix = function()
							repeat task.wait() until char
							while char and task.wait() do
								hue += delta
								 for _, v in ipairs(char:GetChildren()) do
									if v:IsA("MeshPart") then
										v.Color = Color3.fromHSV(hue,1,1)
									end
								end 
								if hue >= 1 then
									hue = 0
								end
							end
							print('rainbowchar run')
						end
						rainbowresetfix()
						table.insert(shared.resetfix, rainbowresetfix)
                        print('rainbowchar start')
                    end)
					shared.callbacks['rainbowchar'] = function()
						shared.resetfix['rainbowchar'] = nil
						task.cancel(thread)
						print('rainbowchar cancel')
					end
                end
            end
        elseif Value == false and shared.callbacks['rainbowchar'] then
            shared.callbacks['rainbowchar']()
            shared.callbacks['rainbowchar'] = nil
        end
    end
})
espbox:AddToggle('forcefieldchar', {
    Text = 'character forcefield',
    Default = false, -- Default value (true / false)
    Tooltip = 'make your entire character forcefield', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            if shared.callbacks['forcefieldchar'] == nil then
                do
                    local thread = task.spawn(function()
						local forcefieldresetfix = function()
							repeat wait() until char
							for i, v in ipairs(char:GetChildren()) do
								if v:IsA("BasePart") then
									v.Material = Enum.Material.ForceField
								end
							end
							print('force field run')
						end
						forcefieldresetfix()
						table.insert(shared.resetfix, forcefieldresetfix)
                        print('forcefieldchar start')
                    end)
					shared.callbacks['forcefieldchar'] = function()
						shared.resetfix['forcefieldchar'] = nil
						print('forcefieldchar cancel')
					end
                end
            end
        elseif Value == false and shared.callbacks['forcefieldchar'] then
            shared.callbacks['forcefieldchar']()
            shared.callbacks['forcefieldchar'] = nil
        end
    end
})
stuffbox:AddLabel('open safe'):AddKeyPicker('opensafe', {

	Default = 'Delete', 
	SyncToggleState = false,
	
	Mode = 'Toggle', 

	Text = 'open safe', 
	NoUI = false, 

	Callback = function(Value)
		players.LocalPlayer.PlayerGui.HUD.Bank.Visible = Value
	end,

	ChangedCallback = empty
})
stuffbox:AddLabel('teleport to base'):AddKeyPicker('teleportbase', {
	Default = 'Home', 
	SyncToggleState = false,
	
	Mode = 'Toggle', 

	Text = 'teleport to base', 
	NoUI = true,
	
	Callback = function(Value)
		if cachedBase then
			Library:Notify('Teleporting to base')
			root:PivotTo(cachedBase:GetPivot())
			return
		end
		for _,v in ipairs(storages:GetChildren()) do
			if v:GetAttribute("Owner") == players.LocalPlayer.Name then
				Library:Notify('Teleporting to base')
				root:PivotTo(v:GetPivot())
				cachedBase = v
				return
			end
		end
		Library:Notify('no base detected')
	end,

	ChangedCallback = empty
})
stuffbox:AddLabel('open crafting table'):AddKeyPicker('opencrafttable', {
	Default = 'I', 
	SyncToggleState = false,
	
	Mode = 'Toggle', 

	Text = 'open crafting table', 
	NoUI = false,
	
	Callback = function(Value)
		if Value == true then
			shared.client:SetupCraft()
		else
			shared.client:CloseCraft()
		end
	end,

	ChangedCallback = empty
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
		executor,
		math.floor(FPS),
		math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
	));
end);

Library.KeybindFrame.Visible = true; 

Library:OnUnload(function()
	WatermarkConnection:Disconnect()
	for index,func in pairs(shared.callbacks) do
		func()
		shared.callbacks[index] = nil
	end
	if rconsoleclose then
		rconsoleclose()
	end
	newprint('Unloaded!')
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

ThemeManager:SetFolder('storagewareBETA')

SaveManager:SetFolder('storagewareBETA/THE-STORAGE')
SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()