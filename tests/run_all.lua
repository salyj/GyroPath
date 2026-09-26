-- tests/run_all.lua
--
-- Runs every GyroPath unit test suite through the vendored luaunit.
-- Usage (from the repo root): lua tests/run_all.lua [luaunit options / test names]
-- Exit code: 0 when every test passes, non-zero on any failure or error (DEC-21).
--
-- Plain Lua 5.1 only -- no LuaJIT-only features, no libraries beyond the stdlib
-- and the vendored tests/lib/luaunit.lua.

-- Make the vendored luaunit resolvable as require("luaunit"), without touching
-- any luaunit installed elsewhere on this machine.
package.path = "tests/lib/?.lua;" .. package.path

local lu = require("luaunit")

-- Explicit list of suite files (DEC-21): stock Lua 5.1 cannot enumerate a
-- directory's contents without extra libraries, so new suites are added here
-- by hand as later phases introduce them.
local suites = {
  "tests/GyroPathFormat_test.lua",
  -- Phase 2: "tests/GyroPathClient_test.lua",
  -- Phase 3: "tests/GyroPathBucket_test.lua",
  -- Phase 4: "tests/GyroPathDistance_test.lua",
}

for _, suitePath in ipairs(suites) do
  local chunk = assert(loadfile(suitePath), "failed to load suite: " .. suitePath)
  chunk()
end

-- lu.LuaUnit.run() with no arguments reads Lua's own `arg` global, so
-- command-line options (e.g. -v) and test-name filters pass straight through.
os.exit(lu.LuaUnit.run())
