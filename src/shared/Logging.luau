local RunService = game:GetService("RunService")

local Logging = {}
Logging.__index = Logging
Logging._Side = if RunService:IsServer() then "Server" else "Client"

local baseMessage = "(%s) [%s][%s] - %s"

function Logging.new(fileName: string)
	return setmetatable({
		_FileName = fileName,
	}, Logging)
end

function Logging:Log(message: string)
	print(baseMessage:format(Logging._Side, "PRINT", self._FileName, message))
end

function Logging:Warn(message: string)
	warn(baseMessage:format(Logging._Side, "WARN", self._FileName, message))
end

function Logging:Error(message: string)
	error(baseMessage:format(Logging._Side, "ERROR", self._FileName, message), 2)
end

function Logging:Fatal(message: string)
	error(baseMessage:format(Logging._Side, "FATAL", self._FileName, message), 1)
end

function Logging:Debug(message: string)
	print(baseMessage:format(Logging._Side, "DEBUG", self._FileName, message))
end

return Logging