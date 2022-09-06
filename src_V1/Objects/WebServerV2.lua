---@meta

---@class WebServerV2
---@field new fun(host: string?, port: integer?): WebServerV2.object

---@class WebServerV2.object
---@field server TcpServer.server
---@field ipAddress string
---@field serverPort integer

---@class copas
---@field handler fun(handler: fun(server: TcpServer.server), params: copas.ssl.params): copas.handler
---@field addServer fun(server: TcpServer.server, handler: copas.handler, name: string)
---@field loop fun()

---@class copas.handler

---@class copas.ssl.params
---@field wrap copas.ssl.params.wrap

---@class copas.ssl.params.wrap
---@field mode "server" tbc
---@field protocol "any"

---@type WebServerV2
local WebServerV2 = {}
local Static = require('Static')
Static.luarocks.loadModule('LuaSocket')

print(
	'copas:',
	Static.table.toString(
		Static.luarocks.loadModule('copas')
	)
)

---@type copas
local copas = require('copas')
---@type socket
local socket = require('socket')


---webservice v2
---@param host string?
---@param port integer?
---@return WebServerV2.object
WebServerV2.new = function(host, port)
	-- pre
	host = host or '*'
	port = port or 3000

	local server = assert(
		socket.bind(host, port),
		'error creating socket server'
	)
	local ipAddress, serverPort = server:getsockname()
	assert(ipAddress, 'missing ip address')

	-- main
	---@type WebServerV2.object
	local object = {}
	object.server = server
	object.ipAddress = ipAddress
	object.serverPort = serverPort
	
	---@type copas.ssl.params
	local sslParams = {
		wrap = {
			protocol = 'any';
			mode = 'server'
		}
	}

	---on request
	---@param client TcpServer.client
	local function onRequest(client)
		local data, err = client:receive()
		print(data)

		client:close()
	end

	copas.addServer(
		server,
		copas.handler(onRequest, sslParams),
		'TestServer'
	)
	

	return object
end

return WebServerV2