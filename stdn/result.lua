-- stdn.result: Result<T, E> type for error handling
-- Provides Rust-like Result enum for explicit error handling

local result = {}

local Result = {}
Result.__index = Result

-- Result type enum
local ResultType = {
    OK = "Ok",
    ERR = "Err"
}

-- Create an Ok variant
function result.Ok(value)
    local self = setmetatable({}, Result)
    self._type = ResultType.OK
    self._value = value
    return self
end

-- Create an Err variant
function result.Err(error)
    local self = setmetatable({}, Result)
    self._type = ResultType.ERR
    self._error = error
    return self
end

-- Check if Result is Ok
function Result:is_ok()
    return self._type == ResultType.OK
end

-- Check if Result is Err
function Result:is_err()
    return self._type == ResultType.ERR
end

-- Unwrap the value, panic if Err
function Result:unwrap()
    if self:is_ok() then
        return self._value
    else
        error(string.format("called `Result:unwrap()` on an `Err` value: %s", tostring(self._error)))
    end
end

-- Unwrap the error, panic if Ok
function Result:unwrap_err()
    if self:is_err() then
        return self._error
    else
        error("called `Result:unwrap_err()` on an `Ok` value")
    end
end

-- Unwrap or return default value
function Result:unwrap_or(default)
    if self:is_ok() then
        return self._value
    else
        return default
    end
end

-- Unwrap or compute default value from function
function Result:unwrap_or_else(fn)
    if self:is_ok() then
        return self._value
    else
        return fn(self._error)
    end
end

-- Expect with custom panic message
function Result:expect(msg)
    if self:is_ok() then
        return self._value
    else
        error(string.format("%s: %s", msg, tostring(self._error)))
    end
end

-- Expect error with custom panic message
function Result:expect_err(msg)
    if self:is_err() then
        return self._error
    else
        error(msg)
    end
end

-- Map the Ok value
function Result:map(fn)
    if self:is_ok() then
        return result.Ok(fn(self._value))
    else
        return self
    end
end

-- Map the Err value
function Result:map_err(fn)
    if self:is_err() then
        return result.Err(fn(self._error))
    else
        return self
    end
end

-- Map or return default
function Result:map_or(default, fn)
    if self:is_ok() then
        return fn(self._value)
    else
        return default
    end
end

-- Map or compute default from error
function Result:map_or_else(default_fn, fn)
    if self:is_ok() then
        return fn(self._value)
    else
        return default_fn(self._error)
    end
end

-- Flat map (monadic bind)
function Result:and_then(fn)
    if self:is_ok() then
        return fn(self._value)
    else
        return self
    end
end

-- Or else combinator
function Result:or_else(fn)
    if self:is_err() then
        return fn(self._error)
    else
        return self
    end
end

-- And combinator
function Result:and_result(other)
    if self:is_ok() then
        return other
    else
        return self
    end
end

-- Or combinator
function Result:or_result(other)
    if self:is_ok() then
        return self
    else
        return other
    end
end

-- Match pattern for Result
function Result:match(patterns)
    if self:is_ok() then
        if patterns.Ok then
            return patterns.Ok(self._value)
        end
    else
        if patterns.Err then
            return patterns.Err(self._error)
        end
    end
end

-- Convert to Option (Err becomes None)
function Result:ok()
    local option = require("stdn.option")
    if self:is_ok() then
        return option.Some(self._value)
    else
        return option.None()
    end
end

-- Convert to Option (Ok becomes None)
function Result:err()
    local option = require("stdn.option")
    if self:is_err() then
        return option.Some(self._error)
    else
        return option.None()
    end
end

-- String representation
function Result:__tostring()
    if self:is_ok() then
        return string.format("Ok(%s)", tostring(self._value))
    else
        return string.format("Err(%s)", tostring(self._error))
    end
end

-- Collect multiple results into one
function result.collect(results)
    local values = {}
    for i, res in ipairs(results) do
        if res:is_err() then
            return result.Err(res:unwrap_err())
        end
        values[i] = res:unwrap()
    end
    return result.Ok(values)
end

-- Try to execute a function and wrap in Result
function result.try(fn, ...)
    local success, value = pcall(fn, ...)
    if success then
        return result.Ok(value)
    else
        return result.Err(value)
    end
end

return result
