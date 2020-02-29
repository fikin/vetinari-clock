--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local function durationBetweenCalls()
    local lastCall = tmr.now()
    return function()
        local now = tmr.now()
        local delta = now - lastCall
        if delta < 0 then
            delta = delta + 2147483647
        end
        lastCall = now
        return delta
    end
end

local function shouldMoveSecondsHand()
    -- math.randomseed(tonumber(tostring(tmr.now()):reverse():sub(1, 6)))

    local secondSize = 1000000
    local constants = {
        minuteSize = secondSize * 60,
        tickSize = secondSize / 2, -- hand moves 2x faster than normal
        oneAndHalfTickSize = secondSize * 3 / 4, -- tickSize x 1.5
        oneAndHalfSec = secondSize * 3 / 2 -- secondSize x 1.5
    }
    -- print(
    --     string.format(
    --         "Setup: minuteSize:%d  tickSize:%d  oneAndHalfTickSize:%d  oneAndHalfSec:%d",
    --         constants.minuteSize,
    --         constants.tickSize,
    --         constants.oneAndHalfTickSize,
    --         constants.oneAndHalfSec
    --     )
    -- )

    local vars = {
        remainingTime = 0,
        movesToMake = -1000
    }
    local calcDuration = durationBetweenCalls()

    local function shouldHandMove()
        if vars.movesToMake == 1 then
            return vars.remainingTime < constants.oneAndHalfTickSize
        end

        if vars.remainingTime <= (vars.movesToMake * constants.tickSize) then
            return true
        else
            return math.random(0, 1) < 0.3 -- <30% chance to move
        end
    end


    local function recalc()
        local d = calcDuration()
        if vars.movesToMake == -1000 or vars.movesToMake == 0 then
            d = 0
            if vars.movesToMake == -1000 then
                vars.remainingTime = constants.minuteSize
                vars.movesToMake = 60
            else
                vars.remainingTime = constants.minuteSize - vars.remainingTime
                vars.movesToMake = 60
            end
            -- print(
            --     string.format(
            --         "MIN : remainingTime:%d  movesToMake:%d",
            --         vars.remainingTime,
            --         vars.movesToMake
            --     )
            -- )
        end
        return d
    end

    local function advance(duration, shouldMove)
        vars.remainingTime = vars.remainingTime - duration
        if shouldMove then
            vars.movesToMake = vars.movesToMake - 1
        end
    end

    return function()
        local d = recalc()
        local flg = shouldHandMove()
        advance(d, flg)
        -- print(
        --     string.format(
        --         "SEC : remaining_time:%d  movesToMake:%d  should_move:%s  duration:%d",
        --         vars.remainingTime,
        --         vars.movesToMake,
        --         tostring(flg),
        --         d
        --     )
        -- )
        return flg
    end
end

local function toggleCoil(coilPins)
    assert(type(coilPins) == "table")
    assert(type(coilPins[1]) == "number", type(coilPins[1]))
    assert(type(coilPins[2]) == "number", type(coilPins[1]))
    assert(coilPins[0] ~= coilPins[1])
    gpio.mode(coilPins[1], gpio.OUTPUT, gpio.PULLUP)
    gpio.mode(coilPins[2], gpio.OUTPUT, gpio.PULLUP)
    local pinIndx = 1
    local lastLevel = 0
    return function(setToLevel)
        if setToLevel == gpio.LOW and lastLevel == gpio.LOW then
            return
        end
        assert(setToLevel ~= gpio.HIGH or lastLevel ~= setToLevel, "missed toggle(gpio.LOW) call somewhere")
        if setToLevel == gpio.HIGH then
            pinIndx = 1 - pinIndx
        end
        gpio.write(coilPins[pinIndx + 1], setToLevel)
        lastLevel = setToLevel
    end
end

local function trueOnNCall(nthCall)
    local cnt = 0
    return function()
        cnt = cnt + 1
        if cnt > nthCall then
            cnt = 1
        end
        return cnt == nthCall
    end
end

local function fireAfter(delayMs, fnc)
    local t = tmr.create()
    t:register(delayMs, tmr.ALARM_SINGLE, fnc)
    t:start()
end

local function fireEvery(delayMs, fnc)
    local t = tmr.create()
    t:register(delayMs, tmr.ALARM_AUTO, fnc)
    t:start()
end

local function loudClock(coilPins)
    local coilFnc = toggleCoil(coilPins)
    local moveHandFnc = shouldMoveSecondsHand()
    fireEvery(
        500,
        function()
            if moveHandFnc() then
                coilFnc(gpio.HIGH)
            end
        end
    )
    fireEvery(
        120,
        function()
            coilFnc(gpio.LOW)
        end
    )
end

local function silentClock(coilPins)
    local coilFnc = toggleCoil(coilPins)
    local moveHandFnc = shouldMoveSecondsHand()
    local isNCallFnc = trueOnNCall(16)
    local moveFlg = false
    fireEvery(
        31,
        function()
            if moveFlg then
                coilFnc(gpio.HIGH)
            end
            if isNCallFnc() then
                moveFlg = moveHandFnc()
            end
        end
    )
    fireAfter(
        20,
        function()
            coilFnc(gpio.LOW)
            fireEvery(
                31,
                function()
                    coilFnc(gpio.LOW)
                end
            )
        end
    )
end

return function(typeOfClock)
    if typeOfClock == "loud" then
        return loudClock
    elseif typeOfClock == "silent" then
        return silentClock
    elseif typeOfClock == "test" then
        return {
            shouldMoveSecondsHand = shouldMoveSecondsHand,
            toggleCoil = toggleCoil,
            trueOnNCall = trueOnNCall
        }
    else
        assert("expected 'silent' or 'loud' clock type but given " .. typeOfClock)
    end
end
