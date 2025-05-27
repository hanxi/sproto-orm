-- 测试命令 lua tools/sproto2lua.lua test/test.sproto test/schema_define.lua

-- 获取脚本所在的完整路径
local script_path = arg[0]

-- 检测路径是否完整
if script_path:match(".+%.lua") then
    -- 如果 arg[0] 包含 .lua 后缀，尝试获取完整路径
    script_path = debug.getinfo(1).source:sub(2)
else
    -- 如果 arg[0] 不含后缀，可能是在命令行直接调用
    if script_path:match("(.+)/[^/]+$") then
        script_path = script_path:match("(.+)/[^/]+$")
    else
        script_path = "."
    end
end

-- 从脚本路径中提取目录
local script_directory = script_path:match("(.*/)") or "./"

-- 将脚本所在目录添加到 package.cpath
package.path = package.path .. ";" .. script_directory .. "sprotodump/?.lua"

local sformat = string.format

-- 读取 proto 文件内容
local filename = arg[1]

-- 检查文件名是否提供
if not filename then
    print("No .sproto file provided")
    return
end

local sprotodump_table = require "module.table"
local sprotodump_parse_core = require "core"
local sprotodump_util = require "util"
local sprotodump_serpent = require "serpent"

local function _gen_trunk_list(sproto_file, namespace)
    local trunk_list = {}
    for i,v in ipairs(sproto_file) do
        namespace = namespace and util.file_basename(v) or nil
        local str = sprotodump_util.read_file(v)
        table.insert(trunk_list, {str, v, namespace})
    end
    return trunk_list
end

local trunk_list = _gen_trunk_list({filename})
local trunk, build = sprotodump_parse_core.gen_trunk(trunk_list)
-- print(trunk)
-- print(build)
-- print(sprotodump_serpent.block(build.type, {comment=false}))
-- sprotodump_table(trunk, build, {})

local cls_map = {}
for k,v in pairs(build.type) do
    cls_map[k] = {}
    for kk,vv in pairs(v) do
        if type(vv) == "table" and vv.name then
            if vv.array == true and vv.map_keyfield and vv.map_valuefield then
                cls_map[k][vv.name] = {
                    type = "map",
                    key = vv.map_keyfield.typename,
                    value = vv.map_valuefield.typename,
                }
            elseif vv.array == true then
                cls_map[k][vv.name] = {
                    type = "array",
                    item = vv.typename,
                }
            else
                cls_map[k][vv.name] = {
                    type = vv.typename,
                }
            end
        end
    end
end

-- 写入文件内容
local outfilename = arg[2]

-- 检查文件名是否提供
if not outfilename then
    outfilename = "schema_define.lua"
end

-- 打开文件
local outfile = io.open(outfilename, "w")

-- 检查文件是否成功打开
if not outfile then
    print("Cannot open file: " .. outfilename)
    return
end


local fmt_file_header = sformat([[
-- Code generated from %s
-- DO NOT EDIT!
return ]], filename)

local s = sprotodump_serpent.block(cls_map, {comment=false})
local out_content = table.concat({fmt_file_header, s}, '')

-- 写入文件内容
local content = outfile:write(out_content)
outfile:close()

print("successfully generated schema define to: " .. outfilename)
