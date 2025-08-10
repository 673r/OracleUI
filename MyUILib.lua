--[[
    Oracle - Modern UI Library
    A high-quality UI library inspired by Java
    
    Features:
    - Modern and clean design
    - Multiple themes
    - Configuration saving/loading
    - Modular component system
    - Easy-to-use API
    
    FIXED: Theme nil reference issues
]]

local Oracle = {
    Version = "1.0.0",
    Build = "A1B2",
    Flags = {},
    Windows = {},
    CurrentTheme = nil,
    ConfigFolder = "Oracle",
    ConfigExtension = ".json"
}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Utility Functions
local function CreateTween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

local function GetNextZIndex()
    local highest = 0
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            if gui.DisplayOrder > highest then
                highest = gui.DisplayOrder
            end
        end
    end
    return highest + 1
end

-- Theme System
Oracle.Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(35, 35, 35),
        TabBackground = Color3.fromRGB(30, 30, 30),
        TabSelected = Color3.fromRGB(45, 45, 45),
        ElementBackground = Color3.fromRGB(40, 40, 40),
        ElementHover = Color3.fromRGB(50, 50, 50),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(0, 162, 255),
        BorderColor = Color3.fromRGB(60, 60, 60),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(245, 245, 245),
        Topbar = Color3.fromRGB(235, 235, 235),
        TabBackground = Color3.fromRGB(240, 240, 240),
        TabSelected = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(250, 250, 250),
        ElementHover = Color3.fromRGB(240, 240, 240),
        TextColor = Color3.fromRGB(50, 50, 50),
        AccentColor = Color3.fromRGB(0, 122, 255),
        BorderColor = Color3.fromRGB(200, 200, 200),
        Shadow = Color3.fromRGB(180, 180, 180)
    },
    
    Ocean = {
        Name = "Ocean",
        Background = Color3.fromRGB(20, 30, 40),
        Topbar = Color3.fromRGB(25, 40, 55),
        TabBackground = Color3.fromRGB(30, 45, 60),
        TabSelected = Color3.fromRGB(40, 60, 80),
        ElementBackground = Color3.fromRGB(35, 50, 65),
        ElementHover = Color3.fromRGB(45, 65, 85),
        TextColor = Color3.fromRGB(220, 240, 255),
        AccentColor = Color3.fromRGB(0, 180, 220),
        BorderColor = Color3.fromRGB(60, 90, 120),
        Shadow = Color3.fromRGB(10, 20, 30)
    },
    
    Purple = {
        Name = "Purple",
        Background = Color3.fromRGB(30, 20, 40),
        Topbar = Color3.fromRGB(40, 25, 50),
        TabBackground = Color3.fromRGB(35, 25, 45),
        TabSelected = Color3.fromRGB(50, 35, 65),
        ElementBackground = Color3.fromRGB(45, 30, 60),
        ElementHover = Color3.fromRGB(55, 40, 75),
        TextColor = Color3.fromRGB(240, 230, 255),
        AccentColor = Color3.fromRGB(150, 80, 200),
        BorderColor = Color3.fromRGB(80, 50, 110),
        Shadow = Color3.fromRGB(20, 10, 30)
    }
}

-- Set default theme IMMEDIATELY after themes are defined
Oracle.CurrentTheme = Oracle.Themes.Dark

-- Helper function to get a valid theme
local function getValidTheme(theme)
    -- If theme is nil, return current theme
    if not theme then
        return Oracle.CurrentTheme or Oracle.Themes.Dark
    end
    
    -- If theme is a string, get the theme from Themes table
    if type(theme) == "string" then
        return Oracle.Themes[theme] or Oracle.CurrentTheme or Oracle.Themes.Dark
    end
    
    -- If theme is already a table, return it
    if type(theme) == "table" then
        return theme
    end
    
    -- Fallback to Dark theme
    return Oracle.Themes.Dark
end

-- Configuration Management
function Oracle.SaveConfiguration(filename)
    -- Check if ConfigManager module exists (optional feature)
    local success, ConfigManager = pcall(function()
        return require(script.ConfigManager)
    end)
    
    if not success then
        warn("Oracle: ConfigManager not found. Configuration saving disabled.")
        return false, "ConfigManager not available"
    end
    
    local configData = {
        Flags = {},
        Theme = Oracle.CurrentTheme.Name,
        Timestamp = os.time()
    }
    
    -- Extract all flag values
    for flagName, flagData in pairs(Oracle.Flags) do
        configData.Flags[flagName] = {
            Value = flagData.Value,
            Type = type(flagData.Value)
        }
    end
    
    return ConfigManager.SaveConfiguration(filename, configData)
end

function Oracle.LoadConfiguration(filename)
    -- Check if ConfigManager module exists (optional feature)
    local success, ConfigManager = pcall(function()
        return require(script.ConfigManager)
    end)
    
    if not success then
        warn("Oracle: ConfigManager not found. Configuration loading disabled.")
        return false, "ConfigManager not available"
    end
    
    local configData, message = ConfigManager.LoadConfiguration(filename)
    
    if not configData then
        return false, message
    end
    
    -- Apply theme
    if configData.Theme and Oracle.Themes[configData.Theme] then
        Oracle.SetTheme(configData.Theme)
    end
    
    -- Apply flag values
    if configData.Flags then
        for flagName, flagData in pairs(configData.Flags) do
            if Oracle.Flags[flagName] and Oracle.Flags[flagName].Set then
                Oracle.Flags[flagName].Set(flagData.Value)
            end
        end
    end
    
    return true, "Configuration loaded successfully"
end

function Oracle.SetTheme(themeName)
    print("SetTheme called with:", themeName, "Type:", type(themeName))
    
    local newTheme = nil
    
    if type(themeName) == "string" then
        if Oracle.Themes[themeName] then
            newTheme = Oracle.Themes[themeName]
            print("Theme found:", themeName)
        else
            warn("Oracle: Theme '" .. tostring(themeName) .. "' not found")
            print("Available themes:")
            for name, _ in pairs(Oracle.Themes) do
                print(" - " .. name)
            end
            return false
        end
    elseif type(themeName) == "table" then
        newTheme = themeName
        print("Theme provided as table")
    else
        warn("Oracle: Invalid theme parameter type: " .. type(themeName))
        return false
    end
    
    -- Validate theme structure
    if not newTheme.Name or not newTheme.Background or not newTheme.TextColor then
        warn("Oracle: Invalid theme structure")
        return false
    end
    
    Oracle.CurrentTheme = newTheme
    print("New theme applied:", Oracle.CurrentTheme.Name)
    
    -- Apply theme to all existing windows
    for _, window in pairs(Oracle.Windows) do
        if window and window.MainFrame then
            window.Theme = Oracle.CurrentTheme
            
            -- Update window colors safely
            if window.MainFrame then
                window.MainFrame.BackgroundColor3 = Oracle.CurrentTheme.Background
            end
            
            if window.MainFrame.TopBar then
                window.MainFrame.TopBar.BackgroundColor3 = Oracle.CurrentTheme.Topbar
            end
            
            if window.MainFrame.TopBar and window.MainFrame.TopBar.TitleLabel then
                window.MainFrame.TopBar.TitleLabel.TextColor3 = Oracle.CurrentTheme.TextColor
            end
            
            if window.TabContainer then
                window.TabContainer.BackgroundColor3 = Oracle.CurrentTheme.TabBackground
                
                -- Update tab buttons
                for _, tab in pairs(window.Tabs) do
                    if tab.Button then
                        tab.Button.TextColor3 = Oracle.CurrentTheme.TextColor
                        if tab == window.CurrentTab then
                            tab.Button.BackgroundColor3 = Oracle.CurrentTheme.TabSelected
                        else
                            tab.Button.BackgroundColor3 = Oracle.CurrentTheme.TabBackground
                        end
                    end
                end
            end
        end
    end
    
    print("Theme successfully applied!")
    return true
end

-- UI Elements (inline to avoid module loading issues)
local UIElements = {}

-- Utility function for creating tweens
local function CreateElementTween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

-- Button Element
function UIElements.CreateButton(section, options)
    options = options or {}
    local buttonText = options.Text or "Button"
    local callback = options.Callback or function() end
    local theme = getValidTheme(options.Theme)
    
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button_" .. buttonText
    buttonFrame.Size = UDim2.new(1, 0, 0, 35)
    buttonFrame.BackgroundColor3 = options.Color or theme.AccentColor
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Text = buttonText
    buttonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonFrame.TextSize = 14
    buttonFrame.Font = Enum.Font.GothamBold
    buttonFrame.Parent = section.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = buttonFrame
    
    local originalColor = options.Color or theme.AccentColor
    
    -- Hover effects
    buttonFrame.MouseEnter:Connect(function()
        CreateElementTween(buttonFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.new(
                math.min(originalColor.R + 0.1, 1),
                math.min(originalColor.G + 0.1, 1),
                math.min(originalColor.B + 0.1, 1)
            )
        })
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        CreateElementTween(buttonFrame, TweenInfo.new(0.2), {BackgroundColor3 = originalColor})
    end)
    
    -- Click functionality
    buttonFrame.MouseButton1Click:Connect(function()
        CreateElementTween(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 33)})
        task.wait(0.1)
        CreateElementTween(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 35)})
        pcall(callback)
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
    local theme = getValidTheme(options.Theme)
    
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
        Oracle.Flags[flag] = {
            Value = currentValue,
            Set = function(value)
                currentValue = value
                local newSwitchColor = value and theme.AccentColor or Color3.fromRGB(100, 100, 100)
                local newCirclePos = value and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
                
                CreateElementTween(toggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = newSwitchColor})
                CreateElementTween(toggleCircle, TweenInfo.new(0.2), {Position = newCirclePos})
                
                pcall(callback, value)
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
        
        CreateElementTween(toggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = newSwitchColor})
        CreateElementTween(toggleCircle, TweenInfo.new(0.2), {Position = newCirclePos})
        
        if flag then
            Oracle.Flags[flag].Value = currentValue
        end
        
        pcall(callback, currentValue)
    end)
    
    -- Hover effects
    toggleButton.MouseEnter:Connect(function()
        CreateElementTween(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementHover})
    end)
    
    toggleButton.MouseLeave:Connect(function()
        CreateElementTween(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementBackground})
    end)
    
    -- Return object with SetValue method
    local toggleObject = {
        Frame = toggleFrame,
        SetValue = function(self, value)
            if Oracle.Flags[flag] then
                Oracle.Flags[flag].Set(value)
            end
        end
    }
    
    return toggleObject
end

-- Slider Element
function UIElements.CreateSlider(section, options)
    options = options or {}
    local sliderText = options.Text or "Slider"
    local minValue = options.Min or 0
    local maxValue = options.Max or 100
    local defaultValue = math.clamp(options.Default or minValue, minValue, maxValue)
    local callback = options.Callback or function() end
    local flag = options.Flag
    local theme = getValidTheme(options.Theme)
    
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
        Oracle.Flags[flag] = {
            Value = currentValue,
            Set = function(value)
                currentValue = math.clamp(value, minValue, maxValue)
                local percentage = (currentValue - minValue) / (maxValue - minValue)
                
                CreateElementTween(sliderFill, TweenInfo.new(0.2), {Size = UDim2.new(percentage, 0, 1, 0)})
                CreateElementTween(sliderHandle, TweenInfo.new(0.2), {Position = UDim2.new(percentage, -8, 0, -5)})
                
                valueLabel.Text = tostring(math.floor(currentValue))
                pcall(callback, currentValue)
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
        
        CreateElementTween(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percentage, 0, 1, 0)})
        CreateElementTween(sliderHandle, TweenInfo.new(0.1), {Position = UDim2.new(percentage, -8, 0, -5)})
        
        valueLabel.Text = tostring(currentValue)
        
        if flag then
            Oracle.Flags[flag].Value = currentValue
        end
        
        pcall(callback, currentValue)
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
    
    -- Return object with SetValue method
    local sliderObject = {
        Frame = sliderFrame,
        SetValue = function(self, value)
            if Oracle.Flags[flag] then
                Oracle.Flags[flag].Set(value)
            end
        end
    }
    
    return sliderObject
end

-- Input Element
function UIElements.CreateInput(section, options)
    options = options or {}
    local inputText = options.Text or "Input"
    local placeholder = options.Placeholder or "Enter text..."
    local defaultValue = options.Default or ""
    local callback = options.Callback or function() end
    local flag = options.Flag
    local theme = getValidTheme(options.Theme)
    
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
        Oracle.Flags[flag] = {
            Value = currentValue,
            Set = function(value)
                currentValue = value
                textBox.Text = value
                pcall(callback, value)
            end
        }
    end
    
    -- Input functionality
    textBox.FocusLost:Connect(function(enterPressed)
        currentValue = textBox.Text
        
        if flag then
            Oracle.Flags[flag].Value = currentValue
        end
        
        pcall(callback, currentValue)
    end)
    
    -- Focus effects
    textBox.Focused:Connect(function()
        CreateElementTween(textBox, TweenInfo.new(0.2), {BorderColor3 = theme.AccentColor})
    end)
    
    textBox.FocusLost:Connect(function()
        CreateElementTween(textBox, TweenInfo.new(0.2), {BorderColor3 = theme.BorderColor})
    end)
    
    -- Return object with SetValue method
    local inputObject = {
        Frame = inputFrame,
        SetValue = function(self, value)
            if Oracle.Flags[flag] then
                Oracle.Flags[flag].Set(value)
            end
        end
    }
    
    return inputObject
end

-- Label Element
function UIElements.CreateLabel(section, options)
    options = options or {}
    local labelText = options.Text or "Label"
    local theme = getValidTheme(options.Theme)
    
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
    label.TextColor3 = options.Color or theme.TextColor
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
    local theme = getValidTheme(options.Theme)
    
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
        Oracle.Flags[flag] = {
            Value = currentValue,
            Set = function(value)
                currentValue = value
                dropdownButton.Text = value .. " ▼"
                pcall(callback, value)
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
            CreateElementTween(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementHover})
        end)
        
        optionButton.MouseLeave:Connect(function()
            CreateElementTween(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            currentValue = option
            dropdownButton.Text = option .. " ▼"
            dropdownList.Visible = false
            isOpen = false
            
            if flag then
                Oracle.Flags[flag].Value = currentValue
            end
            
            pcall(callback, currentValue)
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

-- Add UI Element Functions to Section
local function addElementFunctions(section, theme)
    theme = getValidTheme(theme)
    
    function section.AddButton(options)
        options = options or {}
        options.Theme = theme
        return UIElements.CreateButton(section, options)
    end
    
    function section.AddToggle(options)
        options = options or {}
        options.Theme = theme
        return UIElements.CreateToggle(section, options)
    end
    
    function section.AddSlider(options)
        options = options or {}
        options.Theme = theme
        return UIElements.CreateSlider(section, options)
    end
    
    function section.AddInput(options)
        options = options or {}
        options.Theme = theme
        return UIElements.CreateInput(section, options)
    end
    
    function section.AddLabel(options)
        options = options or {}
        options.Theme = theme
        return UIElements.CreateLabel(section, options)
    end
    
    function section.AddDropdown(options)
        options = options or {}
        options.Theme = theme
        return UIElements.CreateDropdown(section, options)
    end
end

-- Window Creation
function Oracle.CreateWindow(options)
    options = options or {}
    local windowTitle = options.Title or "Oracle Window"
    local windowSize = options.Size or UDim2.new(0, 500, 0, 400)
    local theme = getValidTheme(options.Theme)
    
    print("Creating window with theme:", theme.Name)
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Oracle_" .. windowTitle
    screenGui.DisplayOrder = GetNextZIndex()
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = windowSize
    mainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)
    mainFrame.BackgroundColor3 = theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner Radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Drop Shadow
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = theme.Shadow
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 8)
    shadowCorner.Parent = shadow
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = theme.Topbar
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 8)
    topBarCorner.Parent = topBar
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = theme.TextColor
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = topBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 95, 95)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 150, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = theme.TabBackground
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, -40)
    contentContainer.Position = UDim2.new(0, 150, 0, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Tab List Layout
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 2)
    tabListLayout.Parent = tabContainer
    
    -- Window Object
    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        Tabs = {},
        CurrentTab = nil,
        Theme = theme
    }
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        CreateTween(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        task.wait(0.3)
        screenGui:Destroy()
    end)
    
    -- Add Tab Function
    function window.AddTab(name, icon)
        local tab = {
            Name = name,
            Icon = icon,
            Sections = {},
            Content = nil,
            Button = nil
        }
        
        -- Create Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.Size = UDim2.new(1, -10, 0, 35)
        tabButton.Position = UDim2.new(0, 5, 0, 0)
        tabButton.BackgroundColor3 = theme.TabBackground
        tabButton.BorderSizePixel = 0
        tabButton.Text = (icon and icon .. " " or "") .. name
        tabButton.TextColor3 = theme.TextColor
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        -- Create Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.ScrollBarImageColor3 = theme.AccentColor
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        -- Auto-resize canvas
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        tab.Content = tabContent
        tab.Button = tabButton
        
        -- Tab Selection
        tabButton.MouseButton1Click:Connect(function()
            window.SelectTab(tab)
        end)
        
        -- Add Section Function
        function tab.AddSection(name)
            local section = {
                Name = name,
                Container = nil
            }
            
            -- Create Section Frame
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = name .. "Section"
            sectionFrame.Size = UDim2.new(1, 0, 0, 50)
            sectionFrame.BackgroundColor3 = theme.ElementBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = sectionFrame
            
            -- Section Title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "SectionTitle"
            sectionTitle.Size = UDim2.new(1, -20, 0, 25)
            sectionTitle.Position = UDim2.new(0, 10, 0, 5)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = name
            sectionTitle.TextColor3 = theme.TextColor
            sectionTitle.TextSize = 16
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.Parent = sectionFrame
            
            -- Section Content
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "SectionContent"
            sectionContent.Size = UDim2.new(1, -20, 1, -40)
            sectionContent.Position = UDim2.new(0, 10, 0, 35)
            sectionContent.BackgroundTransparency = 1
            sectionContent.Parent = sectionFrame
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 8)
            sectionLayout.Parent = sectionContent
            
            section.Container = sectionContent
            
            -- Auto-resize section
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 50)
            end)
            
            table.insert(tab.Sections, section)
            
            -- Add element creation functions to section
            addElementFunctions(section, window.Theme)
            
            return section
        end
        
        table.insert(window.Tabs, tab)
        return tab
    end
    
    -- Select Tab Function
    function window.SelectTab(tab)
        -- Hide all tabs
        for _, t in pairs(window.Tabs) do
            if t.Content then
                t.Content.Visible = false
            end
            if t.Button then
                CreateTween(t.Button, TweenInfo.new(0.2), {BackgroundColor3 = window.Theme.TabBackground})
            end
        end
        
        -- Show selected tab
        if tab and tab.Content and tab.Button then
            tab.Content.Visible = true
            CreateTween(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = window.Theme.TabSelected})
            window.CurrentTab = tab
        end
    end
    
    table.insert(Oracle.Windows, window)
    return window
end

-- Helper function to get keys from table (for debugging)
local function table_keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

print("Oracle UI Library loaded successfully!")
print("Version:", Oracle.Version, "Build:", Oracle.Build)
print("Available themes:", table.concat(table_keys(Oracle.Themes), ", "))
print("Current theme:", Oracle.CurrentTheme.Name)

return Oracle
