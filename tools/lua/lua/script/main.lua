print("===========Test========")

print("add(10,20)=", add(10,20))

t = {
	x=40
}

function f(str, x, y)
	print("str, x, y = ", str, x, y)
	return x - y
end

--a = f("hello world", t.x , 10)

local function uv()
    func = newCounter();
    print(func());
    print(func());
    print(func());
 
    func = newCounter();
    print(func());
    print(func());
    print(func());
end

xpcall(uv, print)

local t = {"zhangsan", "lisi", "wangwu", "liubei", "guanyu"}
tbl2Vec(t)

function createTable(t)
	for i,v in ipairs(t) do
		print("i=",i,"v=",v)
	end
	return {
		"zhanliao",
		"yuejin",
		"yujin",
		"zhanhe",
		"xuhuang"
	}
end

--[[
function newCounter()
	local i = 0
	return function ()
		i = i + 1
		return i
	end
end
--]]
--[[
require envTest
local function env()
	local str = "env test"
	envTest.setValue(str)
	print(envTest.getValue())
end

xpcall(env, print)
--]]