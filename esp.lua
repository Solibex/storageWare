local run_service = cloneref(game:GetService('RunService')) :: RunService

local esp_module = {functions = {}}

local camera = workspace.CurrentCamera

function esp_module:AddInstance(object, data)
    local text = Drawing.new('Text')

    text.Color = Color3.new(1, 1, 1)
    text.Size = 12
    text.Outline = true
    text.Font = 2
    text.enabled = false

    for index, value in data or {} do
        text[index] = value
    end

    local connections = {}

    local function die()
        if text then
            text.Remove()
        end

        for _, connection in connections do
            connection:Disconnect()
        end
    end

    local function update()
        if not text then -- incase someone calls text:Remove() :horrot:
            die()
            return
        end

        local vec3, onscreen = camera:WorldToViewportPoint(object:GetPivot().Position)
        if onscreen then
            text.Visible = text.enabled
            text.Position = Vector2.new(vec3.X, vec3.Y)
        else
            text.Visible = false
        end
    end

    table.insert(connections, run_service.RenderStepped:Connect(update))
    table.insert(connections, object.Destroying:Connect(die)) 
    table.insert(esp_module.functions, die)

    return text
end

function esp_module:Unload()
    for _, func in esp_module.functions do
        func()
    end
end

return esp_module