-----------------------------------------------------------------------------------------------  
-- @description 系统
-- @author  liuyao
-- @release  2015/09/18
--------------------------------------------------------------------------------------------
--[[
--@note:
 	System表示一个行为的逻辑，它唯一对应一个Com(one to one)
	System被ECSManager根据Entity是否具有某个Com自动附加System，ECSManager在Com变动的时候通知System
	@note:
		onInit()
		onAttached()
		onComsChanged()
		onDeattached()
]]

local M = class(...)

M._firstType = "DEFAULT_TYPE"
-- 响应Com的类型
-- ECSManager以此来决定当Com被添加或移除的时候要附加或移除哪些System
function M.getFirstType()
	return M._firstType
end

function M.setFirstType(s_firstType)
	M._firstType = s_firstType
end

function M:ctor(param)
	self._priority = 0
	self._isFree = true
	self._isCustom = false
	self._ownEntity = nil
	self._entityManager = nil
end

-- 生命周期
-- 当attach到一个Entity之后，每帧被调用
function M:update(dt)

end

-- 该方法在每次被attach之前总会执行
function M:onInit()

end

-- Entity有组件发生变动时触发
-- System应该始终在这个时候获取需要使用的Com的引用，以减少每帧查找Com
function M:onComsChanged()

end

-- 被附加到一个Entity时触发
-- 这里可以执行事件订阅等事情，这里可以调用getNode，如果存在的话(NodeCom会始终被第一个附加)
function M:onAttached()

end

function M:onDeattached()

end

function M:getNode()
	if self._ownEntity then
		return self._ownEntity:getNode()
	end
end

function M:getComByName(s_name)
	if self._ownEntity then
		return self._ownEntity:getComByName(s_name)
	end
end

-- getter/setter
function M:getEntity()
	return self._ownEntity
end

function M:getName()
	return self.__cname
end

-- 每个Entity中System被执行的顺序,它保证一些逻辑按正确的顺序被执行，尤其对同一Com读取数据
function M:getPriority()
	return self._priority
end

-- Touch 相关
function M:isTouchEnabled()
	return self._touchEnabled
end

function M:setTouchEnabled(enabled)
	if self._touchEnabled ~= enabled then
		self._touchEnabled = enabled
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		if enabled then
			if self._touchListener then
				return
			end
			-- multiply
			if self._touchMode == cc.TOUCH_MODE_ALL_AT_ONCE then
				local listener = cc.EventListenerTouchAllAtOnce:create()
				listener:registerScriptHandler
			end
		else
			eventDispatcher:removeEventListener(self._touchListener)
		end
	end
end

function M:getTouchMode()

end

function M:setTouchMode(mode)

end

function M:isSwallowsTouches()

end

function M:setSwallowsTouches(swallowsTouches)

end

return M