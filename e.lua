Drawing.clear()

getgenv().npc = 'King Brian'
getgenv().item = "King's Crown"

getgenv().stop = false
getgenv().currentCollector = false
getgenv().searchingCollector = false

local replicated_storage = game:GetService('ReplicatedStorage')
local context_action_service = game:GetService('ContextActionService')
local players = game:GetService('Players')

local local_player = players.LocalPlayer
local character = local_player.Character

local storages = workspace:WaitForChild('Storages')

local remote = replicated_storage:WaitForChild('RemoteEvent')

local camera = workspace.CurrentCamera
local vy, vx = camera.ViewportSize.Y, camera.ViewportSize.X

local text = Drawing.new("Text")
text.Visible = true
text.Position = Vector2.new(vx / 2 - 30, vy / 2 + 200)
text.Color = Color3.fromRGB(255, 255, 255)
text.Text = 'press keypad one to start finding'
text.Size = 24

local function handleAction(actionName, inputState, _inputObject)
	if actionName == 'stop_buying' and inputState == Enum.UserInputState.Begin then
		getgenv().stop = true
	end
	if actionName == 'sell_all' and inputState == Enum.UserInputState.Begin then
		if currentCollector ~= false and currentCollector.Parent:FindFirstChild(currentCollector.Name) then
			remote:FireServer("SellAllItems", currentCollector)
			text.Text = 'selling!'
		else
			currentCollector = false
			text.Text = 'no collector! press find collector!'
		end
	end
	if actionName == 'buy_stuff' and inputState == Enum.UserInputState.Begin then
		for _, v in pairs(workspace:GetDescendants()) do
			if getgenv().stop then
				text.Text = 'force stopped' 
				getgenv().stop = false
				break 
			end
			remote:FireServer("BuyItem", {
				getgenv().item, getgenv().npc, v
			})
			task.wait()
		end

	end
	if actionName == 'find_collector' and inputState == Enum.UserInputState.Begin then
		if getgenv().searchingCollector == true then
			return
		end
		currentCollector = false
		getgenv().searchingCollector = true
		while currentCollector == false and task.wait() do
			for _, v in pairs(storages:GetDescendants()) do
				if v.Name == 'The Collector' then
					character:PivotTo(v:GetPivot() * CFrame.new(0, 2, 0))
					text.Text = 'found him!'
					currentCollector = v
					getgenv().searchingCollector = false
				end
			end
			text.Text = 'searching for collector'
		end
	end
end
context_action_service:BindAction('find_collector', handleAction, true, Enum.KeyCode.KeypadOne)
context_action_service:BindAction('buy_stuff', handleAction, true, Enum.KeyCode.KeypadTwo)
context_action_service:BindAction('stop_buying', handleAction, true, Enum.KeyCode.KeypadThree)
context_action_service:BindAction('sell_all', handleAction, true, Enum.KeyCode.KeypadFour)