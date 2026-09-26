local _, gp = ...

-- Pure numeric formatting for GyroPath's tracked distances. No WoW API calls in this
-- file by design, so it can be unit tested outside the game (see tests/GyroPathFormat_test.lua).

local STRIDE_YARDS   = 1.5
local YARDS_PER_MILE = 1760

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

gp.Format = {
  STRIDE_YARDS      = STRIDE_YARDS,
  YARDS_PER_MILE    = YARDS_PER_MILE,
  comma             = comma,
  miles             = miles,
  steps             = steps,
  milesUnformatted  = milesUnformatted,
  stepsUnformatted  = stepsUnformatted,
}

-- Preserve the existing public surface (GyroPathFrame.lua / GyroPathStats.lua already
-- call gp.miles / gp.steps directly).
gp.miles = miles
gp.steps = steps
