local ADDON_NAME, gp = ...

local MINIMAP_ICON   = "Interface\\Icons\\INV_Misc_Map_01"
local MINIMAP_RADIUS = 80

local BUCKET_ROWS = {
  { key = "onFoot", label = "Steps on foot", isSteps = true  },
  { key = "mount",  label = "Mount steps",    isSteps = true  },
  { key = "taxi",   label = "Flight paths",   isSteps = false },
  { key = "swim",   label = "Swam",           isSteps = false },
  { key = "flying", label = "Flying",         isSteps = false },
  { key = "other",  label = "Other",          isSteps = false },
}

local ACHIEVEMENTS = {
  { key = "sessionSteps",        name = "10,000 Steps",        desc = "Take 10,000 steps in a single session." },
  { key = "marathonRunner",      name = "Marathon Runner",     desc = "Take 66,000 steps in a single session." },
  { key = "triatholete",         name = "Triathlete",          desc = "In one session: swim 0.25 mi, ride a mount 6.2 mi, and take 3,000 steps on foot." },
  { key = "frequentFlyer",       name = "Frequent Flyer",      desc = "Fly 100 lifetime miles on Flight Paths." },
  { key = "mileHighClub",        name = "Mile High Club",      desc = "Fly 28,884.84 lifetime miles on Flight Paths." },
  { key = "tourDeFrance",        name = "Tour de France",      desc = "Ride 2,075 lifetime miles on a mount." },
  { key = "rideAroundTheWorld",  name = "Ride Around the World", desc = "Ride 24,888.84 lifetime miles on a mount." },
  { key = "longDistanceSwim",    name = "Channel Swimmer",     desc = "Swim 21 lifetime miles." },
}

local function GetMinimapButtonOffset(angleDeg)
  local angle = math.rad(angleDeg or 225)
  return MINIMAP_RADIUS * math.cos(angle), MINIMAP_RADIUS * math.sin(angle)
end

local function UpdateMinimapButtonPosition(button)
  local x, y = GetMinimapButtonOffset(GyroPath.ui.minimapAngle)
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function BuildMinimapButton()
  local button = CreateFrame("Button", "GyroPathMinimapButton", Minimap)
  button:SetSize(31, 31)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(8)
  button:RegisterForClicks("LeftButtonUp")
  button:RegisterForDrag("LeftButton")

  local icon = button:CreateTexture(nil, "BACKGROUND")
  icon:SetSize(20, 20)
  icon:SetPoint("CENTER", 0, 1)
  icon:SetTexture(MINIMAP_ICON)

  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetSize(53, 53)
  border:SetPoint("TOPLEFT")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  button:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function(self)
      local mx, my = Minimap:GetCenter()
      local px, py = GetCursorPosition()
      local scale = Minimap:GetEffectiveScale()
      px, py = px / scale, py / scale
      GyroPath.ui.minimapAngle = math.deg(math.atan2(py - my, px - mx))
      UpdateMinimapButtonPosition(self)
    end)
  end)

  button:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
  end)

  button:SetScript("OnClick", function()
    if gp.statsFrame:IsShown() then
      gp.statsFrame:Hide()
    else
      gp.statsFrame:Show()
      gp.RefreshStatsFrame()
    end
  end)

  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("|cff33ff99GyroPath|r")
    GameTooltip:AddLine("Click to view detailed stats", 1, 1, 1)
    GameTooltip:Show()
  end)

  button:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  gp.minimapButton = button
  UpdateMinimapButtonPosition(button)
end

local function BuildStatsFrame()
  local frame = CreateFrame("Frame", "GyroPathStatsFrame", UIParent, "BackdropTemplate")
  frame:SetSize(420, 360)
  frame:SetPoint("CENTER")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetFrameStrata("HIGH")
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:Hide()

  frame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -16)
  title:SetText("|cff33ff99GyroPath|r Stats")

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -4, -4)
  close:SetScript("OnClick", function() frame:Hide() end)

  local statsTab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  statsTab:SetSize(90, 22)
  statsTab:SetPoint("TOPLEFT", 16, -42)
  statsTab:SetText("Stats")

  local achievementsTab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  achievementsTab:SetSize(120, 22)
  achievementsTab:SetPoint("LEFT", statsTab, "RIGHT", 4, 0)
  achievementsTab:SetText("Achievements")

  local statsContent = CreateFrame("Frame", nil, frame)
  statsContent:SetAllPoints(frame)

  local achievementsContent = CreateFrame("Frame", nil, frame)
  achievementsContent:SetAllPoints(frame)
  achievementsContent:Hide()

  local lifetimeHeader = statsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  lifetimeHeader:SetPoint("TOPLEFT", 190, -74)
  lifetimeHeader:SetText("Lifetime")

  local sessionHeader = statsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sessionHeader:SetPoint("TOPLEFT", 310, -74)
  sessionHeader:SetText("Session")

  frame.rows = {}
  local rowY = -99
  for _, def in ipairs(BUCKET_ROWS) do
    if def.key ~= "flying" or gp.isBCC then
      local label = statsContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      label:SetPoint("TOPLEFT", 20, rowY)
      label:SetJustifyH("LEFT")
      label:SetText(def.label)

      local lifetimeValue = statsContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      lifetimeValue:SetPoint("TOPLEFT", 190, rowY)
      lifetimeValue:SetJustifyH("LEFT")

      local sessionValue = statsContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      sessionValue:SetPoint("TOPLEFT", 310, rowY)
      sessionValue:SetJustifyH("LEFT")

      frame.rows[def.key] = { def = def, lifetimeValue = lifetimeValue, sessionValue = sessionValue }
      rowY = rowY - 24
    end
  end

  frame.achievementRows = {}
  local achY = -78
  for _, ach in ipairs(ACHIEVEMENTS) do
    local row = CreateFrame("Frame", nil, achievementsContent)
    row:SetSize(384, 20)
    row:SetPoint("TOPLEFT", 16, achY)
    row:EnableMouse(true)

    local icon = row:CreateTexture(nil, "OVERLAY")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", 0, 0)

    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    name:SetJustifyH("LEFT")
    name:SetText(ach.name)

    row:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(ach.name)
      GameTooltip:AddLine(ach.desc, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)

    frame.achievementRows[ach.key] = { def = ach, icon = icon, name = name }
    achY = achY - 24
  end

  local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  footer:SetPoint("BOTTOM", 0, 14)
  footer:SetText("Drag to move  |  Click the minimap button to close")

  local function ShowStatsTab()
    statsContent:Show()
    achievementsContent:Hide()
    statsTab:Disable()
    achievementsTab:Enable()
  end

  local function ShowAchievementsTab()
    statsContent:Hide()
    achievementsContent:Show()
    achievementsTab:Disable()
    statsTab:Enable()
  end

  statsTab:SetScript("OnClick", ShowStatsTab)
  achievementsTab:SetScript("OnClick", ShowAchievementsTab)
  ShowStatsTab()

  gp.statsFrame = frame
  table.insert(UISpecialFrames, "GyroPathStatsFrame")
end

function gp.RefreshStatsFrame()
  local frame = gp.statsFrame
  if not frame or not frame:IsShown() then return end

  local L, S = GyroPath.lifetime, GyroPath.session
  for key, row in pairs(frame.rows) do
    local format = row.def.isSteps and gp.steps or gp.miles
    local suffix = row.def.isSteps and "" or " mi"
    row.lifetimeValue:SetText(format(L[key]) .. suffix)
    row.sessionValue:SetText(format(S[key]) .. suffix)
  end

  for key, row in pairs(frame.achievementRows) do
    local earned = GyroPath.celebrations[key] == true
    if earned then
      row.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
      row.name:SetTextColor(0.1, 1, 0.1)
    else
      row.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
      row.name:SetTextColor(0.5, 0.5, 0.5)
    end
  end
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
  if GyroPath.ui.minimapAngle == nil then
    GyroPath.ui.minimapAngle = 225
  end

  BuildStatsFrame()
  BuildMinimapButton()
  C_Timer.NewTicker(0.5, gp.RefreshStatsFrame)
end)
