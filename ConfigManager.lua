--[[
    ConfigManager.lua - Configuration Management
    Handles saving and loading of UI configurations
]]

local HttpService = game:GetService("HttpService")

local ConfigManager = {}

-- Configuration settings
ConfigManager.ConfigFolder = "Oracle"
ConfigManager.ConfigExtension = ".json"

-- Utility function to check if file system functions are available
local function hasFileSystem()
    return isfolder and makefolder and isfile and writefile and readfile and delfile
end

-- Create configuration folder if it doesn't exist
local function ensureConfigFolder()
    if not hasFileSystem() then
        warn("Oracle: File system functions not available. Configuration saving disabled.")
        return false
    end
    
    if not isfolder(ConfigManager.ConfigFolder) then
        makefolder(ConfigManager.ConfigFolder)
    end
    return true
end

-- Save configuration to file
function ConfigManager.SaveConfiguration(filename, data)
    if not ensureConfigFolder() then
        return false, "File system not available"
    end
    
    local success, result = pcall(function()
        local filePath = ConfigManager.ConfigFolder .. "/" .. filename .. ConfigManager.ConfigExtension
        local jsonData = HttpService:JSONEncode(data)
        writefile(filePath, jsonData)
        return true
    end)
    
    if success then
        return true, "Configuration saved successfully"
    else
        warn("Oracle: Failed to save configuration - " .. tostring(result))
        return false, result
    end
end

-- Load configuration from file
function ConfigManager.LoadConfiguration(filename)
    if not hasFileSystem() then
        warn("Oracle: File system functions not available. Configuration loading disabled.")
        return nil, "File system not available"
    end
    
    local filePath = ConfigManager.ConfigFolder .. "/" .. filename .. ConfigManager.ConfigExtension
    
    if not isfile(filePath) then
        return nil, "Configuration file not found"
    end
    
    local success, result = pcall(function()
        local fileContent = readfile(filePath)
        return HttpService:JSONDecode(fileContent)
    end)
    
    if success then
        return result, "Configuration loaded successfully"
    else
        warn("Oracle: Failed to load configuration - " .. tostring(result))
        return nil, result
    end
end

-- Delete configuration file
function ConfigManager.DeleteConfiguration(filename)
    if not hasFileSystem() then
        return false, "File system not available"
    end
    
    local filePath = ConfigManager.ConfigFolder .. "/" .. filename .. ConfigManager.ConfigExtension
    
    if not isfile(filePath) then
        return false, "Configuration file not found"
    end
    
    local success, result = pcall(function()
        delfile(filePath)
        return true
    end)
    
    if success then
        return true, "Configuration deleted successfully"
    else
        warn("Oracle: Failed to delete configuration - " .. tostring(result))
        return false, result
    end
end

-- List all configuration files
function ConfigManager.ListConfigurations()
    if not hasFileSystem() then
        return {}, "File system not available"
    end
    
    if not isfolder(ConfigManager.ConfigFolder) then
        return {}, "Configuration folder not found"
    end
    
    local success, result = pcall(function()
        local files = {}
        -- Note: listfiles function may not be available in all executors
        if listfiles then
            local allFiles = listfiles(ConfigManager.ConfigFolder)
            for _, file in pairs(allFiles) do
                local fileName = file:match("([^/\\]+)$") -- Get filename from path
                if fileName:match(ConfigManager.ConfigExtension .. "$") then
                    local configName = fileName:gsub(ConfigManager.ConfigExtension .. "$", "")
                    table.insert(files, configName)
                end
            end
        end
        return files
    end)
    
    if success then
        return result, "Configurations listed successfully"
    else
        warn("Oracle: Failed to list configurations - " .. tostring(result))
        return {}, result
    end
end

-- Auto-save configuration for a window
function ConfigManager.AutoSave(window, filename)
    if not window or not filename then
        return false, "Invalid parameters"
    end
    
    local configData = ConfigManager.ExtractWindowConfig(window)
    return ConfigManager.SaveConfiguration(filename, configData)
end

-- Auto-load configuration for a window
function ConfigManager.AutoLoad(window, filename)
    if not window or not filename then
        return false, "Invalid parameters"
    end
    
    local configData, message = ConfigManager.LoadConfiguration(filename)
    if configData then
        return ConfigManager.ApplyWindowConfig(window, configData)
    else
        return false, message
    end
end

-- Extract configuration data from a window
function ConfigManager.ExtractWindowConfig(window)
    local config = {
        WindowTitle = window.MainFrame.TopBar.TitleLabel.Text,
        Theme = window.Theme.Name,
        Flags = {},
        Timestamp = os.time()
    }
    
    -- Extract flag values from the main library
    local Oracle = require(script.Parent)
    for flagName, flagData in pairs(Oracle.Flags) do
        config.Flags[flagName] = {
            Value = flagData.Value,
            Type = type(flagData.Value)
        }
    end
    
    return config
end

-- Apply configuration data to a window
function ConfigManager.ApplyWindowConfig(window, config)
    if not config then
        return false, "No configuration data provided"
    end
    
    local success, result = pcall(function()
        -- Apply theme if specified
        if config.Theme then
            local Oracle = require(script.Parent)
            if Oracle.Themes[config.Theme] then
                Oracle.SetTheme(config.Theme)
            end
        end
        
        -- Apply flag values
        if config.Flags then
            local Oracle = require(script.Parent)
            for flagName, flagData in pairs(config.Flags) do
                if Oracle.Flags[flagName] and Oracle.Flags[flagName].Set then
                    Oracle.Flags[flagName].Set(flagData.Value)
                end
            end
        end
        
        return true
    end)
    
    if success then
        return true, "Configuration applied successfully"
    else
        warn("Oracle: Failed to apply configuration - " .. tostring(result))
        return false, result
    end
end

-- Create a backup of current configuration
function ConfigManager.CreateBackup(filename)
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupName = filename .. "_backup_" .. timestamp
    
    local configData, message = ConfigManager.LoadConfiguration(filename)
    if configData then
        return ConfigManager.SaveConfiguration(backupName, configData)
    else
        return false, message
    end
end

-- Restore configuration from backup
function ConfigManager.RestoreBackup(backupFilename, originalFilename)
    local configData, message = ConfigManager.LoadConfiguration(backupFilename)
    if configData then
        return ConfigManager.SaveConfiguration(originalFilename, configData)
    else
        return false, message
    end
end

-- Validate configuration data
function ConfigManager.ValidateConfig(config)
    if type(config) ~= "table" then
        return false, "Configuration must be a table"
    end
    
    -- Check required fields
    local requiredFields = {"Flags", "Timestamp"}
    for _, field in pairs(requiredFields) do
        if config[field] == nil then
            return false, "Missing required field: " .. field
        end
    end
    
    -- Validate flags structure
    if type(config.Flags) ~= "table" then
        return false, "Flags must be a table"
    end
    
    for flagName, flagData in pairs(config.Flags) do
        if type(flagData) ~= "table" then
            return false, "Flag data must be a table: " .. flagName
        end
        
        if flagData.Value == nil or flagData.Type == nil then
            return false, "Flag missing Value or Type: " .. flagName
        end
    end
    
    return true, "Configuration is valid"
end

-- Get configuration file info
function ConfigManager.GetConfigInfo(filename)
    local configData, message = ConfigManager.LoadConfiguration(filename)
    if not configData then
        return nil, message
    end
    
    local isValid, validationMessage = ConfigManager.ValidateConfig(configData)
    
    return {
        Filename = filename,
        WindowTitle = configData.WindowTitle or "Unknown",
        Theme = configData.Theme or "Unknown",
        FlagCount = configData.Flags and #configData.Flags or 0,
        Timestamp = configData.Timestamp or 0,
        LastModified = os.date("%Y-%m-%d %H:%M:%S", configData.Timestamp or 0),
        IsValid = isValid,
        ValidationMessage = validationMessage
    }, "Configuration info retrieved"
end

return ConfigManager

