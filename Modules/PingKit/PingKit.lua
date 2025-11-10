local pkit = {}
-- PingKit

local http = game:GetService("HttpService")
local ms = game:GetService("MessagingService")
local cs = game:GetService("CollectionService")

local scriptsFolder = game.ReplicatedStorage:FindFirstChild("Scripts")
local ukit = require(scriptsFolder and scriptsFolder:FindFirstChild("UtilKit") or cs:GetTagged("SimplifyDev_UtilKit")[1])
local ekit = require(scriptsFolder and scriptsFolder:FindFirstChild("EventKit") or cs:GetTagged("SimplifyDev_EventKit")[1])

local evId = `SDPingKit`

local pingData = {
	conns = {};
	base = {
		val = 92;
		chars = `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()_+[\{]\};:'"\\|,<.>?\`~ `;
	};
	msgTypeWords = {
		G = (`get/g`):split(`/`);
		P = (`post/p`):split(`/`);
		R = (`return/r`):split(`/`);
	};
}

export type MessageData = {
	-- read a: any?;  -- make all of these read only after the new typer 
	msgType: string;
	requestId: number;
	serverId: number?;
	message: any;
	recipient: number?;
	sent: number;
	delay: number;
	_combinedId: number;
}

pkit._core = {
	fire = function(topic, waitForPublish: boolean?, message, msgType: string, requestId: number?, includeServerId: boolean?, recipient: number?): MessageData
		local encData = pkit._core.format.to(message, msgType, requestId, includeServerId, recipient)
		if waitForPublish then
			ms:PublishAsync(topic, encData)
		else
			coroutine.wrap(function()
				ms:PublishAsync(topic, encData)
			end)()
		end
		return pkit._core.format.from(encData)
	end;
	
	processMessage = function(topic: string, message: {Data: any, Sent: number})
		local data = pkit._core.format.from(message.Data)
		data.sent = message.Sent
		data.delay = ukit.elapsed.unix() - message.Sent;
		
		local msgType = pkit._core.msgType.from(data.msgType)
		msgType = msgType:sub(1, 1):upper() .. msgType:sub(2)

		local allName = `[Topic]{topic}`
		local allParams = {data; msgType}
		ekit.fire(evId, allName, table.unpack(allParams))
		local result1 = nil
		pcall(function()
			result1 = ekit.invoke(evId, allName, table.unpack(allParams))
		end)

		local typeName = `[Type={data.msgType}]{topic}`
		local typeParams = {data}
		ekit.fire(evId, typeName, table.unpack(typeParams))
		local result2 = nil
		pcall(function()
			result2 = ekit.invoke(evId, typeName, table.unpack(typeParams))
		end)

		local finalResult = result2 or result1
		if data.msgType == `G` and finalResult ~= nil then
			pkit._core.fire(topic, false, finalResult, `R`, data.requestId, true, data.serverId)
		end
	end;
	
	format = {
		-- "msgType" must be one character
		to = function(message: any, msgType: string, requestId: number?, includeServerId: boolean?, recipient: number?)
			local sId = pkit.server.getId()
			local listToEnc = {}
			table.insert(listToEnc, requestId or 0)
			table.insert(listToEnc, includeServerId and sId or 0)
			local encResult = ukit.number.base.fromTen(ukit.number.list.encode(listToEnc), pingData.base.val, pingData.base.chars)
			return `{msgType}{encResult}/{recipient and ukit.number.base.fromTen(recipient, pingData.base.val, pingData.base.chars) or ``}/{http:JSONEncode(message)}`
		end;
		
		from = function(data: string): MessageData
			local info, rest = table.unpack(ukit.string.splitId(data, string.find(data, `/`)))
			local combinedId = ukit.number.base.toTen(info:sub(2), pingData.base.val, pingData.base.chars)
			local rId, sId = table.unpack(ukit.number.list.decode(combinedId))
			local recipient, message = table.unpack(ukit.string.splitId(rest, string.find(rest, `/`)))
			recipient = ukit.number.base.toTen(recipient, pingData.base.val, pingData.base.chars)
			return {
				msgType = info:sub(1, 1);
				requestId = rId;
				serverId = sId;
				recipient = recipient;
				_combinedId = combinedId;
				message = http:JSONDecode(message);
			};
		end;
	};
	
	-- Converts a string into a proper type, otherwise throwing an error
	msgType = {
		to = function(str: string)
			str = str:lower()
			for letter, tabl in pairs(pingData.msgTypeWords) do
				if table.find(tabl, str) then return letter end
			end
			error(`Invalid string input. Must be one of the words from pingData.msgTypeWords`)
		end;
		
		from = function(str: string)
			str = str:lower()
			for letter, tabl in pairs(pingData.msgTypeWords) do
				if table.find(tabl, str) then return tabl[1] end
			end
			error(`Invalid string input. Must be one of the words from pingData.msgTypeWords`)
		end;
	};
};

-- Note: since disconnecting from a 

-- Subscribes to a Topic
pkit.subscribe = function(topic: string)
	if ukit.connection.active(pingData.conns[topic]) then return false end
	local conn = ms:SubscribeAsync(topic, function(message)
		return pkit._core.processMessage(topic, message)
	end)
	pingData.conns[topic] = conn
	return true
end;

-- Unsubscribes from a Topic
pkit.unsubscribe = function(topic: string)
	return ukit.connection.disconnect(pingData.conns[topic])
end;

-- Posting on a topic that doesn't exist
pkit.post = function(topic: string, message: any, includeServerId: boolean?)
	return pkit._core.fire(topic, false, message, `P`, nil, includeServerId)
end;

-- Sends a get request to all servers, returning a dictionary of the format: {[serverId]: message}
-- The result gets given back as a Post request with the same process id
-- The <code>dataCollectTime</code> defines how many seconds the code will yield to receive the requests from other servers
pkit.get = function(topic: string, message: any, dataCollectTime: number?): {[number]: {MessageData}}
	local result = {}
	local attName = `RequestCount_{topic}`
	script:SetAttribute(attName, (script:GetAttribute(attName) or 0) + 1)
	local msgData = pkit._core.fire(topic, true, message, `G`, script:GetAttribute(`RequestId_{topic}`), true)
	
	local conn = pkit.connect.type(topic, `R`, function(data: MessageData)
		if not (data.requestId == msgData.requestId and data.recipient == msgData.serverId) then return end
		result[data.serverId] = data
	end, false, false)
	task.wait(dataCollectTime or 1.5)
	ukit.connection.disconnect(conn)
	for sId, data: MessageData in pairs(result) do
		data.delay = ukit.elapsed.unix() - data.sent
	end
	return result
end;

pkit.server = {
	getId = function()
		local id = game:GetService("RunService"):IsStudio() and `sdfghjklqqwertyuioa` or game.JobId
		local hash = 0
		for _, num in pairs({string.byte(id, 1, #id)}) do hash = bit32.bxor(((hash / (2 ^ 5)) - hash), num) end
		hash = hash % (2 ^ 64)
		return hash
	end;
	
	-- Checks if a given id is of this server
	isMe = function(id: number) return id == pkit.server.getId() end;
};

pkit.connect = {
	-- Connects every single message from a topic to a function
	-- Important: This will also trigger for YOUR server. Use PingKit.server.isMe(data.serverId) to check for that
	-- Note: This function is called for all <code>msgType</code>s. Use PingKit.connect.type to specify one
	-- There are 3 possible message types: Post(Sends a message to other servers), Get(Sends a message to other servers, awaiting a response), Return(The data sent back for the Get request by others)
	-- The <code>data</code> table holds some useful data, such as:
	-- "delay" - the amount of time that passed since the message was sent from the other server
	topic = function(topic, func: (data: MessageData, msgType: string) -> nil, once, stopOnInstDel)
		return ekit.connect(evId, `[Topic]{topic}`, func, once, stopOnInstDel)
	end;
	
	-- Read the comment on PingKit.connect.topic for more info on how these work
	type = function(topic, msgType, func: (data: MessageData) -> nil, once, stopOnInstDel)
		return ekit.connect(evId, `[Type={pkit._core.msgType.to(msgType)}]{topic}`, func, once, stopOnInstDel)
	end;
};

pkit.attach = {
	-- Attaches a function which, when called with Get msgType, sends back whatever the function returns (unless nil)
	-- More info attached to the PingKit.connect.topic message
	topic = function(topic, func: (data: MessageData, msgType: string) -> nil)
		return ekit.attach(evId, `[Topic]{topic}`, func)
	end;
	
	-- Read the comment on PingKit.connect.topic for more info on how these work
	type = function(topic, msgType, func: (data: MessageData) -> nil)
		return ekit.attach(evId, `[Type={pkit._core.msgType.to(msgType)}]{topic}`, func)
	end;
};

return pkit
