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
  },
  bag = {
    res = {
      key = "integer",
      type = "map",
      value = "resource"
    },
    res_type = {
      type = "integer"
    }
  },
  mail = {
    attach = {
      type = "mail_attach"
    },
    cfg_id = {
      type = "integer"
    },
    detail = {
      key = "string",
      type = "map",
      value = "string"
    },
    mail_id = {
      type = "integer"
    },
    send_role = {
      type = "mail_role"
    },
    send_time = {
      type = "integer"
    },
    title = {
      key = "string",
      type = "map",
      value = "string"
    }
  },
  mail_attach = {
    res_id = {
      type = "integer"
    },
    res_size = {
      type = "integer"
    },
    res_type = {
      type = "integer"
    }
  },
  mail_role = {
    name = {
      type = "string"
    },
    rid = {
      type = "integer"
    }
  },
  resource = {
    res_id = {
      type = "integer"
    },
    res_size = {
      type = "integer"
    }
  },
  role = {
    _version = {
      type = "integer"
    },
    account = {
      type = "string"
    },
    create_time = {
      type = "integer"
    },
    last_login_time = {
      type = "integer"
    },
    modules = {
      type = "role_modules"
    },
    name = {
      type = "string"
    },
    rid = {
      type = "integer"
    }
  },
  role_bag = {
    bags = {
      key = "integer",
      type = "map",
      value = "bag"
    }
  },
  role_mail = {
    _version = {
      type = "integer"
    },
    mails = {
      key = "integer",
      type = "map",
      value = "mail"
    }
  },
  role_modules = {
    bag = {
      type = "role_bag"
    },
    mail = {
      type = "role_mail"
    }
  },
  str2str = {
    key = {
      type = "string"
    },
    value = {
      type = "string"
    }
  }
}