
-- dispatcher
local M = {}
M.__index = M

function M.new(o)
	o = o or {
		reftime = os.time(),
		tasks = {}
	}
	setmetatable(o, M)
	return o
end

function M:addTask(name, task)
	local t = {
		name = name,
		status = "awake",
		co = coroutine.create(task),
		sender = nil,
		message = nil,
		wakeuptime = 0,
	}
	self.tasks[name] = t
	self.active = t
	coroutine.resume(t.co, self)
end

function M:loop()
	repeat
		self.currTime = os.difftime(os.time(), self.reftime)
		for name, task in pairs(self.tasks) do
			if task.status == "awake" then
				self:execute(task)
			elseif task.status == "sleeping" then
				if self.wakeuptime <= self.currTime then
					self.status = "awake"
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
	local ok, errmsg = coroutine.resume(task.co, task.sender, task.message)
	if not ok then
		error(errmsg)
	end
	if coroutine.status(task.co) == "dead" then
		self.tasks[task.name] = nil
	end
end

function M:transfer(receiver, message)
	if receiver and self.tasks[receiver] then
		local task = self.active
		self.tasks[receiver].sender = task.name
		self.tasks[receiver].message = message
		if self.tasks[receiver].status == "waiting" then
			self.tasks[receiver].status = "awake"
		end
	end
	return coroutine.yield()
end

function M:wait()
	local task = self.active
	task.status = "waiting"
	return coroutine.yield()
end

function M:sleep(dtime)
	local task = self.active
	self.wakeuptime = self.currTime + dtime
	self.status = "sleeping"
	return coroutine.yield()
end


-- simple test
local Character = function(dispatcher)
	local sender, message = dispatcher:wait()
	local reply = {
		hi = "Hi",
		who = "I am a scripter",
		advice = "Try Lua"
	}
	while message ~= "bye" do
		if message == "sleep" then
			io.write("Zzz\n")
			sender, message = dispatcher:sleep(10)
		else
			local answer = reply[message] or "Sorry?"
			sender, message = dispatcher:transfer(sender, answer)
		end
	end
end

local Player = function(dispatcher)
	local sender, message = dispatcher:transfer()
	while true do
		if sender then
			io.write(sender, ": ", message, "\n")
		end
		io.write("Player :")
		local line = io.read()
		if "pause" == line then
			sender, message = dispatcher:sleep(5)
		else
			sender, message = dispatcher:transfer("Character", line)
		end 
		if line == "bye" then
			return
		end
	end
end

local d = M.new()
d:addTask("Character", Character)
d:addTask("Player", Player)
d:loop()
return M

