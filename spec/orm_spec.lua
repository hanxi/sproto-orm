local orm = require "orm"
local schema = require "spec.schema"
local serpent = require "tools.sprotodump.serpent"

local function seri(ret)
    return serpent.block(ret, { comment = false })
end

describe("ORM", function()
    describe("初始化", function()
        it("空值初始化", function()
            local addressBook = schema.AddressBook.new()
            local is_dirty, ret = orm.commit_mongo(addressBook)
            print("空值初始化结果", is_dirty, seri(ret))
        end)

        it("should fail with invalid types", function()
            assert.has_error(function()
                schema.PhoneNumber.new({
                    number = 123,  -- should be string
                    type = 1
                })
            end)

            assert.has_error(function()
                schema.PhoneNumber.new({
                    number = "1234567890",
                    type = "1"  -- should be integer
                })
            end)
        end)
    end)

    describe("Person", function()
        it("should create valid Person with basic fields", function()
            local person = schema.Person.new({
                id = 1,
                name = "John"
            })
            assert.equals(1, person.id)
            assert.equals("John", person.name)
        end)

        it("should handle nested PhoneNumber", function()
            local person = schema.Person.new({
                id = 1,
                name = "John",
                onephone = {
                    number = "1234567890",
                    type = 1
                }
            })
            assert.equals("1234567890", person.onephone.number)
            assert.equals(1, person.onephone.type)
        end)

        it("should handle phone array", function()
            local person = schema.Person.new({
                id = 1,
                name = "John",
                phone = {
                    { number = "1234567890", type = 1 },
                    { number = "0987654321", type = 2 }
                }
            })
            assert.equals("1234567890", person.phone[1].number)
            assert.equals("0987654321", person.phone[2].number)
        end)

        it("should handle phone map", function()
            local person = schema.Person.new({
                id = 1,
                name = "John",
                phonemap = {
                    home = 1,
                    work = 2
                }
            })
            assert.equals(1, person.phonemap.home)
            assert.equals(2, person.phonemap.work)
        end)

        it("should handle complex phone map", function()
            local person = schema.Person.new({
                id = 1,
                name = "John",
                phonemapkv = {
                    home = { number = "1234567890", type = 1 },
                    work = { number = "0987654321", type = 2 }
                }
            })
            assert.equals("1234567890", person.phonemapkv.home.number)
            assert.equals("0987654321", person.phonemapkv.work.number)
        end)

        it("should handle integer to string map", function()
            local person = schema.Person.new({
                id = 1,
                name = "John",
                i2s = {
                    [1] = "one",
                    [2] = "two"
                }
            })
            assert.equals("one", person.i2s[1])
            assert.equals("two", person.i2s[2])
        end)
    end)

    describe("AddressBook", function()
        it("should create valid AddressBook", function()
            local book = schema.AddressBook.new({
                person = {
                    [1] = {
                        id = 1,
                        name = "John",
                        onephone = {
                            number = "1234567890",
                            type = 1
                        }
                    },
                    [2] = {
                        id = 2,
                        name = "Jane",
                        onephone = {
                            number = "0987654321",
                            type = 2
                        }
                    }
                }
            })
            assert.equals("John", book.person[1].name)
            assert.equals("Jane", book.person[2].name)
        end)
    end)

    describe("Change Tracking", function()
        it("should track simple changes", function()
            local person = schema.Person.new({
                id = 1,
                name = "John"
            })
            person.name = "Jane"
            local is_dirty, changes = orm.commit_mongo(person)
            assert.is_true(is_dirty)
            assert.equals("Jane", changes["$set"]["name"])
        end)

        it("should track nested changes", function()
            local person = schema.Person.new({
                id = 1,
                name = "John",
                onephone = {
                    number = "1234567890",
                    type = 1
                }
            })
            person.onephone.number = "0987654321"
            local is_dirty, changes = orm.commit_mongo(person)
            assert.is_true(is_dirty)
            assert.equals("0987654321", changes["$set"]["onephone.number"])
        end)
    end)

    describe("Validation", function()
        it("should reject invalid field names", function()
            local person = schema.Person.new({})
            assert.has_error(function()
                person.invalid_field = "value"
            end)
        end)

        it("should reject invalid types in maps", function()
            local person = schema.Person.new({})
            assert.has_error(function()
                person.phonemap = {
                    home = "1"  -- should be integer
                }
            end)
        end)

        it("should reject invalid array indexes", function()
            local person = schema.Person.new({
                phone = {}
            })
            assert.has_error(function()
                person.phone["invalid"] = {
                    number = "1234567890",
                    type = 1
                }
            end)
        end)
    end)
end)

