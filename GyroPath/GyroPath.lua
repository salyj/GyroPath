local ADDON_NAME, gp = ...

local STRIDE_YARDS = 1.5
local THROTTLE     = 0.1
local YARDS_PER_MILE = 1760

local versionNum = "0.3.0"
local isBCC = false

if(string.match(GetBuildInfo(), "%d+") == "2") then
  isBCC = true
end

gp.isBCC = isBCC
gp.showSessionStats = false

local function newBuckets()
  if isBCC then
    return { onFoot = 0, mount = 0, taxi = 0, swim = 0, flying = 0, other = 0 }
  else
    return { onFoot = 0, mount = 0, taxi = 0, swim = 0, other = 0 }
  end
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

gp.miles = miles
gp.steps = steps

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

  if isBCC then
    if UnitOnTaxi("player") then
      bucket = "taxi"
    elseif b == "Levitate" or (b == "Slow Fall" and IsFalling())  then
      bucket = "other"
    elseif IsFlying() then
      bucket = "flying"
    elseif IsMounted() then
      bucket = "mount"
    elseif IsSwimming() then
      bucket = "swim"
    else
      bucket = "onFoot"
    end
  else
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

local function PrintStats()
  local L, S = GyroPath.lifetime, GyroPath.session
  print("|cff33ff99GyroPath|r  (lifetime / this session)")
  print(string.format("  Steps on foot: %s / %s",  steps(L.onFoot), steps(S.onFoot)))
  print(string.format("  Mount steps:   %s / %s",  steps(L.mount),  steps(S.mount)))
  print(string.format("  Flight paths:  %s mi / %s mi", miles(L.taxi),   miles(S.taxi)))
  print(string.format("  Swam:          %s mi / %s mi", miles(L.swim),   miles(S.swim)))
  if isBCC then
    print(string.format("  Flying:        %s mi / %s mi", miles(L.flying), miles(S.flying)))
  end
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
    gp.RefreshPanel()
  elseif msg == "hide" then
    GyroPath.ui.show = false
    if gp.panel then gp.panel:Hide() end
  elseif msg == "show" then
    GyroPath.ui.show = true
    if gp.panel then gp.panel:Show(); gp.RefreshPanel() end
  elseif msg == "version" then
    print("|cff33ff99GyroPath|r version: " .. versionNum)
  else
    print("|cff33ff99GyroPath|r commands: /GyroPath stats | show | hide | reset | version")
  end
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
  GyroPath = GyroPath or {}
  applyDefaults(defaults, GyroPath)
  GyroPath.session = newBuckets()   -- fresh session each login

  gp.BuildPanel()
  if not GyroPath.ui.show then gp.panel:Hide() end

  C_Timer.NewTicker(0.5, gp.RefreshPanel) -- update text twice a second
  print("|cff33ff99GyroPath|r loaded. Type /GyroPath for stats.")
end)