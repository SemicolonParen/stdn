#!/usr/bin/env lua
-- stdn: Basic Usage Examples
-- Demonstrates common patterns and usage

package.path = package.path .. ";../?.lua"
local stdn = require("stdn")

print("=== stdn: Standard Native Library for Lua ===\n")

-- Example 1: Result type for error handling
print("1. Result<T, E> - Safe Error Handling")
print("--------------------------------------")

local function safe_divide(a, b)
    if b == 0 then
        return stdn.Err("division by zero")
    end
    return stdn.Ok(a / b)
end

local result = safe_divide(10, 2)
result:match({
    Ok = function(value)
        print(string.format("  Success: 10 / 2 = %.1f", value))
    end,
    Err = function(err)
        print(string.format("  Error: %s", err))
    end
})

local error_result = safe_divide(10, 0)
local value = error_result:unwrap_or(0)
print(string.format("  10 / 0 with default: %.1f\n", value))

-- Example 2: Option type for nullable values
print("2. Option<T> - Safe Null Handling")
print("----------------------------------")

local function find_user(id)
    local users = {
        [1] = "Alice",
        [2] = "Bob"
    }

    if users[id] then
        return stdn.Some(users[id])
    else
        return stdn.None()
    end
end

find_user(1):match({
    Some = function(name)
        print(string.format("  Found user: %s", name))
    end,
    None = function()
        print("  User not found")
    end
})

local default_name = find_user(99):unwrap_or("Guest")
print(string.format("  User 99 or default: %s\n", default_name))

-- Example 3: Vec collection
print("3. Vec<T> - Dynamic Array")
print("-------------------------")

local numbers = stdn.vec.from({1, 2, 3, 4, 5, 6, 7, 8, 9, 10})

local evens = numbers:filter(function(n) return n % 2 == 0 end)
print(string.format("  Even numbers: %s", evens))

local doubled = numbers:map(function(n) return n * 2 end)
print(string.format("  Doubled: %s", doubled))

local sum = numbers:fold(0, function(acc, n) return acc + n end)
print(string.format("  Sum: %d\n", sum))

-- Example 4: HashMap
print("4. HashMap<K, V> - Key-Value Store")
print("-----------------------------------")

local config = stdn.hashmap.new()
config:insert("host", "localhost")
config:insert("port", 8080)
config:insert("debug", true)

print("  Configuration:")
for key, value in config:iter() do
    print(string.format("    %s: %s", key, tostring(value)))
end
print()

-- Example 5: HashSet
print("5. HashSet<T> - Unique Values")
print("------------------------------")

local tags = stdn.hashset.from({"lua", "rust", "python", "lua"})
print(string.format("  Unique tags: %s", tags))
print(string.format("  Contains 'rust': %s\n", tags:contains("rust")))

-- Example 6: Iterator operations
print("6. Iterator - Functional Operations")
print("------------------------------------")

local result_iter = stdn.iter.range(1, 10)
    :filter(function(x) return x % 2 == 0 end)
    :map(function(x) return x * x end)
    :take(3)
    :collect()

print("  First 3 even squares: " .. table.concat(result_iter, ", ") .. "\n")

-- Example 7: String utilities
print("7. String Utilities")
print("-------------------")

local text = "  Hello, World!  "
print(string.format("  Original: '%s'", text))
print(string.format("  Trimmed: '%s'", stdn.string.trim(text)))

local csv = "apple,banana,orange"
local fruits = stdn.string.split(csv, ",")
print(string.format("  Split CSV: %s", table.concat(fruits, " | ")))

local snake = stdn.string.to_snake_case("MyVariableName")
print(string.format("  Snake case: %s\n", snake))

-- Example 8: Math utilities
print("8. Math Utilities")
print("-----------------")

local values = {2, 4, 6, 8, 10}
print(string.format("  Values: %s", table.concat(values, ", ")))
print(string.format("  Mean: %.1f", stdn.math.mean(values)))
print(string.format("  Median: %.1f", stdn.math.median(values)))
print(string.format("  Std Dev: %.2f\n", stdn.math.std_dev(values)))

-- Example 9: Path manipulation
print("9. Path Manipulation")
print("--------------------")

local filepath = "/home/user/documents/report.pdf"
print(string.format("  Full path: %s", filepath))
print(string.format("  File name: %s", stdn.path.file_name(filepath)))
print(string.format("  Extension: %s", stdn.path.extension(filepath)))
print(string.format("  Parent: %s\n", stdn.path.parent(filepath)))

-- Example 10: Time measurement
print("10. Time Measurement")
print("--------------------")

local function slow_operation()
    local sum = 0
    for i = 1, 1000000 do
        sum = sum + i
    end
    return sum
end

local duration, result_time = stdn.time.measure(slow_operation)
print(string.format("  Operation took: %s", tostring(duration)))
print(string.format("  Result: %d\n", result_time))

-- Example 11: Error handling
print("11. Error Handling")
print("------------------")

local function risky_operation()
    if math.random() > 0.5 then
        return "success"
    else
        error("random failure")
    end
end

local safe_result = stdn.error.catch_panic(risky_operation)
safe_result:match({
    Ok = function(value)
        print(string.format("  Operation succeeded: %s", value))
    end,
    Err = function(err)
        print(string.format("  Operation failed: %s", err))
    end
})

print()

-- Example 12: Threading (coroutines)
print("12. Threading with Coroutines")
print("------------------------------")

local function worker(name, count)
    for i = 1, count do
        print(string.format("  [%s] Working: %d/%d", name, i, count))
        stdn.thread.yield()
    end
    return string.format("%s completed", name)
end

local thread1 = stdn.thread.spawn(worker, "Worker-1", 3)
local thread2 = stdn.thread.spawn(worker, "Worker-2", 3)

while not (thread1:is_finished() and thread2:is_finished()) do
    thread1:resume()
    thread2:resume()
end

print()

print("=== Examples Complete ===")
