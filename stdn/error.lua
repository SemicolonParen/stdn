-- stdn.error: Error handling and panic utilities
-- Provides Rust-like panic and assertion utilities

local error_utils = {}

-- Panic with message
function error_utils.panic(msg)
    error(string.format("thread panicked: %s", msg), 2)
end

-- Panic with formatted message
function error_utils.panicf(fmt, ...)
    local msg = string.format(fmt, ...)
    error(string.format("thread panicked: %s", msg), 2)
end

-- Assert with panic
function error_utils.assert(condition, msg)
    if not condition then
        error_utils.panic(msg or "assertion failed")
    end
end

-- Assert equality
function error_utils.assert_eq(left, right, msg)
    if left ~= right then
        local error_msg = msg or string.format(
            "assertion failed: `(left == right)`\n  left: `%s`\n right: `%s`",
            tostring(left),
            tostring(right)
        )
        error_utils.panic(error_msg)
    end
end

-- Assert inequality
function error_utils.assert_ne(left, right, msg)
    if left == right then
        local error_msg = msg or string.format(
            "assertion failed: `(left != right)`\n  left: `%s`\n right: `%s`",
            tostring(left),
            tostring(right)
        )
        error_utils.panic(error_msg)
    end
end

-- Debug assert (only in debug mode)
local debug_mode = os.getenv("LUA_DEBUG") ~= nil
function error_utils.debug_assert(condition, msg)
    if debug_mode and not condition then
        error_utils.panic(msg or "debug assertion failed")
    end
end

-- Unreachable code marker
function error_utils.unreachable(msg)
    error_utils.panic(msg or "entered unreachable code")
end

-- Unimplemented marker
function error_utils.unimplemented(msg)
    error_utils.panic(msg or "not yet implemented")
end

-- Todo marker
function error_utils.todo(msg)
    error_utils.panic(msg or "not yet implemented")
end

-- Catch panic and convert to Result
function error_utils.catch_panic(fn, ...)
    local result_module = require("stdn.result")
    local success, value = pcall(fn, ...)

    if success then
        return result_module.Ok(value)
    else
        return result_module.Err(value)
    end
end

-- Try-catch style error handling
function error_utils.try(fn)
    local result_module = require("stdn.result")
    return function(...)
        local success, value = pcall(fn, ...)
        if success then
            return result_module.Ok(value)
        else
            return result_module.Err(value)
        end
    end
end

-- Create error type
function error_utils.new_error(kind, msg, context)
    return {
        kind = kind,
        message = msg,
        context = context or {},
        timestamp = os.time()
    }
end

-- Error chain for context
local ErrorChain = {}
ErrorChain.__index = ErrorChain

function error_utils.chain()
    local self = setmetatable({}, ErrorChain)
    self._errors = {}
    return self
end

function ErrorChain:push(error)
    table.insert(self._errors, error)
    return self
end

function ErrorChain:root()
    return self._errors[1]
end

function ErrorChain:current()
    return self._errors[#self._errors]
end

function ErrorChain:len()
    return #self._errors
end

function ErrorChain:iter()
    local i = 0
    return function()
        i = i + 1
        if i <= #self._errors then
            return self._errors[i]
        end
    end
end

function ErrorChain:__tostring()
    local parts = {}
    for i, err in ipairs(self._errors) do
        parts[i] = string.format("%d: %s", i, tostring(err))
    end
    return table.concat(parts, "\n")
end

-- Backtrace capture
function error_utils.backtrace()
    local trace = debug.traceback("", 2)
    return trace
end

-- Get error with backtrace
function error_utils.error_with_backtrace(msg)
    return {
        message = msg,
        backtrace = error_utils.backtrace()
    }
end

-- Expect helper for panicking with context
function error_utils.expect(value, msg)
    if value == nil then
        error_utils.panic(msg or "expected value but got nil")
    end
    return value
end

-- Unwrap helper for panicking on nil
function error_utils.unwrap(value, msg)
    if value == nil then
        error_utils.panic(msg or "tried to unwrap nil value")
    end
    return value
end

-- Safe division with error
function error_utils.safe_div(a, b)
    if b == 0 then
        local result_module = require("stdn.result")
        return result_module.Err("division by zero")
    end
    local result_module = require("stdn.result")
    return result_module.Ok(a / b)
end

-- Safe index access
function error_utils.safe_index(table, key)
    local option_module = require("stdn.option")
    local value = table[key]
    if value ~= nil then
        return option_module.Some(value)
    else
        return option_module.None()
    end
end

-- Validate function arguments
function error_utils.validate_args(args, validators)
    for name, validator in pairs(validators) do
        local value = args[name]
        local ok, err = validator(value)
        if not ok then
            error_utils.panicf("argument validation failed for '%s': %s", name, err)
        end
    end
end

-- Common validators
error_utils.validators = {
    not_nil = function(value)
        return value ~= nil, "value must not be nil"
    end,

    is_string = function(value)
        return type(value) == "string", "value must be a string"
    end,

    is_number = function(value)
        return type(value) == "number", "value must be a number"
    end,

    is_table = function(value)
        return type(value) == "table", "value must be a table"
    end,

    is_function = function(value)
        return type(value) == "function", "value must be a function"
    end,

    is_boolean = function(value)
        return type(value) == "boolean", "value must be a boolean"
    end,

    is_positive = function(value)
        return type(value) == "number" and value > 0, "value must be positive"
    end,

    is_non_negative = function(value)
        return type(value) == "number" and value >= 0, "value must be non-negative"
    end,

    min = function(min_value)
        return function(value)
            return type(value) == "number" and value >= min_value,
                   string.format("value must be at least %s", min_value)
        end
    end,

    max = function(max_value)
        return function(value)
            return type(value) == "number" and value <= max_value,
                   string.format("value must be at most %s", max_value)
        end
    end,

    range = function(min_value, max_value)
        return function(value)
            return type(value) == "number" and value >= min_value and value <= max_value,
                   string.format("value must be between %s and %s", min_value, max_value)
        end
    end,

    non_empty = function(value)
        return type(value) == "string" and #value > 0, "string must not be empty"
    end
}

return error_utils
