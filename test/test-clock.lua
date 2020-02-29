--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local tools = require("tools")
local nodemcu = require("nodemcu")
local c = require("clock")

function testSilentClock()
  nodemcu.reset()
  c("silent")({5, 6})
end

function testLoudClock()
  nodemcu.reset()
  c("loud")({5, 6})
end

function testNCallFunction()
  nodemcu.reset()
  local f = c("test").trueOnNCall(3)
  lu.assertFalse(f())
  lu.assertFalse(f())
  lu.assertTrue(f())
  lu.assertFalse(f())
  lu.assertFalse(f())
  lu.assertTrue(f())
  lu.assertFalse(f())
end

function testToggleCoil()
  nodemcu.reset()
  local f = c("test").toggleCoil({5, 6})
  lu.assertEquals(nodemcu.gpio_get_mode(5), gpio.OUTPUT)
  lu.assertEquals(nodemcu.gpio_get_mode(6), gpio.OUTPUT)
  local p5 = tools.collectDataToArray()
  nodemcu.gpio_capture(5, p5.putCb)
  local p6 = tools.collectDataToArray()
  nodemcu.gpio_capture(6, p6.putCb)
  f(gpio.HIGH)
  lu.assertEquals(p5.get(), {{5, gpio.HIGH}})
  lu.assertEquals(p6.get(), {})
  f(gpio.LOW)
  lu.assertEquals(p5.get(), {{5, gpio.LOW}})
  lu.assertEquals(p6.get(), {})
  f(gpio.LOW)
  lu.assertEquals(p5.get(), {})
  lu.assertEquals(p6.get(), {})
  f(gpio.HIGH)
  lu.assertEquals(p5.get(), {})
  lu.assertEquals(p6.get(), {{6, gpio.HIGH}})
  f(gpio.LOW)
  lu.assertEquals(p5.get(), {})
  lu.assertEquals(p6.get(), {{6, gpio.LOW}})
  f(gpio.HIGH)
  lu.assertEquals(p5.get(), {{5, gpio.HIGH}})
  lu.assertEquals(p6.get(), {})
end

os.exit(lu.run())
