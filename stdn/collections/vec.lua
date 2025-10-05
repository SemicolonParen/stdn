-- stdn.collections.vec: Dynamic array with Rust-like Vec operations
-- Provides efficient dynamic array with rich API

local vec = {}

local Vec = {}
Vec.__index = Vec

-- Create a new Vec
function vec.new()
    local self = setmetatable({}, Vec)
    self._data = {}
    self._len = 0
    return self
end

-- Create Vec from table
function vec.from(table)
    local self = vec.new()
    for _, value in ipairs(table) do
        self:push(value)
    end
    return self
end

-- Create Vec with capacity
function vec.with_capacity(capacity)
    local self = vec.new()
    -- Lua doesn't have true pre-allocation, but we can hint
    self._capacity = capacity
    return self
end

-- Get length
function Vec:len()
    return self._len
end

-- Check if empty
function Vec:is_empty()
    return self._len == 0
end

-- Push element to end
function Vec:push(value)
    self._len = self._len + 1
    self._data[self._len] = value
end

-- Pop element from end
function Vec:pop()
    if self._len == 0 then
        return nil
    end
    local value = self._data[self._len]
    self._data[self._len] = nil
    self._len = self._len - 1
    return value
end

-- Get element at index (1-based)
function Vec:get(index)
    if index < 1 or index > self._len then
        return nil
    end
    return self._data[index]
end

-- Set element at index
function Vec:set(index, value)
    if index < 1 or index > self._len then
        error(string.format("index out of bounds: index %d, len %d", index, self._len))
    end
    self._data[index] = value
end

-- Get first element
function Vec:first()
    return self:get(1)
end

-- Get last element
function Vec:last()
    return self:get(self._len)
end

-- Insert at index
function Vec:insert(index, value)
    if index < 1 or index > self._len + 1 then
        error(string.format("index out of bounds: index %d, len %d", index, self._len))
    end

    for i = self._len, index, -1 do
        self._data[i + 1] = self._data[i]
    end

    self._data[index] = value
    self._len = self._len + 1
end

-- Remove at index
function Vec:remove(index)
    if index < 1 or index > self._len then
        error(string.format("index out of bounds: index %d, len %d", index, self._len))
    end

    local value = self._data[index]

    for i = index, self._len - 1 do
        self._data[i] = self._data[i + 1]
    end

    self._data[self._len] = nil
    self._len = self._len - 1

    return value
end

-- Swap two elements
function Vec:swap(i, j)
    if i < 1 or i > self._len or j < 1 or j > self._len then
        error("index out of bounds")
    end
    self._data[i], self._data[j] = self._data[j], self._data[i]
end

-- Clear all elements
function Vec:clear()
    self._data = {}
    self._len = 0
end

-- Truncate to length
function Vec:truncate(len)
    if len < self._len then
        for i = len + 1, self._len do
            self._data[i] = nil
        end
        self._len = len
    end
end

-- Retain elements matching predicate
function Vec:retain(predicate)
    local write_index = 1
    for read_index = 1, self._len do
        if predicate(self._data[read_index]) then
            if write_index ~= read_index then
                self._data[write_index] = self._data[read_index]
            end
            write_index = write_index + 1
        end
    end

    for i = write_index, self._len do
        self._data[i] = nil
    end

    self._len = write_index - 1
end

-- Append another Vec
function Vec:append(other)
    for i = 1, other._len do
        self:push(other._data[i])
    end
end

-- Extend with iterator
function Vec:extend(iterator)
    for value in iterator do
        self:push(value)
    end
end

-- Resize with default value
function Vec:resize(new_len, default)
    if new_len < self._len then
        self:truncate(new_len)
    else
        for i = self._len + 1, new_len do
            self._data[i] = default
        end
        self._len = new_len
    end
end

-- Split off at index
function Vec:split_off(at)
    if at > self._len then
        error("index out of bounds")
    end

    local other = vec.new()
    for i = at + 1, self._len do
        other:push(self._data[i])
        self._data[i] = nil
    end

    self._len = at
    return other
end

-- Reverse in place
function Vec:reverse()
    for i = 1, math.floor(self._len / 2) do
        self:swap(i, self._len - i + 1)
    end
end

-- Sort with comparator
function Vec:sort(compare)
    local data = {}
    for i = 1, self._len do
        data[i] = self._data[i]
    end

    table.sort(data, compare)

    for i = 1, self._len do
        self._data[i] = data[i]
    end
end

-- Binary search (requires sorted vec)
function Vec:binary_search(value, compare)
    compare = compare or function(a, b)
        if a < b then return -1
        elseif a > b then return 1
        else return 0 end
    end

    local left, right = 1, self._len

    while left <= right do
        local mid = math.floor((left + right) / 2)
        local cmp = compare(self._data[mid], value)

        if cmp == 0 then
            return mid
        elseif cmp < 0 then
            left = mid + 1
        else
            right = mid - 1
        end
    end

    return nil
end

-- Contains element
function Vec:contains(value)
    for i = 1, self._len do
        if self._data[i] == value then
            return true
        end
    end
    return false
end

-- Find index of element
function Vec:position(predicate)
    for i = 1, self._len do
        if predicate(self._data[i]) then
            return i
        end
    end
    return nil
end

-- Map to new Vec
function Vec:map(fn)
    local result = vec.new()
    for i = 1, self._len do
        result:push(fn(self._data[i]))
    end
    return result
end

-- Filter to new Vec
function Vec:filter(predicate)
    local result = vec.new()
    for i = 1, self._len do
        if predicate(self._data[i]) then
            result:push(self._data[i])
        end
    end
    return result
end

-- Reduce
function Vec:fold(init, fn)
    local acc = init
    for i = 1, self._len do
        acc = fn(acc, self._data[i])
    end
    return acc
end

-- For each
function Vec:for_each(fn)
    for i = 1, self._len do
        fn(self._data[i])
    end
end

-- Any matches predicate
function Vec:any(predicate)
    for i = 1, self._len do
        if predicate(self._data[i]) then
            return true
        end
    end
    return false
end

-- All match predicate
function Vec:all(predicate)
    for i = 1, self._len do
        if not predicate(self._data[i]) then
            return false
        end
    end
    return true
end

-- Clone the Vec
function Vec:clone()
    local result = vec.new()
    for i = 1, self._len do
        result:push(self._data[i])
    end
    return result
end

-- Convert to table
function Vec:to_table()
    local result = {}
    for i = 1, self._len do
        result[i] = self._data[i]
    end
    return result
end

-- Iterator
function Vec:iter()
    local i = 0
    return function()
        i = i + 1
        if i <= self._len then
            return self._data[i]
        end
    end
end

-- Index access (1-based)
function Vec:__index(key)
    if type(key) == "number" then
        return self:get(key)
    else
        return Vec[key]
    end
end

-- Index assignment
function Vec:__newindex(key, value)
    if type(key) == "number" then
        self:set(key, value)
    else
        rawset(self, key, value)
    end
end

-- Length operator
function Vec:__len()
    return self._len
end

-- String representation
function Vec:__tostring()
    local parts = {}
    for i = 1, self._len do
        parts[i] = tostring(self._data[i])
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

return vec
