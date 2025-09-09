cd $(dirname $0)
lua ../tools/sproto2lua.lua schema_define.lua test.sproto
lua ../tools/gen_schema.lua schema.lua schema_define.lua
