-- stdn.collections.hashset: Hash set implementation with Rust-like API
-- Provides efficient unique value storage with set operations

local hashset = {}

local HashSet = {}
HashSet.__index = HashSet

-- Helper: generate hash for any value
local function hash_value(value)
    local t = type(value)
    if t == "string" or t == "number" or t == "boolean" then
        return tostring(value)
    elseif t == "table" then
        return tostring(value)
    else
        return tostring(value)
    end
end

-- Create a new HashSet
function hashset.new()
    local self = setmetatable({}, HashSet)
    self._data = {}
    self._values = {}
    self._size = 0
    return self
end

-- Create HashSet from table
function hashset.from(table)
    local self = hashset.new()
    for _, value in ipairs(table) do
        self:insert(value)
    end
    return self
end

-- Get the number of elements
function HashSet:len()
    return self._size
end

-- Check if empty
function HashSet:is_empty()
    return self._size == 0
end

-- Insert value, returns true if newly inserted
function HashSet:insert(value)
    local hash = hash_value(value)

    if self._data[hash] then
        return false
    end

    self._data[hash] = true
    self._values[hash] = value
    self._size = self._size + 1
    return true
end

-- Remove value, returns true if existed
function HashSet:remove(value)
    local hash = hash_value(value)

    if not self._data[hash] then
        return false
    end

    self._data[hash] = nil
    self._values[hash] = nil
    self._size = self._size - 1
    return true
end

-- Check if value exists
function HashSet:contains(value)
    local hash = hash_value(value)
    return self._data[hash] ~= nil
end

-- Clear all elements
function HashSet:clear()
    self._data = {}
    self._values = {}
    self._size = 0
end

-- Retain elements matching predicate
function HashSet:retain(predicate)
    for hash, _ in pairs(self._data) do
        local value = self._values[hash]
        if not predicate(value) then
            self._data[hash] = nil
            self._values[hash] = nil
            self._size = self._size - 1
        end
    end
end

-- Union with another HashSet
function HashSet:union(other)
    local result = self:clone()
    for value in other:iter() do
        result:insert(value)
    end
    return result
end

-- Intersection with another HashSet
function HashSet:intersection(other)
    local result = hashset.new()
    for value in self:iter() do
        if other:contains(value) then
            result:insert(value)
        end
    end
    return result
end

-- Difference with another HashSet (elements in self but not in other)
function HashSet:difference(other)
    local result = hashset.new()
    for value in self:iter() do
        if not other:contains(value) then
            result:insert(value)
        end
    end
    return result
end

-- Symmetric difference with another HashSet
function HashSet:symmetric_difference(other)
    local result = hashset.new()

    for value in self:iter() do
        if not other:contains(value) then
            result:insert(value)
        end
    end

    for value in other:iter() do
        if not self:contains(value) then
            result:insert(value)
        end
    end

    return result
end

-- Check if subset of another HashSet
function HashSet:is_subset(other)
    if self._size > other._size then
        return false
    end

    for value in self:iter() do
        if not other:contains(value) then
            return false
        end
    end

    return true
end

-- Check if superset of another HashSet
function HashSet:is_superset(other)
    return other:is_subset(self)
end

-- Check if disjoint from another HashSet
function HashSet:is_disjoint(other)
    for value in self:iter() do
        if other:contains(value) then
            return false
        end
    end
    return true
end

-- Extend with another HashSet
function HashSet:extend(other)
    for value in other:iter() do
        self:insert(value)
    end
end

-- Iterator over values
function HashSet:iter()
    local hash
    return function()
        hash = next(self._data, hash)
        if hash then
            return self._values[hash]
        end
    end
end

-- Map to new HashSet
function HashSet:map(fn)
    local result = hashset.new()
    for value in self:iter() do
        result:insert(fn(value))
    end
    return result
end

-- Filter to new HashSet
function HashSet:filter(predicate)
    local result = hashset.new()
    for value in self:iter() do
        if predicate(value) then
            result:insert(value)
        end
    end
    return result
end

-- For each element
function HashSet:for_each(fn)
    for value in self:iter() do
        fn(value)
    end
end

-- Any element matches predicate
function HashSet:any(predicate)
    for value in self:iter() do
        if predicate(value) then
            return true
        end
    end
    return false
end

-- All elements match predicate
function HashSet:all(predicate)
    for value in self:iter() do
        if not predicate(value) then
            return false
        end
    end
    return true
end

-- Clone the HashSet
function HashSet:clone()
    local result = hashset.new()
    for value in self:iter() do
        result:insert(value)
    end
    return result
end

-- Convert to table (array)
function HashSet:to_table()
    local result = {}
    local i = 1
    for value in self:iter() do
        result[i] = value
        i = i + 1
    end
    return result
end

-- Convert to Vec
function HashSet:to_vec()
    local vec = require("stdn.collections.vec")
    local result = vec.new()
    for value in self:iter() do
        result:push(value)
    end
    return result
end

-- Length operator
function HashSet:__len()
    return self._size
end

-- String representation
function HashSet:__tostring()
    local parts = {}
    local i = 1
    for value in self:iter() do
        parts[i] = tostring(value)
        i = i + 1
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

return hashset
