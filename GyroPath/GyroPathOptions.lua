local _, gp = ...
local AceGUI = LibStub("AceGUI-3.0")

function gp.CreateWindow()
    local optionsGUI = gp.options()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("GyroPath", optionsGUI)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GyroPath", "GyroPath")

    gp.optionsFrame = AceGUI:Create("Frame")
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("GyroPath", 600, 300)
    LibStub("AceConfigDialog-3.0"):Open("GyroPath", gp.optionsFrame)
    gp.optionsFrame:Hide()

    gp.optionsFrame = gp.optionsFrame.frame
    table.insert(UISpecialFrames, "GyroPathOptionsFrame")
end

gp.options = function()
    return {
        name = "Options",
        type = "group",
        order = 1,
        args = {
            toggleSession = {
                type = "toggle",
                name = "Track Session Stats",
                desc = "Toggle between showing session stats and all time stats.",
                order = 1,
                get = function() return gp.showSessionStats end,
                set = function(info, value)
                    gp.showSessionStats = value
                    gp.RefreshPanel()
                end,
            },
            toggleCelebrate = {
                type = "toggle",
                name = "Celebrate Milestones",
                desc = "Toggle celebrating milestones - for fun",
                order = 2,
                get = function() return gp.celebrateMilestones end,
                set = function(info, value)
                    gp.celebrateMilestones = value
                end,
            }
        }
    }
end

gp.CreateWindow()