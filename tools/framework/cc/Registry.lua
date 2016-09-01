-----------------------------------------------------------------------------------------------  
-- @description  注册表
-- @author  liuyao
-- @release  2015/09/24
--------------------------------------------------------------------------------------------
--[[
@note:
	注册com和system,用于支持反射
]]
local M = class(...)

M._tmClasses = {}

function M.add(cls, name)
	assert(cls and cls.__cname, "param error: no cls")
	name = name or cls.__cname
	M._tmClasses[name] = cls
end

function M.remove(name)
	assert(name, "param error: no name")
	M._tmClasses[name] = nil
end

function M.exists(name)
	return M._tmClasses[name] ~= nil
end

function M.newObj(name, ...)
	local cls = M._tmClasses[name]
	if not cls then
		-- auto load
		pcall(function()
			cls = require(name)
			M.add(cls, name)
		end)
	end
	return cls.new(...)
end

return M