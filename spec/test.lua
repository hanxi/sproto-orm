package.path = package.path .. ";../?.lua;../?/init.lua"

local serpent = require("tools.sprotodump.serpent")

local schema = require "schema"
local orm = require "orm"

local phone = schema.PhoneNumber.new({
    number = "1234567890",
    type = 1,
})
local address_book = schema.AddressBook.new()
local id = 10086
address_book.person = schema.AddressBook.person.new()
address_book.person[id] = schema.Person.new({
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

print("doc 整体修改")
local phone2 = schema.PhoneNumber.new({
    number = "2",
    type = 2,
})
address_book.person[id].phone[2] = phone2
local dirty, ret = orm.commit_mongo(address_book)
print(dirty, seri(ret))


print("doc 局部修改")
phone2.number = "22"
local dirty, ret = orm.commit_mongo(address_book)
print(dirty, seri(ret))


print("doc 再整体修改")
local phone22 = schema.PhoneNumber.new({
    number = "22",
    type = 22,
})
address_book.person[id].phone[2] = phone22
local dirty, ret = orm.commit_mongo(address_book)
print(dirty, seri(ret))

print("doc 再局部修改")
phone22.number = "222"
local dirty, ret = orm.commit_mongo(address_book)
print(dirty, seri(ret))

print("doc 整体修改为 table")
local phone3 = {
    number = "3",
    type = 3,
}
address_book.person[id].phone[2] = phone3
local dirty, ret = orm.commit_mongo(address_book)
print(dirty, seri(ret))

assert(address_book.person[id].phone[2] == phone3)
print("doc 再局部修改 table")
phone3.number = "33"
local dirty, ret = orm.commit_mongo(address_book)
print(dirty, seri(ret))


