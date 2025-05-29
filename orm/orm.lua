local orm_base = require("orm.orm_base")

local orm = {}
orm.new = orm_base.new
orm.commit_mongo = orm_base.commit_mongo

function orm.init(schema)
    for k,v in pairs(schema) do
        assert(orm[k] == nil, "orm type duplicates. k:"..k)
        orm[k] = v
    end
end

return orm
