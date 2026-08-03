local _, gp = ...
local AceGUI = LibStub("AceGUI-3.0")

function gp.CreateWindow()
    local optionsGUI = gp.tabs()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("GyroPath", optionsGUI)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GyroPath", "GyroPath")

    gp.optionsFrame = AceGUI:Create("Frame")
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("GyroPath", 600, 300)
    LibStub("AceConfigDialog-3.0"):Open("GyroPath", gp.optionsFrame)
    gp.optionsFrame:Hide()

    gp.optionsFrame = gp.optionsFrame.frame
    table.insert(UISpecialFrames, "GyroPathOptionsFrame")
end

gp.tabs = function()
    return {
        name = "GyroPath",
        handler = GyroPath,
        type = "group",
        childGroups = "tab",
        args = {
            options = gp.options(),
            stats = gp.about(),
        }
    }
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

gp.about = function()
    return {
        name = "About",
        type = "group",
        order = 2,
        args = {
            aboutHeader = {
                type = "header",
                name = "About GyroPath",
                order = 1,
            },
            aboutText = {
                type = "description",
                name = "GyroPath ".. gp.versionNum .. "\nCreated by HKRob\n\n\nThis addon uses the GNU GPLv3 License. For more information, see: https://www.gnu.org/licenses/gpl-3.0.en.html",
                order = 2,
                fontSize = "medium",
            },
            thankYouHeader = {
                type = "header",
                name = "Note from the author",
                order = 3,
            },
            thankYouText = {
                type = "description",
                name = "Thank you for using GyroPath! I hope you enjoy it. I would like to take a moment to thank a few people for assisting me on the development of this addon:\n\n    \124cff00ffffMy Wife Olivia\124r - for being an awesome partner despite her frustrations.\n    \124cff00ffffYogitime\124r - for the idea and the push to get it done.\n    \124cff00ffffDottie\124r - for letting me waste her World Buffs testing data points.\n    \124cff00ffffThe Good Vibes Fresh Coffee guild on Doomhowl\124r - You guys have been very supportive of me, thanks!\n    \124cff00ffffThe WoW addon community\124r - I ask a lot of questions, thanks for answering them and not blocking me.",
                order = 4,
                fontSize = "medium",
            },
            donateLink = {
                type = "input",
                name = "Support Development at Buy Me a Coffee",
                desc = "I develop my addons in my free time purely for the love of the game and the community. If you would like to support my development efforts, please consider donating to me at this link.",
                order = 5,
                width="full",
                get = function() return "https://www.buymeacoffee.com/hellknightj" end,
                set = function() end,
            },
        }
    }
end

gp.CreateWindow()