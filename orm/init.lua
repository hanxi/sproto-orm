local next = next
local setmetatable = setmetatable
local getmetatable = getmetatable
local type = type
local rawset = rawset
local table = table
local sformat = string.format

local orm = {}
local NULL = setmetatable({}, {
    __tostring = function()
        return "NULL"
    end,
}) -- nil
orm.null = NULL
local ormdoc_type = setmetatable({}, {
    __tostring = function()
        return "ORM"
    end,
})
local tracedoc_len = setmetatable({}, { __mode = "kv" })

local function doc_len(doc)
    return #doc.__stage
end

local function doc_next(doc, k)
    return next(doc.__stage, k)
end

local function doc_pairs(doc)
    return pairs(doc.__stage)
end

local function doc_ipairs(doc)
    return ipairs(doc.__stage)
end

local function doc_unpack(doc, i, j)
    return table.unpack(doc.__stage, i, j)
end

local function doc_concat(doc, sep, i, j)
    return table.concat(doc.__stage, sep, i, j)
end

local function mark_dirty(doc)
    if not doc.__dirty then
        doc.__dirty = true
        local parent = doc.__parent
        while parent do
            if parent.__dirty then
                break
            end
            parent.__dirty = true
            parent = parent.__parent
        end
    end
end

local function doc_change_value(doc, k, v)
    if getmetatable(v) == ormdoc_type then
        doc.__schema:_check_kv(k, v.__schema)
    elseif v ~= nil then
        doc.__schema:_check_kv(k, v)
    end
    if v ~= doc[k] then
        doc.__changed_keys[k] = true -- mark changed (even nil)
        doc.__changed_values[k] = doc.__stage[k] -- lastversion value
        doc.__stage[k] = v -- current value
        mark_dirty(doc)
    end
end

local _new_doc = nil
local function doc_change_recursively(doc, k, v)
    local schema = doc.__schema[k]
    local lv = doc.__stage[k]
    if getmetatable(v) == ormdoc_type then
        assert(not v.__parent, "non-root nodes cannot be assigned to other objects")
        lv = v
    else
        lv = _new_doc(schema, v)
    end

    lv.__parent = doc
    doc_change_value(doc, k, lv)
    lv.__all_dirty = true
end

local function doc_change(doc, k, v)
    -- parse k
    k = doc.__schema:_parse_k(k)

    if type(v) == "table" then
        doc_change_recursively(doc, k, v)
    elseif doc[k] ~= v then
        doc_change_value(doc, k, v)
    end
end

local function deepcopy(object)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            error("not support circular reference")
        end

        local new_table = {}
        lookup_table[obj] = new_table
        for key, value in pairs(obj) do
            new_table[_copy(key)] = _copy(value)
        end

        return new_table
    end
    return _copy(object)
end

local function _clone_doc(doc)
    assert(getmetatable(doc) == ormdoc_type, "only suppor orm")
    local init = deepcopy(doc)
    return _new_doc(doc.__schema, init)
end

-- refer to table.insert()
local function doc_insert(doc, index, v)
    local len = doc_len(doc)
    if v == nil then
        v = index
        index = len + 1
    end

    for i = len, index, -1 do
        doc[i].__parent = false
        doc[i + 1] = doc[i]
    end
    doc[index] = v
end

-- refer to table.remove()
local function doc_remove(doc, index)
    local len = doc_len(doc)
    index = index or len

    local v = doc[index]
    doc[index] = nil -- trig a clone of doc._lastversion[index] in doc_change()

    for i = index + 1, len do
        doc[i].__parent = false
        doc[i - 1] = doc[i]
    end
    doc[len] = nil

    return v
end

_new_doc = function(schema, init)
    assert(schema, "need schema")
    assert(getmetatable(init) ~= ormdoc_type, "can not orm")

    local doc_stage = {}
    setmetatable(doc_stage, {
        __index = function(t, k)
            schema:_check_k(k)
            return rawget(t, k)
        end,
    })
    local init_copy = {}
    for k, v in pairs(init or {}) do
        init_copy[k] = v
        init[k] = nil
    end

    -- use init addr
    local doc = init or {}
    doc.__dirty = false
    doc.__all_dirty = false
    doc.__parent = false
    doc.__changed_keys = {}
    doc.__changed_values = {}
    doc.__stage = doc_stage
    doc.__schema = schema
    setmetatable(doc, {
        __index = doc_stage,
        __newindex = doc_change,
        __pairs = doc_pairs,
        __ipairs = doc_ipairs,
        __len = doc_len,
        __metatable = ormdoc_type, -- avoid copy by ref

        -- 额外接口
        __next = doc_next,
        __unpack = doc_unpack,
        __concat = doc_concat,
        __insert = doc_insert,
        __remove = doc_remove,
    })

    for k, v in pairs(init_copy) do
        if type(v) == "table" then
            if getmetatable(v) == ormdoc_type then
                if v.__parent then
                    v = _clone_doc(v)
                else
                end
            else
                v = _new_doc(schema[k], v)
            end
        end
        doc[k] = v
    end
    return doc
end

local function _clear_dirty(doc, watched)
    -- 不可能有环
    watched = watched or {}
    if watched[doc] then
        error("why orm has circular reference")
        return
    end
    watched[doc] = true
    doc.__dirty = false
    doc.__all_dirty = false
    doc.__changed_keys = {}
    doc.__changed_values = {}
    for _, v in pairs(doc) do
        if getmetatable(v) == ormdoc_type then
            _clear_dirty(v)
        end
    end
end

function orm.new(schema, init)
    local doc = _new_doc(schema, init)
    _clear_dirty(doc)
    return doc
end

function orm.check_type(doc)
    if type(doc) ~= "table" then
        return false
    end
    local mt = getmetatable(doc)
    return mt == ormdoc_type
end

local function unset_all_dirty(tab, visited)
    if not visited then
        visited = {}
    end

    if visited[tab] then
        return
    end

    visited[tab] = true

    tab.__all_dirty = false
    for k, v in pairs(tab) do
        if getmetatable(v) == ormdoc_type then
            unset_all_dirty(v, visited)
        end
    end
end

local function _commit_mongo(doc, result, prefix)
    doc.__dirty = false
    local changed_keys = doc.__changed_keys
    local changed_values = doc.__changed_values
    local stage = doc.__stage
    local dirty = false
    if next(changed_keys) ~= nil then
        dirty = true
        for k in next, changed_keys do
            local v, lv = stage[k], changed_values[k]
            changed_keys[k] = nil
            changed_values[k] = nil
            if result then
                -- TODO: 优化 prefix，改为 path 数组
                local key
                if doc.__schema.type == "array" then
                    key = prefix and (prefix .. (k - 1)) or tostring(k - 1)
                else
                    key = prefix and (prefix .. k) or tostring(k)
                end
                if v == nil then
                    result["$unset"][key] = ""
                else
                    result["$set"][key] = v
                end
                result._n = result._n + 1
            end
        end
    end
    for k, v in pairs(stage) do
        if getmetatable(v) == ormdoc_type and v.__dirty then
            if result then
                local key
                if doc.__schema.type == "array" then
                    key = prefix and (prefix .. (k - 1)) or tostring(k - 1)
                else
                    key = prefix and (prefix .. k) or tostring(k)
                end
                local change
                if v.__all_dirty then
                    change = _commit_mongo(v)
                else
                    local n = result._n
                    _commit_mongo(v, result, key .. ".")
                    if n ~= result._n then
                        change = true
                    end
                end
                if change then
                    if result["$set"][key] == nil and v.__all_dirty then
                        -- TODO: 序列化bson时，v如果是map，需要把key转为string
                        -- 序列化前修改 pairs, 序列化后还原 pairs
                        -- print("fuck", key, v.__schema)
                        result["$set"][key] = v
                        result._n = result._n + 1
                    end
                    dirty = true
                end
                unset_all_dirty(v)
            else
                local change = _commit_mongo(v)
                dirty = dirty or change
            end
        end
    end
    return dirty
end

function orm.commit_mongo(doc)
    local result = {
        ["$set"] = {},
        ["$unset"] = {},
        _n = 0,
    }
    local is_dirty = _commit_mongo(doc, result)
    result._n = nil
    if next(result["$set"]) == nil then
        result["$set"] = nil
    end
    if next(result["$unset"]) == nil then
        result["$unset"] = nil
    end
    return is_dirty, result
end

function orm.is_dirty(doc)
    return doc.__dirty
end

function orm.clone(doc)
    return _clone_doc(doc)
end

orm.next = doc_next
orm.unpack = doc_unpack
orm.concat = doc_concat
orm.insert = doc_insert
orm.remove = doc_remove

return orm
