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

Ed25519.generatePublicKey = function ()
	error('unimplemented')
end

return Ed25519