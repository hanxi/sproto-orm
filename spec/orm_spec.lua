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
            -- print("空值初始化结果", is_dirty, seri(ret), seri(addressBook))
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
            -- print("有值初始化结果", is_dirty, seri(ret), seri(addressBook))
            assert.equals(false, is_dirty)
            assert.are.same(ret, {})
            assert.are.same(originAddressBook, addressBook)
        end)

        it("map初始化", function()
            -- map 的 key 在数据库中是 string
            local id = "1"
            local originAddressBook = {
                person = {
                    [id] = {
                        name = "hanxi",
                        id = 1,
                    },
                },
            }
            local addressBook = schema.AddressBook.new(originAddressBook)
            assert.equals(addressBook, originAddressBook)
            local is_dirty, ret = orm.commit_mongo(addressBook)
            -- print("map初始化结果", is_dirty, seri(ret), seri(addressBook))
            assert.equals(false, is_dirty)
            assert.are.same(ret, {})
            assert.are.same(originAddressBook, addressBook)
        end)

        it("bson序列化", function()
            local id = "1"
            local originAddressBook = {
                person = {
                    [id] = {
                        name = "hanxi",
                        id = 1,
                    },
                },
            }
            local addressBook = schema.AddressBook.new(originAddressBook)
            -- 使用 orm.totable 模拟 bson_encode 接口，会把 map 中的整数 key 转为字符串
            local ret = orm.with_bson_encode_context(orm.totable, addressBook)
            local ret1 = seri(ret)
            local ret2 = seri(addressBook)
            -- print(ret1, ret2)
            local expected = {
                id = 1,
                name = "hanxi",
            }
            assert.equals(seri(expected), seri(ret.person[id]))
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
            -- print("修改数据", is_dirty, seri(ret), seri(addressBook))

            local one_person = addressBook.person[1]
            -- print("错误读取数据")
            assert.has_error(function()
                -- 不存在的 key
                local age = one_person.age
            end, "not exist key: age")

            -- print("错误修改数据")
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
            -- print("检查数据", is_dirty, seri(ret), seri(addressBook))
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
        end)

        it("整体修改 phone2", function()
            local phone2 = schema.PhoneNumber.new({
                number = "2",
                type = 2,
            })
            address_book.person[id].phone[2] = phone2
            local is_dirty, ret = orm.commit_mongo(address_book)

            -- print("整体修改 phone2", seri(ret), seri(address_book))
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
            -- print("局部修改 phone2", is_dirty, seri(ret), seri(address_book))

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

        it("map元素操作", function()
            -- print(seri(address_book))
            local person2 = orm.clone(address_book.person[1])
            person2.id = 2
            person2.name = "hanxi2"
            address_book.person[1] = nil
            address_book.person[2] = person2
            person2.phone = nil

            local is_dirty, ret = orm.commit_mongo(address_book)
            assert.is_true(is_dirty)
            local expected = {
                ["$set"] = {
                    ["person.2"] = {
                        id = 2,
                        name = "hanxi2",
                    },
                },
                ["$unset"] = {
                    ["person.1"] = true,
                },
            }
            -- print(seri(ret), seri(address_book))
            assert.equals(seri(expected), seri(ret))

            address_book.person[2] = nil
            local new_person = orm.clone(person2)
            address_book.person[3] = new_person
            new_person.id = 3
            new_person.name = "hanxi3"
            local is_dirty, ret = orm.commit_mongo(address_book)
            assert.is_true(is_dirty)
            local expected = {
                ["$set"] = {
                    ["person.3"] = {
                        id = 3,
                        name = "hanxi3",
                    },
                },
                ["$unset"] = {
                    ["person.2"] = true,
                },
            }
            -- print(seri(ret), seri(address_book))
            assert.equals(seri(expected), seri(ret))
        end)

        it("数组元素操作", function()
            local phone = {
                number = "123",
                type = 123,
            }
            address_book.person[id].phone[1] = phone
            address_book.person[id].phone[2] = orm.clone(phone)
            address_book.person[id].phone[3] = orm.clone(phone)
            address_book.person[id].phone[4] = orm.clone(phone)
            local is_dirty, ret = orm.commit_mongo(address_book)
            assert.is_true(is_dirty)
            -- print(seri(ret), seri(address_book))
            assert.equals(seri(phone), seri(ret["$set"]["person.1.phone.0"]))
            assert.equals(seri(phone), seri(ret["$set"]["person.1.phone.1"]))
            assert.equals(seri(phone), seri(ret["$set"]["person.1.phone.2"]))
            assert.equals(seri(phone), seri(ret["$set"]["person.1.phone.3"]))

            -- 数组元素设置为空
            address_book.person[id].phone[1] = nil
            local is_dirty, ret = orm.commit_mongo(address_book)
            assert.is_true(is_dirty)
            -- print(seri(ret), seri(address_book))
            local expected = {
                ["$unset"] = {
                    ["person.1.phone.0"] = true,
                },
            }
            assert.equals(seri(expected), seri(ret))

            -- 删除数组元素
            -- print(seri(address_book))
            orm.remove(address_book.person[id].phone, 1)
            local is_dirty, ret = orm.commit_mongo(address_book)
            assert.is_true(is_dirty)
            -- print(seri(ret), seri(address_book))
            local expected = {
                ["$set"] = {
                    ["person.1.phone.0"] = {
                        number = "123",
                        type = 123,
                    },
                    ["person.1.phone.1"] = {
                        number = "123",
                        type = 123,
                    },
                    ["person.1.phone.2"] = {
                        number = "123",
                        type = 123,
                    },
                },
                ["$unset"] = {
                    ["person.1.phone.3"] = true,
                },
            }
            assert.equals(seri(expected), seri(ret))

            -- phone 已经有 parent 了，不能再放进去
            local new_phone = orm.clone(phone)
            new_phone.number = "new"
            orm.insert(address_book.person[id].phone, 1, new_phone)
            local new_new_phone = orm.clone(phone)
            new_new_phone.number = "new new"
            orm.insert(address_book.person[id].phone, 3, new_new_phone)
            local is_dirty, ret = orm.commit_mongo(address_book)
            assert.is_true(is_dirty)
            -- print(seri(ret), seri(address_book))
            local expected = {
                ["$set"] = {
                    ["person.1.phone.0"] = {
                        number = "new",
                        type = 123,
                    },
                    ["person.1.phone.1"] = {
                        number = "123",
                        type = 123,
                    },
                    ["person.1.phone.2"] = {
                        number = "new new",
                        type = 123,
                    },
                    ["person.1.phone.3"] = {
                        number = "123",
                        type = 123,
                    },
                    ["person.1.phone.4"] = {
                        number = "123",
                        type = 123,
                    },
                },
            }
            assert.equals(seri(expected), seri(ret))
        end)
    end)

    describe("多引用", function()
        it("多引用初始化", function()
            local id = 1
            local originAddressBook = {
                person = {
                    [id] = {
                        id = id,
                        name = "hanxi",
                        phone = {},
                    },
                },
            }
            originAddressBook.person[2] = originAddressBook.person[1]
            -- print("多引用初始化前", seri(originAddressBook))
            assert.equals(originAddressBook.person[2], originAddressBook.person[1])

            local address_book = schema.AddressBook.new(originAddressBook)
            -- print("多引用初始化", seri(address_book))
            assert.not_equals(address_book.person[2], address_book.person[1])
            -- 子表也会深拷贝
            assert.not_equals(address_book.person[2].phone, address_book.person[1].phone)
            local is_dirty, ret = orm.commit_mongo(address_book)
            assert.is_false(is_dirty)
            assert.are.same(ret, {})
        end)
    end)

    describe("parent修改", function()
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
        end)

        it("把一个元素赋值到另一个元素", function()
            local phone1 = {
                number = "1",
                type = 1,
            }
            address_book.person[id].phone[1] = phone1
            assert.has_error(function()
                address_book.person[id].phone[2] = phone1
            end, "non-root nodes cannot be assigned to other objects")
            address_book.person[id].phone[2] = orm.clone(phone1)
            assert.equals(address_book.person[id].phone[1], phone1)
            assert.not_equals(address_book.person[id].phone[2], phone1)
            -- print("把一个元素赋值到另一个元素", seri(address_book))
            local is_dirty, changes = orm.commit_mongo(address_book)
            -- print(seri(changes))
            assert.is_true(is_dirty)
            assert.equals(seri(phone1), seri(changes["$set"]["person.1.phone.1"]))
            assert.equals(seri(phone1), seri(changes["$set"]["person.1.phone.0"]))
        end)
    end)

    describe("默认值", function()
        it("空map", function()
            local originAddressBook = {}
            -- print("空map", seri(originAddressBook))
            local address_book = schema.AddressBook.new(originAddressBook)
            -- print("空map初始化", seri(address_book))
            address_book.person = {}
            local ret = orm.with_bson_encode_context(orm.totable, address_book)
            -- print("空map序列化", seri(ret))
            local is_dirty, ret = orm.commit_mongo(address_book)
            -- print("空map落地", seri(ret))
            assert.is_false(is_dirty)
            assert.are.same(ret, {})
        end)
        it("空struct", function()
            local person = {}
            -- print("空struct", seri(person))
            person = schema.Person.new(person)
            -- print("空struct初始化", seri(person))
            person.onephone = {}
            local ret = orm.with_bson_encode_context(orm.totable, person)
            -- print("空struct序列化", seri(ret))
            local is_dirty, ret = orm.commit_mongo(person)
            local ret = orm.with_bson_encode_context(orm.totable, ret)
            -- print("空struct落地",is_dirty, seri(ret))
            assert.is_false(is_dirty)
            assert.are.same(ret, {})
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
