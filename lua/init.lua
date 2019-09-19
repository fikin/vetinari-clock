--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local function startup()
    print("in startup")
    dofile("clock.lua")
end

print("5 sec to start clock ...")
local t = tmr.create()
t:register(5000, tmr.ALARM_SINGLE, startup)
t:start()
