# stdn - Quick Reference Guide

## Import

```lua
local stdn = require("stdn")
```

## Result<T, E>

```lua
-- Create
stdn.Ok(value)
stdn.Err(error)

-- Check
result:is_ok()
result:is_err()

-- Unwrap
result:unwrap()                    -- panic on Err
result:unwrap_or(default)          -- return default on Err
result:expect("custom message")    -- panic with message

-- Transform
result:map(fn)                     -- map Ok value
result:map_err(fn)                 -- map Err value
result:and_then(fn)                -- flat map

-- Pattern match
result:match({
    Ok = function(value) ... end,
    Err = function(error) ... end
})
```

## Option<T>

```lua
-- Create
stdn.Some(value)
stdn.None()
stdn.option.from_nullable(value)

-- Check
option:is_some()
option:is_none()

-- Unwrap
option:unwrap()                    -- panic on None
option:unwrap_or(default)          -- return default on None
option:expect("message")           -- panic with message

-- Transform
option:map(fn)                     -- map Some value
option:filter(predicate)           -- filter to None if false
option:and_then(fn)                -- flat map

-- Pattern match
option:match({
    Some = function(value) ... end,
    None = function() ... end
})
```

## Vec<T>

```lua
-- Create
local v = stdn.vec.new()
local v = stdn.vec.from({1, 2, 3})
local v = stdn.vec.with_capacity(100)

-- Modify
v:push(value)
v:pop()
v:insert(index, value)
v:remove(index)
v:clear()

-- Access
v:get(index)
v:first()
v:last()
v:len()
v:is_empty()

-- Search
v:contains(value)
v:position(predicate)

-- Transform
v:map(fn)
v:filter(predicate)
v:fold(init, fn)
v:reverse()
v:sort(compare)

-- Iterate
for value in v:iter() do
    print(value)
end
```

## HashMap<K, V>

```lua
-- Create
local m = stdn.hashmap.new()
local m = stdn.hashmap.from({key = value})

-- Modify
m:insert(key, value)
m:remove(key)
m:clear()

-- Access
m:get(key)
m:contains_key(key)
m:len()
m:is_empty()

-- Transform
m:map(fn)
m:filter(predicate)

-- Iterate
for key, value in m:iter() do
    print(key, value)
end

for key in m:keys() do
    print(key)
end

for value in m:values() do
    print(value)
end
```

## HashSet<T>

```lua
-- Create
local s = stdn.hashset.new()
local s = stdn.hashset.from({1, 2, 3})

-- Modify
s:insert(value)
s:remove(value)
s:clear()

-- Access
s:contains(value)
s:len()
s:is_empty()

-- Set operations
s:union(other)
s:intersection(other)
s:difference(other)
s:symmetric_difference(other)

-- Checks
s:is_subset(other)
s:is_superset(other)
s:is_disjoint(other)

-- Iterate
for value in s:iter() do
    print(value)
end
```

## Iterator

```lua
-- Create
stdn.iter.range(1, 10)
stdn.iter.from_table({1, 2, 3})
stdn.iter.repeat_value(42, 5)

-- Transform
iter:map(fn)
iter:filter(predicate)
iter:filter_map(fn)
iter:flat_map(fn)

-- Take/Skip
iter:take(n)
iter:take_while(predicate)
iter:skip(n)
iter:skip_while(predicate)

-- Combine
iter:chain(other)
iter:zip(other)
iter:enumerate()

-- Reduce
iter:fold(init, fn)
iter:reduce(fn)
iter:sum()
iter:product()

-- Search
iter:find(predicate)
iter:position(predicate)
iter:any(predicate)
iter:all(predicate)

-- Terminal
iter:collect()
iter:collect_vec()
iter:count()
iter:last()
iter:nth(n)
```

## String

```lua
-- Split & Join
stdn.string.split(str, delim)
stdn.string.lines(str)
stdn.string.split_whitespace(str)
stdn.string.join(strings, sep)

-- Trim
stdn.string.trim(str)
stdn.string.trim_start(str)
stdn.string.trim_end(str)

-- Check
stdn.string.starts_with(str, prefix)
stdn.string.ends_with(str, suffix)
stdn.string.contains(str, substr)
stdn.string.is_empty(str)

-- Transform
stdn.string.to_uppercase(str)
stdn.string.to_lowercase(str)
stdn.string.to_snake_case(str)
stdn.string.to_camel_case(str)
stdn.string.to_pascal_case(str)
stdn.string.to_kebab_case(str)

-- Replace
stdn.string.replace(str, from, to)
stdn.string.replace_n(str, from, to, n)

-- Misc
stdn.string.reverse(str)
stdn.string.count(str, substr)
stdn.string.pad_start(str, len, fill)
stdn.string.pad_end(str, len, fill)
```

## Filesystem

```lua
-- Read
stdn.fs.read_to_string(path)       -- Result<String, Error>
stdn.fs.read_lines(path)           -- Result<Vec, Error>

-- Write
stdn.fs.write(path, content)       -- Result<(), Error>
stdn.fs.append(path, content)      -- Result<(), Error>

-- File ops
stdn.fs.copy(src, dest)
stdn.fs.rename(old, new)
stdn.fs.remove(path)

-- Directory ops
stdn.fs.create_dir(path)
stdn.fs.create_dir_all(path)
stdn.fs.remove_dir(path)
stdn.fs.read_dir(path)             -- Result<Vec, Error>

-- Checks
stdn.fs.exists(path)
stdn.fs.is_file(path)
stdn.fs.is_dir(path)

-- Metadata
stdn.fs.file_size(path)            -- Result<Number, Error>
stdn.fs.metadata(path)             -- Result<Table, Error>
```

## Path

```lua
-- Manipulate
stdn.path.join("dir", "file.txt")
stdn.path.normalize(path)
stdn.path.absolute(path)

-- Extract
stdn.path.file_name(path)
stdn.path.file_stem(path)
stdn.path.extension(path)
stdn.path.parent(path)

-- Check
stdn.path.is_absolute(path)
stdn.path.is_relative(path)

-- Transform
stdn.path.with_extension(path, ext)
stdn.path.with_file_name(path, name)
```

## Error Handling

```lua
-- Panic
stdn.panic("message")
stdn.panicf("format %s", arg)

-- Assert
stdn.assert(condition, "message")
stdn.assert_eq(left, right)
stdn.assert_ne(left, right)

-- Safe operations
stdn.error.safe_div(a, b)          -- Result
stdn.error.catch_panic(fn, ...)    -- Result
stdn.error.try(fn)                 -- returns fn that returns Result
```

## Math

```lua
-- Basic
stdn.math.clamp(value, min, max)
stdn.math.lerp(a, b, t)
stdn.math.sign(x)
stdn.math.round(x)

-- Statistics
stdn.math.sum(array)
stdn.math.mean(array)
stdn.math.median(array)
stdn.math.variance(array)
stdn.math.std_dev(array)
stdn.math.min(array)
stdn.math.max(array)

-- Number theory
stdn.math.gcd(a, b)
stdn.math.lcm(a, b)
stdn.math.is_prime(n)
stdn.math.factorial(n)

-- Geometry
stdn.math.distance(x1, y1, x2, y2)
stdn.math.angle(x1, y1, x2, y2)
```

## Time

```lua
-- Duration
local d = stdn.time.from_secs(5)
local d = stdn.time.from_millis(5000)
d:as_secs()
d:as_millis()

-- Instant
local start = stdn.time.now()
local elapsed = start:elapsed()

-- Measure
local duration, result = stdn.time.measure(function()
    -- code to measure
end)

-- Stopwatch
local sw = stdn.time.stopwatch()
sw:start()
sw:stop()
sw:reset()
local elapsed = sw:elapsed()

-- Benchmark
local stats = stdn.time.benchmark(fn, iterations)
print(stats.mean, stats.median)
```

## I/O

```lua
-- Stdin
stdn.io.stdin.read_line()
stdn.io.stdin.read_all()

-- Stdout
stdn.io.stdout.write("text")
stdn.io.stdout.write_line("line")
stdn.io.stdout.printf("format %s", arg)

-- Buffered
local reader = stdn.io.buf_reader("file.txt")
local line = reader:read_line()
reader:close()

local writer = stdn.io.buf_writer("out.txt")
writer:write_line("text")
writer:close()

-- Utility
stdn.io.pretty_print(table)
local answer = stdn.io.prompt("Question? ")
local yes = stdn.io.confirm("Confirm? ")
```

## Threading

```lua
-- Thread
local t = stdn.thread.spawn(function()
    return 42
end)
local result = t:join()

-- Channel
local ch = stdn.thread.channel(10)
ch:send(value)
local value = ch:receive()

-- Mutex
local m = stdn.thread.mutex()
m:lock()
-- critical section
m:unlock()

-- Atomic
local a = stdn.thread.atomic(0)
a:store(10)
local old = a:fetch_add(5)
```

## Common Patterns

### Safe File Reading
```lua
stdn.fs.read_to_string("data.txt"):match({
    Ok = function(content)
        -- process content
    end,
    Err = function(err)
        print("Error:", err)
    end
})
```

### Iterator Pipeline
```lua
local result = stdn.iter.range(1, 100)
    :filter(function(x) return x % 2 == 0 end)
    :map(function(x) return x * x end)
    :take(10)
    :collect()
```

### Option Chain
```lua
local result = get_user(id)
    :and_then(function(user) return get_profile(user.id) end)
    :map(function(profile) return profile.name end)
    :unwrap_or("Anonymous")
```

### Collection Transform
```lua
local sum = stdn.vec.from({1, 2, 3, 4, 5})
    :filter(function(x) return x > 2 end)
    :map(function(x) return x * 2 end)
    :fold(0, function(acc, x) return acc + x end)
```
