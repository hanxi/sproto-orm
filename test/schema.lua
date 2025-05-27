-- Code generated from schema_define.lua
-- DO NOT EDIT!

local orm_base = require("orm_base")
local tointeger = math.tointeger
local sformat = string.format

local number_type = setmetatable({}, {
    __tostring = function()
        return "schema_number"
    end,
})
local number = setmetatable({}, {
    __metatable = number_type,
})

local integer_type = setmetatable({}, {
    __tostring = function()
        return "schema_integer"
    end,
})
local integer = setmetatable({}, {
    __metatable = integer_type,
})

local string_type = setmetatable({}, {
    __tostring = function()
        return "schema_string"
    end,
})
local string = setmetatable({}, {
    __metatable = string_type,
})

local boolean_type = setmetatable({}, {
    __tostring = function()
        return "schema_boolean"
    end,
})
local boolean = setmetatable({}, {
    __metatable = boolean_type,
})

local function _check_k_tp(k, need_tp)
    local need_tp_mt =  getmetatable(need_tp)
    if need_tp_mt == integer_type then
        if (type(k) ~= "number") or (tointeger(k) == nil) then
            error(sformat("not equal k type. need integer, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp_mt)))
        end
        return
    elseif need_tp_mt == string_type then
        if type(k) ~= "string" then
            error(sformat("not equal k type. need string, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp_mt)))
            return false
        end
        return
    end
    error(sformat("not support need_tp type: %s, k: %s", tostring(need_tp_mt), tostring(k)))
end

local function _check_v_tp(v, need_tp)
    local need_tp_mt = getmetatable(need_tp)
    if need_tp_mt == integer_type then
        if (type(v) ~= "number") or (tointeger(v) == nil) then
            error(sformat("not equal v type. need integer, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp_mt)))
        end
        return
    elseif need_tp_mt == number_type then
        if type(v) ~= "number" then
            error(sformat("not equal v type. need number, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp_mt)))
        end
        return
    elseif need_tp_mt == string_type then
        if type(v) ~= "string" then
            error(sformat("not equal v type. need string, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp_mt)))
        end
        return
    elseif need_tp_mt == boolean_type then
        if type(v) ~= "boolean" then
            error(sformat("not equal v type. need boolean, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp_mt)))
        end
        return
    end
    if getmetatable(v) ~= need_tp_mt then
        error(sformat("not equal v type. need_tp: %s, real_tp: %s, v: %s", tostring(need_tp_mt), tostring(getmetatable(v)), tostring(v)))
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

local AddressBook, AddressBook_type = {}, {}
local map_integer_Person, map_integer_Person_type = {}, {}
local PhoneNumber, PhoneNumber_type = {}, {}
local Person, Person_type = {}, {}
local map_string_PhoneNumber, map_string_PhoneNumber_type = {}, {}
local map_string_integer, map_string_integer_type = {}, {}
local arr_PhoneNumber, arr_PhoneNumber_type = {}, {}

setmetatable(map_integer_Person_type, {
    __tostring = function()
        return "schema_map_integer_Person"
    end,
})
map_integer_Person._check_k = check_k_func(integer)
map_integer_Person._check_kv = check_kv_func(integer, Person)
map_integer_Person.new = function(init)
    return orm_base.new(map_integer_Person, init)
end
setmetatable(map_integer_Person, {
    __metatable = map_integer_Person_type,
    __index = function(t, k)
        return Person
    end,
})

setmetatable(AddressBook_type, {
    __tostring = function()
        return "schema_AddressBook"
    end,
})
AddressBook.person = map_integer_Person
AddressBook._check_k = check_k
AddressBook._check_kv = check_kv
AddressBook.new = function(init)
    return orm_base.new(AddressBook, init)
end
setmetatable(AddressBook, {
    __metatable = AddressBook_type,
})

setmetatable(PhoneNumber_type, {
    __tostring = function()
        return "schema_PhoneNumber"
    end,
})
PhoneNumber.number = string
PhoneNumber.type = integer
PhoneNumber._check_k = check_k
PhoneNumber._check_kv = check_kv
PhoneNumber.new = function(init)
    return orm_base.new(PhoneNumber, init)
end
setmetatable(PhoneNumber, {
    __metatable = PhoneNumber_type,
})

setmetatable(map_string_PhoneNumber_type, {
    __tostring = function()
        return "schema_map_string_PhoneNumber"
    end,
})
map_string_PhoneNumber._check_k = check_k_func(string)
map_string_PhoneNumber._check_kv = check_kv_func(string, PhoneNumber)
map_string_PhoneNumber.new = function(init)
    return orm_base.new(map_string_PhoneNumber, init)
end
setmetatable(map_string_PhoneNumber, {
    __metatable = map_string_PhoneNumber_type,
    __index = function(t, k)
        return PhoneNumber
    end,
})

setmetatable(map_string_integer_type, {
    __tostring = function()
        return "schema_map_string_integer"
    end,
})
map_string_integer._check_k = check_k_func(string)
map_string_integer._check_kv = check_kv_func(string, integer)
map_string_integer.new = function(init)
    return orm_base.new(map_string_integer, init)
end
setmetatable(map_string_integer, {
    __metatable = map_string_integer_type,
    __index = function(t, k)
        return integer
    end,
})

setmetatable(arr_PhoneNumber_type, {
    __tostring = function()
        return "schema_arr_PhoneNumber"
    end,
})
arr_PhoneNumber._check_k = check_k_func(integer)
arr_PhoneNumber._check_kv = check_kv_func(integer, PhoneNumber)
arr_PhoneNumber.new = function(init)
    return orm_base.new(arr_PhoneNumber, init)
end
setmetatable(arr_PhoneNumber, {
    __metatable = arr_PhoneNumber_type,
    __index = function(t, k)
        return PhoneNumber
    end,
})

setmetatable(Person_type, {
    __tostring = function()
        return "schema_Person"
    end,
})
Person.phonemapkv = map_string_PhoneNumber
Person.onephone = PhoneNumber
Person.name = string
Person.phonemap = map_string_integer
Person.id = integer
Person.phone = arr_PhoneNumber
Person._check_k = check_k
Person._check_kv = check_kv
Person.new = function(init)
    return orm_base.new(Person, init)
end
setmetatable(Person, {
    __metatable = Person_type,
})

return {
    AddressBook = AddressBook,
    map_integer_Person = map_integer_Person,
    PhoneNumber = PhoneNumber,
    Person = Person,
    map_string_PhoneNumber = map_string_PhoneNumber,
    map_string_integer = map_string_integer,
    arr_PhoneNumber = arr_PhoneNumber,
}
