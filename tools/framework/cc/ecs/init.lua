-----------------------------------------------------------------------------------------------  
-- @description ECS初始化 
-- @author  liuyao
-- @release  2015/09/25
--------------------------------------------------------------------------------------------
print("===========================================================")
print("              LOAD ECS MODULE")
print("===========================================================")
local CURRENT_MODULE_NAME = ...
-- init ecs
local ecs = {}

------------------------------------------------
----------@ECS 常量
------------------------------------------------









------------------------------------------------
----------@ECS 组件系统
------------------------------------------------
-- 组件系统
ecs.Com = import(".Com")
ecs.System = import(".System")

local coms = {
	"coms.NodeCom",
}

local systems = {
	"systems.NodeSystem",

}

for _, packageName in ipairs(coms) do
	cc.Registry.add(import("."..packageName, CURRENT_MODULE_NAME))
end

for _, packageName in ipairs(systems) do
	cc.Registry.add(import("."..packageName, CURRENT_MODULE_NAME))
end




return ecs