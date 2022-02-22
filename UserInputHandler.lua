--[[
	William Horn 2019 UserInputHandler Module (Lua 5.1)
	ScriptGuider @ ROBLOX.com
	Updated: 12/6/2019

	Changelog:

		[5/12/2019]
			• Fixed minor bugs

			• Added "IsHandling" and "IsConnected" fields to UserInput object

		[12/6/2019]
			• Major code clean-up

			• Removed "IsHandling" and "IsConnected" fields from UserInput due to irrelevance
			after foundational rework of EventMaker module

			• Added Enable/disable functionality to input devices and events. Similar to unbind,
			Enable/disable will cease communication between an event and it's handler. However, it will
			do so for all signals connected to an event and they can be reactivated at any time
			without needing to re-bind them by calling Enable.

	TO-DO:
		? Add Game Processed support
		? Add support for InputChanged
		• Add custom input combination events
		• Add built-in interval detection
		• Add support for platforms other than PC
--]]

--------------
--------------
-- Game services

local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local InputService = game:GetService("UserInputService")

--------------
--------------
-- Game folders

local GlobalModules = RepStorage.GlobalModules

--------------
--------------
-- Require modules/libraries

local EventMaker = require(GlobalModules.EventMaker)

--------------
--------------
-- Create class module
local UserInput = EventMaker.event({
	_devices = {
		keyboard = EventMaker.event({_events = {}}),
		mouse = EventMaker.event({_events = {}})
	},
})

--[[
	UserInput =>

	{
		-- hidden (should not be accessed)
		_signal = Instance.new("bindableEvent"),
		_connections = {},
		_devices = {
			Keyboard = signal,
			Mouse = signal
		}

		-- fields
		isEnabled = true,

		-- API
		bind = func,
		fire = func,
		wait = func,
		unbind = func,
		disable = func, -- stop UserInput
		enable = func -- resume UserInput

		bindKeyboard
		bindMouse

		unbindKeyboard
		unbindMouse

		fireKeyboard
		fireMouse

		waitForKeyboard
		waitForMouse

		enableKeyboard
		enableMouse

		disableKeyboard
		disableMouse
	}
--]]

--------------
--------------

local function bindEvent(device, input, state, ...)
	local event = UserInput._devices[device]._events[input]
	if not event then
		event = {[state] = EventMaker.event()}
		UserInput._devices[device]._events[input] = event
	elseif not event[state] then
		event[state] = EventMaker.event()
	end
	event[state]:bind(...)
	return event[state]
end

local function unbindEvent(device, input, state, name)
	local event = UserInput._devices[device]._events[input]
	if event and event[state] then
		event[state]:unbind(name)
	end
end

local function fireEvent(device, input, state, ...)
	local event = UserInput._devices[device]._events[input]
	if event and event[state] then
		event[state]:fire(...)
	end
	UserInput._devices[device]:fire(...)
	UserInput:fire(...)
end

local function waitForEvent(device, input, state, timeout)
	local event = UserInput._devices[device]._events[input]
	if not event then
		event = {[state] = EventMaker.event()}
		UserInput._devices[device]._events[input] = event
	elseif not event[state] then
		event[state] = EventMaker.event()
	end
	return event[state]:wait(timeout)
end

local function setEventEnabled(device, input, state, enabled)
	local event = UserInput._devices[device]._events[input]
	if event then
		event[state]:setEnabled(enabled)
	end
end

--------------
--------------

-----------------
--- INPUT API ---
-----------------
-- @var args (...) = {name, function} of EventMaker:bind(name, function)

function UserInput:createInputSequenceEvent(sequence, name)


end

-- bind devices
function UserInput:bindKeyboard(...)
	self._devices.keyboard:bind(...)
end

function UserInput:bindMouse(...)
	self._devices.mouse:bind(...)
end


-- unbind devices
function UserInput:unbindKeyboard(...)
	self._devices.keyboard:unbind(...)
end

function UserInput:unbindMouse(...)
	self._devices.mouse:unbind(...)
end


-- Enable/disable events
function UserInput:enableKeyboard()
	self._devices.keyboard:enable()
end

function UserInput:disableKeyboard()
	self._devices.keyboard:disable()
end

function UserInput:setKeyboardEnabled(bool)
	self._devices.keyboard:setEnabled(bool)
end

function UserInput:isKeyboardEnabled()
	return self._devices.keyboard:isEnabled()
end

function UserInput:getKeyEvent(eventName, state)
	return self._devices.keyboard._event[eventName][state]
end

function UserInput:setMouseEnabled(bool)
	self._devices.mouse:setEnabled(bool)
end

function UserInput:isMouseEnabled()
	return self._devices.mouse:isEnabled()
end

function UserInput:getMouseEvent(eventName, state)
	return self._devices.mouse._events[eventName][state]
end

function UserInput:enableMouse()
	self._devices.mouse:enable()
end

function UserInput:disableMouse()
	self._devices.mouse:disable()
end


-- fire devices
function UserInput:fireKeyboard(...)
	self._devices.keyboard:fire(...)
end

function UserInput:fireMouse(...)
	self._devices.mouse:fire(...)
end


-- wait for devices
function UserInput:waitForKeyboard(timeout)
	self._devices.keyboard:wait(timeout)
end

function UserInput:waitForMouse(timeout)
	self._devices.mouse:wait(timeout)
end

--------------------
--- KEYBOARD API ---
--------------------
-- @var args (...) = {name, function} of EventMaker:bind(name, function)

-- bind keys
function UserInput:bindKeyDown(keyName, ...)
	return bindEvent("keyboard", keyName, "Begin", ...)
end

function UserInput:bindKeyUp(keyName, ...)
	return bindEvent("keyboard", keyName, "End", ...)
end


-- Enable/disable keys (debating on keeping)
function UserInput:enableKeyDown(keyName, name)
	setEventEnabled("keyboard", keyName, "Begin", true)
end

function UserInput:disableKeyDown(keyName, name)
	setEventEnabled("keyboard", keyName, "Begin", false)
end


-- unbind keys
function UserInput:unbindKeyDown(keyName, name)
	unbindEvent("keyboard", keyName, "Begin", name)
end

function UserInput:unbindKeyUp(keyName, name)
	unbindEvent("keyboard", keyName, "End", name)
end


-- wait for keys
function UserInput:waitForKeyDown(keyName, timeout)
	return waitForEvent("keyboard", keyName, "Begin", timeout)
end

function UserInput:waitForKeyUp(keyName, timeout)
	return waitForEvent("keyboard", keyName, "End")
end


-- fire keys
function UserInput:fireKeyDown(keyName, ...)
	fireEvent("keyboard", keyName, "Begin", ...)
end

function UserInput:fireKeyUp(keyName, ...)
	fireEvent("keyboard", keyName, "End", ...)
end


-----------------
--- MOUSE API ---
-----------------
-- @var args (...) = {name, function} of EventMaker:bind(name, function)

-- prototype
---------------------------
function UserInput:bindMouseInput(userInputType, state, ...)
	return bindEvent("mouse", userInputType.Name, state, ...)
end

function UserInput:unbindMouseInput(userInputType, state, name)
	unbindEvent("mouse", userInputType.Name, state, name)
end
---------------------------

-- bind buttons
function UserInput:bindMouse1Down(...)
	return bindEvent("mouse", "MouseButton1", "Begin", ...)
end

function UserInput:bindMouse2Down(...)
	return bindEvent("mouse", "MouseButton2", "Begin", ...)
end

function UserInput:bindMouse3Down(...)
	return bindEvent("mouse", "MouseButton3", "Begin", ...)
end

function UserInput:bindMouse1Up(...)
	return bindEvent("mouse", "MouseButton1", "End", ...)
end

function UserInput:bindMouse2Up(...)
	return bindEvent("mouse", "MouseButton2", "End", ...)
end

function UserInput:bindMouse3Up(...)
	return bindEvent("mouse", "MouseButton3", "End", ...)
end


-- unbind buttons
function UserInput:unbindMouse1Down(name)
	unbindEvent("mouse", "MouseButton1", "Begin", name)
end

function UserInput:unbindMouse2Down(name)
	unbindEvent("mouse", "MouseButton2", "Begin", name)
end

function UserInput:unbindMouse3Down(name)
	unbindEvent("mouse", "MouseButton3", "Begin", name)
end

function UserInput:unbindMouse1Up(name)
	unbindEvent("mouse", "MouseButton1", "End", name)
end

function UserInput:unbindMouse2Up(name)
	unbindEvent("mouse", "MouseButton2", "End", name)
end

function UserInput:unbindMouse3Up(name)
	unbindEvent("mouse", "MouseButton3", "End", name)
end


-- wait for buttons
function UserInput:waitForMouse1Down(timeout)
	return waitForEvent("mouse", "MouseButton1", "Begin", timeout)
end

function UserInput:waitForMouse2Down(timeout)
	return waitForEvent("mouse", "MouseButton2", "Begin", timeout)
end

function UserInput:waitForMouse3Down(timeout)
	return waitForEvent("mouse", "MouseButton3", "Begin", timeout)
end

function UserInput:waitForMouse1Up(timeout)
	return waitForEvent("mouse", "MouseButton1", "End", timeout)
end

function UserInput:waitForMouse2Up(timeout)
	return waitForEvent("mouse", "MouseButton2", "End", timeout)
end

function UserInput:waitForMouse3Up(timeout)
	return waitForEvent("mouse", "MouseButton3", "End", timeout)
end


-- fire buttons
function UserInput:fireMouse1Down(...)
	fireEvent("mouse", "MouseButton1", "Begin", ...)
end

function UserInput:fireMouse2Down(...)
	fireEvent("mouse", "MouseButton2", "Begin", ...)
end

function UserInput:fireMouse3Down(...)
	fireEvent("mouse", "MouseButton3", "Begin", ...)
end

function UserInput:fireMouse1Up(...)
	fireEvent("mouse", "MouseButton1", "End", ...)
end

function UserInput:fireMouse2Up(...)
	fireEvent("mouse", "MouseButton2", "End", ...)
end

function UserInput:fireMouse3Up(...)
	fireEvent("mouse", "MouseButton3", "End", ...)
end


-- Mouse input streams
function UserInput:bindMouseMovement(...)
	return bindEvent("mouse", "MouseMovement", "Change", ...)
end

function UserInput:unbindMouseMovement(...)
	return unbindEvent("mouse", "MouseMovement", "Change", ...)
end

function UserInput:bindMouseWheelForward(...)
	return bindEvent("mouse", "MouseWheelForward", "Change", ...)
end

function UserInput:bindMouseWheelBackward(...)
	return bindEvent("mouse", "MouseWheelBackward", "Change", ...)
end

function UserInput:unbindMouseWheelForward(...)
	unbindEvent("mouse", "MouseWheelForward", "Change", ...)
end

function UserInput:unbindMouseWheelBackward(...)
	unbindEvent("mouse", "MouseWheenBackward", "Change", ...)
end

function UserInput:waitForMouseWheelForward(timeout)
	return waitForEvent("mouse", "MouseWheelForward", "Change", timeout)
end

function UserInput:waitForMouseWheelBackward(timeout)
	return waitForEvent("mouse", "MouseWheelBackward", "Change", timeout)
end

function UserInput:waitForMouseMovement(timeout)
	return waitForEvent("mouse", "MouseMovement", "Change", timeout)
end

function UserInput:fireMouseMovement(...)
	fireEvent("mouse", "MouseMovement", "Change", ...)
end

function UserInput:fireMouseWheelForward(...)
	fireEvent("mouse", "MouseWheelForward", "Change", ...)
end

function UserInput:fireMouseWheelBackward(...)
	fireEvent("mouse", "MouseWheelBackward", "Change", ...)
end

--------------
--------------

local function handleInputState(inputObj, gameProcessed)
	local inputTypeVal = inputObj.UserInputType.Value
	local inputStateName = inputObj.UserInputState.Name
	local keyCode = inputObj.KeyCode

	if UserInput:isEnabled() then

		-- keyboard
		if inputTypeVal == 8 and UserInput._devices.keyboard:isEnabled() then

			fireEvent(
				"keyboard", keyCode.Name, inputStateName,
				gameProcessed, keyCode.Name
			)
			--UserInput:fireKeyboard(inputObj.KeyCode)

		-- mouse
		elseif inputTypeVal <= 3 and UserInput._devices.mouse:isEnabled() then

			fireEvent(
				"mouse", inputObj.UserInputType.Name, inputStateName,
				gameProcessed
			)
			--UserInput:fireMouse(gameProcessed, inputObj)

		end

		--UserInput:fire(gameProcessed, inputObj)

	end
end

local function handleInputChanged(inputObj, gameProcessed)
	local inputTypeVal = inputObj.UserInputType.Value
	--print(inputObj)

	if UserInput:isEnabled() then

		-- Mouse movement
		if inputTypeVal == 4 then
			fireEvent("mouse", "MouseMovement", "Change", gameProcessed, inputObj.Position)

		elseif inputTypeVal == 3 then

			if inputObj.Position.Z == 1 then
				fireEvent("mouse", "MouseWheelForward", "Change", gameProcessed)

			elseif inputObj.Position.Z == -1 then
				fireEvent("mouse", "MouseWheelBackward", "Change", gameProcessed)
			end

		end
	end

end

--------------
--------------

InputService.InputBegan:Connect(handleInputState)
InputService.InputEnded:Connect(handleInputState)
InputService.InputChanged:Connect(handleInputChanged)

--------------
--------------

return UserInput

--------------
--------------
