--[[
    Oracle - Modern UI Library
    A high-quality UI library inspired by Java
    
    Features:
    - Modern and clean design
    - Multiple themes
    - Configuration saving/loading
    - Modular component system
    - Easy-to-use API
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

-- Set default theme
Oracle.CurrentTheme = Oracle.Themes.Dark

-- Configuration Management
function Oracle.SaveConfiguration(filename)
    local ConfigManager = require(script.ConfigManager)
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
    local ConfigManager = require(script.ConfigManager)
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
    if type(themeName) == "string" then
        if Oracle.Themes[themeName] then
            Oracle.CurrentTheme = Oracle.Themes[themeName]
        else
            warn("Oracle: Theme '" .. themeName .. "' not found")
            return false
        end
    elseif type(themeName) == "table" then
        Oracle.CurrentTheme = themeName
    else
        warn("Oracle: Invalid theme parameter")
        return false
    end
    
    -- Apply theme to all existing windows
    for _, window in pairs(Oracle.Windows) do
        window.Theme = Oracle.CurrentTheme
        -- Update window colors
        window.MainFrame.BackgroundColor3 = Oracle.CurrentTheme.Background
        window.MainFrame.TopBar.BackgroundColor3 = Oracle.CurrentTheme.Topbar
        window.TabContainer.BackgroundColor3 = Oracle.CurrentTheme.TabBackground
        -- Update other elements as needed
    end
    
    return true
end

-- Add UI Element Functions to Section
local function addElementFunctions(section, theme)
    local UIElements = require(script.UIElements)
    
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
    local theme = options.Theme or Oracle.CurrentTheme
    
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
        wait(0.3)
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
        tabButton.Text = name
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
        
        return tab
    end
    
    -- Select Tab Function
    function window.SelectTab(tab)
        -- Hide all tabs
        for _, t in pairs(window.Tabs) do
            t.Content.Visible = false
            CreateTween(t.Button, TweenInfo.new(0.2), {BackgroundColor3 = window.Theme.TabBackground})
        end
        
        -- Show selected tab
        tab.Content.Visible = true
        CreateTween(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = window.Theme.TabSelected})
        window.CurrentTab = tab
    end
    
    table.insert(Oracle.Windows, window)
    return window
end

return Oracle 