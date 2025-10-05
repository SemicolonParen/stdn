# stdn - Standard Native Library for Lua

**stdn** (standard native) is a comprehensive, production-ready Lua library that brings Rust's powerful standard library patterns to Lua. It provides modern error handling, rich collections, functional programming utilities, and much more.

## Features

### Core Types
- **Result<T, E>**: Rust-like error handling with explicit success/failure types
- **Option<T>**: Safe handling of nullable values without nil checks

### Collections
- **Vec<T>**: Dynamic array with rich API (map, filter, fold, etc.)
- **HashMap<K, V>**: Hash-based key-value storage with functional operations
- **HashSet<T>**: Unique value storage with set operations (union, intersection, etc.)

### Functional Programming
- **Iterator**: Lazy iterator with adapters (map, filter, take, skip, chain, zip, etc.)
- Composable operations with method chaining
- Collect to various collection types

### String Utilities
- Advanced string manipulation (split, trim, case conversion)
- Pattern matching and replacement
- Case conversions (snake_case, camelCase, PascalCase, kebab-case)
- String similarity and Levenshtein distance

### Filesystem Operations
- Safe file reading/writing with Result types
- Directory operations (create, remove, walk)
- File metadata and size queries
- Cross-platform path handling

### Path Manipulation
- Cross-platform path operations
- Component parsing and joining
- Normalization and absolute path resolution
- Extension and filename utilities

### Error Handling
- Panic and assertion utilities
- Backtracing and error chains
- Safe division and index access
- Argument validation with custom validators

### Math Utilities
- Statistical functions (mean, median, variance, std_dev)
- Interpolation (lerp, remap, smoothstep)
- Number theory (GCD, LCM, prime checks, factorials)
- Vector math (distance, angles)

### Time & Duration
- Duration type with multiple time units
- Instant and stopwatch for timing
- Benchmarking utilities
- Timeout helpers

### I/O Operations
- Buffered readers and writers
- Formatted I/O (printf-style)
- Pretty printing for tables
- Stdin/stdout/stderr utilities

### Threading
- Cooperative threading via coroutines
- Channels for communication
- Thread pools for task management
- Synchronization primitives (Mutex, Atomic, Barrier)

## Installation

```bash
# Clone or download stdn.lua and the stdn/ directory
# Add to your project directory
```

## Quick Start

```lua
local stdn = require("stdn")

-- Error handling with Result
local function safe_divide(a, b)
    if b == 0 then
        return stdn.Err("division by zero")
    end
    return stdn.Ok(a / b)
end

local result = safe_divide(10, 2)
print(result:unwrap())  -- 5

-- Option for nullable values
local function find_user(id)
    local users = {[1] = "Alice", [2] = "Bob"}
    if users[id] then
        return stdn.Some(users[id])
    else
        return stdn.None()
    end
end

local user = find_user(1):unwrap_or("Guest")

-- Functional operations with Vec
local numbers = stdn.vec.from({1, 2, 3, 4, 5})
local sum = numbers
    :filter(function(n) return n % 2 == 0 end)
    :map(function(n) return n * n end)
    :fold(0, function(acc, n) return acc + n end)

-- Iterator chaining
local result = stdn.iter.range(1, 100)
    :filter(function(x) return x % 2 == 0 end)
    :map(function(x) return x * x end)
    :take(5)
    :collect()

-- HashMap operations
local config = stdn.hashmap.new()
config:insert("host", "localhost")
config:insert("port", 8080)

for key, value in config:iter() do
    print(key, value)
end

-- String utilities
local text = "  Hello, World!  "
local trimmed = stdn.string.trim(text)
local parts = stdn.string.split("a,b,c", ",")
local snake = stdn.string.to_snake_case("MyVariableName")

-- File operations
local file_result = stdn.fs.read_to_string("data.txt")
file_result:match({
    Ok = function(content)
        print("File content:", content)
    end,
    Err = function(err)
        print("Error:", err)
    end
})

-- Time measurement
local duration, result = stdn.time.measure(function()
    -- expensive operation
    return 42
end)
print("Took:", duration)
```

## Module Reference

### stdn.result
Functions: `Ok(value)`, `Err(error)`, `collect(results)`, `try(fn, ...)`

Methods: `is_ok()`, `is_err()`, `unwrap()`, `unwrap_or(default)`, `map(fn)`, `and_then(fn)`, `match(patterns)`

### stdn.option
Functions: `Some(value)`, `None()`, `from_nullable(value)`

Methods: `is_some()`, `is_none()`, `unwrap()`, `unwrap_or(default)`, `map(fn)`, `and_then(fn)`, `filter(predicate)`, `match(patterns)`

### stdn.vec
Functions: `new()`, `from(table)`, `with_capacity(n)`

Methods: `push(v)`, `pop()`, `get(i)`, `map(fn)`, `filter(fn)`, `fold(init, fn)`, `sort(cmp)`, `reverse()`, `contains(v)`

### stdn.hashmap
Functions: `new()`, `from(table)`

Methods: `insert(k, v)`, `get(k)`, `remove(k)`, `contains_key(k)`, `iter()`, `keys()`, `values()`, `map(fn)`, `filter(fn)`

### stdn.hashset
Functions: `new()`, `from(table)`

Methods: `insert(v)`, `remove(v)`, `contains(v)`, `union(other)`, `intersection(other)`, `difference(other)`

### stdn.iter
Functions: `new(fn)`, `from_table(t)`, `range(start, stop, step)`, `repeat_value(v, n)`

Methods: `map(fn)`, `filter(fn)`, `take(n)`, `skip(n)`, `fold(init, fn)`, `collect()`, `chain(other)`, `zip(other)`

### stdn.string
Functions: `split(str, delim)`, `trim(str)`, `starts_with(str, prefix)`, `contains(str, substr)`, `to_snake_case(str)`, `to_camel_case(str)`, `replace(str, from, to)`

### stdn.fs
Functions: `exists(path)`, `read_to_string(path)`, `write(path, content)`, `copy(src, dest)`, `remove(path)`, `create_dir(path)`, `read_dir(path)`

### stdn.path
Constants: `SEPARATOR`

Functions: `join(...)`, `file_name(path)`, `extension(path)`, `parent(path)`, `normalize(path)`, `is_absolute(path)`

### stdn.error
Functions: `panic(msg)`, `assert(cond, msg)`, `assert_eq(a, b, msg)`, `catch_panic(fn)`, `safe_div(a, b)`, `backtrace()`

### stdn.math
Constants: `PI`, `E`, `TAU`, `PHI`

Functions: `clamp(v, min, max)`, `lerp(a, b, t)`, `mean(arr)`, `median(arr)`, `std_dev(arr)`, `gcd(a, b)`, `is_prime(n)`, `factorial(n)`

### stdn.time
Functions: `now()`, `from_secs(s)`, `from_millis(ms)`, `measure(fn, ...)`, `stopwatch()`, `benchmark(fn, iterations)`

### stdn.io
Modules: `stdin`, `stdout`, `stderr`

Functions: `buf_reader(file)`, `buf_writer(file)`, `pretty_print(value)`, `prompt(msg)`, `confirm(msg)`

### stdn.thread
Functions: `spawn(fn, ...)`, `yield(...)`, `channel(capacity)`, `mutex()`, `atomic(value)`, `thread_pool(size)`

## Examples

See the `examples/` directory for comprehensive usage examples:
- `basic_usage.lua`: Common patterns and basic usage

## Testing

Run the test suite:

```bash
cd tests
lua test_all.lua
```

## Design Philosophy

**stdn** follows these principles:

1. **Explicit Error Handling**: Use Result and Option types instead of error() and nil
2. **Functional Patterns**: Support method chaining and functional composition
3. **Type Safety**: Provide clear APIs that prevent common mistakes
4. **Performance**: Efficient implementations suitable for production use
5. **Ergonomics**: Clean, intuitive APIs that reduce boilerplate

## Why stdn?

Lua is powerful but its standard library is minimal. **stdn** fills this gap by providing:

- Modern error handling patterns from Rust
- Rich collection types with functional operations
- Comprehensive utilities for common tasks
- Professional-grade code architecture
- Zero dependencies beyond standard Lua

No more messy code with nil checks, pcall wrapping, and manual table operations. Write clean, maintainable Lua code with **stdn**.

## Requirements

- Lua 5.1 or later (including LuaJIT)
- No external dependencies

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please ensure:
- Code follows existing style and conventions
- All tests pass
- New features include tests and documentation

## Version

1.0.0 - Production Ready

---

Built with the goal of bringing Rust's std:: experience to Lua developers.
