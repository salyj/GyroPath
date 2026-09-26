-- tests/GyroPathFormat_test.lua
--
-- Characterization tests for GyroPath/GyroPathFormat.lua, the addon's only pure
-- module (no WoW API calls). These tests lock in the module's current behavior;
-- they do not judge whether that behavior is "correct". Exact expected values
-- come from the Phase 1 builder brief.
--
-- WoW loads every addon file with two arguments via `...`: the addon name and a
-- shared table. We load the module the same way: loadfile(path), then call the
-- result with a fresh addon name and table. The module itself is never modified.

local lu = require("luaunit")

local MODULE_PATH = "GyroPath/GyroPathFormat.lua"

-- Loads a fresh copy of the module into its own table, exactly as WoW would.
local function loadFormatModule()
  local chunk = assert(loadfile(MODULE_PATH))
  local gp = {}
  chunk("GyroPath", gp)
  return gp
end

-- comma() ---------------------------------------------------------------

TestGyroPathFormatComma = {}

function TestGyroPathFormatComma:setUp()
  self.gp = loadFormatModule()
end

function TestGyroPathFormatComma:test_zero()
  lu.assertEquals(self.gp.Format.comma(0), "0")
end

function TestGyroPathFormatComma:test_below_one_thousand()
  lu.assertEquals(self.gp.Format.comma(999), "999")
end

function TestGyroPathFormatComma:test_exactly_one_thousand()
  lu.assertEquals(self.gp.Format.comma(1000), "1,000")
end

function TestGyroPathFormatComma:test_hundred_thousand_has_no_leading_comma()
  lu.assertEquals(self.gp.Format.comma(100000), "100,000")
end

function TestGyroPathFormatComma:test_millions_get_two_separators()
  lu.assertEquals(self.gp.Format.comma(1234567), "1,234,567")
end

function TestGyroPathFormatComma:test_fraction_rounds_down()
  lu.assertEquals(self.gp.Format.comma(1234.4), "1,234")
end

function TestGyroPathFormatComma:test_fraction_rounds_up_at_half()
  lu.assertEquals(self.gp.Format.comma(1234.5), "1,235")
end

function TestGyroPathFormatComma:test_half_rounds_up_across_thousand_boundary()
  lu.assertEquals(self.gp.Format.comma(999.5), "1,000")
end

-- steps() -----------------------------------------------------------------

TestGyroPathFormatSteps = {}

function TestGyroPathFormatSteps:setUp()
  self.gp = loadFormatModule()
end

function TestGyroPathFormatSteps:test_one_stride_is_one_step()
  lu.assertEquals(self.gp.Format.steps(1.5), "1")
end

function TestGyroPathFormatSteps:test_ten_thousand_steps_formatted()
  lu.assertEquals(self.gp.Format.steps(15000), "10,000")
end

-- miles() -----------------------------------------------------------------

TestGyroPathFormatMiles = {}

function TestGyroPathFormatMiles:setUp()
  self.gp = loadFormatModule()
end

function TestGyroPathFormatMiles:test_zero_miles()
  lu.assertEquals(self.gp.Format.miles(0), "0.00")
end

function TestGyroPathFormatMiles:test_half_mile()
  lu.assertEquals(self.gp.Format.miles(880), "0.50")
end

function TestGyroPathFormatMiles:test_one_mile()
  lu.assertEquals(self.gp.Format.miles(1760), "1.00")
end

-- stepsUnformatted() / milesUnformatted() ----------------------------------

TestGyroPathFormatUnformatted = {}

function TestGyroPathFormatUnformatted:setUp()
  self.gp = loadFormatModule()
end

function TestGyroPathFormatUnformatted:test_steps_unformatted_is_a_raw_number()
  lu.assertEquals(self.gp.Format.stepsUnformatted(3), 2)
end

function TestGyroPathFormatUnformatted:test_miles_unformatted_is_a_raw_number()
  lu.assertEquals(self.gp.Format.milesUnformatted(3520), 2)
end

-- Constants -----------------------------------------------------------------

TestGyroPathFormatConstants = {}

function TestGyroPathFormatConstants:setUp()
  self.gp = loadFormatModule()
end

function TestGyroPathFormatConstants:test_stride_yards()
  lu.assertEquals(self.gp.Format.STRIDE_YARDS, 1.5)
end

function TestGyroPathFormatConstants:test_yards_per_mile()
  lu.assertEquals(self.gp.Format.YARDS_PER_MILE, 1760)
end

-- Public surface aliases (gp.steps / gp.miles) -------------------------------
-- GyroPathFrame.lua and GyroPathStats.lua call gp.miles / gp.steps directly,
-- so the module keeps these as aliases onto gp.Format. Confirm they are the
-- *same function objects*, not just equivalent behavior.

TestGyroPathFormatPublicAliases = {}

function TestGyroPathFormatPublicAliases:setUp()
  self.gp = loadFormatModule()
end

function TestGyroPathFormatPublicAliases:test_gp_steps_is_gp_Format_steps()
  lu.assertIs(self.gp.steps, self.gp.Format.steps)
end

function TestGyroPathFormatPublicAliases:test_gp_miles_is_gp_Format_miles()
  lu.assertIs(self.gp.miles, self.gp.Format.miles)
end
