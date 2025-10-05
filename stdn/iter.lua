-- stdn.iter: Iterator utilities with functional operations
-- Provides Rust-like iterator adapters and combinators

local iter = {}

local Iter = {}
Iter.__index = Iter

-- Create iterator from function
function iter.new(func)
    local self = setmetatable({}, Iter)
    self._func = func
    return self
end

-- Create iterator from table
function iter.from_table(table)
    local i = 0
    local n = #table
    return iter.new(function()
        i = i + 1
        if i <= n then
            return table[i]
        end
    end)
end

-- Create iterator from pairs
function iter.from_pairs(table)
    local key, value
    return iter.new(function()
        key, value = next(table, key)
        if key ~= nil then
            return key, value
        end
    end)
end

-- Create range iterator
function iter.range(start, stop, step)
    step = step or 1
    local current = start

    if stop == nil then
        stop = start
        current = 1
    end

    return iter.new(function()
        if step > 0 and current <= stop or step < 0 and current >= stop then
            local value = current
            current = current + step
            return value
        end
    end)
end

-- Create repeat iterator
function iter.repeat_value(value, count)
    local i = 0
    return iter.new(function()
        if count == nil or i < count then
            i = i + 1
            return value
        end
    end)
end

-- Create once iterator
function iter.once(value)
    local done = false
    return iter.new(function()
        if not done then
            done = true
            return value
        end
    end)
end

-- Create empty iterator
function iter.empty()
    return iter.new(function() return nil end)
end

-- Advance iterator
function Iter:next()
    return self._func()
end

-- Map adapter
function Iter:map(fn)
    local func = self._func
    return iter.new(function()
        local value = func()
        if value ~= nil then
            return fn(value)
        end
    end)
end

-- Filter adapter
function Iter:filter(predicate)
    local func = self._func
    return iter.new(function()
        while true do
            local value = func()
            if value == nil then
                return nil
            end
            if predicate(value) then
                return value
            end
        end
    end)
end

-- Filter map adapter
function Iter:filter_map(fn)
    local func = self._func
    return iter.new(function()
        while true do
            local value = func()
            if value == nil then
                return nil
            end
            local mapped = fn(value)
            if mapped ~= nil then
                return mapped
            end
        end
    end)
end

-- Take first n elements
function Iter:take(n)
    local func = self._func
    local count = 0
    return iter.new(function()
        if count < n then
            count = count + 1
            return func()
        end
    end)
end

-- Take while predicate is true
function Iter:take_while(predicate)
    local func = self._func
    local done = false
    return iter.new(function()
        if not done then
            local value = func()
            if value ~= nil and predicate(value) then
                return value
            else
                done = true
            end
        end
    end)
end

-- Skip first n elements
function Iter:skip(n)
    local func = self._func
    local skipped = 0
    return iter.new(function()
        while skipped < n do
            func()
            skipped = skipped + 1
        end
        return func()
    end)
end

-- Skip while predicate is true
function Iter:skip_while(predicate)
    local func = self._func
    local skipping = true
    return iter.new(function()
        while true do
            local value = func()
            if value == nil then
                return nil
            end
            if skipping then
                if not predicate(value) then
                    skipping = false
                    return value
                end
            else
                return value
            end
        end
    end)
end

-- Chain with another iterator
function Iter:chain(other)
    local func = self._func
    local first_done = false
    return iter.new(function()
        if not first_done then
            local value = func()
            if value ~= nil then
                return value
            end
            first_done = true
        end
        return other:next()
    end)
end

-- Zip with another iterator
function Iter:zip(other)
    local func = self._func
    return iter.new(function()
        local a = func()
        local b = other:next()
        if a ~= nil and b ~= nil then
            return {a, b}
        end
    end)
end

-- Enumerate with index
function Iter:enumerate()
    local func = self._func
    local index = 0
    return iter.new(function()
        local value = func()
        if value ~= nil then
            index = index + 1
            return {index, value}
        end
    end)
end

-- Flat map
function Iter:flat_map(fn)
    local func = self._func
    local inner = nil

    return iter.new(function()
        while true do
            if inner then
                local value = inner:next()
                if value ~= nil then
                    return value
                end
                inner = nil
            end

            local outer_value = func()
            if outer_value == nil then
                return nil
            end

            inner = fn(outer_value)
        end
    end)
end

-- Inspect each element
function Iter:inspect(fn)
    local func = self._func
    return iter.new(function()
        local value = func()
        if value ~= nil then
            fn(value)
        end
        return value
    end)
end

-- Partition into two collections
function Iter:partition(predicate)
    local left, right = {}, {}
    local left_count, right_count = 0, 0

    while true do
        local value = self:next()
        if value == nil then break end

        if predicate(value) then
            left_count = left_count + 1
            left[left_count] = value
        else
            right_count = right_count + 1
            right[right_count] = value
        end
    end

    return left, right
end

-- Fold (reduce)
function Iter:fold(init, fn)
    local acc = init
    while true do
        local value = self:next()
        if value == nil then break end
        acc = fn(acc, value)
    end
    return acc
end

-- Reduce (fold without initial value)
function Iter:reduce(fn)
    local acc = self:next()
    if acc == nil then
        error("reduce on empty iterator")
    end

    while true do
        local value = self:next()
        if value == nil then break end
        acc = fn(acc, value)
    end

    return acc
end

-- Scan (stateful map)
function Iter:scan(init, fn)
    local func = self._func
    local state = init

    return iter.new(function()
        local value = func()
        if value ~= nil then
            state = fn(state, value)
            return state
        end
    end)
end

-- For each
function Iter:for_each(fn)
    while true do
        local value = self:next()
        if value == nil then break end
        fn(value)
    end
end

-- Count elements
function Iter:count()
    local count = 0
    while true do
        local value = self:next()
        if value == nil then break end
        count = count + 1
    end
    return count
end

-- Last element
function Iter:last()
    local last_value = nil
    while true do
        local value = self:next()
        if value == nil then break end
        last_value = value
    end
    return last_value
end

-- Nth element (0-indexed)
function Iter:nth(n)
    local count = 0
    while true do
        local value = self:next()
        if value == nil then break end
        if count == n then
            return value
        end
        count = count + 1
    end
    return nil
end

-- Find first matching element
function Iter:find(predicate)
    while true do
        local value = self:next()
        if value == nil then break end
        if predicate(value) then
            return value
        end
    end
    return nil
end

-- Find position of first matching element
function Iter:position(predicate)
    local pos = 0
    while true do
        local value = self:next()
        if value == nil then break end
        if predicate(value) then
            return pos
        end
        pos = pos + 1
    end
    return nil
end

-- Check if any element matches
function Iter:any(predicate)
    while true do
        local value = self:next()
        if value == nil then break end
        if predicate(value) then
            return true
        end
    end
    return false
end

-- Check if all elements match
function Iter:all(predicate)
    while true do
        local value = self:next()
        if value == nil then break end
        if not predicate(value) then
            return false
        end
    end
    return true
end

-- Sum numeric elements
function Iter:sum()
    local sum = 0
    while true do
        local value = self:next()
        if value == nil then break end
        sum = sum + value
    end
    return sum
end

-- Product of numeric elements
function Iter:product()
    local product = 1
    while true do
        local value = self:next()
        if value == nil then break end
        product = product * value
    end
    return product
end

-- Maximum element
function Iter:max()
    local max_value = self:next()
    if max_value == nil then return nil end

    while true do
        local value = self:next()
        if value == nil then break end
        if value > max_value then
            max_value = value
        end
    end

    return max_value
end

-- Minimum element
function Iter:min()
    local min_value = self:next()
    if min_value == nil then return nil end

    while true do
        local value = self:next()
        if value == nil then break end
        if value < min_value then
            min_value = value
        end
    end

    return min_value
end

-- Collect into table
function Iter:collect()
    local result = {}
    local i = 1
    while true do
        local value = self:next()
        if value == nil then break end
        result[i] = value
        i = i + 1
    end
    return result
end

-- Collect into Vec
function Iter:collect_vec()
    local vec = require("stdn.collections.vec")
    local result = vec.new()
    while true do
        local value = self:next()
        if value == nil then break end
        result:push(value)
    end
    return result
end

-- Collect into HashSet
function Iter:collect_set()
    local hashset = require("stdn.collections.hashset")
    local result = hashset.new()
    while true do
        local value = self:next()
        if value == nil then break end
        result:insert(value)
    end
    return result
end

-- Make iterator callable
function Iter:__call()
    return self:next()
end

return iter
