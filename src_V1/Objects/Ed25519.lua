---@meta

---@class Ed25519
---@field generateSecretKey fun(): string
---@field generatePublicKey fun(secretKey: string): string
---@field sign fun(secretKey: string, publicKey: string, text: string): string
---@field verify fun(publicKey: string, text: string, signature: string): boolean
---@field hexTo256 fun(s: string): string

---@type Ed25519
local Ed25519 = {}

---generates a random key, 32 bytes long
---@return string
Ed25519.generateSecretKey = function()
    local result = ''

	for _ = 1, 32 do
        result = result ..
			string.char(math.random(0, 255))
	end
	
	return result
end

---converts hex to 256, see https://discord.com/developers/docs/interactions/receiving-and-responding#security-and-authorization
---@param s string
---@return string
Ed25519.hexTo256 = function (s)
	local result = s:gsub('%x%x', function (a)
		return string.char(tonumber(a, 16))
	end)
	return result
end

-- anything after this is modeled by tweetnacl, I have no idea how this
-- works
-- https://github.com/dchest/tweetnacl-js

return Ed25519