local Registry = import(".Registry")

local M = {}

function M.extend(target)
	target.tmComs_ = {}
	function target:checkComponent(name)
		return self.tmComs_[name] ~= nil
	end

	function target:addComponent(name)
		local com = Registry.newObject(name)
		self.tmComs_[name] = com
		com:bind_(self)
		return com
	end

	function target:removeComponent(name)
		local com = self.tmComs_[name]
		if com then com:unbind_() end
		self.tmComs_[name] = nil
	end

	function target:getComponent(name)
		return self.tmComs_[name]
	end

	return target
end

return M