-- stdn.io: Enhanced I/O operations
-- Provides buffered and formatted I/O utilities

local io_utils = {}
local result = require("stdn.result")

-- Stdin utilities
io_utils.stdin = {}

-- Read line from stdin
function io_utils.stdin.read_line()
    local line = io.read("*l")
    if line then
        return result.Ok(line)
    else
        return result.Err("failed to read line")
    end
end

-- Read all from stdin
function io_utils.stdin.read_all()
    local content = io.read("*a")
    if content then
        return result.Ok(content)
    else
        return result.Err("failed to read stdin")
    end
end

-- Read stdin lines as iterator
function io_utils.stdin.lines()
    return io.lines()
end

-- Stdout utilities
io_utils.stdout = {}

-- Write to stdout
function io_utils.stdout.write(...)
    io.write(...)
    return result.Ok(nil)
end

-- Write line to stdout
function io_utils.stdout.write_line(str)
    io.write(str, "\n")
    return result.Ok(nil)
end

-- Flush stdout
function io_utils.stdout.flush()
    io.flush()
    return result.Ok(nil)
end

-- Formatted print
function io_utils.stdout.printf(fmt, ...)
    io.write(string.format(fmt, ...))
    return result.Ok(nil)
end

-- Stderr utilities
io_utils.stderr = {}

-- Write to stderr
function io_utils.stderr.write(...)
    io.stderr:write(...)
    return result.Ok(nil)
end

-- Write line to stderr
function io_utils.stderr.write_line(str)
    io.stderr:write(str, "\n")
    return result.Ok(nil)
end

-- Flush stderr
function io_utils.stderr.flush()
    io.stderr:flush()
    return result.Ok(nil)
end

-- Formatted print to stderr
function io_utils.stderr.printf(fmt, ...)
    io.stderr:write(string.format(fmt, ...))
    return result.Ok(nil)
end

-- Buffered reader
local BufReader = {}
BufReader.__index = BufReader

function io_utils.buf_reader(file_or_path)
    local self = setmetatable({}, BufReader)

    if type(file_or_path) == "string" then
        local file, err = io.open(file_or_path, "r")
        if not file then
            return nil, err
        end
        self._file = file
        self._owns_file = true
    else
        self._file = file_or_path
        self._owns_file = false
    end

    self._buffer = ""
    self._buffer_size = 4096
    self._eof = false

    return self
end

function BufReader:read_line()
    while true do
        local newline_pos = self._buffer:find("\n", 1, true)

        if newline_pos then
            local line = self._buffer:sub(1, newline_pos - 1)
            self._buffer = self._buffer:sub(newline_pos + 1)
            return result.Ok(line)
        end

        if self._eof then
            if #self._buffer > 0 then
                local line = self._buffer
                self._buffer = ""
                return result.Ok(line)
            else
                return result.Err("EOF")
            end
        end

        local chunk = self._file:read(self._buffer_size)
        if not chunk then
            self._eof = true
        else
            self._buffer = self._buffer .. chunk
        end
    end
end

function BufReader:read_all()
    local parts = {}

    if #self._buffer > 0 then
        table.insert(parts, self._buffer)
        self._buffer = ""
    end

    local chunk = self._file:read("*a")
    if chunk then
        table.insert(parts, chunk)
    end

    self._eof = true
    return result.Ok(table.concat(parts))
end

function BufReader:lines()
    return function()
        local line_result = self:read_line()
        if line_result:is_ok() then
            return line_result:unwrap()
        else
            return nil
        end
    end
end

function BufReader:close()
    if self._owns_file and self._file then
        self._file:close()
    end
end

-- Buffered writer
local BufWriter = {}
BufWriter.__index = BufWriter

function io_utils.buf_writer(file_or_path, buffer_size)
    local self = setmetatable({}, BufWriter)

    if type(file_or_path) == "string" then
        local file, err = io.open(file_or_path, "w")
        if not file then
            return nil, err
        end
        self._file = file
        self._owns_file = true
    else
        self._file = file_or_path
        self._owns_file = false
    end

    self._buffer = {}
    self._buffer_size = buffer_size or 4096
    self._current_size = 0

    return self
end

function BufWriter:write(str)
    table.insert(self._buffer, str)
    self._current_size = self._current_size + #str

    if self._current_size >= self._buffer_size then
        return self:flush()
    end

    return result.Ok(nil)
end

function BufWriter:write_line(str)
    return self:write(str .. "\n")
end

function BufWriter:flush()
    if #self._buffer > 0 then
        local content = table.concat(self._buffer)
        local ok, err = self._file:write(content)

        if not ok then
            return result.Err(err or "write failed")
        end

        self._buffer = {}
        self._current_size = 0
        self._file:flush()
    end

    return result.Ok(nil)
end

function BufWriter:close()
    self:flush()
    if self._owns_file and self._file then
        self._file:close()
    end
end

-- Pretty print
function io_utils.pretty_print(value, indent)
    indent = indent or 0
    local indent_str = string.rep("  ", indent)

    if type(value) == "table" then
        local is_array = true
        local count = 0

        for k, v in pairs(value) do
            count = count + 1
            if type(k) ~= "number" or k ~= count then
                is_array = false
                break
            end
        end

        if is_array and count > 0 then
            io.write("[\n")
            for i, v in ipairs(value) do
                io.write(indent_str, "  ")
                io_utils.pretty_print(v, indent + 1)
                if i < #value then
                    io.write(",")
                end
                io.write("\n")
            end
            io.write(indent_str, "]")
        else
            io.write("{\n")
            local is_first = true
            for k, v in pairs(value) do
                if not is_first then
                    io.write(",\n")
                end
                io.write(indent_str, "  ", tostring(k), " = ")
                io_utils.pretty_print(v, indent + 1)
                is_first = false
            end
            if not is_first then
                io.write("\n")
            end
            io.write(indent_str, "}")
        end
    elseif type(value) == "string" then
        io.write(string.format("%q", value))
    else
        io.write(tostring(value))
    end

    if indent == 0 then
        io.write("\n")
    end
end

-- Prompt for input
function io_utils.prompt(message)
    io.write(message)
    io.flush()
    return io.read("*l")
end

-- Confirm yes/no
function io_utils.confirm(message)
    local response = io_utils.prompt(message .. " (y/n): ")
    return response and (response:lower() == "y" or response:lower() == "yes")
end

return io_utils
