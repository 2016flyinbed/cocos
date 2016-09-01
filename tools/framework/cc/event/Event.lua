-----------------------------------------------------------------------------------------------  
-- @description 事件
-- @author  liuyao
-- @release  2015/10/03
--------------------------------------------------------------------------------------------
--[[
--@note:
 	Event只能包含纯数据
]]

local M = class(...)

function M:ctor(param)
	self._name = nil
	self._data = nil
	self._isStopped = false
end

function M:isStopped()
	return self._isStopped
end

function M:stopPropagation()
	self._isStopped = true
end

-- getter/setter
function M:setData(data)
	self._data = data
end

function M:getData()
	return self._data
end

function M:getName()
	return self._name
end

function M:setName(name)
	self._name = name
end


return M