-- stdn.time: Time and duration utilities
-- Provides time measurement and formatting

local time_utils = {}

-- Duration type
local Duration = {}
Duration.__index = Duration

-- Create duration from seconds
function time_utils.from_secs(secs)
    local self = setmetatable({}, Duration)
    self._secs = secs
    return self
end

-- Create duration from milliseconds
function time_utils.from_millis(millis)
    return time_utils.from_secs(millis / 1000)
end

-- Create duration from microseconds
function time_utils.from_micros(micros)
    return time_utils.from_secs(micros / 1000000)
end

-- Create duration from nanoseconds
function time_utils.from_nanos(nanos)
    return time_utils.from_secs(nanos / 1000000000)
end

-- Get duration as seconds
function Duration:as_secs()
    return self._secs
end

-- Get duration as milliseconds
function Duration:as_millis()
    return self._secs * 1000
end

-- Get duration as microseconds
function Duration:as_micros()
    return self._secs * 1000000
end

-- Get duration as nanoseconds
function Duration:as_nanos()
    return self._secs * 1000000000
end

-- Add durations
function Duration:__add(other)
    return time_utils.from_secs(self._secs + other._secs)
end

-- Subtract durations
function Duration:__sub(other)
    return time_utils.from_secs(self._secs - other._secs)
end

-- Multiply duration by scalar
function Duration:__mul(scalar)
    return time_utils.from_secs(self._secs * scalar)
end

-- Divide duration by scalar
function Duration:__div(scalar)
    return time_utils.from_secs(self._secs / scalar)
end

-- Compare durations
function Duration:__eq(other)
    return self._secs == other._secs
end

function Duration:__lt(other)
    return self._secs < other._secs
end

function Duration:__le(other)
    return self._secs <= other._secs
end

-- String representation
function Duration:__tostring()
    local s = self._secs

    if s < 0.000001 then
        return string.format("%.0fns", s * 1000000000)
    elseif s < 0.001 then
        return string.format("%.2fµs", s * 1000000)
    elseif s < 1 then
        return string.format("%.2fms", s * 1000)
    elseif s < 60 then
        return string.format("%.2fs", s)
    elseif s < 3600 then
        local mins = math.floor(s / 60)
        local secs = s % 60
        return string.format("%dm %.2fs", mins, secs)
    else
        local hours = math.floor(s / 3600)
        local mins = math.floor((s % 3600) / 60)
        local secs = s % 60
        return string.format("%dh %dm %.2fs", hours, mins, secs)
    end
end

-- Instant type (point in time)
local Instant = {}
Instant.__index = Instant

-- Get current instant
function time_utils.now()
    local self = setmetatable({}, Instant)
    self._time = os.clock()
    return self
end

-- Get system time (Unix timestamp)
function time_utils.system_time()
    return os.time()
end

-- Get elapsed duration since instant
function Instant:elapsed()
    return time_utils.from_secs(os.clock() - self._time)
end

-- Duration between two instants
function Instant:duration_since(earlier)
    return time_utils.from_secs(self._time - earlier._time)
end

-- Add duration to instant
function Instant:__add(duration)
    local new_instant = time_utils.now()
    new_instant._time = self._time + duration:as_secs()
    return new_instant
end

-- Subtract duration from instant
function Instant:__sub(other)
    if getmetatable(other) == Instant then
        return time_utils.from_secs(self._time - other._time)
    else
        local new_instant = time_utils.now()
        new_instant._time = self._time - other:as_secs()
        return new_instant
    end
end

-- Stopwatch for timing
local Stopwatch = {}
Stopwatch.__index = Stopwatch

function time_utils.stopwatch()
    local self = setmetatable({}, Stopwatch)
    self._start = nil
    self._elapsed = 0
    self._running = false
    return self
end

function Stopwatch:start()
    if not self._running then
        self._start = os.clock()
        self._running = true
    end
end

function Stopwatch:stop()
    if self._running then
        self._elapsed = self._elapsed + (os.clock() - self._start)
        self._running = false
    end
end

function Stopwatch:reset()
    self._elapsed = 0
    self._start = nil
    self._running = false
end

function Stopwatch:restart()
    self:reset()
    self:start()
end

function Stopwatch:elapsed()
    local current = self._elapsed
    if self._running then
        current = current + (os.clock() - self._start)
    end
    return time_utils.from_secs(current)
end

function Stopwatch:is_running()
    return self._running
end

-- Measure execution time of function
function time_utils.measure(fn, ...)
    local start = time_utils.now()
    local results = {fn(...)}
    local duration = start:elapsed()
    return duration, table.unpack(results)
end

-- Sleep for duration (busy wait, not efficient)
function time_utils.sleep(duration)
    local start = os.clock()
    local target = start + duration:as_secs()
    while os.clock() < target do
        -- Busy wait
    end
end

-- Format time
function time_utils.format_time(timestamp, format)
    format = format or "%Y-%m-%d %H:%M:%S"
    return os.date(format, timestamp)
end

-- Parse date components
function time_utils.date(timestamp)
    timestamp = timestamp or os.time()
    return os.date("*t", timestamp)
end

-- Get current date components
function time_utils.local_time()
    return os.date("*t")
end

-- Get UTC date components
function time_utils.utc_time()
    return os.date("!*t")
end

-- Days between two timestamps
function time_utils.days_between(ts1, ts2)
    local diff = math.abs(ts2 - ts1)
    return math.floor(diff / 86400)
end

-- Is leap year
function time_utils.is_leap_year(year)
    return (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
end

-- Days in month
function time_utils.days_in_month(year, month)
    local days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    if month == 2 and time_utils.is_leap_year(year) then
        return 29
    end
    return days[month]
end

-- Timeout helper
local Timeout = {}
Timeout.__index = Timeout

function time_utils.timeout(duration)
    local self = setmetatable({}, Timeout)
    self._deadline = time_utils.now() + duration
    return self
end

function Timeout:is_expired()
    return time_utils.now() >= self._deadline
end

function Timeout:remaining()
    local now = time_utils.now()
    if now >= self._deadline then
        return time_utils.from_secs(0)
    end
    return self._deadline - now
end

-- Retry with timeout
function time_utils.retry_with_timeout(fn, duration, interval)
    local timeout = time_utils.timeout(duration)
    interval = interval or time_utils.from_millis(100)

    while not timeout:is_expired() do
        local success, result = pcall(fn)
        if success then
            return result
        end
        time_utils.sleep(interval)
    end

    error("operation timed out")
end

-- Benchmark function
function time_utils.benchmark(fn, iterations)
    iterations = iterations or 1000
    local times = {}

    for i = 1, iterations do
        local duration = time_utils.measure(fn)
        times[i] = duration:as_secs()
    end

    table.sort(times)

    local sum = 0
    for _, t in ipairs(times) do
        sum = sum + t
    end

    local mean = sum / iterations
    local median = times[math.floor(iterations / 2)]
    local min = times[1]
    local max = times[iterations]

    return {
        iterations = iterations,
        mean = time_utils.from_secs(mean),
        median = time_utils.from_secs(median),
        min = time_utils.from_secs(min),
        max = time_utils.from_secs(max)
    }
end

return time_utils
