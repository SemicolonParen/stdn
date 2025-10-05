#!/usr/bin/env lua
-- stdn comprehensive test suite

-- Add parent directory to path
package.path = package.path .. ";../?.lua"

local stdn = require("stdn")

-- Test framework
local tests_passed = 0
local tests_failed = 0
local current_suite = ""

local function test_suite(name)
    current_suite = name
    print(string.format("\n=== %s ===", name))
end

local function assert_test(condition, test_name)
    if condition then
        tests_passed = tests_passed + 1
        print(string.format("  ✓ %s", test_name))
    else
        tests_failed = tests_failed + 1
        print(string.format("  ✗ %s", test_name))
    end
end

local function assert_eq(actual, expected, test_name)
    assert_test(actual == expected, test_name)
end

-- Result tests
test_suite("Result<T, E>")

local ok_result = stdn.Ok(42)
assert_test(ok_result:is_ok(), "Ok variant is_ok")
assert_test(not ok_result:is_err(), "Ok variant not is_err")
assert_eq(ok_result:unwrap(), 42, "Ok unwrap returns value")

local err_result = stdn.Err("error")
assert_test(err_result:is_err(), "Err variant is_err")
assert_test(not err_result:is_ok(), "Err variant not is_ok")

local mapped = ok_result:map(function(x) return x * 2 end)
assert_eq(mapped:unwrap(), 84, "Result map transformation")

local unwrap_or = err_result:unwrap_or(100)
assert_eq(unwrap_or, 100, "Result unwrap_or default")

-- Option tests
test_suite("Option<T>")

local some_opt = stdn.Some(10)
assert_test(some_opt:is_some(), "Some variant is_some")
assert_test(not some_opt:is_none(), "Some variant not is_none")
assert_eq(some_opt:unwrap(), 10, "Some unwrap returns value")

local none_opt = stdn.None()
assert_test(none_opt:is_none(), "None variant is_none")
assert_test(not none_opt:is_some(), "None variant not is_some")

local mapped_opt = some_opt:map(function(x) return x + 5 end)
assert_eq(mapped_opt:unwrap(), 15, "Option map transformation")

local unwrap_or_opt = none_opt:unwrap_or(99)
assert_eq(unwrap_or_opt, 99, "Option unwrap_or default")

-- Vec tests
test_suite("Vec<T> Collection")

local vec = stdn.vec.new()
vec:push(1)
vec:push(2)
vec:push(3)
assert_eq(vec:len(), 3, "Vec length after pushes")
assert_eq(vec:get(2), 2, "Vec get element")

local popped = vec:pop()
assert_eq(popped, 3, "Vec pop returns last")
assert_eq(vec:len(), 2, "Vec length after pop")

local filtered = vec:filter(function(x) return x > 1 end)
assert_eq(filtered:len(), 1, "Vec filter")

local sum = vec:fold(0, function(acc, x) return acc + x end)
assert_eq(sum, 3, "Vec fold (reduce)")

-- HashMap tests
test_suite("HashMap<K, V> Collection")

local map = stdn.hashmap.new()
map:insert("name", "Alice")
map:insert("age", 30)
assert_eq(map:len(), 2, "HashMap length")
assert_eq(map:get("name"), "Alice", "HashMap get value")
assert_test(map:contains_key("age"), "HashMap contains key")

local removed = map:remove("age")
assert_eq(removed, 30, "HashMap remove returns value")
assert_eq(map:len(), 1, "HashMap length after remove")

-- HashSet tests
test_suite("HashSet<T> Collection")

local set = stdn.hashset.new()
assert_test(set:insert(1), "HashSet insert new returns true")
assert_test(not set:insert(1), "HashSet insert duplicate returns false")
set:insert(2)
set:insert(3)
assert_eq(set:len(), 3, "HashSet length")
assert_test(set:contains(2), "HashSet contains element")

local set2 = stdn.hashset.new()
set2:insert(2)
set2:insert(4)

local union = set:union(set2)
assert_eq(union:len(), 4, "HashSet union")

local intersection = set:intersection(set2)
assert_eq(intersection:len(), 1, "HashSet intersection")

-- Iterator tests
test_suite("Iterator Operations")

local iter = stdn.iter.range(1, 5)
local sum_iter = iter:fold(0, function(acc, x) return acc + x end)
assert_eq(sum_iter, 15, "Iterator range and fold")

local mapped_iter = stdn.iter.range(1, 3):map(function(x) return x * 2 end)
local collected = mapped_iter:collect()
assert_eq(#collected, 3, "Iterator map and collect")
assert_eq(collected[1], 2, "Iterator mapped first element")

local filtered_iter = stdn.iter.range(1, 10):filter(function(x) return x % 2 == 0 end)
local count = filtered_iter:count()
assert_eq(count, 5, "Iterator filter and count")

-- String tests
test_suite("String Utilities")

local str = "  hello world  "
assert_eq(stdn.string.trim(str), "hello world", "String trim")

local parts = stdn.string.split("a,b,c", ",")
assert_eq(#parts, 3, "String split count")
assert_eq(parts[2], "b", "String split element")

assert_test(stdn.string.starts_with("hello", "hel"), "String starts_with")
assert_test(stdn.string.ends_with("world", "rld"), "String ends_with")

local snake = stdn.string.to_snake_case("CamelCase")
assert_eq(snake, "camel_case", "String to_snake_case")

local upper = stdn.string.to_uppercase("hello")
assert_eq(upper, "HELLO", "String to_uppercase")

-- Math tests
test_suite("Math Utilities")

assert_eq(stdn.math.clamp(5, 0, 10), 5, "Math clamp in range")
assert_eq(stdn.math.clamp(-5, 0, 10), 0, "Math clamp below range")
assert_eq(stdn.math.clamp(15, 0, 10), 10, "Math clamp above range")

assert_eq(stdn.math.lerp(0, 10, 0.5), 5, "Math lerp")

local arr = {1, 2, 3, 4, 5}
assert_eq(stdn.math.sum(arr), 15, "Math sum array")
assert_eq(stdn.math.mean(arr), 3, "Math mean")
assert_eq(stdn.math.min(arr), 1, "Math min")
assert_eq(stdn.math.max(arr), 5, "Math max")

assert_test(stdn.math.is_prime(7), "Math is_prime true")
assert_test(not stdn.math.is_prime(8), "Math is_prime false")

assert_eq(stdn.math.gcd(12, 18), 6, "Math GCD")
assert_eq(stdn.math.factorial(5), 120, "Math factorial")

-- Path tests
test_suite("Path Utilities")

local filepath = "/home/user/file.txt"
assert_eq(stdn.path.file_name(filepath), "file.txt", "Path file_name")
assert_eq(stdn.path.file_stem(filepath), "file", "Path file_stem")
assert_eq(stdn.path.extension(filepath), "txt", "Path extension")

local joined = stdn.path.join("home", "user", "file.txt")
assert_test(joined:find("home") ~= nil, "Path join contains parts")

assert_test(stdn.path.is_absolute("/home/user"), "Path is_absolute")
assert_test(stdn.path.is_relative("user/file"), "Path is_relative")

-- Error handling tests
test_suite("Error Handling")

local function safe_divide(a, b)
    return stdn.error.safe_div(a, b)
end

local div_ok = safe_divide(10, 2)
assert_test(div_ok:is_ok(), "Safe division success")
assert_eq(div_ok:unwrap(), 5, "Safe division result")

local div_err = safe_divide(10, 0)
assert_test(div_err:is_err(), "Safe division by zero error")

local caught = stdn.error.catch_panic(function()
    return 42
end)
assert_test(caught:is_ok(), "Catch panic on success")

-- Time tests
test_suite("Time Utilities")

local duration = stdn.time.from_secs(5)
assert_eq(duration:as_millis(), 5000, "Duration as_millis")

local d1 = stdn.time.from_secs(10)
local d2 = stdn.time.from_secs(5)
local sum_duration = d1 + d2
assert_eq(sum_duration:as_secs(), 15, "Duration addition")

local stopwatch = stdn.time.stopwatch()
stopwatch:start()
assert_test(stopwatch:is_running(), "Stopwatch is running")
stopwatch:stop()
assert_test(not stopwatch:is_running(), "Stopwatch stopped")

-- Thread tests
test_suite("Thread Utilities")

local thread = stdn.thread.spawn(function()
    return 42
end)

assert_test(not thread:is_finished(), "Thread not finished initially")

local result = thread:join()
assert_eq(result, 42, "Thread join returns result")
assert_test(thread:is_finished(), "Thread finished after join")

local channel = stdn.thread.channel(10)
channel:send(100)
assert_eq(channel:len(), 1, "Channel has item")
local received = channel:receive()
assert_eq(received, 100, "Channel receive correct value")

local mutex = stdn.thread.mutex()
assert_test(not mutex:is_locked(), "Mutex initially unlocked")
mutex:lock()
assert_test(mutex:is_locked(), "Mutex locked")
mutex:unlock()
assert_test(not mutex:is_locked(), "Mutex unlocked")

-- Print summary
print(string.format("\n" .. string.rep("=", 50)))
print(string.format("Tests passed: %d", tests_passed))
print(string.format("Tests failed: %d", tests_failed))
print(string.format("Total tests: %d", tests_passed + tests_failed))
print(string.format("Success rate: %.1f%%", (tests_passed / (tests_passed + tests_failed)) * 100))
print(string.rep("=", 50))

if tests_failed > 0 then
    os.exit(1)
else
    print("\n✓ All tests passed!")
    os.exit(0)
end
