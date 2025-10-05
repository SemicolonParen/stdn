-- stdn.thread: Threading and concurrency utilities
-- Provides cooperative threading via coroutines

local thread_utils = {}

-- Thread handle
local Thread = {}
Thread.__index = Thread

-- Create a new thread from function
function thread_utils.spawn(fn, ...)
    local self = setmetatable({}, Thread)
    self._coroutine = coroutine.create(fn)
    self._args = {...}
    self._started = false
    self._finished = false
    self._result = nil
    self._error = nil
    return self
end

-- Resume thread
function Thread:resume()
    if self._finished then
        return false
    end

    local args = self._args
    self._args = nil
    self._started = true

    local success, result = coroutine.resume(self._coroutine, table.unpack(args or {}))

    if not success then
        self._error = result
        self._finished = true
        return false
    end

    if coroutine.status(self._coroutine) == "dead" then
        self._result = result
        self._finished = true
    end

    return true
end

-- Check if thread is finished
function Thread:is_finished()
    return self._finished
end

-- Get thread result (blocks until finished)
function Thread:join()
    while not self._finished do
        if not self:resume() then
            break
        end
    end

    if self._error then
        error(self._error)
    end

    return self._result
end

-- Yield from thread
function thread_utils.yield(...)
    return coroutine.yield(...)
end

-- Get current thread
function thread_utils.current()
    return coroutine.running()
end

-- Channel for thread communication
local Channel = {}
Channel.__index = Channel

function thread_utils.channel(capacity)
    local self = setmetatable({}, Channel)
    self._queue = {}
    self._capacity = capacity or math.huge
    self._closed = false
    return self
end

function Channel:send(value)
    if self._closed then
        error("cannot send on closed channel")
    end

    if #self._queue >= self._capacity then
        error("channel is full")
    end

    table.insert(self._queue, value)
end

function Channel:try_send(value)
    if self._closed then
        return false
    end

    if #self._queue >= self._capacity then
        return false
    end

    table.insert(self._queue, value)
    return true
end

function Channel:receive()
    if #self._queue == 0 then
        if self._closed then
            return nil
        end
        error("channel is empty")
    end

    return table.remove(self._queue, 1)
end

function Channel:try_receive()
    if #self._queue == 0 then
        return nil
    end

    return table.remove(self._queue, 1)
end

function Channel:close()
    self._closed = true
end

function Channel:is_closed()
    return self._closed
end

function Channel:is_empty()
    return #self._queue == 0
end

function Channel:len()
    return #self._queue
end

-- Thread pool
local ThreadPool = {}
ThreadPool.__index = ThreadPool

function thread_utils.thread_pool(size)
    local self = setmetatable({}, ThreadPool)
    self._threads = {}
    self._tasks = {}
    self._size = size
    return self
end

function ThreadPool:submit(fn, ...)
    local args = {...}
    table.insert(self._tasks, {fn = fn, args = args})
end

function ThreadPool:run()
    while #self._tasks > 0 do
        local available_slots = self._size - #self._threads

        for i = 1, math.min(available_slots, #self._tasks) do
            local task = table.remove(self._tasks, 1)
            local thread = thread_utils.spawn(task.fn, table.unpack(task.args))
            table.insert(self._threads, thread)
        end

        local i = 1
        while i <= #self._threads do
            local thread = self._threads[i]

            if not thread:resume() then
                table.remove(self._threads, i)
            else
                i = i + 1
            end
        end
    end

    while #self._threads > 0 do
        local i = 1
        while i <= #self._threads do
            local thread = self._threads[i]

            if not thread:resume() then
                table.remove(self._threads, i)
            else
                i = i + 1
            end
        end
    end
end

-- Mutex for synchronization
local Mutex = {}
Mutex.__index = Mutex

function thread_utils.mutex()
    local self = setmetatable({}, Mutex)
    self._locked = false
    return self
end

function Mutex:lock()
    while self._locked do
        thread_utils.yield()
    end
    self._locked = true
end

function Mutex:try_lock()
    if self._locked then
        return false
    end
    self._locked = true
    return true
end

function Mutex:unlock()
    self._locked = false
end

function Mutex:is_locked()
    return self._locked
end

-- Execute function with mutex locked
function Mutex:with_lock(fn)
    self:lock()
    local success, result = pcall(fn)
    self:unlock()

    if not success then
        error(result)
    end

    return result
end

-- Atomic reference
local Atomic = {}
Atomic.__index = Atomic

function thread_utils.atomic(initial_value)
    local self = setmetatable({}, Atomic)
    self._value = initial_value
    self._mutex = thread_utils.mutex()
    return self
end

function Atomic:load()
    return self._value
end

function Atomic:store(value)
    self._mutex:lock()
    self._value = value
    self._mutex:unlock()
end

function Atomic:swap(value)
    self._mutex:lock()
    local old = self._value
    self._value = value
    self._mutex:unlock()
    return old
end

function Atomic:compare_and_swap(expected, new)
    self._mutex:lock()
    local success = self._value == expected
    if success then
        self._value = new
    end
    self._mutex:unlock()
    return success
end

function Atomic:fetch_add(delta)
    self._mutex:lock()
    local old = self._value
    self._value = self._value + delta
    self._mutex:unlock()
    return old
end

function Atomic:fetch_sub(delta)
    return self:fetch_add(-delta)
end

-- Barrier for synchronization
local Barrier = {}
Barrier.__index = Barrier

function thread_utils.barrier(count)
    local self = setmetatable({}, Barrier)
    self._count = count
    self._waiting = 0
    return self
end

function Barrier:wait()
    self._waiting = self._waiting + 1

    if self._waiting >= self._count then
        self._waiting = 0
        return true
    end

    while self._waiting < self._count do
        thread_utils.yield()
    end

    return false
end

-- Once flag for one-time initialization
local Once = {}
Once.__index = Once

function thread_utils.once()
    local self = setmetatable({}, Once)
    self._called = false
    self._mutex = thread_utils.mutex()
    return self
end

function Once:call_once(fn)
    if self._called then
        return
    end

    self._mutex:lock()

    if not self._called then
        fn()
        self._called = true
    end

    self._mutex:unlock()
end

return thread_utils
