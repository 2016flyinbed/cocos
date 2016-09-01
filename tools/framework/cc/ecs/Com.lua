-----------------------------------------------------------------------------------------------  
-- @description 组件 
-- @author  liuyao
-- @release  2015/09/18
--------------------------------------------------------------------------------------------
--[[
@note:
 	Com只能包含纯数据(行为由System决定)
	Com表示一个行为"类型"，所有行为逻辑都以此类型为准
]]


local M = class(...)

function M:ctor(param)
	self._isCustom = false
	self._ownEntity = nil
end

function M:initWithTable(value)

end

function M:getComByName(s_name)
	if self._ownEntity then
		return self._ownEntity:getComByName(s_name)
	end
end

-- getter/setter
function M:getName()
	return self.__cname
end

function M:getEntity()
	return self._ownEntity
end

return M