local x = 1

-- Single line comment
--[[ Multi line
     comment ]]
--[==[ Comment with level ]==]

---Documentation comment.
---@param name string
---@return table
local function new_user(name)
  return { name = name, age = 0 }
end

-- Numbers and constants
local int, float, exp, hex, hexf, hexp = 42, 3.14, 1e-10, 0xFF, 0x1p4, 0xA.8P-2
local yes, no, nothing = true, false, nil
local all = ...

-- Strings
local single = 'single'
local double = "double \"escaped\" \n\t\65\u{48}"
local long = [[
long string
]]
local leveled = [==[ with ]] inside ]==]

-- Operators
local sum = 1 + 2 - 3 * 4 / 5 // 6 % 7 ^ 8
local cmp = 1 == 2 or 1 ~= 2 and 1 < 2 and 1 <= 2 and 1 > 2 and 1 >= 2
local bits = 1 & 2 | 3 ~ 4 << 5 >> 6
local len, neg, inv, concat = #"abc", -x, ~x, "a" .. "b"
local truth = not false

-- Attributes (Lua 5.4)
local limit <const> = 10
local file <close> = io.open("file.txt")

-- Functions
function global_function(a, b, ...)
  local args = { ... }
  return a + b + select("#", ...)
end

local Account = {}
Account.__index = Account

function Account.new(balance)
  local self = setmetatable({}, Account)
  self.balance = balance or 0
  return self
end

function Account:deposit(amount)
  self.balance = self.balance + amount
end

function Account.nested.field:method() end

local anonymous = function(value)
  return value * 2
end

local lambda = function() return nil end

-- Calls
local account = Account.new(100)
account:deposit(50)
print(account.balance)
print "no parens"
print { 1, 2, 3 }
string.format("%d", 42)
table.insert(args, 1)
math.floor(math.pi)
local m = require("module")

-- Tables
local tbl = {
  1, 2, 3,
  key = "value",
  ["computed key"] = true,
  [42] = "number key",
  nested = { a = { b = { c = 1 } } },
  method = function(self) return self end,
}
tbl.key = tbl["key"]

-- Control flow
if x > 0 then
  print("positive")
elseif x < 0 then
  print("negative")
else
  print("zero")
end

while x < 10 do
  x = x + 1
  if x == 5 then break end
end

repeat
  x = x - 1
until x <= 0

for i = 1, 10, 2 do
  print(i)
end

for k, v in pairs(tbl) do
  print(k, v)
end

for i, v in ipairs({ "a", "b" }) do
  goto continue
  ::continue::
end

do
  local scoped = "block"
end

-- Coroutines and metatables
local co = coroutine.create(function(a)
  local b = coroutine.yield(a + 1)
  return b * 2
end)
local ok, result = coroutine.resume(co, 1)

setmetatable(tbl, {
  __add = function(a, b) return a end,
  __tostring = function(self) return "tbl" end,
})

-- Errors
local success, err = pcall(function()
  error("something went wrong", 2)
end)
assert(success, err)

return Account
