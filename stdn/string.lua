-- stdn.string: Enhanced string utilities with Rust-like operations
-- Provides rich string manipulation beyond standard Lua

local string_utils = {}

-- Split string by delimiter
function string_utils.split(str, delimiter)
    if delimiter == "" then
        local chars = {}
        for i = 1, #str do
            chars[i] = str:sub(i, i)
        end
        return chars
    end

    local result = {}
    local pattern = "(.-)" .. delimiter
    local last_end = 1
    local s, e, cap

    while true do
        s, e, cap = str:find(pattern, last_end)
        if not s then break end
        table.insert(result, cap)
        last_end = e + 1
    end

    table.insert(result, str:sub(last_end))
    return result
end

-- Split string into lines
function string_utils.lines(str)
    return string_utils.split(str:gsub("\r\n", "\n"):gsub("\r", "\n"), "\n")
end

-- Split whitespace
function string_utils.split_whitespace(str)
    local result = {}
    for word in str:gmatch("%S+") do
        table.insert(result, word)
    end
    return result
end

-- Trim whitespace from both ends
function string_utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Trim whitespace from start
function string_utils.trim_start(str)
    return str:match("^%s*(.*)$")
end

-- Trim whitespace from end
function string_utils.trim_end(str)
    return str:match("^(.-)%s*$")
end

-- Check if string starts with prefix
function string_utils.starts_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-- Check if string ends with suffix
function string_utils.ends_with(str, suffix)
    return suffix == "" or str:sub(-#suffix) == suffix
end

-- Check if string contains substring
function string_utils.contains(str, substr)
    return str:find(substr, 1, true) ~= nil
end

-- Replace all occurrences
function string_utils.replace(str, from, to)
    return str:gsub(from:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"), to)
end

-- Replace n occurrences
function string_utils.replace_n(str, from, to, n)
    return str:gsub(from:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"), to, n)
end

-- Repeat string n times
function string_utils.repeat_str(str, n)
    return str:rep(n)
end

-- Pad start to length with fill char
function string_utils.pad_start(str, len, fill)
    fill = fill or " "
    local padding = math.max(0, len - #str)
    return fill:rep(padding) .. str
end

-- Pad end to length with fill char
function string_utils.pad_end(str, len, fill)
    fill = fill or " "
    local padding = math.max(0, len - #str)
    return str .. fill:rep(padding)
end

-- Reverse string
function string_utils.reverse(str)
    return str:reverse()
end

-- Convert to uppercase
function string_utils.to_uppercase(str)
    return str:upper()
end

-- Convert to lowercase
function string_utils.to_lowercase(str)
    return str:lower()
end

-- Convert to title case
function string_utils.to_titlecase(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

-- Convert to snake_case
function string_utils.to_snake_case(str)
    str = str:gsub("([A-Z])", "_%1"):lower()
    str = str:gsub("^_", "")
    str = str:gsub("%s+", "_")
    str = str:gsub("[^%w_]", "")
    return str
end

-- Convert to camelCase
function string_utils.to_camel_case(str)
    str = str:gsub("[-_](%w)", function(c) return c:upper() end)
    str = str:gsub("^%u", function(c) return c:lower() end)
    return str
end

-- Convert to PascalCase
function string_utils.to_pascal_case(str)
    str = str:gsub("[-_](%w)", function(c) return c:upper() end)
    str = str:gsub("^%l", function(c) return c:upper() end)
    return str
end

-- Convert to kebab-case
function string_utils.to_kebab_case(str)
    str = str:gsub("([A-Z])", "-%1"):lower()
    str = str:gsub("^-", "")
    str = str:gsub("%s+", "-")
    str = str:gsub("[^%w-]", "")
    return str
end

-- Count occurrences of substring
function string_utils.count(str, substr)
    local count = 0
    local start = 1
    while true do
        local pos = str:find(substr, start, true)
        if not pos then break end
        count = count + 1
        start = pos + 1
    end
    return count
end

-- Get character at index (1-based)
function string_utils.char_at(str, index)
    if index < 1 or index > #str then
        return nil
    end
    return str:sub(index, index)
end

-- Get slice of string
function string_utils.slice(str, start_idx, end_idx)
    return str:sub(start_idx, end_idx)
end

-- Find first occurrence
function string_utils.find(str, substr)
    local pos = str:find(substr, 1, true)
    return pos
end

-- Find last occurrence
function string_utils.rfind(str, substr)
    local last_pos = nil
    local start = 1
    while true do
        local pos = str:find(substr, start, true)
        if not pos then break end
        last_pos = pos
        start = pos + 1
    end
    return last_pos
end

-- Check if string is empty
function string_utils.is_empty(str)
    return #str == 0
end

-- Check if string is alphanumeric
function string_utils.is_alphanumeric(str)
    return str:match("^%w+$") ~= nil
end

-- Check if string is alphabetic
function string_utils.is_alphabetic(str)
    return str:match("^%a+$") ~= nil
end

-- Check if string is numeric
function string_utils.is_numeric(str)
    return str:match("^%d+$") ~= nil
end

-- Check if string is whitespace
function string_utils.is_whitespace(str)
    return str:match("^%s*$") ~= nil
end

-- Join strings with separator
function string_utils.join(strings, separator)
    return table.concat(strings, separator)
end

-- Interleave strings
function string_utils.interleave(str1, str2)
    local result = {}
    local max_len = math.max(#str1, #str2)

    for i = 1, max_len do
        if i <= #str1 then
            result[#result + 1] = str1:sub(i, i)
        end
        if i <= #str2 then
            result[#result + 1] = str2:sub(i, i)
        end
    end

    return table.concat(result)
end

-- Truncate string to length with suffix
function string_utils.truncate(str, len, suffix)
    suffix = suffix or "..."
    if #str <= len then
        return str
    end
    return str:sub(1, len - #suffix) .. suffix
end

-- Escape special characters for pattern matching
function string_utils.escape_pattern(str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

-- Levenshtein distance (edit distance)
function string_utils.levenshtein(str1, str2)
    local len1, len2 = #str1, #str2
    local matrix = {}

    for i = 0, len1 do
        matrix[i] = {[0] = i}
    end

    for j = 0, len2 do
        matrix[0][j] = j
    end

    for i = 1, len1 do
        for j = 1, len2 do
            local cost = str1:sub(i, i) == str2:sub(j, j) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i - 1][j] + 1,
                matrix[i][j - 1] + 1,
                matrix[i - 1][j - 1] + cost
            )
        end
    end

    return matrix[len1][len2]
end

-- Check string similarity (0-1)
function string_utils.similarity(str1, str2)
    local max_len = math.max(#str1, #str2)
    if max_len == 0 then return 1.0 end
    local distance = string_utils.levenshtein(str1, str2)
    return 1.0 - (distance / max_len)
end

-- Encode to base64
function string_utils.to_base64(str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local result = {}

    for i = 1, #str, 3 do
        local a, b, c = str:byte(i, i + 2)
        b = b or 0
        c = c or 0

        local value = a * 65536 + b * 256 + c
        local d1 = math.floor(value / 262144) + 1
        local d2 = math.floor((value % 262144) / 4096) + 1
        local d3 = math.floor((value % 4096) / 64) + 1
        local d4 = (value % 64) + 1

        result[#result + 1] = b64chars:sub(d1, d1)
        result[#result + 1] = b64chars:sub(d2, d2)
        result[#result + 1] = i + 1 <= #str and b64chars:sub(d3, d3) or '='
        result[#result + 1] = i + 2 <= #str and b64chars:sub(d4, d4) or '='
    end

    return table.concat(result)
end

-- Chars iterator
function string_utils.chars(str)
    local i = 0
    return function()
        i = i + 1
        if i <= #str then
            return str:sub(i, i)
        end
    end
end

-- Bytes iterator
function string_utils.bytes(str)
    local i = 0
    return function()
        i = i + 1
        if i <= #str then
            return str:byte(i)
        end
    end
end

-- Format with named placeholders
function string_utils.format(template, values)
    return template:gsub("{(%w+)}", values)
end

return string_utils
