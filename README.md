# sproto-orm: 基于 Sproto 的 MongoDB Lua ORM

[![Language](https://img.shields.io/badge/language-Lua-blue.svg)](https://www.lua.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

**一款专为游戏服务器设计的高效 ORM (Object-Relational Mapping)，为你的 Lua 项目带来健壮、高性能的 MongoDB 数据持久化方案。**

`sproto-orm` 利用 `sproto` schema 来自动追踪对象变更，并以差异更新（Delta Update）的方式同步到 MongoDB，从而极大地减少数据库写入开销，是高并发游戏服务器的理想选择。

> 本项目是 [lua-dirty-mongo](https://github.com/hanxi/lua-dirty-mongo) (Protobuf 版本) 的精神续作，采用更严格的 sproto schema 设计，代码更稳健。

## ✨ 核心特性

- **Sproto-Driven Schema**: 使用 `sproto` 定义清晰、强类型的数据结构，保证数据一致性，从源头杜绝“脏”数据。
- **高效的差异更新 (Dirty-Tracking)**: 自动追踪对象修改，仅将发生变化的字段更新到 MongoDB，极大减少数据库写入压力和网络 IO。
- **强制 Schema，更稳健**: 与旧版不同，此版本强制要求 Schema 定义，这让代码更具可维护性，并避免了许多潜在的数据错误。
- **完备的测试用例**: 使用 [busted](https://github.com/lunarmodules/busted) 框架编写了完整的测试，确保库的稳定性和可靠性。
- **为游戏开发而生**: 核心设计理念源于真实游戏项目的性能需求和开发痛点。

## 🚀 快速开始

### 1. 定义 Schema

首先，创建一个 `.sproto` 文件来定义你的数据结构。例如 `role.sproto`：

```sproto
# role.sproto
.role {
    _version 0 : integer   # 内部使用的版本号
    rid 1 : integer        # 角色ID
    name 2 : string        # 角色名
    account 3 : string     # 关联账号
}
```

### 2. 生成 Lua Schema

使用项目提供的工具脚本，将 `.sproto` 文件转换为 ORM 可用的 `schema.lua` 文件。

```bash
# 步骤 1: 从 role.sproto 生成中间定义文件 schema_define.lua
lua tools/sproto2lua.lua schema_define.lua role.sproto

# 步骤 2: 从 schema_define.lua 生成最终的 schema.lua
lua tools/gen_schema.lua schema.lua schema_define.lua
```

这个过程将 `sproto` 定义转换为了 ORM 内部使用的高效格式。

### 3. 在代码中使用

现在，你可以在 Lua 代码中像操作普通 table 一样操作你的数据对象。

```lua
local orm = require "orm"         -- 引入 ORM 核心库
local schema = require "schema"   -- 引入上一步生成的 schema

-- 创建一个新对象，或从数据库加载数据
local role_data = {
    _version = 1,
    rid = 1001,
}

-- 使用 schema.new() 将其包装成 ORM 对象
local role_obj = schema.role.new(role_data)

-- 修改对象属性，ORM 会自动追踪这些变化
role_obj.name = "sproto-orm"
role_obj.account = "hanxi"

-- 提交变更到数据库
-- orm.commit_mongo 会检查对象是否“变脏”（有字段被修改）
-- 如果变脏，则生成用于 MongoDB 更新的 $set 指令
local is_dirty, update_data = orm.commit_mongo(role_obj)

-- 打印结果
-- is_dirty: true
-- update_data: { ["$set"] = { account = "hanxi", name = "sproto-orm" } }
print(is_dirty, update_data["$set"].account, update_data["$set"].name)
-- 输出: true   sproto-orm   hanxi
```

`update_data` 就是你可以直接传递给 MongoDB 驱动进行 `update` 操作的文档。

想了解更多高级用法，请参考[测试用例 `spec/orm_spec.lua`](https://github.com/hanxi/sproto-orm/blob/master/spec/orm_spec.lua)。你可以直接在项目根目录运行 `busted` 命令来执行所有测试。

## 🔌 接入 Skynet

本项目并非一个开箱即用的 Skynet 应用，但可以作为核心模块轻松集成。在 Skynet 中使用时，你通常需要：

1. 实现一个 `mongod` 服务来处理数据库请求。
2. 在你的业务服务（如 `agent`）中使用本 ORM 来管理对象状态。
3. 调用 `orm.commit_mongo` 生成更新指令，并将其发送给 `mongod` 服务执行。

如果您正在寻找一个集成了此 ORM 的、更完整的 Skynet 开发框架，请关注作者的另一个项目 **[skyext](https://github.com/hanxi/skyext)**，它提供了更完善的解决方案。

## 💡 扩展与兼容

### 支持 Protobuf Schema

虽然本项目的核心是 `sproto`，但其设计是可扩展的。`tools/sproto2lua.lua` 的作用是将 schema 定义转换为一个通用的 Lua table 格式（即 `schema_define.lua`）。

因此，如果你想支持 Protobuf 或其他 schema 定义语言，只需编写一个类似的转换工具，生成相同格式的 `schema_define.lua` 文件即可无缝接入。这种解耦设计提供了极大的灵活性。

## 📚 参考资料

- **设计思路**: [适合游戏服务器开发的ORM](https://blog.hanxi.cc/p/93/)
- **旧版实现**: [lua-dirty-mongo (Protobuf 版本)](https://github.com/hanxi/lua-dirty-mongo)
