-- stdn.fs: Filesystem operations with Rust-like API
-- Provides safe file and directory operations

local fs = {}
local result = require("stdn.result")

-- Check if path exists
function fs.exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- Check if path is a file
function fs.is_file(path)
    local file = io.open(path, "r")
    if not file then
        return false
    end

    local ok, err, code = file:read(0)
    file:close()

    return code ~= 21
end

-- Check if path is a directory
function fs.is_dir(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            return true
        end
    end
    return ok and true or false
end

-- Read entire file to string
function fs.read_to_string(path)
    local file, err = io.open(path, "r")
    if not file then
        return result.Err(err)
    end

    local content = file:read("*all")
    file:close()

    if content then
        return result.Ok(content)
    else
        return result.Err("failed to read file")
    end
end

-- Read file as lines
function fs.read_lines(path)
    local file, err = io.open(path, "r")
    if not file then
        return result.Err(err)
    end

    local lines = {}
    for line in file:lines() do
        table.insert(lines, line)
    end
    file:close()

    return result.Ok(lines)
end

-- Write string to file
function fs.write(path, content)
    local file, err = io.open(path, "w")
    if not file then
        return result.Err(err)
    end

    local ok, write_err = file:write(content)
    file:close()

    if ok then
        return result.Ok(nil)
    else
        return result.Err(write_err or "failed to write file")
    end
end

-- Append string to file
function fs.append(path, content)
    local file, err = io.open(path, "a")
    if not file then
        return result.Err(err)
    end

    local ok, write_err = file:write(content)
    file:close()

    if ok then
        return result.Ok(nil)
    else
        return result.Err(write_err or "failed to append to file")
    end
end

-- Copy file
function fs.copy(src, dest)
    local src_file, src_err = io.open(src, "rb")
    if not src_file then
        return result.Err(src_err)
    end

    local content = src_file:read("*all")
    src_file:close()

    local dest_file, dest_err = io.open(dest, "wb")
    if not dest_file then
        return result.Err(dest_err)
    end

    local ok, write_err = dest_file:write(content)
    dest_file:close()

    if ok then
        return result.Ok(nil)
    else
        return result.Err(write_err or "failed to write destination file")
    end
end

-- Move/rename file
function fs.rename(old_path, new_path)
    local ok, err = os.rename(old_path, new_path)
    if ok then
        return result.Ok(nil)
    else
        return result.Err(err)
    end
end

-- Delete file
function fs.remove(path)
    local ok, err = os.remove(path)
    if ok then
        return result.Ok(nil)
    else
        return result.Err(err)
    end
end

-- Create directory
function fs.create_dir(path)
    local ok, err = os.execute("mkdir " .. path)
    if ok then
        return result.Ok(nil)
    else
        return result.Err(err or "failed to create directory")
    end
end

-- Create directory and all parent directories
function fs.create_dir_all(path)
    local ok, err
    if package.config:sub(1,1) == '\\' then
        ok, err = os.execute("mkdir " .. path)
    else
        ok, err = os.execute("mkdir -p " .. path)
    end

    if ok then
        return result.Ok(nil)
    else
        return result.Err(err or "failed to create directories")
    end
end

-- Remove directory
function fs.remove_dir(path)
    local ok, err
    if package.config:sub(1,1) == '\\' then
        ok, err = os.execute("rmdir " .. path)
    else
        ok, err = os.execute("rmdir " .. path)
    end

    if ok then
        return result.Ok(nil)
    else
        return result.Err(err or "failed to remove directory")
    end
end

-- Remove directory and all contents
function fs.remove_dir_all(path)
    local ok, err
    if package.config:sub(1,1) == '\\' then
        ok, err = os.execute("rmdir /s /q " .. path)
    else
        ok, err = os.execute("rm -rf " .. path)
    end

    if ok then
        return result.Ok(nil)
    else
        return result.Err(err or "failed to remove directory tree")
    end
end

-- Get file metadata (size, modification time)
function fs.metadata(path)
    if not fs.exists(path) then
        return result.Err("path does not exist")
    end

    local ok, err, code = os.rename(path, path)
    if not ok and code == 13 then
        return result.Ok({
            is_file = false,
            is_dir = true,
            exists = true
        })
    end

    local file = io.open(path, "r")
    if not file then
        return result.Err("cannot open file")
    end

    local size = file:seek("end")
    file:close()

    return result.Ok({
        is_file = true,
        is_dir = false,
        exists = true,
        size = size
    })
end

-- Get file size
function fs.file_size(path)
    local file, err = io.open(path, "r")
    if not file then
        return result.Err(err)
    end

    local size = file:seek("end")
    file:close()

    return result.Ok(size)
end

-- Read directory entries
function fs.read_dir(path)
    local entries = {}
    local handle

    if package.config:sub(1,1) == '\\' then
        handle = io.popen('dir "' .. path .. '" /b')
    else
        handle = io.popen('ls -1 "' .. path .. '"')
    end

    if not handle then
        return result.Err("failed to read directory")
    end

    for entry in handle:lines() do
        table.insert(entries, entry)
    end

    handle:close()
    return result.Ok(entries)
end

-- Walk directory tree recursively
function fs.walk_dir(path, callback)
    local function walk(dir)
        local entries_result = fs.read_dir(dir)
        if entries_result:is_err() then
            return
        end

        local entries = entries_result:unwrap()
        for _, entry in ipairs(entries) do
            local full_path = dir .. "/" .. entry

            callback(full_path)

            if fs.is_dir(full_path) then
                walk(full_path)
            end
        end
    end

    local success, err = pcall(walk, path)
    if success then
        return result.Ok(nil)
    else
        return result.Err(err)
    end
end

-- Create temporary file
function fs.create_temp_file(prefix)
    prefix = prefix or "tmp"
    local temp_path = os.tmpname()

    local file, err = io.open(temp_path, "w")
    if not file then
        return result.Err(err)
    end

    file:close()
    return result.Ok(temp_path)
end

-- Canonicalize path (resolve to absolute path)
function fs.canonicalize(path)
    if package.config:sub(1,1) == '\\' then
        local handle = io.popen('cd "' .. path .. '" && cd')
        if not handle then
            return result.Err("failed to resolve path")
        end
        local abs_path = handle:read("*l")
        handle:close()
        return result.Ok(abs_path)
    else
        local handle = io.popen('realpath "' .. path .. '"')
        if not handle then
            return result.Err("failed to resolve path")
        end
        local abs_path = handle:read("*l")
        handle:close()
        return result.Ok(abs_path)
    end
end

return fs
