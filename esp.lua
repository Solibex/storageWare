local run_service = cloneref(game:GetService('RunService')) :: RunService

local esp_module = {functions = {}}
local esp_object = {}
esp_object.__index = esp_object

local camera = workspace.CurrentCamera

function esp_object:Remove()
    if self.Text then
        self.Text:Remove()
    end
    for _, connection in self.Connections do
        connection:Disconnect()
    end
end

local function add_object()
    local object = setmetatable({Text = Drawing.new('Text'), Connections = {}}, esp_object)

    return object
end


function esp_module:AddInstance(object, data)
    local text_object = add_object()

    text_object.Text.Color = Color3.new(1, 1, 1)
    text_object.Text.Size = 12
    text_object.Text.Outline = true
    text_object.Text.Font = 2

    for index, value in data or {} do
        text_object.Text[index] = value
    end

    local function update()
        if not text_object.Text then -- incase someone calls text:Remove() :horrot:
            return text_object:Remove()
        end

        local vec3, onscreen = camera:WorldToViewportPoint(object:GetPivot().Position)
        if onscreen then
            text_object.Text.Visible = text_object.enabled
            text_object.Text.Position = Vector2.new(vec3.X, vec3.Y)
        else
            text_object.Text.Visible = false
        end
    end

    table.insert(text_object.Connections, run_service.RenderStepped:Connect(update))
    table.insert(text_object.Connections, object.Destroying:Connect(function()
        text_object:Remove()
    end)) 
    table.insert(esp_module.functions, text_object)

    return text_object
end

function esp_module:Unload()
    for _, func in esp_module.functions do
        if func then
            func:Remove()
        end
    end
end

return esp_module