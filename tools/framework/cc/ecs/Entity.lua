-----------------------------------------------------------------------------------------------  
-- @description 实体
-- @author  liuyao
-- @release  2015/09/18
--------------------------------------------------------------------------------------------
--[[
@note:
	Entity不能被继承
	Entity只能通过ECSManager来创建和删除，ECSManager负责Entity的Com和System附加管理，不能手动创建
	Entity仅表示一个Id,它可以用来表示游戏中的任何有意义的游戏对象，如button,hero,boss,tree等
	每个Entity包含或者不包含一个Node，所有的Entity对象是扁平的，但是Node的树形结构保持不变
]]

local NodeCom = import(".coms.NodeCom")

local M = class(...)

-- 必须由ECSManager创建
function M:ctor(param)
	assert(param and param.id, "param error:entity no id")
	self._id = param.id
	self._isBeRemoving = false
	self._tmComs = {}
	self._tmSystems = {}
end

function M:getComByName(s_name)
	return self._tmComs[s_name]
end

function M:getNode()
	local nodeCom = self:getComByName(NodeCom.__cname)
	if nodeCom then
		return nodeCom._node
	end
end

-- 同一类型组件当且仅当为1
function M:removeCom(s_name)
	local com = self:getComByName(s_name)
	if not com then
		--移除对应的System(one to more)
		local tm = {}
		for name, system in pairs(self._tmSystems) do
			if system:getFirstType() == s_name then
				system:onDeattached()
			else
				tm[name] = system
			end
		end

		self._tmSystems = tm
		self._tmComs[s_name] = nil
	end
end

function M:removeAllComs()
	repeat
		for name in pairs(self._tmComs) do
			self:removeCom(name)
		end
	until not next(self._tmComs)
end

function M:comsChanged()
	for _,system in pairs(self._tmSystems) do
		system:onComsChanged()
	end
end

function M:sendEvent(eventName)
	for _,system in pairs(self._tmSystems) do
		system:onEntityEvent(eventName)
	end
end

function M:isEqual(entity)
	return self._id == entity._id
end

--对象桶式更新
function M:setBucket(n_bucket)

end

function M:getParent()

end

--@ getter/setter
function M:getIsRemoving()
	return self._isBeRemoving
end

function M:getId()
	return self._id
end


return M