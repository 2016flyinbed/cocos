-----------------------------------------------------------------------------------------------  
-- @description ECS管理器
-- @author  liuyao
-- @release  2015/09/18
--------------------------------------------------------------------------------------------
local Registry = cc.Registry
local Entity = import(".ecs.Entity")

local M = class(...)

local n_globalEntityId = 1

function M:ctor(param)
	self._tlAdding = {}
	self._tlRemoving = {}
	self._tlHandling = {}
	self._tmEntities = {}

	-- 存储每个类型Com对应的所有Entity
	self._tmTlComEntities = {}
	self._tmSystemEntities = {}
	-- 类反射
	self._tmComClass = {}
	self._tmSystemClass = {}
end

function M:generateEntityId()
	n_globalEntityId = n_globalEntityId + 1
	return n_globalEntityId
end

function M:createEntity()
	local entity = Entity.new{
		id = self:generateEntityId()
	}
	table.insert(self._tlAdding, entity)
	return entity
end

function M:createEntityWithFile(fileName)

end

function M:removeEntity(entity)
	if not entity return end
	entity._isBeRemoving = true
	-- 加入待移除列表
	table.insert(self._tlRemoving, entity)
end

function M:update(dt)
	-- 加入上一帧或者其他待加入的游戏对象
	self:_addingEntities()
	-- 更新游戏对象(mark,bind scene)
	for _, entity in pairs(self._tmEntities) do
		-- if entity._isBeRemoving then

		for _, system in pairs(entity._tmSystems) do
			system:update(dt)
		end
	end
	-- 移除游戏对象
	self:_removingEntities()
end

function M:_addingEntities()

end

function M:_removingEntities()

end

function M:createCom(comName)
	return Registry.new(comName)
end

function M:addComToEntity(com, entity)
	if not com or not entity then return end
	-- 1 每种类型的com只能有一个实例
	if entity:getComByName(com:getName()) then
		return
	end

	entity._tmComs[com:getName()] = com
	com._ownEntity = entity
	-- 2 auto-attach System
	self:_autoAttachingSystem(com:getName(), entity)
end

function M:_autoAttachingSystem(comName, entity)
	for _, system in pairs(entity._tmSystems) do
		if system:getFirstType() == comName then
			return
		end
	end
	-- 注册表中查找
	for name, cls in pairs(Registry._tmClasses) do
		if cls._firstType == comName then
			local s = cls.new()
			entity._tmSystems[name] = s
			s._isFree = false
			s._entityManager = self
			s:onInit()
			s._ownEntity = entity
			s:onAttached()
			break
		end
	end
end

--getter/setter
function M:getAllEntitiesPossessCom(comName)
	return self._tmTlComEntities[comName]
end

return M