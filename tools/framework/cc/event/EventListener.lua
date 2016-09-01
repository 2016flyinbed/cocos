-----------------------------------------------------------------------------------------------  
-- @description 事件收听者
-- @author  liuyao
-- @release  2015/10/03
--------------------------------------------------------------------------------------------
--[[
--@note:
 	EventListener表示一个行为的逻辑，它唯一对应一个Event
]]

local M = class(...)

function M:ctor(param)
	assert( param and param.name, "param error: eventlistener no name")
	self._name = param.name
	self._callback = param.callback
	self._priority = 0
	self._isRegistered = false
	self._isEnabled = true
end

--@public:
function M:checkAvailable()
	return self._callback ~= nil
end

function M:onEvent(event)
	if self._callback then
		self._callback(event)
		return event:isStopped()
	end
end

function M:setCallback(callback)
	self._callback = callback
end

function M:getName()
	return self._name
end


function M:isEnabled()
	return self._isEnabled
end

function M:setEnabled(isEnabled)
	self._isEnabled = isEnabled
end

--@private:
function M:setRegistered(isRegistered)
	self._isRegistered = isRegistered
end

function M:isRegistered()
	return self._isRegistered
end

-- 值越小优先级越高(通过EventMgr设置)
function M:setPriority(priority)
	self._priority = priority
end

function M:getPriority()
	return self._priority
end


return M