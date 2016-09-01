local M = class(...)

M.tmCls_ = {}
M.tmObjs_ = {}

function M.add(cls, name)
    assert(type(cls) == "table" and cls.__cname ~= nil, "Registry.add() - invalid class")
	if not name then name = cls.__cname end
    assert(M.tmCls_[name] == nil, string.format("Registry.add() - class \"%s\" already exists", tostring(name)))
    M.tmCls_[name] = cls
end

function M.remove(name)
	assert(M.tmCls_[name] ~= nil, string.format("Registry.remove() - class \"%s\" not found", name))
	M.tmCls_[name] = nil
end

function M.exists(name)
	return M.tmCls_[name] ~= nil
end

function M.newObject(name, ...)
	local cls = M.tmCls_[name]
	if not cls then
		pcall(function()
			cls = require(name)
			M.add(cls, name)
		end)
	end
    assert(cls ~= nil, string.format("Registry.newObject() - invalid class \"%s\"", tostring(name)))
	return cls.new(...)
end

function M.setObject(obj, name)
	assert(M.tmObjs_[name] == nil, string.format("Registry.setObject() - object \"%s\" already exists", tostring(name)))
    M.tmObjs_[name] = obj
end

function M.getObject(name)
    assert(M.tmObjs_[name] ~= nil, string.format("Registry.getObject() - object \"%s\" not exists", tostring(name)))
	return M.tmObjs_[name]
end

function M.removeObject(name)
    assert(M.tmObjs_[name] ~= nil, string.format("Registry.removeObject() - object \"%s\" not exists", tostring(name)))
    M.tmObjs_[name] = nil
end

function M.isObjExists(name)
	return M.tmObjs_[name] ~= nil
end

return M