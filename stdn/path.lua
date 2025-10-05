-- stdn.path: Path manipulation utilities
-- Provides cross-platform path operations

local path = {}

-- Determine path separator
local separator = package.config:sub(1,1)
path.SEPARATOR = separator

-- Join path components
function path.join(...)
    local parts = {...}
    local result = {}

    for _, part in ipairs(parts) do
        if part ~= "" then
            table.insert(result, part)
        end
    end

    return table.concat(result, separator)
end

-- Get file name from path
function path.file_name(filepath)
    return filepath:match("^.+[/\\](.+)$") or filepath
end

-- Get file stem (name without extension)
function path.file_stem(filepath)
    local name = path.file_name(filepath)
    return name:match("^(.+)%..+$") or name
end

-- Get file extension
function path.extension(filepath)
    local name = path.file_name(filepath)
    local ext = name:match("%.([^%.]+)$")
    return ext
end

-- Get parent directory
function path.parent(filepath)
    local parent = filepath:match("^(.+)[/\\][^/\\]+$")
    return parent or ""
end

-- Check if path is absolute
function path.is_absolute(filepath)
    if separator == "\\" then
        return filepath:match("^%a:") ~= nil
    else
        return filepath:sub(1, 1) == "/"
    end
end

-- Check if path is relative
function path.is_relative(filepath)
    return not path.is_absolute(filepath)
end

-- Normalize path (resolve . and ..)
function path.normalize(filepath)
    local parts = {}

    for part in filepath:gmatch("[^/\\]+") do
        if part == ".." then
            if #parts > 0 and parts[#parts] ~= ".." then
                table.remove(parts)
            else
                table.insert(parts, part)
            end
        elseif part ~= "." then
            table.insert(parts, part)
        end
    end

    local result = table.concat(parts, separator)

    if path.is_absolute(filepath) then
        if separator == "\\" then
            local drive = filepath:match("^(%a:)")
            result = drive .. separator .. result
        else
            result = separator .. result
        end
    end

    return result
end

-- Split path into components
function path.components(filepath)
    local parts = {}

    if path.is_absolute(filepath) then
        if separator == "\\" then
            local drive = filepath:match("^(%a:)")
            if drive then
                table.insert(parts, drive)
                filepath = filepath:sub(3)
            end
        else
            table.insert(parts, "/")
            filepath = filepath:sub(2)
        end
    end

    for part in filepath:gmatch("[^/\\]+") do
        table.insert(parts, part)
    end

    return parts
end

-- Add extension to path
function path.with_extension(filepath, ext)
    local stem = path.file_stem(filepath)
    local parent = path.parent(filepath)

    if ext:sub(1, 1) ~= "." then
        ext = "." .. ext
    end

    if parent ~= "" then
        return parent .. separator .. stem .. ext
    else
        return stem .. ext
    end
end

-- Change file name
function path.with_file_name(filepath, name)
    local parent = path.parent(filepath)

    if parent ~= "" then
        return parent .. separator .. name
    else
        return name
    end
end

-- Get common prefix of paths
function path.common_prefix(paths)
    if #paths == 0 then
        return ""
    end

    local components = {}
    for _, p in ipairs(paths) do
        table.insert(components, path.components(p))
    end

    local common = {}
    local min_len = math.huge

    for _, comps in ipairs(components) do
        min_len = math.min(min_len, #comps)
    end

    for i = 1, min_len do
        local comp = components[1][i]
        local all_match = true

        for j = 2, #components do
            if components[j][i] ~= comp then
                all_match = false
                break
            end
        end

        if all_match then
            table.insert(common, comp)
        else
            break
        end
    end

    if #common == 0 then
        return ""
    end

    return table.concat(common, separator)
end

-- Make path relative to base
function path.relative_to(filepath, base)
    local file_parts = path.components(filepath)
    local base_parts = path.components(base)

    local common_len = 0
    for i = 1, math.min(#file_parts, #base_parts) do
        if file_parts[i] == base_parts[i] then
            common_len = i
        else
            break
        end
    end

    local result = {}

    for i = common_len + 1, #base_parts do
        table.insert(result, "..")
    end

    for i = common_len + 1, #file_parts do
        table.insert(result, file_parts[i])
    end

    if #result == 0 then
        return "."
    end

    return table.concat(result, separator)
end

-- Convert to forward slashes
function path.to_forward_slashes(filepath)
    return filepath:gsub("\\", "/")
end

-- Convert to backslashes
function path.to_back_slashes(filepath)
    return filepath:gsub("/", "\\")
end

-- Expand tilde to home directory
function path.expand_home(filepath)
    if filepath:sub(1, 1) == "~" then
        local home = os.getenv("HOME") or os.getenv("USERPROFILE")
        if home then
            return home .. filepath:sub(2)
        end
    end
    return filepath
end

-- Check if path contains another path
function path.contains(base, sub)
    local base_parts = path.components(path.normalize(base))
    local sub_parts = path.components(path.normalize(sub))

    if #sub_parts < #base_parts then
        return false
    end

    for i = 1, #base_parts do
        if base_parts[i] ~= sub_parts[i] then
            return false
        end
    end

    return true
end

-- Get current working directory
function path.cwd()
    local handle
    if separator == "\\" then
        handle = io.popen("cd")
    else
        handle = io.popen("pwd")
    end

    if not handle then
        return nil
    end

    local cwd = handle:read("*l")
    handle:close()
    return cwd
end

-- Convert to absolute path
function path.absolute(filepath)
    if path.is_absolute(filepath) then
        return path.normalize(filepath)
    end

    local cwd = path.cwd()
    if not cwd then
        return filepath
    end

    return path.normalize(path.join(cwd, filepath))
end

-- Compare two paths
function path.equals(path1, path2)
    return path.normalize(path1) == path.normalize(path2)
end

return path
