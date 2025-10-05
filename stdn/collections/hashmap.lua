-- stdn.collections.hashmap: Hash map implementation with Rust-like API
-- Provides efficient key-value storage with rich operations

local hashmap = {}

local HashMap = {}
HashMap.__index = HashMap

-- Helper: generate hash for any value
local function hash_value(value)
    local t = type(value)
    if t == "string" or t == "number" or t == "boolean" then
        return tostring(value)
    elseif t == "table" then
        return tostring(value) -- use table address
    else
        return tostring(value)
    end
end

-- Create a new HashMap
function hashmap.new()
    local self = setmetatable({}, HashMap)
    self._data = {}
    self._keys = {}
    self._size = 0
    return self
end

-- Create HashMap from table
function hashmap.from(table)
    local self = hashmap.new()
    for key, value in pairs(table) do
        self:insert(key, value)
    end
    return self
end

-- Get the number of entries
function HashMap:len()
    return self._size
end

-- Check if empty
function HashMap:is_empty()
    return self._size == 0
end

-- Insert key-value pair, returns old value if existed
function HashMap:insert(key, value)
    local hash = hash_value(key)
    local old_value = self._data[hash]

    if old_value == nil then
        self._size = self._size + 1
        self._keys[hash] = key
    end

    self._data[hash] = value
    return old_value
end

-- Get value by key
function HashMap:get(key)
    local hash = hash_value(key)
    return self._data[hash]
end

-- Get key-value entry
function HashMap:get_entry(key)
    local hash = hash_value(key)
    local value = self._data[hash]
    if value ~= nil then
        return {key = self._keys[hash], value = value}
    end
    return nil
end

-- Remove key-value pair, returns value if existed
function HashMap:remove(key)
    local hash = hash_value(key)
    local value = self._data[hash]

    if value ~= nil then
        self._data[hash] = nil
        self._keys[hash] = nil
        self._size = self._size - 1
    end

    return value
end

-- Check if key exists
function HashMap:contains_key(key)
    local hash = hash_value(key)
    return self._data[hash] ~= nil
end

-- Get value or insert default
function HashMap:get_or_insert(key, default)
    local hash = hash_value(key)
    local value = self._data[hash]

    if value == nil then
        self:insert(key, default)
        return default
    end

    return value
end

-- Get value or insert from function
function HashMap:get_or_insert_with(key, fn)
    local hash = hash_value(key)
    local value = self._data[hash]

    if value == nil then
        local new_value = fn()
        self:insert(key, new_value)
        return new_value
    end

    return value
end

-- Clear all entries
function HashMap:clear()
    self._data = {}
    self._keys = {}
    self._size = 0
end

-- Retain entries matching predicate
function HashMap:retain(predicate)
    for hash, value in pairs(self._data) do
        local key = self._keys[hash]
        if not predicate(key, value) then
            self._data[hash] = nil
            self._keys[hash] = nil
            self._size = self._size - 1
        end
    end
end

-- Extend with another HashMap
function HashMap:extend(other)
    for key, value in other:iter() do
        self:insert(key, value)
    end
end

-- Iterator over key-value pairs
function HashMap:iter()
    local hash, value
    return function()
        hash, value = next(self._data, hash)
        if hash then
            return self._keys[hash], value
        end
    end
end

-- Iterator over keys
function HashMap:keys()
    local hash, key
    return function()
        hash, key = next(self._keys, hash)
        if hash then
            return key
        end
    end
end

-- Iterator over values
function HashMap:values()
    local hash, value
    return function()
        hash, value = next(self._data, hash)
        if hash then
            return value
        end
    end
end

-- Map values to new HashMap
function HashMap:map(fn)
    local result = hashmap.new()
    for key, value in self:iter() do
        result:insert(key, fn(key, value))
    end
    return result
end

-- Filter to new HashMap
function HashMap:filter(predicate)
    local result = hashmap.new()
    for key, value in self:iter() do
        if predicate(key, value) then
            result:insert(key, value)
        end
    end
    return result
end

-- For each entry
function HashMap:for_each(fn)
    for key, value in self:iter() do
        fn(key, value)
    end
end

-- Any entry matches predicate
function HashMap:any(predicate)
    for key, value in self:iter() do
        if predicate(key, value) then
            return true
        end
    end
    return false
end

-- All entries match predicate
function HashMap:all(predicate)
    for key, value in self:iter() do
        if not predicate(key, value) then
            return false
        end
    end
    return true
end

-- Clone the HashMap
function HashMap:clone()
    local result = hashmap.new()
    for key, value in self:iter() do
        result:insert(key, value)
    end
    return result
end

-- Convert to table
function HashMap:to_table()
    local result = {}
    for key, value in self:iter() do
        result[key] = value
    end
    return result
end

-- Get all keys as Vec
function HashMap:keys_vec()
    local vec = require("stdn.collections.vec")
    local result = vec.new()
    for key in self:keys() do
        result:push(key)
    end
    return result
end

-- Get all values as Vec
function HashMap:values_vec()
    local vec = require("stdn.collections.vec")
    local result = vec.new()
    for value in self:values() do
        result:push(value)
    end
    return result
end

-- Index access
function HashMap:__index(key)
    if type(key) == "string" and HashMap[key] then
        return HashMap[key]
    else
        return self:get(key)
    end
end

-- Index assignment
function HashMap:__newindex(key, value)
    self:insert(key, value)
end

-- Length operator
function HashMap:__len()
    return self._size
end

-- String representation
function HashMap:__tostring()
    local parts = {}
    local i = 1
    for key, value in self:iter() do
        parts[i] = string.format("%s: %s", tostring(key), tostring(value))
        i = i + 1
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

return hashmap
