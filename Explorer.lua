local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false -- Forces AddToggle to AddCheckbox
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)

local Window = Library:CreateWindow({
	-- Set Center to true if you want the menu to appear in the center
	-- Set AutoShow to true if you want the menu to appear when it is created
	-- Set Resizable to true if you want to have in-game resizable Window
	-- Set ShowCustomCursor to false if you don't want to use the Linoria cursor
	-- NotifySide = Changes the side of the notifications (Left, Right) (Default value = Left)
	-- Position and Size are also valid options here
	-- but you do not need to define them unless you are changing them :)

	Title = "Explorer Fish",
	Footer = "Exploit Pro Version",
	Icon = 18148044143,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	-- Creates a new tab titled Main
	Main = Window:AddTab('Fish Automatic'),
	['UI Settings'] = Window:AddTab('UI Addons'),
}

local a = Tabs.Main:AddLeftGroupbox('Automatic')
a:AddToggle('Automatic Fish', {
    Text = 'Automatic Fishing',
    Default = false,
    Tooltip = 'Automatically fish using the specified parameters',
    Callback = function(state)
        if state then
            -- Enable automatic fishing
            local autoFish = true
            
            -- Function to execute the fishing actions
            local function performFishing()
                while autoFish do
                    -- First set of args
                    local args1 = {
                        [1] = 100,
                        [2] = 1
                    }

                    game:GetService("Players").LocalPlayer:WaitForChild("cast"):FireServer(unpack(args1))

                    -- Wait a bit before the next action
                    task.wait(0.5)

                    -- Second set of args
                    local args2 = {
                        [1] = 100,
                        [2] = true
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(unpack(args2))

                    -- Wait before repeating
                    task.wait(0.5)
                end
            end

            -- Start the fishing loop in a new thread
            task.spawn(performFishing)

        else
            -- Disable automatic fishing
            autoFish = false
        end
    end
})

a:AddToggle('Equip Carbon Rod', {
    Text = 'Equip Carbon Rod',
    Default = false,
    Tooltip = 'Equip the Carbon Rod from your inventory',
    Callback = function(state)
        if state then
            -- Enable equipping Carbon Rod
            local autoEquip = true
            
            -- Function to execute the equip action
            local function performEquip()
                while autoEquip do
                    local args = {
                        [1] = game:GetService("Players").LocalPlayer:WaitForChild("Carbon Rod")
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/Backpack/Equip"):FireServer(unpack(args))
                    
                    -- Wait before repeating
                    task.wait(0.5)
                end
            end

            -- Start the equip loop in a new thread
            task.spawn(performEquip)

        else
            -- Disable equipping Carbon Rod
            autoEquip = false
        end
    end
})
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place") -- if the game has multiple places inside of it (for example: DOORS)
-- you can use this to save configs for those places separately
-- The path in this script would be: MyScriptHub/specific-game/settings/specific-place
-- [ This is optional ]

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs["UI Settings"])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
