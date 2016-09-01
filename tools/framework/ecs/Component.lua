local M = class(...)

function M:ctor(name, depends)
	self.name_ = name
	self.depends_ = checktable(depends)
end

function M:getName()
	return self.name_
end

function M:getDepends()
	return self.depends_
end

function M:getTarget()
	return self.target_
end

function M:exportMethods_(methods)
	self.exportMethods_ = methods
	local target = self.target_
	local com = self
	for _, key in ipairs(methods) do
		if not target[key] then
			local m = com[key]
			target[key] = function(_, ...)
				return m(com, ...)
			end
		end
	end
	return self
end

function M:bind_(target)
	self.target_ = target
	for _, name in ipairs(self.depends_) do
		if not target:checkComponent(name) then
			target:addComponent(name)
		end
	end
	self:onBind_(target)
end

function M:unbind_()
	if self.exportMethods_ then
		local target = self.target_
		for _, key in ipairs(self.exportMethods_) do
			target[key] = nil
		end
	end
	self:onUnbind_()
end

----------------------
-- @note:
-- 派生类需要覆盖接收事件消息
-- overrided by derived cls
-----------------------
function M:onBind_(target)
end

function M:onUnbind_()
end

function M:onUpdate(dt)

end

return M