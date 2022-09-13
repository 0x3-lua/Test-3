---@class Database @responsible for saving and loading data, 
--- this was modeled by replit so this interface is subject to change
---@field get fun(str: string): string @get value
--- from database
---@field set fun(str: string, v: any):Database @sets 
--- value from database
---@field delete fun(str: string): Database @deletes entry
---@field list fun(term: string): string @returns list of keys in database

---@class bit
---@field toBit fun(x: integer): integer
---@field toHex fun(x: integer, bits: integer): integer
---@field bnot fun(x: integer): integer
---@field bor bit.bitOperation
---@field band bit.bitOperation
---@field bxor bit.bitOperation
---@field lshift bit.arg2Operation
---@field rshift bit.arg2Operation
---@field arshift bit.arg2Operation
---@field rol bit.arg2Operation
---@field ror bit.arg2Operation
---@field bswap fun(x: integer): integer

---@alias bit.bitOperation fun(n: integer, ...:integer): integer
---@alias bit.arg2Operation fun(n: integer, n2:integer): integer

return nil;