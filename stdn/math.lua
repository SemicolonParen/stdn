-- stdn.math: Extended math utilities
-- Provides additional mathematical operations beyond standard Lua

local math_utils = {}

-- Constants
math_utils.PI = math.pi
math_utils.E = 2.718281828459045
math_utils.TAU = 2 * math.pi
math_utils.PHI = (1 + math.sqrt(5)) / 2  -- Golden ratio
math_utils.SQRT2 = math.sqrt(2)
math_utils.SQRT3 = math.sqrt(3)

-- Clamp value between min and max
function math_utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Linear interpolation
function math_utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Inverse linear interpolation
function math_utils.inv_lerp(a, b, value)
    return (value - a) / (b - a)
end

-- Remap value from one range to another
function math_utils.remap(value, in_min, in_max, out_min, out_max)
    return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)
end

-- Sign of number (-1, 0, 1)
function math_utils.sign(x)
    if x > 0 then return 1
    elseif x < 0 then return -1
    else return 0 end
end

-- Round to nearest integer
function math_utils.round(x)
    return math.floor(x + 0.5)
end

-- Round to n decimal places
function math_utils.round_to(x, n)
    local mult = 10 ^ n
    return math.floor(x * mult + 0.5) / mult
end

-- Check if nearly equal (with epsilon)
function math_utils.approx_eq(a, b, epsilon)
    epsilon = epsilon or 1e-10
    return math.abs(a - b) < epsilon
end

-- Distance between two points (2D)
function math_utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Distance between two points (3D)
function math_utils.distance3d(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Manhattan distance
function math_utils.manhattan(x1, y1, x2, y2)
    return math.abs(x2 - x1) + math.abs(y2 - y1)
end

-- Angle between two points (radians)
function math_utils.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

-- Convert degrees to radians
function math_utils.rad(degrees)
    return degrees * math.pi / 180
end

-- Convert radians to degrees
function math_utils.deg(radians)
    return radians * 180 / math.pi
end

-- Normalize angle to [0, 2π)
function math_utils.normalize_angle(angle)
    angle = angle % (2 * math.pi)
    if angle < 0 then
        angle = angle + 2 * math.pi
    end
    return angle
end

-- Factorial
function math_utils.factorial(n)
    if n <= 1 then return 1 end
    local result = 1
    for i = 2, n do
        result = result * i
    end
    return result
end

-- Binomial coefficient (n choose k)
function math_utils.binomial(n, k)
    if k > n then return 0 end
    if k == 0 or k == n then return 1 end

    local result = 1
    k = math.min(k, n - k)

    for i = 0, k - 1 do
        result = result * (n - i) / (i + 1)
    end

    return result
end

-- Greatest common divisor
function math_utils.gcd(a, b)
    while b ~= 0 do
        a, b = b, a % b
    end
    return math.abs(a)
end

-- Least common multiple
function math_utils.lcm(a, b)
    return math.abs(a * b) / math_utils.gcd(a, b)
end

-- Check if number is prime
function math_utils.is_prime(n)
    if n < 2 then return false end
    if n == 2 then return true end
    if n % 2 == 0 then return false end

    local sqrt_n = math.floor(math.sqrt(n))
    for i = 3, sqrt_n, 2 do
        if n % i == 0 then
            return false
        end
    end

    return true
end

-- Check if number is even
function math_utils.is_even(n)
    return n % 2 == 0
end

-- Check if number is odd
function math_utils.is_odd(n)
    return n % 2 ~= 0
end

-- Power with integer exponent (more efficient)
function math_utils.powi(base, exp)
    if exp == 0 then return 1 end
    if exp < 0 then return 1 / math_utils.powi(base, -exp) end

    local result = 1
    while exp > 0 do
        if exp % 2 == 1 then
            result = result * base
        end
        base = base * base
        exp = math.floor(exp / 2)
    end

    return result
end

-- Square
function math_utils.sqr(x)
    return x * x
end

-- Cube
function math_utils.cube(x)
    return x * x * x
end

-- Sum of array
function math_utils.sum(arr)
    local total = 0
    for _, v in ipairs(arr) do
        total = total + v
    end
    return total
end

-- Product of array
function math_utils.product(arr)
    local result = 1
    for _, v in ipairs(arr) do
        result = result * v
    end
    return result
end

-- Mean (average)
function math_utils.mean(arr)
    if #arr == 0 then return 0 end
    return math_utils.sum(arr) / #arr
end

-- Median
function math_utils.median(arr)
    if #arr == 0 then return 0 end

    local sorted = {}
    for i, v in ipairs(arr) do
        sorted[i] = v
    end
    table.sort(sorted)

    local mid = math.floor(#sorted / 2)
    if #sorted % 2 == 0 then
        return (sorted[mid] + sorted[mid + 1]) / 2
    else
        return sorted[mid + 1]
    end
end

-- Mode (most frequent value)
function math_utils.mode(arr)
    if #arr == 0 then return nil end

    local counts = {}
    for _, v in ipairs(arr) do
        counts[v] = (counts[v] or 0) + 1
    end

    local max_count = 0
    local mode_value = nil

    for value, count in pairs(counts) do
        if count > max_count then
            max_count = count
            mode_value = value
        end
    end

    return mode_value
end

-- Variance
function math_utils.variance(arr)
    if #arr == 0 then return 0 end

    local mean = math_utils.mean(arr)
    local sum_sq_diff = 0

    for _, v in ipairs(arr) do
        local diff = v - mean
        sum_sq_diff = sum_sq_diff + diff * diff
    end

    return sum_sq_diff / #arr
end

-- Standard deviation
function math_utils.std_dev(arr)
    return math.sqrt(math_utils.variance(arr))
end

-- Min of array
function math_utils.min(arr)
    if #arr == 0 then return nil end
    local min_val = arr[1]
    for i = 2, #arr do
        if arr[i] < min_val then
            min_val = arr[i]
        end
    end
    return min_val
end

-- Max of array
function math_utils.max(arr)
    if #arr == 0 then return nil end
    local max_val = arr[1]
    for i = 2, #arr do
        if arr[i] > max_val then
            max_val = arr[i]
        end
    end
    return max_val
end

-- Range (max - min)
function math_utils.range(arr)
    if #arr == 0 then return 0 end
    return math_utils.max(arr) - math_utils.min(arr)
end

-- Sigmoid function
function math_utils.sigmoid(x)
    return 1 / (1 + math.exp(-x))
end

-- ReLU (Rectified Linear Unit)
function math_utils.relu(x)
    return math.max(0, x)
end

-- Softplus
function math_utils.softplus(x)
    return math.log(1 + math.exp(x))
end

-- Logistic map
function math_utils.logistic(r, x)
    return r * x * (1 - x)
end

-- Map value through smoothstep
function math_utils.smoothstep(edge0, edge1, x)
    x = math_utils.clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return x * x * (3 - 2 * x)
end

-- Generate random integer in range [min, max]
function math_utils.random_int(min, max)
    return math.random(min, max)
end

-- Generate random float in range [min, max)
function math_utils.random_float(min, max)
    return min + math.random() * (max - min)
end

-- Generate random boolean
function math_utils.random_bool()
    return math.random() < 0.5
end

return math_utils
