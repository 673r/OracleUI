--[[
    UIElements.lua - UI Element Components
    Contains all the interactive UI elements for Oracle
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UIElements = {}

-- Utility function for creating tweens
local function CreateTween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

-- Button Element
function UIElements.CreateButton(section, options)
    options = options or {}
    local buttonText = options.Text or "Button"
    local callback = options.Callback or function() end
    local theme = options.Theme
    
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button_" .. buttonText
    buttonFrame.Size = UDim2.new(1, 0, 0, 35)
    buttonFrame.BackgroundColor3 = theme.AccentColor
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Text = buttonText
    buttonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonFrame.TextSize = 14
    buttonFrame.Font = Enum.Font.GothamBold
    buttonFrame.Parent = section.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = buttonFrame
    
    -- Hover effects
    buttonFrame.MouseEnter:Connect(function()
        CreateTween(buttonFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.new(
                math.min(theme.AccentColor.R + 0.1, 1),
                math.min(theme.AccentColor.G + 0.1, 1),
                math.min(theme.AccentColor.B + 0.1, 1)
            )
        })
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        CreateTween(buttonFrame, TweenInfo.new(0.2), {BackgroundColor3 = theme.AccentColor})
    end)
    
    -- Click functionality
    buttonFrame.MouseButton1Click:Connect(function()
        CreateTween(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 33)})
        wait(0.1)
        CreateTween(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 35)})
        callback()
    end)
    
    return buttonFrame
end

-- Toggle Element
function UIElements.CreateToggle(section, options)
    options = options or {}
    local toggleText = options.Text or "Toggle"
    local defaultValue = options.Default or false
    local callback = options.Callback or function() end
    local flag = options.Flag
    local theme = options.Theme
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle_" .. toggleText
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundColor3 = theme.ElementBackground
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = section.Container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleFrame
    
    -- Toggle Label
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "ToggleLabel"
    toggleLabel.Size = UDim2.new(1, -50, 1, 0)
    toggleLabel.Position = UDim2.new(0, 10, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = toggleText
    toggleLabel.TextColor3 = theme.TextColor
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Parent = toggleFrame
    
    -- Toggle Switch
    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Name = "ToggleSwitch"
    toggleSwitch.Size = UDim2.new(0, 40, 0, 20)
    toggleSwitch.Position = UDim2.new(1, -50, 0.5, -10)
    toggleSwitch.BackgroundColor3 = defaultValue and theme.AccentColor or Color3.fromRGB(100, 100, 100)
    toggleSwitch.BorderSizePixel = 0
    toggleSwitch.Parent = toggleFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 10)
    switchCorner.Parent = toggleSwitch
    
    -- Toggle Circle
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "ToggleCircle"
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = defaultValue and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleSwitch
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0, 8)
    circleCorner.Parent = toggleCircle
    
    local currentValue = defaultValue
    
    -- Store flag reference
    if flag then
        require(script.Parent).Flags[flag] = {
            Value = currentValue,
            Set = function(value)
                currentValue = value
                local newSwitchColor = value and theme.AccentColor or Color3.fromRGB(100, 100, 100)
                local newCirclePos = value and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
                
                CreateTween(toggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = newSwitchColor})
                CreateTween(toggleCircle, TweenInfo.new(0.2), {Position = newCirclePos})
                
                callback(value)
            end
        }
    end
    
    -- Click functionality
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    toggleButton.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        
        local newSwitchColor = currentValue and theme.AccentColor or Color3.fromRGB(100, 100, 100)
        local newCirclePos = currentValue and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
        
        CreateTween(toggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = newSwitchColor})
        CreateTween(toggleCircle, TweenInfo.new(0.2), {Position = newCirclePos})
        
        if flag then
            require(script.Parent).Flags[flag].Value = currentValue
        end
        
        callback(currentValue)
    end)
    
    -- Hover effects
    toggleButton.MouseEnter:Connect(function()
        CreateTween(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementHover})
    end)
    
    toggleButton.MouseLeave:Connect(function()
        CreateTween(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementBackground})
    end)
    
    return toggleFrame
end

-- Slider Element
function UIElements.CreateSlider(section, options)
    options = options or {}
    local sliderText = options.Text or "Slider"
    local minValue = options.Min or 0
    local maxValue = options.Max or 100
    local defaultValue = options.Default or minValue
    local callback = options.Callback or function() end
    local flag = options.Flag
    local theme = options.Theme
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider_" .. sliderText
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundColor3 = theme.ElementBackground
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = section.Container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = sliderFrame
    
    -- Slider Label
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "SliderLabel"
    sliderLabel.Size = UDim2.new(1, -60, 0, 20)
    sliderLabel.Position = UDim2.new(0, 10, 0, 5)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = sliderText
    sliderLabel.TextColor3 = theme.TextColor
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.Parent = sliderFrame
    
    -- Value Label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = theme.AccentColor
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = sliderFrame
    
    -- Slider Track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "SliderTrack"
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 10, 0, 30)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack
    
    -- Slider Fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = theme.AccentColor
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    -- Slider Handle
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "SliderHandle"
    sliderHandle.Size = UDim2.new(0, 16, 0, 16)
    sliderHandle.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -8, 0, -5)
    sliderHandle.BackgroundColor3 = theme.AccentColor
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Parent = sliderTrack
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 8)
    handleCorner.Parent = sliderHandle
    
    local currentValue = defaultValue
    local dragging = false
    
    -- Store flag reference
    if flag then
        require(script.Parent).Flags[flag] = {
            Value = currentValue,
            Set = function(value)
                currentValue = math.clamp(value, minValue, maxValue)
                local percentage = (currentValue - minValue) / (maxValue - minValue)
                
                CreateTween(sliderFill, TweenInfo.new(0.2), {Size = UDim2.new(percentage, 0, 1, 0)})
                CreateTween(sliderHandle, TweenInfo.new(0.2), {Position = UDim2.new(percentage, -8, 0, -5)})
                
                valueLabel.Text = tostring(math.floor(currentValue))
                callback(currentValue)
            end
        }
    end
    
    -- Slider functionality
    local function updateSlider(input)
        local trackPosition = sliderTrack.AbsolutePosition.X
        local trackSize = sliderTrack.AbsoluteSize.X
        local mouseX = input.Position.X
        
        local percentage = math.clamp((mouseX - trackPosition) / trackSize, 0, 1)
        currentValue = minValue + (percentage * (maxValue - minValue))
        currentValue = math.floor(currentValue)
        
        CreateTween(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percentage, 0, 1, 0)})
        CreateTween(sliderHandle, TweenInfo.new(0.1), {Position = UDim2.new(percentage, -8, 0, -5)})
        
        valueLabel.Text = tostring(currentValue)
        
        if flag then
            require(script.Parent).Flags[flag].Value = currentValue
        end
        
        callback(currentValue)
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return sliderFrame
end

-- Input Element
function UIElements.CreateInput(section, options)
    options = options or {}
    local inputText = options.Text or "Input"
    local placeholder = options.Placeholder or "Enter text..."
    local defaultValue = options.Default or ""
    local callback = options.Callback or function() end
    local flag = options.Flag
    local theme = options.Theme
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "Input_" .. inputText
    inputFrame.Size = UDim2.new(1, 0, 0, 60)
    inputFrame.BackgroundColor3 = theme.ElementBackground
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = section.Container
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputFrame
    
    -- Input Label
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Name = "InputLabel"
    inputLabel.Size = UDim2.new(1, -20, 0, 20)
    inputLabel.Position = UDim2.new(0, 10, 0, 5)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = inputText
    inputLabel.TextColor3 = theme.TextColor
    inputLabel.TextSize = 14
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    inputLabel.Font = Enum.Font.Gotham
    inputLabel.Parent = inputFrame
    
    -- Text Box
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, -20, 0, 25)
    textBox.Position = UDim2.new(0, 10, 0, 30)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    textBox.BorderSizePixel = 1
    textBox.BorderColor3 = theme.BorderColor
    textBox.Text = defaultValue
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = theme.TextColor
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.ClearButtonOnFocus = false
    textBox.Parent = inputFrame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 4)
    textBoxCorner.Parent = textBox
    
    local currentValue = defaultValue
    
    -- Store flag reference
    if flag then
        require(script.Parent).Flags[flag] = {
            Value = currentValue,
            Set = function(value)
                currentValue = value
                textBox.Text = value
                callback(value)
            end
        }
    end
    
    -- Input functionality
    textBox.FocusLost:Connect(function(enterPressed)
        currentValue = textBox.Text
        
        if flag then
            require(script.Parent).Flags[flag].Value = currentValue
        end
        
        callback(currentValue)
    end)
    
    -- Focus effects
    textBox.Focused:Connect(function()
        CreateTween(textBox, TweenInfo.new(0.2), {BorderColor3 = theme.AccentColor})
    end)
    
    textBox.FocusLost:Connect(function()
        CreateTween(textBox, TweenInfo.new(0.2), {BorderColor3 = theme.BorderColor})
    end)
    
    return inputFrame
end

-- Label Element
function UIElements.CreateLabel(section, options)
    options = options or {}
    local labelText = options.Text or "Label"
    local theme = options.Theme
    
    local labelFrame = Instance.new("Frame")
    labelFrame.Name = "Label_" .. labelText
    labelFrame.Size = UDim2.new(1, 0, 0, 25)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Parent = section.Container
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = theme.TextColor
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = labelFrame
    
    return labelFrame
end

-- Dropdown Element
function UIElements.CreateDropdown(section, options)
    options = options or {}
    local dropdownText = options.Text or "Dropdown"
    local dropdownOptions = options.Options or {"Option 1", "Option 2", "Option 3"}
    local defaultValue = options.Default or dropdownOptions[1]
    local callback = options.Callback or function() end
    local flag = options.Flag
    local theme = options.Theme
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown_" .. dropdownText
    dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
    dropdownFrame.BackgroundColor3 = theme.ElementBackground
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = section.Container
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdownFrame
    
    -- Dropdown Label
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "DropdownLabel"
    dropdownLabel.Size = UDim2.new(1, -20, 0, 20)
    dropdownLabel.Position = UDim2.new(0, 10, 0, 5)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = dropdownText
    dropdownLabel.TextColor3 = theme.TextColor
    dropdownLabel.TextSize = 14
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.Parent = dropdownFrame
    
    -- Dropdown Button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(1, -20, 0, 25)
    dropdownButton.Position = UDim2.new(0, 10, 0, 30)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdownButton.BorderSizePixel = 1
    dropdownButton.BorderColor3 = theme.BorderColor
    dropdownButton.Text = defaultValue .. " ▼"
    dropdownButton.TextColor3 = theme.TextColor
    dropdownButton.TextSize = 14
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.Parent = dropdownFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = dropdownButton
    
    -- Dropdown List
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "DropdownList"
    dropdownList.Size = UDim2.new(1, -20, 0, #dropdownOptions * 25)
    dropdownList.Position = UDim2.new(0, 10, 0, 60)
    dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropdownList.BorderSizePixel = 1
    dropdownList.BorderColor3 = theme.BorderColor
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.Parent = dropdownFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList
    
    local currentValue = defaultValue
    local isOpen = false
    
    -- Store flag reference
    if flag then
        require(script.Parent).Flags[flag] = {
            Value = currentValue,
            Set = function(value)
                currentValue = value
                dropdownButton.Text = value .. " ▼"
                callback(value)
            end
        }
    end
    
    -- Create option buttons
    for _, option in pairs(dropdownOptions) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. option
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = theme.TextColor
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Parent = dropdownList
        
        optionButton.MouseEnter:Connect(function()
            CreateTween(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementHover})
        end)
        
        optionButton.MouseLeave:Connect(function()
            CreateTween(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            currentValue = option
            dropdownButton.Text = option .. " ▼"
            dropdownList.Visible = false
            isOpen = false
            
            if flag then
                require(script.Parent).Flags[flag].Value = currentValue
            end
            
            callback(currentValue)
        end)
    end
    
    -- Dropdown functionality
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
        
        if isOpen then
            dropdownFrame.Size = UDim2.new(1, 0, 0, 60 + (#dropdownOptions * 25))
        else
            dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
        end
    end)
    
    return dropdownFrame
end

return UIElements

