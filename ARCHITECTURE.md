# stdn - Architecture & Design

## Project Structure

```
stdn/
├── stdn.lua                    # Main entry point, exports all modules
├── stdn/
│   ├── result.lua              # Result<T, E> type implementation
│   ├── option.lua              # Option<T> type implementation
│   ├── iter.lua                # Iterator with functional adapters
│   ├── string.lua              # String manipulation utilities
│   ├── fs.lua                  # Filesystem operations
│   ├── path.lua                # Path manipulation
│   ├── error.lua               # Error handling and panic utilities
│   ├── math.lua                # Extended math operations
│   ├── io.lua                  # Enhanced I/O operations
│   ├── time.lua                # Time and duration utilities
│   ├── thread.lua              # Threading via coroutines
│   └── collections/
│       ├── vec.lua             # Dynamic array (Vec<T>)
│       ├── hashmap.lua         # Hash map (HashMap<K, V>)
│       └── hashset.lua         # Hash set (HashSet<T>)
├── tests/
│   └── test_all.lua            # Comprehensive test suite
├── examples/
│   └── basic_usage.lua         # Usage examples
├── README.md                   # Documentation
├── LICENSE                     # MIT License
└── ARCHITECTURE.md             # This file
```

## Module Architecture

### Core Types Layer

**result.lua** and **option.lua** form the foundation of error handling:
- Result<T, E>: Represents success (Ok) or failure (Err)
- Option<T>: Represents presence (Some) or absence (None)
- Both support pattern matching, mapping, and monadic operations

### Collections Layer

Efficient data structures with rich APIs:
- **Vec<T>**: Dynamic array with functional operations
- **HashMap<K, V>**: Hash-based key-value storage
- **HashSet<T>**: Unique value collection

All collections support:
- Functional operations (map, filter, fold)
- Iterators for lazy evaluation
- Method chaining for composition

### Utilities Layer

Specialized modules for common tasks:
- **iter**: Lazy iterators with adapters (map, filter, take, skip, chain, zip)
- **string**: Advanced string manipulation
- **math**: Statistical and mathematical operations
- **path**: Cross-platform path handling
- **fs**: Safe filesystem operations

### System Layer

System interaction and low-level operations:
- **io**: Buffered I/O and formatted output
- **time**: Duration, timing, and benchmarking
- **thread**: Cooperative threading via coroutines
- **error**: Panic handling and validation

## Design Patterns

### 1. Explicit Error Handling

Instead of:
```lua
local file = io.open("data.txt", "r")
if not file then
    error("failed to open file")
end
```

Use:
```lua
local result = stdn.fs.read_to_string("data.txt")
result:match({
    Ok = function(content) ... end,
    Err = function(err) ... end
})
```

### 2. Method Chaining

Compose operations fluently:
```lua
local result = stdn.vec.from({1, 2, 3, 4, 5})
    :filter(function(x) return x % 2 == 0 end)
    :map(function(x) return x * x end)
    :fold(0, function(acc, x) return acc + x end)
```

### 3. Iterator Laziness

Operations are evaluated lazily:
```lua
local iter = stdn.iter.range(1, 1000000)
    :filter(predicate)
    :map(transform)
    :take(10)  -- Only processes 10 elements
```

### 4. Type Safety Through Patterns

Result and Option enforce handling all cases:
```lua
result:match({
    Ok = function(value) ... end,
    Err = function(error) ... end
})
```

## Implementation Details

### Hash-Based Collections

HashMap and HashSet use Lua table addresses for hashing:
- String/number/boolean keys use value-based hashing
- Table keys use reference-based hashing
- Maintains separate storage for keys and values

### Iterator System

Iterators wrap generator functions:
- Lazy evaluation minimizes memory usage
- Composable adapters build transformation pipelines
- Terminal operations trigger evaluation

### Thread Model

Cooperative threading via Lua coroutines:
- Threads are wrapped coroutines with state tracking
- Channels provide message passing
- Mutexes and atomics provide synchronization primitives
- Thread pools manage concurrent task execution

### Time Measurement

Uses `os.clock()` for high-resolution timing:
- Duration type wraps seconds with unit conversions
- Instant captures point-in-time measurements
- Stopwatch provides start/stop timing

## Performance Considerations

### Memory

- Collections pre-allocate when capacity is known
- Iterators use lazy evaluation to minimize allocations
- Buffered I/O reduces system calls

### CPU

- Hash operations use efficient table lookups
- Iterator fusion avoids intermediate allocations
- Math operations use optimized algorithms (e.g., integer exponentiation)

### Best Practices

1. **Use iterators for large datasets**: Avoid creating intermediate collections
2. **Pre-allocate collections**: Use `vec.with_capacity()` when size is known
3. **Reuse objects**: Clone only when necessary
4. **Buffer I/O**: Use buf_reader/buf_writer for file operations

## Extension Points

### Adding New Collection Types

1. Create module in `stdn/collections/`
2. Implement standard interface (new, from, len, is_empty)
3. Add functional operations (map, filter, fold)
4. Export from main `stdn.lua`

### Adding New Iterator Adapters

1. Add method to Iter class in `stdn/iter.lua`
2. Return new iterator wrapping transformation
3. Maintain lazy evaluation semantics

### Adding New Validators

1. Add to `error.validators` table in `stdn/error.lua`
2. Return `(bool, error_message)` tuple
3. Support composition with existing validators

## Testing Strategy

The test suite (`tests/test_all.lua`) covers:
- Core type operations (Result, Option)
- Collection operations (Vec, HashMap, HashSet)
- Iterator transformations
- String manipulations
- Path operations
- Math functions
- Time measurement
- Threading primitives

Run tests with:
```bash
cd tests
lua test_all.lua
```

## Code Metrics

- **Total Lines**: ~4,600 LOC
- **Modules**: 15 core modules
- **Functions**: 500+ public functions/methods
- **Test Coverage**: 50+ test cases

## Future Enhancements

Potential additions:
- Regex support
- JSON serialization
- Async I/O operations
- Network utilities
- Cryptographic functions
- Logging framework

## Philosophy

**stdn** embodies these values:

1. **Explicitness over Implicitness**: Make errors and nulls explicit
2. **Composition over Complexity**: Build complex behavior from simple parts
3. **Safety over Convenience**: Prevent bugs at API level
4. **Performance over Abstraction**: Efficient implementations
5. **Ergonomics over Purity**: Practical, usable APIs

The goal is to make Lua development feel like using a modern, well-designed standard library while maintaining Lua's simplicity and performance.
