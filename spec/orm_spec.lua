local orm = require "orm"
local schema = require "spec.schema"
local serpent = require "tools.sprotodump.serpent"

local function seri(ret)
    return serpent.block(ret, { comment = false })
end

describe("ORM", function()
    describe("基础测试", function()
        it("空值初始化", function()
            local addressBook = schema.AddressBook.new()
            local is_dirty, ret = orm.commit_mongo(addressBook)
            print("空值初始化结果", is_dirty, seri(ret), seri(addressBook))
            assert.equals(false, is_dirty)
            assert.are.same(ret, {})
        end)

        it("有值初始化", function()
            local originAddressBook = {
                person = {
                    [1] = {
                        name = "hanxi",
                        id = 1,
                    },
                },
            }
            local addressBook = schema.AddressBook.new(originAddressBook)
            assert.equals(addressBook, originAddressBook)
            local is_dirty, ret = orm.commit_mongo(addressBook)
            print("有值初始化结果", is_dirty, seri(ret), seri(addressBook))
            assert.equals(false, is_dirty)
            assert.are.same(ret, {})
            assert.are.same(originAddressBook, addressBook)
        end)

        it("读取和修改数据", function()
            local originAddressBook = {
                person = {
                    [1] = {
                        name = "hanxi",
                        id = 1,
                    },
                },
            }
            local addressBook = schema.AddressBook.new(originAddressBook)
            addressBook.person[1].name = "hanxinew"
            local is_dirty, ret = orm.commit_mongo(addressBook)
            local need_ret = {
                ["$set"] = {
                    ["person.1.name"] = "hanxinew",
                },
            }
            assert.are.same(ret, need_ret)
            print("修改数据", is_dirty, seri(ret), seri(addressBook))

            local one_person = addressBook.person[1]
            print("错误读取数据")
            assert.has_error(function()
                -- 不存在的 key
                local age = one_person.age
            end, "not exist key: age")

            print("错误修改数据")
            assert.has_error(function()
                -- 类型错误
                one_person.name = 1
            end, "not equal v type. need string, real: number, v: 1, need_tp: schema_string")
            assert.has_error(function()
                -- 类型错误
                one_person.id = "idhanxi"
            end, "not equal v type. need integer, real: string, v: idhanxi, need_tp: schema_integer")
            assert.has_error(function()
                -- 不存在的 key
                one_person.null = 1
            end, "not exist key: null")

            local is_dirty, ret = orm.commit_mongo(addressBook)
            assert.equals(false, is_dirty)
            assert.are.same(ret, {})
            print("检查数据", is_dirty, seri(ret), seri(addressBook))
        end)
    end)

    describe("子表修改", function()
        local id = 1
        local address_book

        before_each(function()
            address_book = schema.AddressBook.new({
                person = {
                    [id] = {
                        id = id,
                        name = "hanxi",
                        phone = {},
                    },
                },
            })
            -- 初始化提交，确保干净
            local _, _ = orm.commit_mongo(address_book)
        end)

        it("整体修改 phone2", function()
            local phone2 = schema.PhoneNumber.new({
                number = "2",
                type = 2,
            })
            address_book.person[id].phone[2] = phone2
            local is_dirty, ret = orm.commit_mongo(address_book)

            print("整体修改 phone2", seri(ret), seri(address_book))
            assert.is_true(is_dirty)
            local expected = {
                ["$set"] = {
                    ["person.1.phone.1"] = {
                        number = "2",
                        type = 2,
                    },
                },
            }
            assert.equals(seri(expected), seri(ret))
        end)

        it("局部修改 phone2", function()
            local phone2 = schema.PhoneNumber.new({
                number = "2",
                type = 2,
            })
            address_book.person[id].phone[2] = phone2
            orm.commit_mongo(address_book)

            phone2.number = "22"
            local is_dirty, ret = orm.commit_mongo(address_book)
            print("局部修改 phone2", is_dirty, seri(ret), seri(address_book))

            assert.is_true(is_dirty)
            assert.equals("22", ret["$set"]["person.1.phone.1.number"])
        end)

        it("再整体修改 phone22", function()
            local phone22 = schema.PhoneNumber.new({
                number = "22",
                type = 22,
            })
            address_book.person[id].phone[2] = phone22
            local is_dirty, ret = orm.commit_mongo(address_book)
            local expected = {
                number = "22",
                type = 22,
            }
            assert.is_true(is_dirty)
            assert.equals(seri(expected), seri(ret["$set"]["person.1.phone.1"]))
        end)

        it("再局部修改 phone22", function()
            local phone22 = schema.PhoneNumber.new({
                number = "22",
                type = 22,
            })
            address_book.person[id].phone[2] = phone22
            orm.commit_mongo(address_book)

            phone22.number = "222"
            local is_dirty, ret = orm.commit_mongo(address_book)

            assert.is_true(is_dirty)
            assert.equals("222", ret["$set"]["person.1.phone.1.number"])
        end)

        it("整体修改为 table", function()
            local phone3 = {
                number = "3",
                type = 3,
            }
            address_book.person[id].phone[2] = phone3
            local is_dirty, ret = orm.commit_mongo(address_book)

            assert.is_true(is_dirty)
            local expected = {
                number = "3",
                type = 3,
            }
            assert.equals(seri(expected), seri(ret["$set"]["person.1.phone.1"]))
            assert.equals(phone3, address_book.person[id].phone[2])
        end)

        it("再局部修改 table", function()
            local phone3 = {
                number = "3",
                type = 3,
            }
            address_book.person[id].phone[2] = phone3
            orm.commit_mongo(address_book)

            phone3.number = "33"
            local is_dirty, ret = orm.commit_mongo(address_book)

            assert.is_true(is_dirty)
            assert.equals("33", ret["$set"]["person.1.phone.1.number"])
        end)
    end)

    -- AI 生成的测试用例
    describe("Person", function()
        it("should create valid Person with basic fields", function()
            local person = schema.Person.new({
                id = 1,
                name = "John",
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
                    type = 1,
                },
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
                    { number = "0987654321", type = 2 },
                },
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
                    work = 2,
                },
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
                    work = { number = "0987654321", type = 2 },
                },
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
                    [2] = "two",
                },
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
                            type = 1,
                        },
                    },
                    [2] = {
                        id = 2,
                        name = "Jane",
                        onephone = {
                            number = "0987654321",
                            type = 2,
                        },
                    },
                },
            })
            assert.equals("John", book.person[1].name)
            assert.equals("Jane", book.person[2].name)
        end)
    end)

    describe("Change Tracking", function()
        it("should track simple changes", function()
            local person = schema.Person.new({
                id = 1,
                name = "John",
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
                    type = 1,
                },
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
                    home = "1", -- should be integer
                }
            end)
        end)

        it("should reject invalid array indexes", function()
            local person = schema.Person.new({
                phone = {},
            })
            assert.has_error(function()
                person.phone["invalid"] = {
                    number = "1234567890",
                    type = 1,
                }
            end)
        end)
    end)
end)
