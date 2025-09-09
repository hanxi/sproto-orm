-- Code generated from schema_define.lua
-- DO NOT EDIT!

local orm = require "orm"
local tointeger = math.tointeger
local sformat = string.format

local number = setmetatable({
    type = "number",
}, {
    __tostring = function()
        return "schema_number"
    end,
})

local integer = setmetatable({
    type = "integer",
}, {
    __tostring = function()
        return "schema_integer"
    end,
})

local string = setmetatable({
    type = "string",
}, {
    __tostring = function()
        return "schema_string"
    end,
})

local boolean = setmetatable({
    type = "boolean",
}, {
    __tostring = function()
        return "schema_boolean"
    end,
})

local function _parse_k_tp(k, need_tp)
    if need_tp == integer then
        nk = tointeger(k)
        if tointeger(k) == nil then
            error(sformat("not equal k type. need integer, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp)))
        end
        return nk
    elseif need_tp == string then
        return tostring(k)
    end
    error(sformat("not support need_tp type: %s, k: %s", tostring(need_tp), tostring(k)))
end

local function _check_k_tp(k, need_tp)
    if need_tp == integer then
        if (type(k) ~= "number") or (tointeger(k) == nil) then
            error(sformat("not equal k type. need integer, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp)))
        end
        return
    elseif need_tp == string then
        if type(k) ~= "string" then
            error(sformat("not equal k type. need string, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp)))
        end
        return
    end
    error(sformat("not support need_tp type: %s, k: %s", tostring(need_tp), tostring(k)))
end

local function _check_v_tp(v, need_tp)
    if need_tp == integer then
        if (type(v) ~= "number") or (tointeger(v) == nil) then
            error(sformat("not equal v type. need integer, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp)))
        end
        return
    elseif need_tp == number then
        if type(v) ~= "number" then
            error(sformat("not equal v type. need number, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp)))
        end
        return
    elseif need_tp == string then
        if type(v) ~= "string" then
            error(sformat("not equal v type. need string, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp)))
        end
        return
    elseif need_tp == boolean then
        if type(v) ~= "boolean" then
            error(sformat("not equal v type. need boolean, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp)))
        end
        return
    end
    if v ~= need_tp then
        error(sformat("not equal v type. need_tp: %s, v: %s", tostring(need_tp), tostring(v)))
    end
end

local function parse_k_func(need_tp)
    return function(self, k)
        return _parse_k_tp(k, need_tp)
    end
end

local function check_k_func(need_tp)
    return function(self, k)
        _check_k_tp(k, need_tp)
    end
end

local function check_kv_func(k_need_tp, v_need_tp)
    return function(self, k, v)
        _check_k_tp(k, k_need_tp)
        _check_v_tp(v, v_need_tp)
    end
end

local function parse_k(self, k)
    local schema = self[k]
    if not schema then
        error(sformat("not exist key: %s", k))
    end
    return k
end

local function check_k(self, k)
    local schema = self[k]
    if not schema then
        error(sformat("not exist key: %s", k))
    end
end

local function check_kv(self, k, v)
    local schema = self[k]
    if not schema then
        error(sformat("not exist key: %s", k))
    end

    _check_v_tp(v, schema)
end

local AddressBook = { type = "struct" }
local map_integer_Person = { type = "map"}
local IntKeyStringValue = { type = "struct" }
local Person = { type = "struct" }
local map_integer_string = { type = "map"}
local arr_PhoneNumber = { type = "array" }
local map_string_integer = { type = "map"}
local map_string_PhoneNumber = { type = "map"}
local PhoneNumber = { type = "struct" }

setmetatable(map_integer_Person, {
    __tostring = function()
        return "schema_map_integer_Person"
    end,
    __index = function(t, k)
        return Person
    end,
})
map_integer_Person._parse_k = parse_k_func(integer)
map_integer_Person._check_k = check_k_func(integer)
map_integer_Person._check_kv = check_kv_func(integer, Person)
map_integer_Person.new = function(init)
    return orm.new(map_integer_Person, init)
end

setmetatable(AddressBook, {
    __tostring = function()
        return "schema_AddressBook"
    end,
})
AddressBook.person = map_integer_Person
AddressBook._parse_k = parse_k
AddressBook._check_k = check_k
AddressBook._check_kv = check_kv
AddressBook.new = function(init)
    return orm.new(AddressBook, init)
end

setmetatable(IntKeyStringValue, {
    __tostring = function()
        return "schema_IntKeyStringValue"
    end,
})
IntKeyStringValue.key = integer
IntKeyStringValue.value = string
IntKeyStringValue._parse_k = parse_k
IntKeyStringValue._check_k = check_k
IntKeyStringValue._check_kv = check_kv
IntKeyStringValue.new = function(init)
    return orm.new(IntKeyStringValue, init)
end

setmetatable(map_integer_string, {
    __tostring = function()
        return "schema_map_integer_string"
    end,
    __index = function(t, k)
        return string
    end,
})
map_integer_string._parse_k = parse_k_func(integer)
map_integer_string._check_k = check_k_func(integer)
map_integer_string._check_kv = check_kv_func(integer, string)
map_integer_string.new = function(init)
    return orm.new(map_integer_string, init)
end

setmetatable(arr_PhoneNumber, {
    __tostring = function()
        return "schema_arr_PhoneNumber"
    end,
    __index = function(t, k)
        return PhoneNumber
    end,
})
arr_PhoneNumber._parse_k = parse_k_func(integer)
arr_PhoneNumber._check_k = check_k_func(integer)
arr_PhoneNumber._check_kv = check_kv_func(integer, PhoneNumber)
arr_PhoneNumber.new = function(init)
    return orm.new(arr_PhoneNumber, init)
end

setmetatable(map_string_integer, {
    __tostring = function()
        return "schema_map_string_integer"
    end,
    __index = function(t, k)
        return integer
    end,
})
map_string_integer._parse_k = parse_k_func(string)
map_string_integer._check_k = check_k_func(string)
map_string_integer._check_kv = check_kv_func(string, integer)
map_string_integer.new = function(init)
    return orm.new(map_string_integer, init)
end

setmetatable(map_string_PhoneNumber, {
    __tostring = function()
        return "schema_map_string_PhoneNumber"
    end,
    __index = function(t, k)
        return PhoneNumber
    end,
})
map_string_PhoneNumber._parse_k = parse_k_func(string)
map_string_PhoneNumber._check_k = check_k_func(string)
map_string_PhoneNumber._check_kv = check_kv_func(string, PhoneNumber)
map_string_PhoneNumber.new = function(init)
    return orm.new(map_string_PhoneNumber, init)
end

setmetatable(Person, {
    __tostring = function()
        return "schema_Person"
    end,
})
Person.i2s = map_integer_string
Person.id = integer
Person.name = string
Person.onephone = PhoneNumber
Person.phone = arr_PhoneNumber
Person.phonemap = map_string_integer
Person.phonemapkv = map_string_PhoneNumber
Person._parse_k = parse_k
Person._check_k = check_k
Person._check_kv = check_kv
Person.new = function(init)
    return orm.new(Person, init)
end

setmetatable(PhoneNumber, {
    __tostring = function()
        return "schema_PhoneNumber"
    end,
})
PhoneNumber.number = string
PhoneNumber.type = integer
PhoneNumber._parse_k = parse_k
PhoneNumber._check_k = check_k
PhoneNumber._check_kv = check_kv
PhoneNumber.new = function(init)
    return orm.new(PhoneNumber, init)
end

return {
    AddressBook = AddressBook,
    map_integer_Person = map_integer_Person,
    IntKeyStringValue = IntKeyStringValue,
    Person = Person,
    map_integer_string = map_integer_string,
    arr_PhoneNumber = arr_PhoneNumber,
    map_string_integer = map_string_integer,
    map_string_PhoneNumber = map_string_PhoneNumber,
    PhoneNumber = PhoneNumber,
}
