-----------------------------------------------------------------------------------------------  
-- @description 任务安排
-- @author  liuyao
-- @release  2015/10/02
--------------------------------------------------------------------------------------------
--[[
--@note:
	协程实现多任务安排
	事件排队
]]

local M = class(...)

function M:ctor(param)
	self.tasks = {}
	self.reftime = os.time()
end

function M:addTask(name, task)
	local t = {
		name = name,
		status = "awake",
		co = coroutine.create(task),
		wakeuptime = 0,
		sender = nil,
		message = nil,
	}
	self.tasks[name] = t
	self.active = t
	coroutine.resume(t.co, self)
end

function M:loop()
	repeat 
		self.currtime = os.difftime(os.time(),self.reftime)
        for name,task in pairs(self.tasks) do
            if task.status == "awake" then
                self:execute(task)
            elseif task.status == "sleeping" then
                if task.wakeuptime <= self.currtime then
                    task.status = "awake"
                    self:execute(task)
                end
            end
            task.sender = nil
            task.message = nil
       	end	
    until not next(self.tasks)
end

function M:execute(task)
	self.active = task
	local ok, errmsg = 
		coroutine.resume(t.co, task.sender, task.message)
	if not ok then
		print("errmsg:", errmsg)
	end
	if coroutine.status(task.co) == "dead" then
		self.tasks[task.name] = nil
	end
end

function M:transfer(receiver, message)
	if receiver and self.tasks[receiver] then
		local task = self.active
		self.tasks[receiver].sender = task.name
		self.tasks[receiver].message = task.message
		-- 等待即激活
		if self.tasks[receiver].status == "waiting" then
			self.tasks[receiver].status = "awake"
		end
	end
	return coroutine.yield()
end

function M:sleep(dt)
	local task = self.active
	task.wakeuptime = self.currtime + dt
	task.status = "sleeping"
	return coroutine.yield()
end

function M:wait()
	local task = self.active
	task.status = "waiting"
	return coroutine.yield()
end

return M