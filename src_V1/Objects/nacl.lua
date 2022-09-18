---@meta

-- see https://github.com/philanc/plc and tweetnacl
-- Class specs after licence

-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------
--[[

ec25519 - curve25519 scalar multiplication

Ported to Lua from the original C tweetnacl implementation,
(public domain, by Dan Bernstein, Tanja Lange et al
see http://tweetnacl.cr.yp.to/ )

To make debug and validation easier, the original code structure
and function names have been conserved as much as possible.



]]

------------------------------------------------------------

-- specs
---@class nacl
---@field base string
---@field crypto_scalarmult fun(out: integer[], n: integer[], p: integer[]): integer
---@field crypto_scalarmult_base fun(out: integer[], n: integer[]): integer
---@field scalarmult fun(n: string, p: string): string
---@field getRandomString fun(len: integer?): string
---@field getKeyPair fun(secret: string?): string, string
---@field getSignature fun(secretKey: string, message: string): string
---@field verify fun(message: string, signature: string, publicKey: string): boolean

---@class nacl.range
---@field hi integer
---@field lo integer

---@type bit
local bit = require("bit")
local Static = require("Static")

-- because bit.lshift is signed, we need an unsigned version
local bitExtra = {
	---unsigned left shift
	---@param n integer
	---@param digits integer
	---@return integer
	uleftShift = function(n, digits)
		assert(n and digits, debug.traceback())

		return n * math.floor(2 ^ digits)
	end
}

local function rshiftBand(a)
	return bit.band(bit.rshift(a, 16), 1)
end

-- set25519() not used
AA = 1

local function car25519(o)
	local c
	for i = 1, 16 do
		o[i] = o[i] + 65536 -- 1 << 16
		-- lua ">>" doesn't perform sign extension...
		-- so the following >>16 doesn't work with negative numbers!!
		-- ...took a bit of time to find this one :-)
		-- c = o[i] >> 16
		c = math.floor(o[i] / 65536) -- recheck this later to check accuracy
		
		-- ok
		if i < 16 then
			o[i+1] = o[i+1] + (c - 1)
		else
			o[1] = o[1] + 38 * (c - 1)
		end
		
		o[i] = o[i] - bitExtra.uleftShift(c, 16)
	end
end --car25519()

local function sel25519(p, q, b)
	local c = bit.bnot(b-1)
	local t
	for i = 1, 16 do
		t = bit.band(c, bit.bxor(p[i], q[i]))
		p[i] = bit.bxor(p[i], t)
		q[i] = bit.bxor(q[i], t)
	end
end --sel25519

local function pack25519(o, n)
	-- out o[32], in n[16]
	local m, t = {}, {}
	local b
	for i = 1, 16 do t[i] = n[i] end
	car25519(t)
	car25519(t)
	car25519(t)
	for _ = 1, 2 do
		m[1] = t[1] - 0xffed
		for i = 2, 15 do
			m[i] = t[i] - 0xffff - 
				rshiftBand(m[i-1])
				-- bit.band(bit.rshift(m[i-1], 16), 1)
			m[i-1] = bit.band(m[i-1], 0xffff)
		end
		m[16] = t[16] - 0x7fff -
			rshiftBand(m[15])
			-- bit.band(bit.rshift(m[15], 16), 1)
		b = rshiftBand(m[16]) -- (m[16] >> 16) & 1
		m[15] = bit.band(m[15], 0xffff)
		sel25519(t, m, 1-b)
	end
	for i = 1, 16 do
		o[2*i-1] = bit.band(t[i], 0xff)
		o[2*i] = bit.rshift(t[i], 8)
	end
end -- pack25519

-- neq25519() not used
-- par25519() not used

local function unpack25519(o, n)
	-- out o[16], in n[32]
	for i = 1, 16 do
		o[i] = n[2*i-1] + bitExtra.uleftShift(n[2*i], 8)
	end
	o[16] = bit.band(o[16], 0x7fff)
end -- unpack25519

local function A(o, a, b) --add
	for i = 1, 16 do o[i] = a[i] + b[i] end
end

local function Z(o, a, b) --sub
	for i = 1, 16 do o[i] = a[i] - b[i] end
end

local function M(o, a, b) --mul  gf, gf -> gf
	local t = {}
	for i = 1, 32 do t[i] = 0  end
	for i = 1, 16 do
		for j = 1, 16 do
			t[i+j-1] = t[i+j-1] + (a[i] * b[j])
		end
	end
	for i = 1, 15 do t[i] = t[i] + 38 * t[i+16] end
	for i = 1, 16 do o[i] = t[i] end

	car25519(o)
	car25519(o)
end

local function S(o, a)  --square
	M(o, a, a)
end

local function inv25519(o, i)
	local c = {}
	for a = 1, 16 do c[a] = i[a] end
	for a = 253, 0, -1 do
		S(c, c)
		if a ~= 2 and a ~= 4 then M(c, c, i) end
	end
	for a = 1, 16 do o[a] = c[a] end
--~ 	pt(o)
end

--pow2523() not used

local t_121665 = {0xDB41,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

---@param q integer[] output of function
---@param n integer[]
---@param p integer[]
---@return integer
local function crypto_scalarmult(q, n, p)
	-- out q[], in n[], in p[]
	local z = {}
	local x = {}
	local a = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local b = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local c = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local d = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local e = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local f = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	for i = 1, 31 do z[i] = n[i] end
	
	z[32] = bit.bor(bit.band(n[32], 127), 64)
	z[1] = bit.band(z[1], 248)
--~ 	pt(z)
	unpack25519(x, p)
	
--~ 	pt(x)
	for i = 1, 16 do
		b[i] = x[i]
		a[i] = 0
		c[i] = 0
		d[i] = 0
	end
	a[1] = 1
	d[1] = 1
	for i = 254, 0, -1 do
		local r =
			bit.band(
				bit.rshift(
					z[bit.rshift(i, 3) + 1],
					bit.band(i, 7)
				),
				1
		)
		
		sel25519(a, b, r)
		-- a corrupted at i==252
		
		sel25519(c,d,r)
		A(e,a,c)
		Z(a,a,c)
		A(c,b,d)
		Z(b,b,d)
		S(d,e)
		S(f,a)
		M(a,c,a)
		M(c,b,e)
		A(e, a, c)
		Z(a,a,c)
		S(b,a)
		Z(c, d, f)
		M(a,c,t_121665)
		A(a, a, d)
		M(c,c,a)
		M(a,d,f)
		M(d,b,x)
		S(b,e)
		sel25519(a,b,r)
		sel25519(c,d,r)
	end

	for i = 1, 16 do
		x[i+16] = a[i]
		x[i+32] = c[i]
		x[i+48] = b[i]
		x[i+64] = d[i]
	end
	-- cannot use pointer arithmetics...
	local x16, x32 = {}, {}
	for i = 1, #x do
		if i > 16 then x16[i-16] = x[i] end
		if i > 32 then x32[i-32] = x[i] end
	end
	inv25519(x32,x32)
	M(x16,x16,x32)
	pack25519(q,x16)
	return 0
end -- crypto_scalarmult

local t_9 = { -- u8 * 32
	9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	}

---@param q integer[] output
---@param n integer[]
---@return integer
local function crypto_scalarmult_base(q, n)
	-- out q[], in n[]
	return crypto_scalarmult(q, n, t_9)
end

------------------------------------------------------------------------
-- convenience function (using binary strings instead of byte tables)
--
-- curve point and scalars are represented as 32-byte binary strings
-- (encoded as little endian)

---@param n string must be 32 bytes long
---@param p string see arg n
---@return string
local function scalarmult(n, p)
	-- n, a scalar (little endian) as a 32-byte string
	-- p, a curve point as a 32-byte string
	-- return the scalar product np as a 32-byte string
	
	assert(#n == 32)
	assert(#p == 32)

	local qt, nt, pt = {}, {}, {} 
	for i = 1, 32 do 
		nt[i] = string.byte(n, i) 
		pt[i] = string.byte(p, i) 
	end
	crypto_scalarmult(qt, nt, pt)
	
	local q = string.char(unpack(qt))
	return q
end

-- base: the curve point generator = 9

local base = '\9' .. ('\0'):rep(31)

--[[

--- How to use scalarmult to generate curve25519 keypairs

For any scalar s (a 32-byte string), the scalar product 's . base' is a point on the elliptic curve. 'base' is a generator.
	point = scalarmult(s, base)

	If s2 is another scalar, 
	point2 = scalarmult(s2, point) is also a point on the curve.

Secret keys are random scalars (a 32-byte random string).
The associated public keys are the corresponding points on the curve
(also encoded as 32-byte strings):
   public = scalarmult(secret, base)

let 'ask' and 'bsk' be repectively Alice and Bob private keys 
(random 32-byte strings)

Alice public key 'apk' is obtained by:
   apk = scalarmult(ask, base)

Similarly for Bob public key 'bpk':
   bpk = scalarmult(bsk, base)

--- How to perform an ECDH exchange

When Alice wants to send a message to Bob, they must be able to establish
a common session key (for a symmetric encryption algorithm).

   Alice and Bob each have the public key of the other party.
   
   Alice compute a secret s:
   s = scalarmult(ask, bpk)
   
   Bob is able to compute the same secret s as:
   s = scalarmult(bsk, apk)
   
   This is the same secret since apk = ask . base and bpk = bsk . base
   thus:  s = ask . bsk . base = bsk . ask . base since the scalar
   multiplication is commutative

   the secret s is a 32-byte string. It is advised not to use it
   directly as a session key since the bit dstribution in s is not 
   completely uniform. So the secret s should be "washed" with 
   a cryptographic hash function to get a uniformly distributed key.
   
   NaCl use the Salsa20 core encryption function to do that (see
   the hsalsa20() function and the stream_key() function in file
   box.lua
   
   But any other hash function can do. (eg. sha256 or blake2b)

--- scalarmult implementation notes

- scalars are represented as little endian

- the 3 lower bits of the scalar are ignored (the actual scalar 
  is contained in bits 3 to 255)
  so for example, 
   scalarmult(('\0'):rep(32), base)
   == scalarmult('\6' .. ('\0'):rep(31), base)

- the bit 254 of the scalar is always set. so:
   scalarmult(('\0'):rep(32), base)
   == scalarmult(('\0'):rep(31) .. '\x40', base)

- the group order N is (2^252 + 27742317777372353535851937790883648493)
  let N8 the 32-byte string containing 8 * N as a little endian 
  32-byte int. (the hex rep of the 32-byte string is: 
  689faee7d21893c0b2e6bc17f5cef7a600000000000000000000000000000080 )
  then,
	 scalarmult(('\0'):rep(32), base) == scalarmult(N8, base)
  
  
  
]]

---@type nacl
local nacl51 = {
	crypto_scalarmult = crypto_scalarmult,
	crypto_scalarmult_base = crypto_scalarmult_base,
	--
	-- convenience function and definition
	--
	scalarmult = scalarmult,
	base = base,
	---- end of ec25519 module
}

--#####################################################################
-- additions
--#####################################################################

---@param s string
---@return integer[]
function stringToByteArray(s)
	local result = {}

	for i = 1, #s do
		result[i] = s:sub(i,i):byte()
	end

	return result
end

---@param a integer[]
---@return string
function byteArrayToStr(a)
	local result = ''
	
	for i = 1, #a do
		result = result .. a[i]
	end

	return result
end

---@param len integer
---@return number[]
function getNumberArray(len, init)
	local result = {}
	
	if len then
		for i = 1, len do
			result[i] = 0 
		end
	end

	if init then
		for i = 1, #init do
			result[i] = init[i]
		end
	end

	return result
end

function getNA64()return getNumberArray(64)end
function getNA32()return getNumberArray(32)end
function gf(init)return getNumberArray(16, init)end
-- sub main

---@param high integer
---@param low integer
---@return nacl.range
function u64(high, low)
	return {
		hi = bit.bor(high, bit.rshift(0, 0)); 
		lo = bit.bor(low, bit.rshift(0, 0) )
	}
end

---@param x integer[]
---@param i integer
---@return nacl.range
function dl64(x, i)
    -- print(Static.table.toString(x), i)
	i = i + 1
	local h = bit.bor(
		bitExtra.uleftShift(x[i], 24),
		bitExtra.uleftShift(x[i + 1], 16),
		bitExtra.uleftShift(x[i+2], 8),
		x[i+3]
	)
	local l = bit.bor(
		bitExtra.uleftShift(x[i + 4], 24),
		bitExtra.uleftShift(x[i + 5], 16),
		bitExtra.uleftShift(x[i + 6], 8),
		x[i+7]
	);
	
	return u64(h, l);
end

---@param ... nacl.range
---@return nacl.range
function add64(...)
	local a, b, c, d = 0, 0, 0, 0
	local m16 = 0xFFFF
	
	for i = 1, select('#', ...)  do
		local l = select(i, ...).lo
		local h = select(i, ...).hi
		a = a + bit.band(l, m16)
		b = b + bit.rshift(l, 16)
		c = c + bit.band(h, m16)
		d = d + bit.rshift
	end
	
	b = b + bit.rshift(a, 16)
	c = c + bit.rshift(b, 16)
	d = d + bit.rshift(c, 16)
	
	return u64(
		bit.bor(
			bit.band(c, m16),
			bitExtra.uleftShift(d, 16)
		),
		bit.bor(
			bit.band(a, m16),
			bitExtra.uleftShift(b, 16)
		)
	)
end

---@param ... nacl.range
---@return nacl.range
function xor64(...)
	local l = 0
	local h = 0

	for i = 1, select("#", ...)do
		l = bit.bxor(l, select(i, ...).lo)
		h = bit.bxor(h, select(i, ...).hi)
	end

	return u64(h, l)
end

---@param x nacl.range
---@param c integer
---@return nacl.range
function R(x, c)
	assert(c <= 64, 'invalid c')

	local h, l
	local c1 = 32 - c
	
	local a = c < 32 and 'hi' or 'lo'
	local b = c < 32 and 'lo' or 'hi'
	
	h = bit.bor(bit.rshift(x[a], c), bitExtra.uleftShift(x[b], c1))
	l = bit.bor(bit.rshift(x[b], c), bitExtra.uleftShift(x[a], c1))
	
	return u64(h,l)
end

---@param x nacl.range
---@return nacl.range
function Sigma0(x)return xor64(R(x,28), R(x,34), R(x,39))end

---@param x nacl.range
---@return nacl.range
function Sigma1(x)return xor64(R(x,14), R(x,18), R(x,41))end

---@param x nacl.range
---@param c integer
---@return nacl.range
function shr64(x, c)
	return u64(
		bit.rshift(x.hi, c),
		bit.bor(
			bit.rshift(x.lo, c),
			bit.lshift(x.hi, (32 - c))
		)
	);
end

---@param x nacl.range
---@return nacl.range
function sigma0(x)return xor64(R(x, 1), R(x, 8), shr64(x,7))end

---@param x nacl.range
---@return nacl.range
function sigma1(x)return xor64(R(x,19), R(x,61), shr64(x,6))end

---@param x nacl.range
---@param y nacl.range
---@param z nacl.range
---@return nacl.range
function Ch(x,y,z)
	return u64(
		bit.bxor(
			bit.band(x.hi, y.hi),
			bit.band(
				bit.bnot(x.hi),
				z.hi
			)
		),
		bit.bxor(
			bit.band(x.lo, y.lo),
			bit.band(
				bit.bnot(x.lo),
				z.lo
			)
		)
	)
end

---@param x nacl.range
---@param y nacl.range
---@param z nacl.range
---@return nacl.range
function Maj(x,y,z)
	return u64(
		bit.bxor(
			bit.band(x.hi, y.hi),
			bit.band(x.hi, z.hi),
			bit.band(y.hi, z.hi)
		),
		bit.bxor(
			bit.band(x.lo, y.lo), 
			bit.band(x.lo, z.lo),
			bit.band(y.lo, z.lo)
		)
	)
end

---@param x integer[]
---@param i integer
---@param u nacl.range
function ts64(x, i, u)
	for j = 0, 7 do
		local a = j < 4 and 'hi' or 'lo'
		x[i + j] = bit.band(
			bitExtra.uleftShift(u[a], 24 - (j % 4) * 8),
			0xFF
		)
	end
	--[[
	x[i]   = (u.hi >> 24) & 0xff;
	x[i+1] = (u.hi >> 16) & 0xff;
	x[i+2] = (u.hi >>  8) & 0xff;
	x[i+3] = u.hi & 0xff;
	x[i+4] = (u.lo >> 24)  & 0xff;
	x[i+5] = (u.lo >> 16)  & 0xff;
	x[i+6] = (u.lo >>  8)  & 0xff;
	x[i + 7]= u.lo & 0xff;
	--]]
end

crypo_hashblocks_K = {
	u64(0x428a2f98, 0xd728ae22), u64(0x71374491, 0x23ef65cd),
	u64(0xb5c0fbcf, 0xec4d3b2f), u64(0xe9b5dba5, 0x8189dbbc),
	u64(0x3956c25b, 0xf348b538), u64(0x59f111f1, 0xb605d019),
	u64(0x923f82a4, 0xaf194f9b), u64(0xab1c5ed5, 0xda6d8118),
	u64(0xd807aa98, 0xa3030242), u64(0x12835b01, 0x45706fbe),
	u64(0x243185be, 0x4ee4b28c), u64(0x550c7dc3, 0xd5ffb4e2),
	u64(0x72be5d74, 0xf27b896f), u64(0x80deb1fe, 0x3b1696b1),
	u64(0x9bdc06a7, 0x25c71235), u64(0xc19bf174, 0xcf692694),
	u64(0xe49b69c1, 0x9ef14ad2), u64(0xefbe4786, 0x384f25e3),
	u64(0x0fc19dc6, 0x8b8cd5b5), u64(0x240ca1cc, 0x77ac9c65),
	u64(0x2de92c6f, 0x592b0275), u64(0x4a7484aa, 0x6ea6e483),
	u64(0x5cb0a9dc, 0xbd41fbd4), u64(0x76f988da, 0x831153b5),
	u64(0x983e5152, 0xee66dfab), u64(0xa831c66d, 0x2db43210),
	u64(0xb00327c8, 0x98fb213f), u64(0xbf597fc7, 0xbeef0ee4),
	u64(0xc6e00bf3, 0x3da88fc2), u64(0xd5a79147, 0x930aa725),
	u64(0x06ca6351, 0xe003826f), u64(0x14292967, 0x0a0e6e70),
	u64(0x27b70a85, 0x46d22ffc), u64(0x2e1b2138, 0x5c26c926),
	u64(0x4d2c6dfc, 0x5ac42aed), u64(0x53380d13, 0x9d95b3df),
	u64(0x650a7354, 0x8baf63de), u64(0x766a0abb, 0x3c77b2a8),
	u64(0x81c2c92e, 0x47edaee6), u64(0x92722c85, 0x1482353b),
	u64(0xa2bfe8a1, 0x4cf10364), u64(0xa81a664b, 0xbc423001),
	u64(0xc24b8b70, 0xd0f89791), u64(0xc76c51a3, 0x0654be30),
	u64(0xd192e819, 0xd6ef5218), u64(0xd6990624, 0x5565a910),
	u64(0xf40e3585, 0x5771202a), u64(0x106aa070, 0x32bbd1b8),
	u64(0x19a4c116, 0xb8d2d0c8), u64(0x1e376c08, 0x5141ab53),
	u64(0x2748774c, 0xdf8eeb99), u64(0x34b0bcb5, 0xe19b48a8),
	u64(0x391c0cb3, 0xc5c95a63), u64(0x4ed8aa4a, 0xe3418acb),
	u64(0x5b9cca4f, 0x7763e373), u64(0x682e6ff3, 0xd6b2b8a3),
	u64(0x748f82ee, 0x5defb2fc), u64(0x78a5636f, 0x43172f60),
	u64(0x84c87814, 0xa1f0ab72), u64(0x8cc70208, 0x1a6439ec),
	u64(0x90befffa, 0x23631e28), u64(0xa4506ceb, 0xde82bde9),
	u64(0xbef9a3f7, 0xb2c67915), u64(0xc67178f2, 0xe372532b),
	u64(0xca273ece, 0xea26619c), u64(0xd186b8c7, 0x21c0c207),
	u64(0xeada7dd6, 0xcde0eb1e), u64(0xf57d4f7f, 0xee6ed178),
	u64(0x06f067aa, 0x72176fba), u64(0x0a637dc5, 0xa2c898a6),
	u64(0x113f9804, 0xbef90dae), u64(0x1b710b35, 0x131c471b),
	u64(0x28db77f5, 0x23047d84), u64(0x32caab7b, 0x40c72493),
	u64(0x3c9ebe0a, 0x15c9bebc), u64(0x431d67c4, 0x9c100d4c),
	u64(0x4cc5d4be, 0xcb3e42b6), u64(0x597f299c, 0xfc657e2a),
	u64(0x5fcb6fab, 0x3ad6faec), u64(0x6c44198c, 0x4a475817)
}

function crypto_hashblocks(result, array, n)
	local z,b,a,w = {}, {}, {}, {}
	local t;
	
    for i = 1, 8 do
        a[i] = dl64(result, 8 * (i - 1));
        z[i] = a[i]
	end

	local pos = 0

	while n >= 128 do
		for i = 1, 16 do
			w[i] = dl64(array, 8 * (i - 1) + pos);
		end

		for i = 1, 80 do
			local k = i - 1
			for j = 1, 8 do b[j] = a[j]end
			
			t = add64(
				a[8],
				Sigma1(a[5]),
				Ch(unpack(a, 5,7)),
				crypo_hashblocks_K[k],
				w[k % 16 + 1]
			)

			b[8] = add64(t, Sigma0(a[1]), Maj(unpack(a)))
			b[4] = add64(b[4], t)

			for j = 1, 8 do a[j % 8] = b[j - 1] end
			
			if k % 16 == 15 then
				for j = 1, 16 do
					w[j] = add64(
						w[j],
						w[(j + 8) % 16 + 1],
						sigma0(w[j%16 + 1]),
						sigma1(w[(j+13)%16 + 1])
					)
				end
			end
		end
		
		for i = 1, 8 do
			a[i] = add64(a[i], z[i]);
			z[i] = a[i];
		end
	  
		pos = pos + 128;
		n = n - 128;
	end

	for i = 1, 8 do ts64(result, 8*(i - 1), z[i]) end
	return n
end

local crypto_hash_K = {
	0x6a,0x09,0xe6,0x67,0xf3,0xbc,0xc9,0x08,
	0xbb,0x67,0xae,0x85,0x84,0xca,0xa7,0x3b,
	0x3c,0x6e,0xf3,0x72,0xfe,0x94,0xf8,0x2b,
	0xa5,0x4f,0xf5,0x3a,0x5f,0x1d,0x36,0xf1,
	0x51,0x0e,0x52,0x7f,0xad,0xe6,0x82,0xd1,
	0x9b,0x05,0x68,0x8c,0x2b,0x3e,0x6c,0x1f,
	0x1f,0x83,0xd9,0xab,0xfb,0x41,0xbd,0x6b,
	0x5b,0xe0,0xcd,0x19,0x13,0x7e,0x21,0x79,
}

---@param result integer[]
---@param m integer[]
---@param n integer
function crypto_hash(result, m, n)
	local h = Static.table.clone(crypto_hash_K)
	local x = getNumberArray(256);
	local b = n;
	
	crypto_hashblocks(h, m, n);
	n = n % 128

	for i = 1, 256 do x[i] = 0 end
	for i = 1, n do x[i] = m[b - n + i] end
	x[n + 1] = 128
	n = 256 - 128 * (n < 112 and 1 or 0);
	x[n - 8] = 0;
	ts64(
		x,
		n - 8,
		u64(
			bit.bor((b / 0x20000000), 0),
			bitExtra.uleftShift(b, 3)
		)
	);
	
	for i = 1, 64 do result[i] = h[i]; end
end

local modL_K = {0xed, 0xd3, 0xf5, 0x5c, 0x1a, 0x63, 0x12, 0x58, 0xd6, 0x9c, 0xf7, 0xa2, 0xde, 0xf9, 0xde, 0x14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x10}

---@param r integer[]
---@param x integer[]
function modL(r, x)
	local carry, i, j, k
	
	for i = 63, 32, -1 do
		carry = 0
		
		local k = i - 12
		local j = i - 32

		while j < k do
			j = j + 1
			x[j] = x[j] + carry - 16 * x[i] * modL_K[j - (i - 32)];
			carry = math.floor((x[j] + 128) / 256);
			x[j] = x[j] - carry * 256;
		end

		x[j] = x[j] + carry
		x[i] = 0
	end
	
	carry = 0;

	for j = 1, 32 do
		x[j] = x[j] + carry - bit.rshift(x[32], 4) * modL_K[j]
		carry = bit.rshift(x[j], 8)
		x[j] = bit.band(x[j], 0xFF)
	end
	
	for j = 1, 32 do x[j] = x[j] - carry * modL_K[j] end
	for i = 1, 32 do
		x[i + 1] = bit.rshift(x[i], 8)
		r[i] = bit.band(x[i], 0xFF)
	end
end

---@param r integer[]
function reduce(r)
	local x = getNA64();
	for i = 1, 64 do x[i] = r[i]; end
	for i = 1, 64 do r[i] = 0; end
	modL(r, x);
end

function set25519(r, a)for i = 1, 16 do r[i] = bit.bor(a[i], 0)end end

function cswap(p, q, b)for i = 1, 4 do sel25519(p[i], q[i], b)end end

local add_D2_K = getNumberArray(16, {0xf159, 0x26b2, 0x9b94, 0xebd6, 0xb156, 0x8283, 0x149a, 0x00e0, 0xd130, 0xeef3, 0x80f2, 0x198e, 0xfce7, 0x56df, 0xd9dc, 0x2406})

function add(p, q)
	local a, b, c, d, e, f, g, h, t = 
		getNumberArray(16), getNumberArray(16), getNumberArray(16),
		getNumberArray(16), getNumberArray(16), getNumberArray(16),
		getNumberArray(16), getNumberArray(16), getNumberArray(16)

	Z(a, p[2], p[1]);
	Z(t, q[2], q[1]);
	M(a, a, t);
	A(b, p[1], p[2]);
	A(t, q[1], q[2]);
	M(b, b, t);
	M(c, p[4], q[4]);
	M(c, c, add_D2_K);
	M(d, p[3], q[3]);
	A(d, d, d);
	Z(e, b, a);
	Z(f, d, c);
	A(g, d, c);
	A(h, b, a);
	  
	M(p[1], e, f);
	M(p[2], h, g);
	M(p[3], g, f);
	M(p[4], e, h);
end

local scalarbase_K_X = getNumberArray(16, {0xd51a, 0x8f25, 0x2d60,
	0xc956, 0xa7b2, 0x9525, 0xc760, 0x692c, 0xdc5c, 0xfdd6, 0xe231, 0xc0a4, 0x53fe,
	0xcd6e, 0x36d3, 0x2169})
local scalarbase_K_Y = getNumberArray(16, { 0x6658, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666,
	0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, })
local scalarbase_K_gf1 = getNumberArray(16, {1})
local scalarbase_K_gf0 = getNumberArray(16)

function scalarmult_2(p, q, s)
	set25519(p[1], scalarbase_K_gf0)
	set25519(p[2], scalarbase_K_gf1)
	set25519(p[3], scalarbase_K_gf1)
	set25519(p[4], scalarbase_K_gf0)

	for i = 255, 0, -1 do
		local b = bit.band(
			1,
			bit.rshift(
				s[bit.bor(i/8,0) + 1],
				i % 7
			)
		)

		cswap(p, q, b);
		add(q, p);
		add(p, p);
		cswap(p, q, b);
	end
end

function scalarbase(p, s)
	local q = { getNA32(), getNA32(), getNA32(), getNA32() }
	
	set25519(q[1], scalarbase_K_X)
	set25519(q[2], scalarbase_K_Y)
	set25519(q[3], scalarbase_K_gf1)
	M(q[4], scalarbase_K_X, scalarbase_K_Y)
	scalarmult_2(p, q, s);
end

function par25519(a)
	local b = getNA32()
	pack25519(b, a)
	return bit.band(b[1], 1)
end

function pack(r, p)
	local tx, ty, zi = gf(), gf(), gf()
	inv25519(zi, p[3])
	M(tx, p[1], zi);
	M(ty, p[2], zi);
	pack25519(r, ty)
	r[32] = bit.bxor(
		r[32],
		bitExtra.uleftShift(par25519(tx),7)
	)
end

---@param result integer[]
---@param message integer[]
---@param len integer
---@param secretKey integer[]
function crypto_sign(result, message, len, secretKey)
	local d, h, r, x =
		getNA64(), getNA64(), getNA64(), getNA64()
		
	local p = { getNA32(), getNA32(), getNA32(), getNA32() }
	
	crypto_hash(d, secretKey, 32);
	d[1] = bit.band(d[1], 248);
	d[32] = bit.bor(bit.band(d[32], 127), 64)
	
	local smlen = len + 64
	
	for i = 1, len do result[63 + i] = message[i]end
	for i = 1, 32 do result[31 + i] = d[31 + i]end
	
	crypto_hash(r, {unpack(result, 33)}, len+32);
	reduce(r)
	scalarbase(p, r)
	pack(result, p);
	
	for i = 32, 64 do result[i] = secretKey[i]end
	crypto_hash(h, secretKey, len + 64)
	reduce(h)
	
	for i = 1, 64 do x[i] = 0 end
	for i = 1, 32 do x[i] = r[i] end
	
	for i = 1, 32 do
		for j = 1, 32 do
			x[i+j-1] = x[i+j-1] + h[i] * d[j]
		end
	end

	modL({ unpack(secretKey, 33) }, x);
	return smlen
end

function crypto_sign_keypair(pk, sk)
	local d = getNA64()
	local p = {gf(),gf(),gf(),gf()}
	
	crypto_hash(d, sk, 32)
	d[1] = bit.band(d[1], 248)
	d[32] = bit.bor(bit.band(d[32], 127), 64)

	scalarbase(p, d)
	pack(pk, p)
	for i = 1, 32 do
		sk[i + 32] = pk[i]
	end
end

function pow2523(o, i)
    local c = gf()
    for a = 1, 16 do c[a] = i[i] end
	for a = 250, 0, -1 do
        S(c, c)
		if a ~= 1 then M(c, c, i) end
    end
	for a = 1, 16 do o[a] = c[a] end
end

local unpackneg_D_K = gf({ 0x78a3, 0x1359, 0x4dca, 0x75eb, 0xd8ab, 0x4141, 0x0a4d, 0x0070, 0xe898, 0x7779, 0x4079, 0x8cc7,
    0xfe73, 0x2b6f, 0x6cee, 0x5203 })

function unpackneg(r, p)
    local t, chk, num, den, den2, den4, den6 = gf(), gf(), gf(), gf(), gf(), gf(), gf()
	
    set25519(r[3], scalarbase_K_gf1)
    unpack25519(r[2], p)
    S(num, r[2])
    M(den, num, unpackneg_D_K)
    Z(num, num, r[3])
    A(den, r[3], den)
	
    S(den2, den)
    S(den4, den2)
    M(den6, den4, den2)
    M(t, den6, num)
    M(t, t, den)
	
    pow2523(t, t)
    M(t, t, num)
    M(t, t, den)
    M(t, t, den)
    M(r[1], t, den)
	
	S(chk, r[1])
    M(chk, chk, den)
	
end

--[[
	
	
	  S(chk, r[0]);
	  M(chk, chk, den);
	  if (neq25519(chk, num)) M(r[0], r[0], I);
	
	  S(chk, r[0]);
	  M(chk, chk, den);
	  if (neq25519(chk, num)) return -1;
	
	  if (par25519(r[0]) === (p[31]>>7)) Z(r[0], gf0, r[0]);
	
	  M(r[3], r[0], r[1]);
	  return 0;
	}

]]
function crypto_sign_open(m, sm, n, pk)
    -- pre
	if n < 64 then
		return -1
	end
	
	local q = {gf(), gf(), gf(), gf()}

	local t = getNA32()
    local h = getNA32()
    local p = {gf(), gf(), gf(), gf()}


end

--[[

	function crypto_sign_open(m, sm, n, pk) {
	  var i;
	  var t = new Uint8Array(32), h = new Uint8Array(64);
	  var p = [gf(), gf(), gf(), gf()],
		  q = [gf(), gf(), gf(), gf()];
	
	  if (n < 64) return -1;
	
	  if (unpackneg(q, pk)) return -1;
	
	  for (i = 0; i < n; i++) m[i] = sm[i];
	  for (i = 0; i < 32; i++) m[i+32] = pk[i];
	  crypto_hash(h, m, n);
	  reduce(h);
	  scalarmult(p, q, h);
	
	  scalarbase(q, sm.subarray(32));
	  add(p, q);
	  pack(t, p);
	
	  n -= 64;
	  if (crypto_verify_32(sm, 0, t, 0)) {
		for (i = 0; i < n; i++) m[i] = 0;
		return -1;
	  }
	
	  for (i = 0; i < n; i++) m[i] = sm[i + 64];
	  return n;
	}

]]

---returns a string of random characters, with bytes 0 to 255
---@param len integer?
---@return string
nacl51.getRandomString = function(len)
	-- pre
	len = len or 32
	
	-- main
	local result = ''

	for _ = 1, len do
		result = result .. string.char(math.random(1, 256) - 1)
	end

	return result
end

---returns a key pair, the secret key, and the public key,
---note that the secret key compromises of a prefix and public key
---@param secretKey string?
---@return string, string
nacl51.getKeyPair = function (secretKey)
	-- pre
	secretKey = secretKey or nacl51.getRandomString()
	-- main
	local publicKeyArray = getNA32()
	local secretKeyArray = getNA64()

	for i = 1, #secretKey do
		secretKeyArray[i] = secretKey:byte(i,i)
	end

	crypto_sign_keypair(publicKeyArray, secretKeyArray)
	print(#publicKeyArray, #secretKeyArray)
    print(Static.table.toString(publicKeyArray), Static.table.toString(secretKeyArray))

	return byteArrayToStr(secretKeyArray),
		byteArrayToStr(publicKeyArray)
end

---returns signature
---@param message string
---@param secretKey string
---@return string
nacl51.getSignature = function (message, secretKey)
	-- pre
	assert(#secretKey == 64)

	local signedMessage = {}

	crypto_sign(
		signedMessage,
		stringToByteArray(message),
		#message,
		stringToByteArray(secretKey)
	);

	return byteArrayToStr(signedMessage)
end

---comment
---@param message string
---@param signature string must be exactly 64 bytes
---@param publicKey string must be exactly 32 bytes
---@return boolean
nacl51.verify = function (message, signature, publicKey)
	-- pre
	assert(#signature == 64, 'bad signature length')
	assert(#publicKey == 32, 'bad public key length')
	
	-- main
    local len = #message + 32
	
    local sm = {}
	local m = getNumberArray(len)

    for i = 1, 64 do sm[i] = signature:byte(i, i) end
	for i = 1, #message do sm[i + 64] = message:byte(i,i)end

	-- post
	assert(len == #sm)

	return false
	-- return crypto_sign_open(m, sm, len, stringToByteArray(publicKey))
end

return nacl51