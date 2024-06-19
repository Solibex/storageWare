print('[storageware] loading')
-- solara being retarded
if not getgenv()['Toggles'] then
    getgenv().Toggles = {}
end
if not getgenv()['Options'] then
    getgenv().Options = {}
end

local texts = {
    -- stuff
    instant_prompt = {Text = 'instant prompt', Tooltip = 'instantly pick up items, etc..'};
    no_slide_cd = {Text = 'no slide cooldown', Tooltip = 'remove slide cooldown'};

    -- esp
    player_esp = {Text = 'player esp', Tooltip = 'esp for player'};
    item_esp = {Text = 'item esp', Tooltip = 'esp for item'};
    npc_esp = {Text = 'npc esp', Tooltip = 'esp for npc'};
    mob_esp = {Text = 'mob esp', Tooltip = 'esp for mobs'};
    storage_esp = {Text = 'storage esp', Tooltip = 'esp for storage'}
}

local CHECK_MARK = '✅'
local WARNING_MARK = '⚠️'
local DENIED_MARK = '❌'

local run_service = cloneref(game:GetService('RunService')) :: RunService
local players = cloneref(game:GetService('Players')) :: Players
local replicated_storage = cloneref(game:GetService('ReplicatedStorage')) :: ReplicatedStorage
local proximity_prompt_service = cloneref(game:GetService('ProximityPromptService')) :: ProximityPromptService

local modules = replicated_storage:WaitForChild('Modules')

local shop_lib = require(modules:WaitForChild('ShopLib')) or {}

local local_player = players.LocalPlayer

local character = local_player.Character or local_player.CharacterAdded:Wait();

local storages = workspace:WaitForChild('Storages')
local mobs = workspace:WaitForChild('Mobs')

local client_table, ult_table

local connections_table = {}
local objects_table = {
    player_esp = {};
    item_esp = {};
    npc_esp = {};
    mob_esp = {};
    storage_esp = {};
}

local npc_shops = {}

local executor = (identifyexecutor and identifyexecutor()) or "shit executor"
local fireprompt = fireproximityprompt or function(Obj)
	if Obj.ClassName == "ProximityPrompt" then 
		Obj:InputHoldBegin()
		Obj:InputHoldEnd()
	else 
		error("userdata<ProximityPrompt> expected")
	end
end


local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local esp_library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Solibex/storageWare/main/esp.lua'))()
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

function notify(title, text, duration)
	if client_table then
        client_table:Noti({
            Title = title or "none",
            Text = text or "none", 
            Duration = duration or 1
        })
    else
        print(title, text, duration)
        Library:Notify(`[{title}]: {text}`)
    end
end

if getgc and type(getgc) == 'function' and #getgc(false) > 0 then
    for _,v in getgc(true) do
        if type(v) == 'table' and rawget(v, 'Player') then
            client_table = v
        end
        if type(v) == 'table' and rawget(v, 'timeFormat') then
            ult_table = v
        end
    end    
end
if client_table  then
    notify(CHECK_MARK, 'Successfully hooked client', 1)
else
    notify(WARNING_MARK, 'Failed to hook client.', 1)
end
if ult_table then
    notify(CHECK_MARK, 'Successfully hooked utilities', 1)
else
    notify(WARNING_MARK, 'Failed to hook utilities.', 1)
end
if (not client_table) and (not ult_table) then
    notify(DENIED_MARK, 'Failed to hook anything.', 1)
end

if not client_table then
    texts.no_slide_cd.Text = `[ {WARNING_MARK} ] {texts.no_slide_cd.Text}`
    texts.no_slide_cd.Tooltip = `[ {WARNING_MARK} ] This feature wont work due to client not being able to hook.`
end

for name, value in pairs(shop_lib) do
	if rawget(value, 'ToolTypes') then -- sellers
		continue
	end

	table.insert(npc_shops, name)
end


local window = Library:CreateWindow({
	Title = 'storage ware',
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 0.2
})

Library:SetWatermark('storage ware rewrite')

local tabs = {
	main = window:AddTab('main');
    esp = window:AddTab('esp');
	ui_settings = window:AddTab('UI Settings');
}


local stuff_box = tabs.main:AddLeftGroupbox('stuff')

local player_tab = tabs.esp:AddLeftGroupbox('player esp')
local item_tab = tabs.esp:AddRightGroupbox('item')
local npc_tab = tabs.esp:AddLeftGroupbox('npc')
local mob_tab = tabs.esp:AddRightGroupbox('mob')
local storage_tab = tabs.esp:AddLeftGroupbox('storage')

stuff_box:AddToggle('instant_prompt', {
	Text = texts.instant_prompt.Text,
	Default = false, 
	Tooltip = texts.instant_prompt.Tooltip, 

	Callback = function() end
})

stuff_box:AddToggle('no_slide_cd', {
	Text = texts.no_slide_cd.Text,
	Default = false, 
	Tooltip = texts.no_slide_cd.Tooltip, 

	Callback = function() end
})

player_tab:AddToggle('player_esp', {
    Text = texts.player_esp.Text,
    Default = false,
    Tooltip = texts.player_esp.Tooltip,
    Callback = function() end
})

item_tab:AddToggle('item_esp', {
    Text = texts.item_esp.Text,
    Default = false,
    Tooltip = texts.item_esp.Tooltip,
    Callback = function() end
})

npc_tab:AddToggle('npc_esp', {
    Text = texts.npc_esp.Text,
    Default = false,
    Tooltip = texts.npc_esp.Tooltip,
    Callback = function() end
})

mob_tab:AddToggle('mob_esp', {
    Text = texts.mob_esp.Text,
    Default = false,
    Tooltip = texts.mob_esp.Tooltip,
    Callback = function() end
})

storage_tab:AddToggle('storage_esp', {
    Text = texts.mob_esp.Text,
    Default = false,
    Tooltip = texts.mob_esp.Tooltip,
    Callback = function() end
})


local ui_box = tabs.ui_settings:AddLeftGroupbox('ui')

ui_box:AddToggle('watermark_visible', {
	Text = 'watermark visibilty',
	Default = false, 
	Tooltip = 'self-explainatory', 

	Callback = function(value)
        Library:SetWatermarkVisibility(value)
    end
})

ui_box:AddLabel('menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

ui_box:AddButton({
    Text = 'unload',
    Func = Library.Unload,
    DoubleClick = false,
    Tooltip = 'unload the whole script'
})

function instant_prompt(prompt)
    if Toggles.instant_prompt.Value then
        prompt.HoldDuration = 0
    end
end

function render_stepped()
    if Toggles.no_slide_cd.Value and client_table then
        -- metatable is an option but some exploits doesnt support it
        -- and this works just fine 🤷
        rawset(client_table, 'SlideCD', -1)
    end

    for _, object in objects_table.mob_esp do
        object.enabled = Toggles.mob_esp.Value
    end
    for _, object in objects_table.player_esp do
        object.enabled = Toggles.player_esp.Value
    end
end

function mob_added(child)
    local mob_object = esp_library:AddInstance(child, {
        enabled = Toggles.mob_esp.Value,
        Text = child.Name,
    })

    table.insert(objects_table.mob_esp, mob_object)
end

function item_added(child)
    local item_object = esp_library:AddInstance(child, {
        enabled = Toggles.item_esp.Value,
        Text = child.Name,
    })

    table.insert(objects_table.item_esp, item_object)
end

function storage_added(child)
    local mobs_folder = child:FindFirstChild('Mobs')
    local loot_folder = child:FindFirstChild('Loot')
    local items_folder = child:FindFirstChild('Items')

    if mobs_folder then
        print('storage mobs')
        table.insert(connections_table, mobs_folder.ChildAdded:Connect(mob_added))
    end
    if loot_folder then
        print('storage loot')
        table.insert(connections_table, loot_folder.ChildAdded:Connect(item_added))
    end
    if items_folder then
        print('storage item')
        table.insert(connections_table, items_folder.ChildAdded:Connect(item_added))
    end
end

function player_added(player)
    local character = player.Character or player.CharacterAdded:Wait()

    local player_object = esp_library:AddInstance(character, {
        enabled = Toggles.player_esp.Value,
        Text = player.Name,
    })

    table.insert(objects_table.player_esp, player_object)
end

table.insert(connections_table, proximity_prompt_service.PromptButtonHoldBegan:Connect(instant_prompt))
table.insert(connections_table, run_service.RenderStepped:Connect(render_stepped))
table.insert(connections_table, mobs.ChildAdded:Connect(mob_added))
table.insert(connections_table, storages.ChildAdded:Connect(storage_added))
table.insert(connections_table, players.PlayerAdded:Connect(player_added))

for _, player in players:GetPlayers() do
    player_added(player)
end

for _, storage in storages:GetChildren() do
    storage_added(storage)
end

for _, mob in mobs:GetChildren() do
    mob_added(mob)
end

Library:OnUnload(function()
    for _, connection in connections_table do
        connection:Disconnect()
    end
    esp_library:Unload()
    print('Unloaded!')
    Library.Unloaded = true
end)
