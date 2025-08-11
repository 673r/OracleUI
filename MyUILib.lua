--[[
    Oracle - Modern UI Library
    A high-quality UI library inspired by Java
    
    Features:
    - Modern and clean design
    - Multiple themes
    - Configuration saving/loading
    - Modular component system
    - Easy-to-use API
    
    FIXED: Theme nil reference issues and syntax errors
]]

local Oracle = {
    Version = "1.0.1",
    Build = "A1B3",
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

-- Load UIElements module
local UIElements = require(script.UIElements)

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

-- Window Creation
function Oracle.CreateWindow(options)
    options = options or {}
    local windowTitle = options.Title or "Oracle Window"
    local windowSize = options.Size or UDim2.new(0, 500, 0, 400)
    local theme = getValidTheme(options.Theme)
    
    local window = {
        Title = windowTitle,
        Size = windowSize,
        Theme = theme,
        Tabs = {},
        CurrentTab = nil,
        Visible = true
    }
    
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
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    -- Drop Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = theme.Shadow
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
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
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
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
    closeButton.Position = UDim2.new(1, -35, 0, 5)
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
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, -40)
    contentContainer.Position = UDim2.new(0, 150, 0, 40)
    contentContainer.BackgroundColor3 = theme.Background
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Store references
    window.ScreenGui = screenGui
    window.MainFrame = mainFrame
    window.TopBar = topBar
    window.TitleLabel = titleLabel
    window.CloseButton = closeButton
    window.TabContainer = tabContainer
    window.ContentContainer = contentContainer
    
    -- Close functionality
    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- Dragging functionality
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
    
    -- Window methods
    function window:CreateTab(tabName)
        local tab = {
            Name = tabName,
            Window = self,
            Sections = {},
            Visible = false
        }
        
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. tabName
        tabButton.Size = UDim2.new(1, 0, 0, 35)
        tabButton.BackgroundColor3 = theme.TabBackground
        tabButton.BorderSizePixel = 0
        tabButton.Text = tabName
        tabButton.TextColor3 = theme.TextColor
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = self.TabContainer
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "TabContent_" .. tabName
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.ScrollBarImageColor3 = theme.AccentColor
        tabContent.Visible = false
        tabContent.Parent = self.ContentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.Parent = tabContent
        
        -- Store references
        tab.Button = tabButton
        tab.Content = tabContent
        
        -- Tab switching
        tabButton.MouseButton1Click:Connect(function()
            self:SwitchTab(tab)
        end)
        
        -- Tab methods
        function tab:CreateSection(sectionName)
            local section = {
                Name = sectionName,
                Tab = self,
                Elements = {}
            }
            
            -- Section Frame
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "Section_" .. sectionName
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.BackgroundColor3 = theme.ElementBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.Parent = self.Content
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = sectionFrame
            
            -- Section Title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "SectionTitle"
            sectionTitle.Size = UDim2.new(1, 0, 0, 30)
            sectionTitle.Position = UDim2.new(0, 0, 0, 0)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = theme.TextColor
            sectionTitle.TextSize = 16
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.Parent = sectionFrame
            
            local titlePadding = Instance.new("UIPadding")
            titlePadding.PaddingLeft = UDim.new(0, 15)
            titlePadding.Parent = sectionTitle
            
            -- Section Container
            local sectionContainer = Instance.new("Frame")
            sectionContainer.Name = "SectionContainer"
            sectionContainer.Size = UDim2.new(1, 0, 0, 0)
            sectionContainer.Position = UDim2.new(0, 0, 0, 30)
            sectionContainer.BackgroundTransparency = 1
            sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
            sectionContainer.Parent = sectionFrame
            
            local containerLayout = Instance.new("UIListLayout")
            containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            containerLayout.Padding = UDim.new(0, 5)
            containerLayout.Parent = sectionContainer
            
            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingTop = UDim.new(0, 5)
            containerPadding.PaddingBottom = UDim.new(0, 10)
            containerPadding.PaddingLeft = UDim.new(0, 15)
            containerPadding.PaddingRight = UDim.new(0, 15)
            containerPadding.Parent = sectionContainer
            
            -- Store references
            section.Frame = sectionFrame
            section.Container = sectionContainer
            
            -- Section methods
            function section:CreateButton(options)
                local button = UIElements.CreateButton(self, options)
                table.insert(self.Elements, button)
                return button
            end
            
            function section:CreateToggle(options)
                local toggle = UIElements.CreateToggle(self, options)
                table.insert(self.Elements, toggle)
                return toggle
            end
            
            function section:CreateSlider(options)
                local slider = UIElements.CreateSlider(self, options)
                table.insert(self.Elements, slider)
                return slider
            end
            
            function section:CreateInput(options)
                local input = UIElements.CreateInput(self, options)
                table.insert(self.Elements, input)
                return input
            end
            
            function section:CreateLabel(options)
                local label = UIElements.CreateLabel(self, options)
                table.insert(self.Elements, label)
                return label
            end
            
            function section:CreateDropdown(options)
                local dropdown = UIElements.CreateDropdown(self, options)
                table.insert(self.Elements, dropdown)
                return dropdown
            end
            
            table.insert(self.Sections, section)
            return section
        end
        
        table.insert(self.Tabs, tab)
        
        -- Auto-select first tab
        if #self.Tabs == 1 then
            self:SwitchTab(tab)
        end
        
        return tab
    end
    
    function window:SwitchTab(targetTab)
        -- Hide all tabs
        for _, tab in pairs(self.Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = self.Theme.TabBackground
            tab.Visible = false
        end
        
        -- Show target tab
        targetTab.Content.Visible = true
        targetTab.Button.BackgroundColor3 = self.Theme.TabSelected
        targetTab.Visible = true
        self.CurrentTab = targetTab
    end
    
    function window:SetVisible(visible)
        self.Visible = visible
        self.ScreenGui.Enabled = visible
    end
    
    function window:Destroy()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
        
        -- Remove from windows table
        for i, win in pairs(Oracle.Windows) do
            if win == self then
                table.remove(Oracle.Windows, i)
                break
            end
        end
    end
    
    table.insert(Oracle.Windows, window)
    return window
end

-- Expose UIElements for external use
Oracle.UIElements = UIElements

return Oracle

