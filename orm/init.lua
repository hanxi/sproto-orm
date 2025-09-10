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
    return #doc._stage
end

local function doc_next(doc, k)
    return next(doc._stage, k)
end

local function doc_pairs(doc)
    return pairs(doc._stage)
end

local function doc_ipairs(doc)
    return ipairs(doc._stage)
end

local function doc_unpack(doc, i, j)
    return table.unpack(doc._stage, i, j)
end

local function doc_concat(doc, sep, i, j)
    return table.concat(doc._stage, sep, i, j)
end

local function mark_dirty(doc)
    if not doc._dirty then
        doc._dirty = true
        local parent = doc._parent
        while parent do
            if parent._dirty then
                break
            end
            parent._dirty = true
            parent = parent._parent
        end
    end
end

local function doc_change_value(doc, k, v)
    if getmetatable(v) == ormdoc_type then
        doc._schema:_check_kv(k, v._schema)
    elseif v ~= nil then
        doc._schema:_check_kv(k, v)
    end
    if v ~= doc[k] then
        doc._changed_keys[k] = true -- mark changed (even nil)
        doc._changed_values[k] = doc._stage[k] -- lastversion value
        doc._stage[k] = v -- current value
        mark_dirty(doc)
    end
end

local _new_doc = nil
local function doc_change_recursively(doc, k, v)
    local schema = doc._schema[k]
    local lv = doc._stage[k]
    if getmetatable(v) == ormdoc_type then
        lv = v
    else
        lv = _new_doc(schema, v)
    end

    lv._parent = doc
    doc_change_value(doc, k, lv)
    lv._all_dirty = true
end

local function doc_change(doc, k, v)
    -- parse k
    k = doc._schema:_parse_k(k)

    if type(v) == "table" then
        doc_change_recursively(doc, k, v)
    elseif doc[k] ~= v then
        doc_change_value(doc, k, v)
    end
end

-- refer to table.insert()
local function doc_insert(doc, index, v)
    local len = orm.len(doc)
    if v == nil then
        v = index
        index = len + 1
    end

    for i = len, index, -1 do
        doc[i + 1] = doc[i]
    end
    doc[index] = v
end

-- refer to table.remove()
local function doc_remove(doc, index)
    local len = orm.len(doc)
    index = index or len

    local v = doc[index]
    doc[index] = nil -- trig a clone of doc._lastversion[index] in doc_change()

    for i = index + 1, len do
        doc[i - 1] = doc[i]
    end
    doc[len] = nil

    return v
end

orm.len = doc_len
orm.next = doc_next
orm.pairs = doc_pairs
orm.ipairs = doc_ipairs
orm.unpack = doc_unpack
orm.concat = doc_concat
orm.insert = doc_insert
orm.remove = doc_remove

_new_doc = function(schema, init)
    local doc_stage = {}
    if schema == nil then
        error("need schema")
    end

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
    doc._dirty = false
    doc._all_dirty = false
    doc._parent = false
    doc._changed_keys = {}
    doc._changed_values = {}
    doc._stage = doc_stage
    doc._schema = schema
    setmetatable(doc, {
        __index = doc_stage,
        __newindex = doc_change,
        __pairs = doc_pairs,
        __ipairs = doc_ipairs,
        __len = doc_len,
        __metatable = ormdoc_type, -- avoid copy by ref
    })

    for k, v in pairs(init_copy) do
        if getmetatable(v) ~= ormdoc_type and type(v) == "table" then
            doc[k] = _new_doc(schema[k], v)
        else
            doc[k] = v
        end
    end
    return doc
end

function orm.new(schema, init)
    local doc = _new_doc(schema, init)
    -- TODO: 另外实现一个函数或者修改 _new_doc 的实现
    orm.commit_mongo(doc)
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

    tab._all_dirty = false
    for k, v in pairs(tab) do
        if getmetatable(v) == ormdoc_type then
            unset_all_dirty(v, visited)
        end
    end
end

local function _commit_mongo(doc, result, prefix)
    doc._dirty = false
    local changed_keys = doc._changed_keys
    local changed_values = doc._changed_values
    local stage = doc._stage
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
                if doc._schema.type == "array" then
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
        if getmetatable(v) == ormdoc_type and v._dirty then
            if result then
                local key
                if doc._schema.type == "array" then
                    key = prefix and (prefix .. (k - 1)) or tostring(k - 1)
                else
                    key = prefix and (prefix .. k) or tostring(k)
                end
                local change
                if v._all_dirty then
                    change = _commit_mongo(v)
                else
                    local n = result._n
                    _commit_mongo(v, result, key .. ".")
                    if n ~= result._n then
                        change = true
                    end
                end
                if change then
                    if result["$set"][key] == nil and v._all_dirty then
                        -- TODO: 序列化bson时，v如果是map，需要把key转为string
                        -- 序列化前修改 pairs, 序列化后还原 pairs
                        -- print("fuck", key, v._schema)
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
    return dock._dirty
end

return orm
