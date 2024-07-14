local promptservice = game:GetService('ProximityPromptService')
local replicatedstorage = game:GetService('ReplicatedStorage')
local players = game:GetService('Players')

function empty() end

function notify(title, text, duration)
	getgenv().client:Noti({
		Title = title or "none",
		Text = text or "none", 
		Duration = duration or 1
	})
end
getgenv().callbacks = {}
getgenv().resetfix = {}


local modules = replicatedstorage:WaitForChild('Modules')

local shoplib = require(modules:WaitForChild('ShopLib')) or {}

local storages = workspace:WaitForChild('Storages')
local mobs = workspace:WaitForChild('Mobs')

local localplr = players.LocalPlayer

local char = localplr.Character or localplr.CharacterAdded:Wait();
local root = char:WaitForChild('HumanoidRootPart')

localplr.CharacterAdded:Connect(function(character)
	char = character
	root = character:WaitForChild('HumanoidRootPart')
	for index,func in next, getgenv().resetfix do
		print('reset fix run | '..index)
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

getgenv().client = {Noti = function(data)
	Library:Notify(`[{data.Title}] {data.Text}`)
end}
getgenv().utl = {}

for _,v in getgc(true) do
    if type(v) == 'table' and rawget(v, 'Player') then
        getgenv().client = v
    end
	if type(v) == 'table' and rawget(v, 'timeFormat') then
		getgenv().utl = v
	end
end

task.spawn(function()
	notify("[✅] success", "hooked into the client, and utilities!", 1)
end)
local Tabs = {
	Main = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

local executor = identifyexecutor() or "shit executor"

local stuffbox = Tabs.Main:AddLeftGroupbox('stuff')
local espbox = Tabs.Main:AddRightGroupbox('esp')

local fireprompt = fireproximityprompt or function(Obj)
	if Obj.ClassName == "ProximityPrompt" then 
		Obj:InputHoldBegin()
		Obj:InputHoldEnd()
	else 
		error("userdata<ProximityPrompt> expected")
	end
end

if not fireproximityprompt or executor == "Electron" then -- electron has dummy function
	notify("[❌] bad", "fireproximityprompt is bad, requires to be looked", 1)
end
local npcs_shops = {}

for i, v in pairs(shoplib) do
	if rawget(v, 'ToolTypes') then -- sellers
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
			if getgenv().callbacks['instant_prompt'] == nil then
				do
					local thread = task.spawn(function()
						local connection = promptservice.PromptButtonHoldBegan:Connect(function(prompt)
							prompt.HoldDuration = 0
						end)

						print('instant_prompt start')

						getgenv().callbacks['instant_prompt'] = function()
							connection:Disconnect() 
							print('instant_prompt cancel') 
						end
					end)
				end
			end
		elseif Value == false and getgenv().callbacks['instant_prompt'] then
			getgenv().callbacks['instant_prompt']()
			getgenv().callbacks['instant_prompt'] = nil
		end
	end
})
stuffbox:AddToggle('noslidecd', {
	Text = 'no slide cooldown',
	Default = false, 
	Tooltip = 'remove slide cooldown', 

	Callback = function(Value)
		if Value == true then
			if getgenv().callbacks['noslidecd'] == nil then
				do
					local thread = task.spawn(function()
						while task.wait() and Toggles.noslidecd.Value do
							rawset(getgenv().client, 'SlideCD', -1)
						end
						print('noslidecd start')
					end)
					getgenv().callbacks['noslidecd'] = function()
						task.cancel(thread)
						rawset(getgenv().client, 'SlideCD', time())
						print('noslidecd cancel')
					end
				end
			end
		elseif Value == false and getgenv().callbacks['noslidecd'] then
			getgenv().callbacks['noslidecd']()
			getgenv().callbacks['noslidecd'] = nil
		end
	end
})
espbox:AddToggle('item_esp', {
	Text = 'item esp',
	Default = false, 
	Tooltip = 'esp for item', 

	Callback = function(Value)
		if Value == true then
			if getgenv().callbacks['item_esp'] == nil then
				do
					local shit = {}
					local thread = task.spawn(function()
						for _, v in next, storages:GetChildren() do
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
						print('item_esp start')
					end)
					getgenv().callbacks['item_esp'] = function()
						for _,v in next, shit do
							v:Disconnect()
						end
						print('item_esp cancel')
						task.cancel(thread)
					end
				end
			end
		elseif Value == false and getgenv().callbacks['item_esp'] then
			getgenv().callbacks['item_esp']()
			getgenv().callbacks['item_esp'] = nil
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
			if getgenv().callbacks['mob_esp'] == nil then
				do
					local shit = {}
					local thread = task.spawn(function()
						for _,v in next, storages:GetChildren() do
							table.insert(shit, v.DescendantAdded:Connect(function(part)
								if part.Parent.Name ~= 'Mobs' then return end
								esp(part, Color3.new(255, 0, 0), Options.mobesp_distance.Value)
							end))
							table.insert(shit, mobs.ChildAdded:Connect(function(part)
								esp(part, Color3.new(255, 0, 0), Options.mobesp_distance.Value)
							end))
						end
						print('mob_esp start')
					end)
					getgenv().callbacks['mob_esp'] = function()
						for _,v in next, shit do
							v:Disconnect()
						end
						print('mob_esp cancel')
						task.cancel(thread)
					end
				end
			end
		elseif Value == false and getgenv().callbacks['mob_esp'] then
			getgenv().callbacks['mob_esp']()
			getgenv().callbacks['mob_esp'] = nil
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
			if getgenv().callbacks['npc_esp'] == nil then
				do
					local connection
					local thread = task.spawn(function()
						connection = workspace.DescendantAdded:Connect(function(part)
							if part.Parent.Name ~= 'NPC' then return end
							esp(part,Color3.new(0,0,255), Options.npcesp_distance.Value)
						end)
						print('npc_esp start')
					end)
					getgenv().callbacks['npc_esp'] = function()
						if connection then
							connection:Disconnect()
						end
						print('npc_esp cancel')
						task.cancel(thread)
					end
				end
			end
		elseif Value == false and getgenv().callbacks['npc_esp'] then
			getgenv().callbacks['npc_esp']()
			getgenv().callbacks['npc_esp'] = nil
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
			if getgenv().callbacks['locked_esp'] == nil then
				do
					local shit = {}
					local thread = task.spawn(function()
						for _,v in next, storages:GetChildren() do
							if v:GetAttribute('Locked') and v:FindFirstChild('Door') and v.Door:FindFirstChild('Lock') then
								esp(v.Door.Lock,Color3.fromRGB(255, 172, 28), Options.lockedesp_distance.Value, 'Locked')
							end
						end
						print('locked_esp start')
					end)
					getgenv().callbacks['locked_esp'] = function()
						print('locked_esp cancel')
						task.cancel(thread)
					end
				end
			end
		elseif Value == false and getgenv().callbacks['locked_esp'] then
			getgenv().callbacks['locked_esp']()
			getgenv().callbacks['locked_esp'] = nil
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
			if getgenv().callbacks['third_person'] == nil then
				do
					local shit = {}
					table.insert(shit, localplr:GetPropertyChangedSignal('CameraMode'):Connect(function()
						localplr.CameraMode = Enum.CameraMode.Classic
					end))
					table.insert(shit, localplr:GetPropertyChangedSignal('CameraMinZoomDistance'):Connect(function()
						localplr.CameraMinZoomDistance = 20
					end))
					table.insert(shit, localplr:GetPropertyChangedSignal('CameraMaxZoomDistance'):Connect(function()
						localplr.CameraMaxZoomDistance = 20
					end))
					print('third_person start')
					getgenv().callbacks['third_person'] = function()
						for _, v in next, shit do
							v:Disconnect()
						end

						print('third_person cancel')
					end
				end
			end
		elseif Value == false and getgenv().callbacks['third_person'] then
			getgenv().callbacks['third_person']()
			getgenv().callbacks['third_person'] = nil
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
			if getgenv().callbacks['autopickup'] == nil then
				do
					local shit = {}
					local cum = {}

					local thread = task.spawn(function()
						for _, storage in next, storages:GetChildren() do
							table.insert(shit, storage.DescendantAdded:Connect(function(part)
								if (part.Parent.Name == 'Loot') or (part.Parent.Name == 'Items') or (part.Name == "Golden Skull") then
									table.insert(cum, part)
								end
							end))

							table.insert(shit, storage.DescendantRemoving:Connect(function(part)
								if table.find(cum, part) then
									table.remove(cum, table.find(cum, part))
								end
							end))
						end
						while task.wait() do
							for _, v in next, cum do
								local prompt = v:FindFirstChild('ProximityPrompt', true) or v:FindFirstChild('Prompt', true)
								if (not prompt) or (root.Position - v:GetPivot().Position).Magnitude >= 25 then
									continue
								end
								fireprompt(prompt)
							end
						end
					end)

					print('autopickup start')

					getgenv().callbacks['autopickup'] = function()
						task.cancel(thread)
						for _,v in next, shit do
							v:Disconnect()
						end

						print('autopick cancel')
					end
				end
			end
		elseif Value == false and getgenv().callbacks['autopickup'] then
			getgenv().callbacks['autopickup']()
			getgenv().callbacks['autopickup'] = nil
		end
	end
})

stuffbox:AddToggle('nolaser', {
	Text = 'no laser',
	Default = false, 
	Tooltip = 'removes laser hitbox', 

	Callback = function(Value)
		if Value == true then
			if getgenv().callbacks['nolaser'] == nil then
				do
					local shit = {}

					local thread = task.spawn(function()
						for _, storage in next, storages:GetChildren() do
							table.insert(shit, storage.DescendantAdded:Connect(function(part)
								if (part.Parent.Name == 'Kill') then
									part.Parent:Destroy()
								end
							end))
						end

						print('nolaser start')
					end)

					getgenv().callbacks['nolaser'] = function()
						for _,v in next, shit do
							v:Disconnect()
						end
						task.cancel(thread)
						print('nolaser cancel')
					end
				end
			end
		elseif Value == false and getgenv().callbacks['nolaser'] then
			getgenv().callbacks['nolaser']()
			getgenv().callbacks['nolaser'] = nil
		end
	end
})
stuffbox:AddToggle('nodart', {
	Text = 'no dart trap',
	Default = false, 
	Tooltip = 'removes dart trap (the string trap) hitbox', 

	Callback = function(Value)
		if Value == true then
			if getgenv().callbacks['nodart'] == nil then
				do
					local shit = {}

					local thread = task.spawn(function()
						for _,v in next, storages:GetChildren() do
							table.insert(shit, v.DescendantAdded:Connect(function(part)
								if (part.Parent.Name == 'Wire') then
									part.Parent:Destroy()
								end
							end))
						end
						print('nodart start')
					end)

					getgenv().callbacks['nodart'] = function()
						for _,v in next, shit do
							v:Disconnect()
						end
						print('nodart cancel')
						task.cancel(thread)
					end
				end
			end
		elseif Value == false and getgenv().callbacks['nodart'] then
			getgenv().callbacks['nodart']()
			getgenv().callbacks['nodart'] = nil
		end
	end
})
local used = {}

local function get_random_object()
	for _,v in next, workspace:GetDescendants() do
		if table.find(used, v) then
			continue
		end
		table.insert(used, v)
		return v
	end
end

if #npcs_shops > 0 then
	stuffbox:AddDropdown('open_npc_shop', {
		Values = npcs_shops,
		Default = 1, -- number index of the value / string
		Multi = false, -- true / false, allows multiple choices to be selected
	
		Text = 'open npc shop',
		Tooltip = 'lets you open and buy any item', -- Information shown when you hover over the dropdown
	
		Callback = function(Value)
			local selected = get_random_object()
			local old = rawget(getgenv().utl.Channel, 'new')
			if old then
				rawset(getgenv().utl.Channel, 'new', function()
					return {Duration = empty, Start = function()
						rawset(getgenv().utl.Channel, 'new', old)
						notify("[✅] success", "opened shop gui", 1)
					end, Cancel = empty}
				end)
				getgenv().client:OpenShopGui({selected, Value})
			else
				notify("[❌] error", "failed to obtain channel.new", 1)
			end
		end
	})
end

local hue = 0
local delta = 0.005
espbox:AddToggle('rainbowchar', {
    Text = 'character rainbow',
    Default = false, -- Default value (true / false)
    Tooltip = 'make your entire character rainbow', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            if getgenv().callbacks['rainbowchar'] == nil then
                do
                    local thread = task.spawn(function()
						local rainbowresetfix = function()
							repeat task.wait() until char
							while char and task.wait() do
								hue += delta
								for _, v in next, char:GetChildren() do
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
						table.insert(getgenv().resetfix, rainbowresetfix)
                        print('rainbowchar start')
                    end)
					getgenv().callbacks['rainbowchar'] = function()
						getgenv().resetfix['rainbowchar'] = nil
						task.cancel(thread)
						print('rainbowchar cancel')
					end
                end
            end
        elseif Value == false and getgenv().callbacks['rainbowchar'] then
            getgenv().callbacks['rainbowchar']()
            getgenv().callbacks['rainbowchar'] = nil
        end
    end
})
espbox:AddToggle('forcefieldchar', {
    Text = 'character forcefield',
    Default = false, -- Default value (true / false)
    Tooltip = 'make your entire character forcefield', -- Information shown when you hover over the toggle

    Callback = function(Value)
        if Value == true then
            if getgenv().callbacks['forcefieldchar'] == nil then
                do
                    local thread = task.spawn(function()
						local forcefieldresetfix = function()
							repeat task.wait() until char
							for _, v in char:GetChildren() do
								if v:IsA("BasePart") then
									v.Material = Enum.Material.ForceField
								end
							end
							print('force field run')
						end
						forcefieldresetfix()
						table.insert(getgenv().resetfix, forcefieldresetfix)
                        print('forcefieldchar start')
                    end)
					getgenv().callbacks['forcefieldchar'] = function()
						getgenv().resetfix['forcefieldchar'] = nil
						print('forcefieldchar cancel')
					end
                end
            end
        elseif Value == false and getgenv().callbacks['forcefieldchar'] then
            getgenv().callbacks['forcefieldchar']()
            getgenv().callbacks['forcefieldchar'] = nil
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
		localplr.PlayerGui.HUD.Bank.Visible = Value
	end,

	ChangedCallback = empty
})
local cachedBase
stuffbox:AddLabel('teleport to base'):AddKeyPicker('teleportbase', {
	Default = 'Home', 
	SyncToggleState = false,
	
	Mode = 'Toggle', 

	Text = 'teleport to base', 
	NoUI = true,
	
	Callback = function(Value)
		notify("[❓] info", "attempting to teleporting to base", 1)
		for _,v in next, storages:GetChildren() do
			if v:GetAttribute("Owner") == localplr.Name then
				root:PivotTo(v:GetPivot())
				notify("[✅] success", "teleported to base", 1)
				return
			end
		end
		notify('[❌] failed', "failed to find base", 1)
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
			getgenv().client:SetupCraft()
		else
			getgenv().client:CloseCraft()
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
	for index,func in pairs(getgenv().callbacks) do
		func()
		getgenv().callbacks[index] = nil
	end
	print('Unloaded!')
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