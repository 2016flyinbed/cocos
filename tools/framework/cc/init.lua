-----------------------------------------------------------------------------------------------  
-- @description 初始化 
-- @author  liuyao
-- @release  2015/09/25
--------------------------------------------------------------------------------------------
-- init base classes
cc.Registry = import(".Registry")

-- init event
cc.event = import(".event.init")

-- init ecs
cc.ecs = import(".ecs.init")