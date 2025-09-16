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
local bag = { type = "struct" }
local map_integer_resource = { type = "map"}
local mail = { type = "struct" }
local map_string_string = { type = "map"}
local mail_attach = { type = "struct" }
local mail_role = { type = "struct" }
local resource = { type = "struct" }
local role = { type = "struct" }
local role_bag = { type = "struct" }
local map_integer_bag = { type = "map"}
local role_mail = { type = "struct" }
local map_integer_mail = { type = "map"}
local role_modules = { type = "struct" }
local str2str = { type = "struct" }

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
local AddressBook_fields = {"person"}
AddressBook.fields = function()
    return AddressBook_fields
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
local IntKeyStringValue_fields = {"key","value"}
IntKeyStringValue.fields = function()
    return IntKeyStringValue_fields
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
local Person_fields = {"i2s","id","name","onephone","phone","phonemap","phonemapkv"}
Person.fields = function()
    return Person_fields
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
local PhoneNumber_fields = {"number","type"}
PhoneNumber.fields = function()
    return PhoneNumber_fields
end

setmetatable(map_integer_resource, {
    __tostring = function()
        return "schema_map_integer_resource"
    end,
    __index = function(t, k)
        return resource
    end,
})
map_integer_resource._parse_k = parse_k_func(integer)
map_integer_resource._check_k = check_k_func(integer)
map_integer_resource._check_kv = check_kv_func(integer, resource)
map_integer_resource.new = function(init)
    return orm.new(map_integer_resource, init)
end

setmetatable(bag, {
    __tostring = function()
        return "schema_bag"
    end,
})
bag.res = map_integer_resource
bag.res_type = integer
bag._parse_k = parse_k
bag._check_k = check_k
bag._check_kv = check_kv
bag.new = function(init)
    return orm.new(bag, init)
end
local bag_fields = {"res","res_type"}
bag.fields = function()
    return bag_fields
end

setmetatable(map_string_string, {
    __tostring = function()
        return "schema_map_string_string"
    end,
    __index = function(t, k)
        return string
    end,
})
map_string_string._parse_k = parse_k_func(string)
map_string_string._check_k = check_k_func(string)
map_string_string._check_kv = check_kv_func(string, string)
map_string_string.new = function(init)
    return orm.new(map_string_string, init)
end

setmetatable(mail, {
    __tostring = function()
        return "schema_mail"
    end,
})
mail.attach = mail_attach
mail.cfg_id = integer
mail.detail = map_string_string
mail.mail_id = integer
mail.send_role = mail_role
mail.send_time = integer
mail.title = map_string_string
mail._parse_k = parse_k
mail._check_k = check_k
mail._check_kv = check_kv
mail.new = function(init)
    return orm.new(mail, init)
end
local mail_fields = {"attach","cfg_id","detail","mail_id","send_role","send_time","title"}
mail.fields = function()
    return mail_fields
end

setmetatable(mail_attach, {
    __tostring = function()
        return "schema_mail_attach"
    end,
})
mail_attach.res_id = integer
mail_attach.res_size = integer
mail_attach.res_type = integer
mail_attach._parse_k = parse_k
mail_attach._check_k = check_k
mail_attach._check_kv = check_kv
mail_attach.new = function(init)
    return orm.new(mail_attach, init)
end
local mail_attach_fields = {"res_id","res_size","res_type"}
mail_attach.fields = function()
    return mail_attach_fields
end

setmetatable(mail_role, {
    __tostring = function()
        return "schema_mail_role"
    end,
})
mail_role.name = string
mail_role.rid = integer
mail_role._parse_k = parse_k
mail_role._check_k = check_k
mail_role._check_kv = check_kv
mail_role.new = function(init)
    return orm.new(mail_role, init)
end
local mail_role_fields = {"name","rid"}
mail_role.fields = function()
    return mail_role_fields
end

setmetatable(resource, {
    __tostring = function()
        return "schema_resource"
    end,
})
resource.res_id = integer
resource.res_size = integer
resource._parse_k = parse_k
resource._check_k = check_k
resource._check_kv = check_kv
resource.new = function(init)
    return orm.new(resource, init)
end
local resource_fields = {"res_id","res_size"}
resource.fields = function()
    return resource_fields
end

setmetatable(role, {
    __tostring = function()
        return "schema_role"
    end,
})
role._version = integer
role.account = string
role.create_time = integer
role.last_login_time = integer
role.modules = role_modules
role.name = string
role.rid = integer
role._parse_k = parse_k
role._check_k = check_k
role._check_kv = check_kv
role.new = function(init)
    return orm.new(role, init)
end
local role_fields = {"_version","account","create_time","last_login_time","modules","name","rid"}
role.fields = function()
    return role_fields
end

setmetatable(map_integer_bag, {
    __tostring = function()
        return "schema_map_integer_bag"
    end,
    __index = function(t, k)
        return bag
    end,
})
map_integer_bag._parse_k = parse_k_func(integer)
map_integer_bag._check_k = check_k_func(integer)
map_integer_bag._check_kv = check_kv_func(integer, bag)
map_integer_bag.new = function(init)
    return orm.new(map_integer_bag, init)
end

setmetatable(role_bag, {
    __tostring = function()
        return "schema_role_bag"
    end,
})
role_bag.bags = map_integer_bag
role_bag._parse_k = parse_k
role_bag._check_k = check_k
role_bag._check_kv = check_kv
role_bag.new = function(init)
    return orm.new(role_bag, init)
end
local role_bag_fields = {"bags"}
role_bag.fields = function()
    return role_bag_fields
end

setmetatable(map_integer_mail, {
    __tostring = function()
        return "schema_map_integer_mail"
    end,
    __index = function(t, k)
        return mail
    end,
})
map_integer_mail._parse_k = parse_k_func(integer)
map_integer_mail._check_k = check_k_func(integer)
map_integer_mail._check_kv = check_kv_func(integer, mail)
map_integer_mail.new = function(init)
    return orm.new(map_integer_mail, init)
end

setmetatable(role_mail, {
    __tostring = function()
        return "schema_role_mail"
    end,
})
role_mail._version = integer
role_mail.mails = map_integer_mail
role_mail._parse_k = parse_k
role_mail._check_k = check_k
role_mail._check_kv = check_kv
role_mail.new = function(init)
    return orm.new(role_mail, init)
end
local role_mail_fields = {"_version","mails"}
role_mail.fields = function()
    return role_mail_fields
end

setmetatable(role_modules, {
    __tostring = function()
        return "schema_role_modules"
    end,
})
role_modules.bag = role_bag
role_modules.mail = role_mail
role_modules._parse_k = parse_k
role_modules._check_k = check_k
role_modules._check_kv = check_kv
role_modules.new = function(init)
    return orm.new(role_modules, init)
end
local role_modules_fields = {"bag","mail"}
role_modules.fields = function()
    return role_modules_fields
end

setmetatable(str2str, {
    __tostring = function()
        return "schema_str2str"
    end,
})
str2str.key = string
str2str.value = string
str2str._parse_k = parse_k
str2str._check_k = check_k
str2str._check_kv = check_kv
str2str.new = function(init)
    return orm.new(str2str, init)
end
local str2str_fields = {"key","value"}
str2str.fields = function()
    return str2str_fields
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
    bag = bag,
    map_integer_resource = map_integer_resource,
    mail = mail,
    map_string_string = map_string_string,
    mail_attach = mail_attach,
    mail_role = mail_role,
    resource = resource,
    role = role,
    role_bag = role_bag,
    map_integer_bag = map_integer_bag,
    role_mail = role_mail,
    map_integer_mail = map_integer_mail,
    role_modules = role_modules,
    str2str = str2str,
}
