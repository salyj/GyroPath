local ADDON_NAME, gp = ...

local STRIDE_YARDS = 1.5
local THROTTLE     = 0.1
local YARDS_PER_MILE = 1760

local versionNum = "1.0.1"
local isBCC = false

if(string.match(GetBuildInfo(), "%d+") == "2") then
  isBCC = true
end

gp.versionNum = versionNum
gp.isBCC = isBCC
gp.showSessionStats = false
gp.celebrateMilestones = false

local function newCelebrations()
  return {
    sessionSteps = false,         -- 10k steps in 1 session
    frequentFlyer = false,        -- 100 miles on flight paths
    marathonRunner = false,       -- 66k steps in 1 session
    triatholete = false,          -- .25 miles swam, 16,368 steps mounted, 3000 steps in 1 session
    tourDeFrance = false,         -- 5,478,000 steps on mount
    rideAroundTheWorld = false,   -- 65,706,538 miles on mount
    longDistanceSwim = false,     -- 21 miles swim
    mileHighClub = false          -- 24,888.84 miles on flight paths
  }
end

local function newBuckets()
  if isBCC then
    return { onFoot = 0, mount = 0, taxi = 0, swim = 0, flying = 0, other = 0 }
  else
    return { onFoot = 0, mount = 0, taxi = 0, swim = 0, other = 0 }
  end
end

local defaults = {
  lifetime     = newBuckets(),
  session      = newBuckets(),
  celebrations = newCelebrations(),
  ui           = { show = true, x = 0, y = 0, point = "CENTER" },
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

local function milesUnformatted(yards) return yards / YARDS_PER_MILE end
local function stepsUnformatted(yards) return yards / STRIDE_YARDS end

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

  if stepsUnformatted(S.onFoot) >= 10000 and GyroPath.celebrations.sessionSteps == false then
    PlaySoundFile(568672, "Master")
    print("|cff33ff99GyroPath|r You have taken 10,000 steps this session!")
    GyroPath.celebrations.sessionSteps = true
  end

  if milesUnformatted(L.taxi) >= 100.0 and GyroPath.celebrations.frequentFlyer == false then
    PlaySoundFile(568672, "Master")
    print("|cff33ff99GyroPath|r you have flown for 100 miles on Flight Paths!")
    GyroPath.celebrations.frequentFlyer = true
  end

  if stepsUnformatted(S.onFoot) >= 66000 and GyroPath.celebrations.marathonRunner == false then
    PlaySoundFile(568672, "Master")
    print("|cff33ff99GyroPath|r you have ran a marathon this session!")
    GyroPath.celebrations.marathonRunner = true
  end

  if milesUnformatted(S.swim) >= 0.25 and stepsUnformatted(S.mount) >= 16368 and stepsUnformatted(S.onFoot) >= 3000 and GyroPath.celebrations.triatholete == false then
    PlaySoundFile(568672, "Master")
    print("|cff33ff99GyroPath|r you have done a triatholon this session!")
    GyroPath.celebrations.triatholete = true
  end

  if stepsUnformatted(L.mount) >= 5478000 and GyroPath.celebrations.tourDeFrance == false then
    PlaySoundFile(568672, "Master")
    print("|cff33ff99GyroPath|r you have ridden the equivalent of the Tour De France on mount!")
    GyroPath.celebrations.tourDeFrance = true
  end

  if stepsUnformatted(L.mount) >= 65706538 and GyroPath.celebrations.rideAroundTheWorld == false then
    PlaySoundFile(568672, "Master")
    print("|cff33ff99GyroPath|r you have circumnavigated the world on your mount!")
    GyroPath.celebrations.rideAroundTheWorld = true
  end

  if milesUnformatted(L.swim) >= 21 and GyroPath.celebrations.longDistanceSwim == false then
    PlaySoundFile(568672, "Master")
    print("|cff33ff99GyroPath|r you have swam the distance of crossing the English Channel!")
    GyroPath.celebrations.longDistanceSwim = true
  end

  if milesUnformatted(L.taxi) >= 28884.84 and GyroPath.celebrations.mileHighClub == false then
    PlaySoundFile(568672, "Master")
    print("|cff33ff99GyroPath|r you have flown around the world!")
    GyroPath.celebrations.mileHighClub = true
  end
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
    GyroPath.celebrations = newCelebrations()
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
  GyroPath.celebrations.sessionSteps = false

  gp.BuildPanel()
  if not GyroPath.ui.show then gp.panel:Hide() end

  C_Timer.NewTicker(0.5, gp.RefreshPanel) -- update text twice a second
  print("|cff33ff99GyroPath|r loaded. Type /GyroPath for stats.")
end)