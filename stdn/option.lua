-- stdn.option: Option<T> type for handling nullable values
-- Provides Rust-like Option enum for explicit null handling

local option = {}

local Option = {}
Option.__index = Option

-- Option type enum
local OptionType = {
    SOME = "Some",
    NONE = "None"
}

-- Create a Some variant
function option.Some(value)
    if value == nil then
        error("cannot create Some with nil value, use None instead")
    end
    local self = setmetatable({}, Option)
    self._type = OptionType.SOME
    self._value = value
    return self
end

-- Create a None variant
function option.None()
    local self = setmetatable({}, Option)
    self._type = OptionType.NONE
    return self
end

-- Check if Option is Some
function Option:is_some()
    return self._type == OptionType.SOME
end

-- Check if Option is None
function Option:is_none()
    return self._type == OptionType.NONE
end

-- Check if Some and predicate is true
function Option:is_some_and(predicate)
    return self:is_some() and predicate(self._value)
end

-- Unwrap the value, panic if None
function Option:unwrap()
    if self:is_some() then
        return self._value
    else
        error("called `Option:unwrap()` on a `None` value")
    end
end

-- Unwrap or return default value
function Option:unwrap_or(default)
    if self:is_some() then
        return self._value
    else
        return default
    end
end

-- Unwrap or compute default value from function
function Option:unwrap_or_else(fn)
    if self:is_some() then
        return self._value
    else
        return fn()
    end
end

-- Expect with custom panic message
function Option:expect(msg)
    if self:is_some() then
        return self._value
    else
        error(msg)
    end
end

-- Map the Some value
function Option:map(fn)
    if self:is_some() then
        return option.Some(fn(self._value))
    else
        return self
    end
end

-- Map or return default
function Option:map_or(default, fn)
    if self:is_some() then
        return fn(self._value)
    else
        return default
    end
end

-- Map or compute default
function Option:map_or_else(default_fn, fn)
    if self:is_some() then
        return fn(self._value)
    else
        return default_fn()
    end
end

-- Flat map (monadic bind)
function Option:and_then(fn)
    if self:is_some() then
        return fn(self._value)
    else
        return self
    end
end

-- Or else combinator
function Option:or_else(fn)
    if self:is_none() then
        return fn()
    else
        return self
    end
end

-- And combinator
function Option:and_option(other)
    if self:is_some() then
        return other
    else
        return self
    end
end

-- Or combinator
function Option:or_option(other)
    if self:is_some() then
        return self
    else
        return other
    end
end

-- XOR combinator
function Option:xor(other)
    if self:is_some() and other:is_none() then
        return self
    elseif self:is_none() and other:is_some() then
        return other
    else
        return option.None()
    end
end

-- Filter the Option value
function Option:filter(predicate)
    if self:is_some() and predicate(self._value) then
        return self
    else
        return option.None()
    end
end

-- Match pattern for Option
function Option:match(patterns)
    if self:is_some() then
        if patterns.Some then
            return patterns.Some(self._value)
        end
    else
        if patterns.None then
            return patterns.None()
        end
    end
end

-- Convert to Result
function Option:ok_or(err)
    local result = require("stdn.result")
    if self:is_some() then
        return result.Ok(self._value)
    else
        return result.Err(err)
    end
end

-- Convert to Result with error function
function Option:ok_or_else(err_fn)
    local result = require("stdn.result")
    if self:is_some() then
        return result.Ok(self._value)
    else
        return result.Err(err_fn())
    end
end

-- Transpose Option<Result<T, E>> to Result<Option<T>, E>
function Option:transpose()
    local result = require("stdn.result")
    if self:is_none() then
        return result.Ok(option.None())
    end

    local inner = self._value
    if inner.is_ok then -- Check if it's a Result
        if inner:is_ok() then
            return result.Ok(option.Some(inner:unwrap()))
        else
            return result.Err(inner:unwrap_err())
        end
    else
        error("transpose called on non-Result inner value")
    end
end

-- Flatten Option<Option<T>> to Option<T>
function Option:flatten()
    if self:is_none() then
        return self
    end

    local inner = self._value
    if getmetatable(inner) == Option then
        return inner
    else
        return self
    end
end

-- Take the value, leaving None in its place
function Option:take()
    if self:is_some() then
        local value = self._value
        self._type = OptionType.NONE
        self._value = nil
        return option.Some(value)
    else
        return option.None()
    end
end

-- Replace the value, returning the old Option
function Option:replace(value)
    local old = self:is_some() and option.Some(self._value) or option.None()
    self._type = OptionType.SOME
    self._value = value
    return old
end

-- String representation
function Option:__tostring()
    if self:is_some() then
        return string.format("Some(%s)", tostring(self._value))
    else
        return "None"
    end
end

-- Create Option from nullable value
function option.from_nullable(value)
    if value == nil then
        return option.None()
    else
        return option.Some(value)
    end
end

return option
