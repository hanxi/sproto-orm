-- Code generated from test.sproto
-- DO NOT EDIT!
return {
  AddressBook = {
    person = {
      key = "integer",
      type = "map",
      value = "Person"
    }
  },
  IntKeyStringValue = {
    key = {
      type = "integer"
    },
    value = {
      type = "string"
    }
  },
  Person = {
    i2s = {
      key = "integer",
      type = "map",
      value = "string"
    },
    id = {
      type = "integer"
    },
    name = {
      type = "string"
    },
    onephone = {
      type = "PhoneNumber"
    },
    phone = {
      item = "PhoneNumber",
      type = "array"
    },
    phonemap = {
      key = "string",
      type = "map",
      value = "integer"
    },
    phonemapkv = {
      key = "string",
      type = "map",
      value = "PhoneNumber"
    }
  },
  PhoneNumber = {
    number = {
      type = "string"
    },
    type = {
      type = "integer"
    }
  }
}