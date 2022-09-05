---@meta

local Enum = {}

---@enum mimeType
Enum.mimeTypes =  {
	html = 'text/html';
	txt = 'text/plain'
}

---@enum requestType
Enum.requestTypes = {
	GET = 'GET';
	POST = 'POST'
}

return Enum