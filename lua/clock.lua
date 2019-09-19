--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local clock = {
    -- constants
    coilPins = {5, 6},
    maxTicksPerSec = 2,
    usPerMin = 60 * 1000 * 1000,
    coilOffTimeoutMs = 200,
    ticksPerMin = 60,
    -- calculated
    maxTicksUs = nil,
    lastTickDeltaUs = nil,
    -- coil related
    currentPinOn = nil,
    pinOffTimer = nil,
    -- minute related
    minRemainingTimeUs = nil,
    minRemainingTicks = nil,
    lastTickTime = nil
}

local function pinOff()
    gpio.write(clock.coilPins[clock.currentPinOn + 1], gpio.HIGH)
    clock.currentPinOn = 1 - clock.currentPinOn
end

local function newMinuteStarts()
    clock.minRemainingTicks = clock.ticksPerMin
    -- compensateForTimerDrift
    if clock.minRemainingTimeUs > clock.maxTicksUs then
        clock.minRemainingTicks = clock.minRemainingTicks + 1
        clock.minRemainingTimeUs = clock.minRemainingTimeUs - clock.maxTicksUs
    end
    --
    clock.minRemainingTimeUs = clock.minRemainingTimeUs + clock.usPerMin
end

local function decideToMove()
    -- last tick has to end the minute
    if clock.minRemainingTicks == 1 then
        return clock.minRemainingTimeUs < (clock.maxTicksUs + clock.lastTickDeltaUs)
    end
    --

    local noTimeToWaitLeft = clock.minRemainingTicks * clock.maxTicksUs
    local leasureTime = clock.minRemainingTimeUs - noTimeToWaitLeft

    if leasureTime <= 0 then
        return true
    else
        local r = math.random(0, 1)
        return r < 0.3 -- 1 to 2 for moving vs. waiting
    end
end

local function clockTick(tmrObj)
    if clock.minRemainingTicks == 0 then
        newMinuteStarts()
    end

    -- advance time per interrupt
    local now = tmr.now()
    clock.minRemainingTimeUs = clock.minRemainingTimeUs - (now - clock.lastTickTime)
    clock.lastTickTime = now
    --

    if decideToMove() then
        clock.minRemainingTicks = clock.minRemainingTicks - 1
        -- toggle coil
        gpio.write(clock.coilPins[clock.currentPinOn + 1], gpio.LOW)
        clock.pinOffTimer:start()
    end
end

local function startTickTimer()
    local tmrTick = tmr.create()
    tmrTick:register(clock.maxTicksUs / 1000, tmr.ALARM_AUTO, clockTick)
    tmrTick:start()
end

local function createPinOffTimer()
    local tmrTick = tmr.create()
    tmrTick:register(clock.coilOffTimeoutMs, tmr.ALARM_SEMI, pinOff)
    return tmrTick
end

local function initClock()
    for i = 1, 2 do
        gpio.mode(clock.coilPins[i], gpio.OUTPUT, gpio.PULLUP)
    end
    clock.pinOffTimer = createPinOffTimer()
    clock.maxTicksUs = 1000000 / clock.maxTicksPerSec
    clock.lastTickDeltaUs = clock.maxTicksUs / 2

    clock.currentPinOn = 0

    clock.minRemainingTicks = 0
    clock.minRemainingTimeUs = 0
    clock.lastTickTime = tmr.now()
end

local function main()
    initClock()
    startTickTimer()
end

main()
