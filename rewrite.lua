local texts = {
    -- stuff
    instant_prompt = {Text = 'instant prompt', Tooltip = 'instantly pick up items, etc..'};
    no_slide_cd = {Text = 'no slide cooldown', Tooltip = 'remove slide cooldown'};

    -- esp
    item_esp = {Text = 'item esp', Tooltip = 'esp for item'};
    mob_esp = {Text = 'mob esp', Tooltip = 'esp for mobs'};
}

local CHECK_MARK = '✅'
local WARNING_MARK = '⚠️'
local DENIED_MARK = '❌'

local run_service = cloneref(game:GetService('RunService')) :: RunService
local players = cloneref(game:GetService('Players')) :: Players
local replicated_storage = cloneref(game:GetService('ReplicatedStorage')) :: ReplicatedStorage
local proximity_prompt_service = cloneref(game:GetService('ProximityPromptService')) :: ProximityPromptService

local modules = replicated_storage:WaitForChild('Modules')

local shop_lib = require(modules:WaitForChild('ShopLib'))

local local_player = players.LocalPlayer

local storages = workspace:WaitForChild('Storages')
local mobs = workspace:WaitForChild('Mobs')

local client_table, ult_table
local connections_table = {}
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

local Sense = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Sirius/request/library/sense/source.lua'))()
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
	main = window:AddTab('Main');
	ui_settings = window:AddTab('UI Settings');
}


local stuff_box = tabs.main:AddLeftGroupbox('stuff')
local esp_box = tabs.main:AddRightGroupbox('esp')

local player_tab = esp_box:AddTab('player')
local item_tab = esp_box:AddTab('item')
local mob_tab = esp_box:AddTab('mob')
local storage_tab = esp_box:AddTab('storage')

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

esp_box:AddToggle('emen')

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

table.insert(connections_table, proximity_prompt_service.PromptButtonHoldBegan:Connect(function(prompt)
    if Toggles.instant_prompt.Value then
        prompt.HoldDuration = 0
    end
end))

table.insert(connections_table, run_service.RenderStepped:Connect(function(delta)
    if Toggles.no_slide_cd.Value and client_table then
        -- metatable is an option but some exploits doesnt support it
        rawset(client_table, 'SlideCD', -1)
    end
end))

Library:OnUnload(function()
    for _, connection in connections_table do
        connection:Disconnect()
    end
    print('Unloaded!')
    Library.Unloaded = true
end)

Sense.Load()