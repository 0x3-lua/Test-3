---@class Database @responsible for saving and loading data, 
--- this was modeled by replit so this interface is subject to change
---@field get fun(str: string): string @get value
--- from database
---@field set fun(str: string, v: any):Database @sets 
--- value from database
---@field delete fun(str: string): Database @deletes entry
---@field list fun(term: string): string @returns list of keys in database

---@class curve25519
---@field public_key fun(s: string): string
---@field randombytes fun(a: integer): string
---@field shared_key fun()

---@class encoder
---@field encode fun(s: string): string
---@field decode fun(s: string): string

return nil;