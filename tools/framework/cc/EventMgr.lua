-----------------------------------------------------------------------------------------------  
-- @description 即时事件系统
-- @author  liuyao
-- @release  2015/10/03
--------------------------------------------------------------------------------------------
--[[
--@note:
	扩展cocos中的EventCustom:即时事件
	保留cocos中其他的触摸事件(
		TOUCH,KEYBOARD,ACCELERATION,
	    MOUSE,FOCUS,GAME_CONTROLLER,
    )
]]
local Event = import(".event.Event")
local EventListener = import(".event.EventListener")

local M = class(...)

function M:ctor(param)
	self._inDispatch = 0
	self._isEnabled = true
	self._tmTlListener = {}	

	-- 派发中增加
	self._tlAddListener = {}

	-- 减少排序次数
	self._tmDirtyListener = {}
end

function M:addEventListener(listener, priority)
	assert(not listener:isRegistered(), "error:listener has been registered")
	priority = priority or 1
	if not listener:checkAvailable() then
		return
	end
	listener:setPriority(priority)
	listener:setRegistered(true)
	-- listener:setTarget()
	if self._inDispatch == 0 then -- 不在派发中
		self:forceAddEventListener(listener)
	else
		table.insert(self._tlAddListener, listener)
	end
end

function M:forceAddEventListener(listener)
	local listenerId = listener:getName()
	local tlListener = self._tmTlListener[listenerId]
	if not tlListener then
		tlListener = {}
		self._tmTlListener[listenerId] = tlListener
	end
	table.insert(tlListener, listener)
	self:setDirty(listenerId)
end

function M:setDirty(listenerId)
	self._tmDirtyListener[listenerId] = true
end

-- 容错cocos
function M:dispatchEvent(event)
	if not self._isEnabled then
		return
	end
	-- 设置哨兵
	self._inDispatch = self._inDispatch + 1

	local listenerId = event:getName()
	self:sortEventListeners(listenerId)

	-- 兼容cocos
	local tlListener = self._tmTlListener[listenerId]
	
	if tlListener then
		-- local shouldStopPropagation = false
		for _, l in ipairs(tlListener) do
			if l:isEnabled() and l:isRegistered() and l:onEvent(event) then
				-- shouldStopPropagation = true
				break
			end
		end
	else
		-- 使用cocos派发(兼容cocos)
		self:dispatchEventOnCocos(event)
	end

	self:updateListeners(event)

	self._inDispatch = self._inDispatch - 1
end

-- 仅仅为兼容
function M:dispatchEventOnCocos(event)
	print("warning : event is not Found, we use cocos EventDispatcher instead")
	print(debug.traceback())
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:dispatchEvent(cc.EventCustom:new(event:getName()))
end

function M:sortEventListeners(listenerId)
	if self._tmDirtyListener[listenerId] then -- 优化
		self._tmDirtyListener[listenerId] = false
		local tlListener = self._tmTlListener[listenerId]
		if not tlListener then
			return
		end
		table.sort(tlListener, function(l1, l2)
			return l1:getPriority() < l2:getPriority()
		end)
	end
end

function M:updateListeners(event)
	if self._inDispatch > 1 then
		return
	end

	local tlListener = self._tmTlListener[event:getName()] or {}

	-- handle remove
	--fix me:删除较大数据量时,创建一个新表解除旧表的引用比较靠谱
	for i = #tlListener, 1 -1 do
		if not tlListener[i]:isRegistered() then
			table.remove(tlListener, i)
		end
	end 

	-- 检测
	for listenerId, v in pairs(self._tmTlListener) do
		if not next(v) then
			self._tmDirtyListener[listenerId] = nil
			self._tmTlListener[listenerId] = nil
		end
	end

	-- handle add
	for _, l in ipairs(self._tlAddListener) do
		self:forceAddEventListener(listener)
	end
	self._tlAddListener = {}
end

function M:removeEventListener(listener)
	if not listener then
		return
	end

	local isFound = false

	local function remove(tlListener)
		for i = #tlListener, 1, -1 do
			if tlListener[i] == listener then -- 比较地址
				l:setRegistered(false)
				if self._inDispatch == 0 then
					table.remove(tlListener, i)
				end
				isFound = true
				break
			end
		end
	end

	for _, tl in pairs(self._tmTlListener) do
		remove(tl)
		if isFound then
			self:setDirty(listener:getName())
		end

		if not next(tl) then
			self._tmDirtyListener[listener:getName()] = nil
			self._tmTlListener[listener:getName()] = nil
		end

		if isFound then
			break
		end
	end

	-- _tlAddListener中找
	if not isFound then
		for i, l in ipairs(self._tlAddListener) do
			if l == listener then
				listener:setRegistered(false)
				table.remove(self._tlAddListener, i)
				break
			end
		end
	end
end

function M:removeEventListenerByListenerId(listenerId)
	local tlListener = self._tmTlListener[listenerId] or {}

	for _, l in ipairs(tlListener) do
		l:setRegistered(false)
		-- if self._inDispatch == 0 then--不在派发

		-- end
	end

	-- remove dirty listener according the 'listenerId'
	-- No need to check whether the dispatcher is dispatching event.
	self._tmDirtyListener[listenerId] = nil
	-- not dispatching event
	if self._inDispatch == 0 then
		self._tmTlListener[listenerId] = nil
	end

	-- remove add listener, same to dirty listener
	for i = #self._tlAddListener, 1, -1 do
		if l:getName() == listenerId then
			l:setRegistered(false)
			table.remove(self._tlAddListener, i)
		end
	end
end

function M:removeAllEventListeners()
	for listenerId, tl in pairs(self._tmTlListener) do
		self:removeEventListenerByListenerId(listenerId)
	end
end

function M:setPriority(listener, priority)
	if not listener then
		return
	end

	for _, tl in pairs(self._tmTlListener) do
		for _, l in ipairs(tl) do
			if l == listener then
				if l:getPriority() ~= priority then
					listener:setPriority(priority)
					self:setDirty(listener:getName())
					return
				end
			end
		end
	end	
end

-- getter/setter
function M:getListeners()
	return self._listeners
end

function M:setEnabled(isEnabled)
	self._isEnabled = isEnabled
end

function M:getEnabled()
	return self._isEnabled
end



return M