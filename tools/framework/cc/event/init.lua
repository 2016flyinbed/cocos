-----------------------------------------------------------------------------------------------  
-- @description Event初始化 
-- @author  liuyao
-- @release  2015/09/25
--------------------------------------------------------------------------------------------
--[[
--@note:
	事件系统独立ECS最大程度降低耦合性
]]

-- init event
local event = {}

event.Event = import(".Event")
event.EventListener = import(".EventListener")

return event