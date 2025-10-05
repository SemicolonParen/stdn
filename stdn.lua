-- stdn: Standard Native Library for Lua
-- A comprehensive standard library inspired by Rust's std::
-- Version: 1.0.0
-- License: MIT

local stdn = {
    _VERSION = "1.0.0",
    _DESCRIPTION = "Standard Native Library for Lua - Rust-inspired std:: for Lua",
    _LICENSE = "MIT"
}

-- Load all modules
stdn.result = require("stdn.result")
stdn.option = require("stdn.option")
stdn.vec = require("stdn.collections.vec")
stdn.hashmap = require("stdn.collections.hashmap")
stdn.hashset = require("stdn.collections.hashset")
stdn.iter = require("stdn.iter")
stdn.string = require("stdn.string")
stdn.fs = require("stdn.fs")
stdn.path = require("stdn.path")
stdn.error = require("stdn.error")
stdn.math = require("stdn.math")
stdn.io = require("stdn.io")
stdn.time = require("stdn.time")
stdn.thread = require("stdn.thread")

-- Convenience exports
stdn.Ok = stdn.result.Ok
stdn.Err = stdn.result.Err
stdn.Some = stdn.option.Some
stdn.None = stdn.option.None
stdn.panic = stdn.error.panic
stdn.assert_eq = stdn.error.assert_eq

return stdn
