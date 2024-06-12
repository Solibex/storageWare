local texts = {
    -- stuff
    instant_prompt = {Text = 'instant prompt', Tooltip = 'instantly pick up items, etc..'};
    no_slide_cd = {Text = 'no slide cooldown', Tooltip = 'remove slide cooldown'};

    -- esp
    item_esp = {Text = 'item esp', Tooltip = ''};
    mob_esp = {Text = 'mob esp', Tooltip = ''};
}

local CHECK_MARK = '✅'
local WARNING_MARK = '⚠️'
local DENIED_MARK = '❌'

local run_service = game:GetService('RunService')
local players = game:GetService('Players')
local replicated_storage = game:GetService('ReplicatedStorage')
local proximity_prompt_service = game:GetService('ProximityPromptService')

local modules = replicated_storage:WaitForChild('Modules')

local shop_lib = require(modules:WaitForChild('ShopLib'))

local local_player = players.LocalPlayer

local storages = workspace:WaitForChild('Storages')
local mobs = workspace:WaitForChild('Mobs')

local client_table, ult_table
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

local window = Library:CreateWindow({
	Title = 'storage ware',
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 0.2
})

local tabs = {
	main = window:AddTab('Main');
	ui_settings = window:AddTab('UI Settings');
}


local stuff_box = tabs.main:AddLeftGroupbox('stuff')
local esp_box = tabs.main:AddRightGroupbox('esp')

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
proximity_prompt_service.PromptButtonHoldBegan:Connect(function(prompt)
    if Toggles.instant_prompt.Value then
        prompt.HoldDuration = 0
    end
end)
run_service.RenderStepped:Connect(function(delta)
    if Toggles.no_slide_cd.Value and client_table then
        rawset(client_table, 'SlideCD', -1)
    end
end)

Library:SetWatermark('storage ware rewrite')