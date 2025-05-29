package.path = package.path .. ";../?.lua;../?/init.lua"

local serpent = require("tools.sprotodump.serpent")

local schema = require("schema")
local orm = require("orm")
orm.init(schema)

local phone = orm.PhoneNumber.new({
    number = "1234567890",
    type = 1,
})
local address_book = orm.AddressBook.new()
local id = 10086
address_book.person = orm.AddressBook.person.new()
address_book.person[id] = orm.Person.new({
    name = "John Doe",
    id = id,
    phone = { phone },
    i2s = {
        ["100"] = "s1",
        ["200"] = "s2",
    },
})

local dirty, ret = orm.commit_mongo(address_book)

local function seri(ret)
    return serpent.block(ret, { comment = false })
end
print(dirty, seri(ret))

address_book.person[id].name = "Jane Doe"
address_book.person[id].phone[1].number = "0987654321"
local dirty, ret = orm.commit_mongo(address_book)
print(dirty, seri(ret))

print(seri(address_book))
