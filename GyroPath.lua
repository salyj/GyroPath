local ADDON_NAME = ...

local STRIDE_YARDS = 1.5
local THROTTLE     = 0.1
local YARDS_PER_MILE = 1760

local function newBuckets()
  return { onFoot = 0, mount = 0, taxi = 0, swim = 0, other = 0 }
end

local defaults = {
  lifetime = newBuckets(),
  session  = newBuckets(),
  ui       = { show = true, x = 0, y = 0, point = "CENTER" },
}

local function applyDefaults(src, dst)
  for k, v in pairs(src) do
    if type(v) == "table" then
      if type(dst[k]) ~= "table" then dst[k] = {} end
      applyDefaults(v, dst[k])
    elseif dst[k] == nil then
      dst[k] = v
    end
  end
end

local function comma(n)
  n = math.floor(n + 0.5)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function miles(yards) return string.format("%.2f", yards / YARDS_PER_MILE) end
local function steps(yards) return comma(yards / STRIDE_YARDS) end

local driver = CreateFrame("Frame", "GyroPathDriver", UIParent)
local accum = 0

local function accumulate(dt)
  if not EditModeManagerFrame:IsEditModeActive() then
    if AuraUtil.FindAuraByName("Slow Fall", "player") ~= nil then
      b = "Slow Fall"
    elseif AuraUtil.FindAuraByName("Levitate", "player") ~= nil then
      b = "Levitate"
    else
      b = nil
    end
  end
  
  local speed = GetUnitSpeed("player")
  if not speed or speed <= 0 then return end
  local dist = speed * dt

  local L, S = GyroPath.lifetime, GyroPath.session
  local bucket
  if UnitOnTaxi("player") then
    bucket = "taxi"
  elseif b == "Levitate" or (b == "Slow Fall" and IsFalling())  then
    bucket = "other"
  elseif IsMounted() then
    bucket = "mount"
  elseif IsSwimming() then
    bucket = "swim"
  else
    bucket = "onFoot"
  end

  L[bucket] = L[bucket] + dist
  S[bucket] = S[bucket] + dist
end

driver:SetScript("OnUpdate", function(_, elapsed)
  accum = accum + elapsed
  if accum < THROTTLE then return end
  accumulate(accum)
  accum = 0
end)

local panel
local function BuildPanel()
  panel = CreateFrame("Frame", "GyroPathFrame", UIParent, "BackdropTemplate")
  panel:SetSize(160, 110)
  panel:SetPoint(GyroPath.ui.point, UIParent, GyroPath.ui.point, GyroPath.ui.x, GyroPath.ui.y)
  panel:SetMovable(true)
  panel:EnableMouse(true)
  panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart", panel.StartMoving)
  panel:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    GyroPath.ui.point, GyroPath.ui.x, GyroPath.ui.y = point, x, y
  end)

  if panel.SetBackdrop then
    panel:SetBackdrop({
      bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 16, edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
  end

  local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", 0, -8)
  title:SetText("|cff33ff99GyroPath|r")

  local body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  body:SetPoint("TOPLEFT", 14, -28)
  body:SetJustifyH("LEFT")
  body:SetSpacing(3)
  panel.body = body
end

local function RefreshPanel()
  if not panel or not panel:IsShown() then return end
  local L = GyroPath.lifetime
  panel.body:SetText(
    string.format("Steps: |cffffffff%s|r\n", steps(L.onFoot)) ..
    string.format("Mount steps: |cffffffff%s|r\n", steps(L.mount)) ..
    string.format("Flight paths: |cffffffff%s mi|r\n", miles(L.taxi)) ..
    string.format("Swam: |cffffffff%s mi|r\n", miles(L.swim)) ..
    string.format("Other: |cffffffff%s mi|r", miles(L.other))
  )
end

local function PrintStats()
  local L, S = GyroPath.lifetime, GyroPath.session
  print("|cff33ff99GyroPath|r  (lifetime / this session)")
  print(string.format("  Steps on foot: %s / %s",  steps(L.onFoot), steps(S.onFoot)))
  print(string.format("  Mount steps:   %s / %s",  steps(L.mount),  steps(S.mount)))
  print(string.format("  Flight paths:  %s mi / %s mi", miles(L.taxi),   miles(S.taxi)))
  print(string.format("  Swum:          %s mi / %s mi", miles(L.swim),   miles(S.swim)))
  print(string.format("  Other:         %s mi / %s mi", miles(L.other),  miles(S.other)))
end

SLASH_GYROPATH1 = "/GyroPath"
SLASH_GYROPATH2 = "/gp"
SlashCmdList.GYROPATH = function(msg)
  msg = (msg or ""):lower():gsub("%s+", "")
  if msg == "stats" then
    PrintStats()
  elseif msg == "reset" then
    GyroPath.lifetime = newBuckets()
    GyroPath.session  = newBuckets()
    print("|cff33ff99GyroPath|r lifetime totals reset.")
    RefreshPanel()
  elseif msg == "hide" then
    GyroPath.ui.show = false
    if panel then panel:Hide() end
  elseif msg == "show" then
    GyroPath.ui.show = true
    if panel then panel:Show(); RefreshPanel() end
  else
    print("|cff33ff99GyroPath|r commands: /GyroPath stats | show | hide | reset")
  end
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
  GyroPath = GyroPath or {}
  applyDefaults(defaults, GyroPath)
  GyroPath.session = newBuckets()   -- fresh session each login

  BuildPanel()
  if not GyroPath.ui.show then panel:Hide() end

  C_Timer.NewTicker(0.5, RefreshPanel) -- update text twice a second
  print("|cff33ff99GyroPath|r loaded. Type /GyroPath for stats.")
end)