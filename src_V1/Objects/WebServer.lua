---@meta

--[[spec]]

-- nixOS: pkgs.lua51Packages.luasocket
-- socket
-- refer to https://w3.impa.br/~diego/software/luasocket/reference.html
---@class WebServer
---@field new fun(host: string?, port: number?): WebServer.object

---@class WebServer.object
---@field server TcpServer.server
---@field ipAddress string
---@field serverPort number
---@field isAlive boolean
---@field replitDataBase ReplitDataBase May need to modify this later, dont bother using this extensively
---@field onRequest fun(webPage: string, requestType: string, response: fun(client: TcpServer.client, request: cURL.ClientRequest, response: cURL.ServerResponse)): WebServer.object
---@field onInvalidRequest fun(response: fun(client: TcpServer.client, request: cURL.ClientRequest, response: cURL.ServerResponse)): WebServer.object
---@field StringParser StringParser.object
---@field launch fun(): WebServer.object
---@field keepAlive fun(): WebServer.object

---@class socket
---@field bind fun(host: string, port: number): TcpServer.server
--- your server

---@class TcpServer.super
---@field settimeout fun(self:TcpServer.super, val: 'b' | 't' | number | 'bt' | 'tb' | nil)

---@class TcpServer.master: TcpServer.super
---@field listen fun(): string

---@class TcpServer.server: TcpServer.super
---@field getsockname fun(): string, number
---@field accept fun(): TcpServer.client
---@field setoption fun(option: string, value: string?)

---@class TcpServer.client: TcpServer.super
---@field receive fun(self: TcpServer.client, s: (string | integer)?): string, string?
--- recieves a string from client
---@field close fun(self: TcpServer.client) @closes connection to 
--- client
---@field send fun(self:TcpServer.client, data: string)
--- sends data through client

---@class Headers
---@field X-Forwarded-For string? ip address from address

---@type WebServer
local WebServer = {}
local Enum = require('Enum')
local isLoaded = false

local cURL = require('cURL')

-- Static.luarocks.loadModule('socket')
local socket = require('socket')
local Static = require('Static')
local StringParser = require('StringParser')
local cURL = require('cURL')
local ReplitDataBase = require('ReplitDatabase')

---returns webserver object
---@param host string?
---@param port integer?
---@return WebServer.object
function WebServer.new(host, port)
	-- pre
	assert(
		not isLoaded,
		'object is constucted only once'
	)
	host = host or '*'
	port = port or 8080

	-- main
	---@type WebServer.object
	local object = {}
	
	object.isAlive = false
	object.server = socket.bind(host, port)
	object.ipAddress, object.serverPort = 
		object.server:getsockname()

	object.replitDataBase = ReplitDataBase
	object.StringParser = 
		StringParser.new''
	
	assert(
		object.ipAddress,
		'missing ip address: ' .. object.serverPort
	)
	local requestResponses = {}

	---responsible for catch any valid request made to server
	---@param webPage string
	---@param requestType string
	---@param responseFunc fun(client: TcpServer.client, headers: Headers)
	---@return WebServer.object
	function object.onRequest(webPage, requestType, responseFunc)
		requestResponses[webPage] = requestResponses[webPage] or {}

		local webPageResponses = requestResponses[webPage]
		
		webPageResponses[requestType] = responseFunc

		return object
	end

	local invalidFunc

	---responsible for recieving any non indexed requests
	---@param func fun(webPage: string, requestType: string, client: TcpServer.client, headers: Headers)
	---@return WebServer.object
	function object.onInvalidRequest(func)
		invalidFunc = func
		return object
	end

	local launched = false

    ---launches web server, at that point it is able to recieve messages
	--- and respond to them
	function object.launch()
		assert(not launched, 'can only launch once')
		assert(invalidFunc, 'needs invalid func')

		launched = true
		coroutine.wrap(function()
			while true do
				local client = object.server:accept()

				local request = cURL
					.clientRequest
					.fromTCPClient(client)
				
				local responseWebPage = Static.table.access(
					requestResponses, 
					request.webPage, 
					request.requestType
				)
	
				assert(responseWebPage or invalidFunc)
	
				local response = cURL.serverResponse.new()
				response.statusCode = 501
				response.statusMessage = 'not implemented'
				response.body = 'oops, server did something wrong'
				response.headers['Content-Type'] =
					Enum.mimeTypes.txt
				response.success = false
				response.httpVersion = request.httpVersion

				local _ = (responseWebPage or invalidFunc)(client, request, response)
				
				client:send(response.toString())

				-- atm, its only a recieve and respond type webservice
				client:close()
			end
		end)()
    end
	
    ---keeps server alive to avoid shutting down (indevelopment)
	---@deprecated
	---@return WebServer.object
    function object.keepAlive()
        -- main
        object.isAlive = true
		object.server:setoption('keepalive')
		return object
	end

	return object
end

return WebServer