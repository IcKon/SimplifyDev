local ekit = {}

local rs = game:GetService("RunService")
local players = game:GetService("Players")

local ukit = require(script.Parent:WaitForChild("UtilKit"))

export type ConnInst = Instance|false|nil
export type Category = Instance|string|nil
local sdRoot = ukit.instance.get(`Folder`, "-SimplifyDev-", game:GetService("RunService"):IsServer() and game.ServerStorage or game.ReplicatedStorage)
local storageRoot = ukit.instance.get(`Folder`, `EventKit`, sdRoot)

local eData = {
	holder = {
		data = {} :: {[Instance]: {conns: {RBXScriptConnection}; id: number; count: number}};
		index = {} :: {[number]: Instance};
		count = 0;
	};
	event = {
		data = {} :: {[BindableEvent]: {conns: {RBXScriptConnection}; globalId: number; id: number; name: string; isAttached: boolean}};
		index = {} :: {[number]: BindableEvent};
		count = 0;
	};
	instConnections = {};
	baseChars = table.concat(ukit.table.randomize(string.split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890", "")));
}
ekit._core = {
	name = {
		-- TODO: Name encoding doesn't work yet. The plan is to obfuscate what events do what for those sneaky people firing your events for some in-game advantage
		-- Returns a unique name to an Event (ukit.number.list.encode({parentId; eventId}), then to a high base. Shift idea: multiply each eventId by 100 and shift each assign (based on a seed?) by 0-99)
		-- Note: The encoding does not happen in Studio
		encode = function(name: string, parent: Instance)
			--if rs:IsStudio() then return name end
			local event = ekit._core.getEvent(name, parent)
			local evId = eData.event.data[event].id
			local hoId = eData.holder.data[event.Parent].id
			return ukit.number.base.fromTen(ukit.number.list.encode({hoId; evId}), #eData.baseChars, eData.baseChars)
		end;

		-- Returns the original name from an encoded one
		decode = function(encName: string): string
			--if rs:IsStudio() then return encName end
			local hoId, evId = table.unpack(ukit.number.list.decode(ukit.number.base.toTen(encName, #eData.baseChars, eData.baseChars)))
			local holder = eData.holder.index[hoId]
			if not holder then return end
			local event = eData.event.index[evId]
			return event and eData.event.data[event].name or nil
		end;
	};

	getEvent = function(name: string, parent: Instance, create: boolean?): BindableEvent
		ekit._core.setupHolder(parent)
		local event: BindableEvent? = create and ukit.instance.get("BindableEvent", name, parent) or parent:FindFirstChild(name)
		if not event then return end
		if not eData.event.data[event] then
			local conns: {RBXScriptConnection} = {}
			eData.event.count += 1
			eData.holder.data[event.Parent].count += 1
			local globalId = eData.event.count
			local id = eData.holder.data[event.Parent].count
			eData.event.data[event] = {conns = conns; globalId = globalId; id = id; name = name; isAttached = false}
			eData.event.index[id] = event
			event.Destroying:Once(function()
				ukit.table.deep.clear(eData.event.data[event])
				eData.event.data[event] = nil
				eData.event.index[id] = nil
			end)
		end
		return event
	end;

	-- Returns a BindFunction Instance attached to an event
	-- A bind's parent is always the Event with the same name
	getBind = function(name: string, parent: Instance?, create: boolean?): BindableFunction
		local event = ekit._core.getEvent(name, parent, create)
		if not event then return false end
		local bind: BindableFunction = create and ukit.instance.get("BindableFunction", "Bind", event) or event:FindFirstChild("Bind")
		return bind
	end;

	-- Sets up a parent to work with
	setupHolder = function(inst: Instance)
		if eData.holder.data[inst] then return false end
		local conns: {RBXScriptConnection} = {}
		eData.holder.count += 1
		local id = eData.holder.count
		eData.holder.data[inst] = {conns = conns; id = id; count = 0}
		eData.holder.index[id] = inst
		table.insert(conns, inst.Destroying:Once(function()
			ukit.connection.disconnectTable(conns)
		end))
		return true
	end;
	
	fire = function(name: string, parent: Instance, ...)
		local event = ekit._core.getEvent(name, parent, false)
		if not event then return false end
		event:Fire(...)
		return true
	end;
	
	connect = function(name: string, parent: Instance, func: (...any?) -> nil, once: boolean?, connectionInstance: ConnInst)
		local event = ekit._core.getEvent(name, parent, true)
		
		local instConn: RBXScriptConnection = nil
		local conn: RBXScriptConnection = nil
		local function performEvent(...: any?)
			if once then ukit.connection.disconnect(conn) end
			local result = func(...)
			if result == "DisconnectAll" then
				ekit._core.disconnectAll(name, parent)
				ukit.connection.disconnect(instConn)
			end
			return result
		end
		conn = event.Event:Connect(performEvent)
		-- TODO: (the connection-fire thing)
		--if eventData.data[event].connFire then
		--	performEvent(table.unpack(eventData.data[event].connFireData))
		--	if not re.conn.isConnected(conn) then return conn end
		--end
		if connectionInstance == nil then connectionInstance = ukit.instance.caller(1) end
		if connectionInstance then
			if not eData.instConnections[connectionInstance] then
				eData.instConnections[connectionInstance] = {}
				local function disconnectAll()
					ukit.connection.disconnectTable(eData.instConnections[connectionInstance])
					eData.instConnections[connectionInstance] = nil
					ekit._core.disconnectAll(name, parent)
				end
				table.insert(eData.instConnections[connectionInstance], connectionInstance.Destroying:Once(disconnectAll))
				table.insert(eData.instConnections[connectionInstance], ekit.connect(script, `Tick`, function(dt)
					local remaining = 0
					-- Going from end to 2nd (ignoring the first two connection)
					for i = #eData.instConnections[connectionInstance], 3, -1 do
						local testConn = eData.instConnections[connectionInstance][i]
						if not ukit.connection.active(testConn) then
							table.remove(eData.instConnections[connectionInstance], i)
							continue
						end
						remaining += 1
					end
					if remaining > 0 then return end
					disconnectAll()
				end, false, false))
			end
			table.insert(eData.instConnections[connectionInstance], conn)
		end
		return conn
	end;
	
	-- Disconnects every connection and attachment to an Event and Bind with a specified name
	disconnectAll = function(name: string, parent: Instance)
		return ukit.instance.destroy(ekit._core.getEvent(name, parent, false))
	end;
	
	invoke = function(name: string, parent: Instance, ...)
		local bind: BindableFunction = ekit._core.getBind(name, parent)
		if not bind or not eData.event.data[bind.Parent].isAttached then return end
		return bind:Invoke(table.unpack({...}))
	end;
	
	attach = function(name: string, parent: Instance, func: ((...any?) -> nil)|nil)
		if func == nil then return ekit._core.detach(name, parent) end
		local bind: BindableFunction = ekit._core.getBind(name, parent, true)
		bind.OnInvoke = func
		eData.event.data[bind.Parent].isAttached = true
		return true
	end;
	
	detach = function(name: string, parent: Instance)
		local bind = ekit._core.getBind(name, parent)
		if not bind or not eData.event.data[bind.Parent].isAttached then return false end
		bind.OnInvoke = nil
		eData.event.data[bind.Parent].isAttached = false
		return true
	end;
	
	isAttached = function(name: string, parent: Instance)
		local event = ekit._core.getEvent(name, parent)
		if not event then return false end
		return eData.event.data[event].isAttached
	end;
	
	wait = function(name: string, parent: Instance, waitAmount: number)
		waitAmount = waitAmount or 1
		if waitAmount <= 0 then return false end
		local event = ekit._core.getEvent(name, parent, true)
		local waitEvent = Instance.new("BindableEvent")
		local conn: RBXScriptConnection = nil
		local called = 0
		conn = event.Event:Connect(function()
			called += 1
			if called < waitAmount then return end
			waitEvent:Fire()
			ukit.connection.disconnect(conn)
		end)
		waitEvent.Event:Wait()
		return true
	end;
	
	getSignal = function(name: string, parent: Instance)
		return ekit._core.getEvent(name, parent, true).Event
	end;
	
	-- TODO: Make this actually do the thing
	-- The variadic parameters are the data to be passed for each new connection
	connectFire = function(name: string, parent: Instance, ...: any?)
		
	end;
	
	-- TODO: Make it do the thing. Probably also rename it
	-- EMERALD. I need naming help
	stopConnectFire = function(name: string, parent: Instance)
		
	end;
};

local globalEvents = ukit.instance.get(`Folder`, `Global`, storageRoot)
local categoryEvents = ukit.instance.get(`Folder`, `Category`, storageRoot)
local instEvents = ukit.instance.get(`Folder`, `Instance`, storageRoot)

local reliableEvent = script:WaitForChild(`ReliableEvent`)
local unreliableEvent = script:WaitForChild(`UnreliableEvent`)
local reliableFunc = script:WaitForChild("ReliableFunction")

local instHolders: {[Instance]: Folder} = {}
local function processCategory(category: Category)
	if not category then
		return globalEvents
	elseif type(category) == `string` then
		return ukit.instance.get(`Folder`, category, categoryEvents)
	elseif typeof(category) == `Instance` then
		local holder = instHolders[category]
		if not holder then
			holder = Instance.new(`Folder`, instEvents)
			holder.Name = category.Name:sub(1, 25)
			instHolders[category] = holder
			local conns: {RBXScriptConnection} = {}
			local function destroyed()
				ukit.connection.disconnectTable(conns)
				ukit.instance.destroy(holder)
				instHolders[category] = nil
			end
			table.insert(conns, category.Destroying:Once(destroyed))
			table.insert(conns, category:GetPropertyChangedSignal(`Parent`):Connect(function()
				if category.Parent ~= nil then return end
				destroyed()
			end))
		end
		return holder
	end
	error(`Incorrect Category type provided. Must be: nil|string|Instance`)
end

ekit.fire = function(category, name, ...) return ekit._core.fire(name, processCategory(category), ...) end;
ekit.connect = function(category, name, func, once, connectionInstance) return ekit._core.connect(name, processCategory(category), func, once, connectionInstance) end;
ekit.invoke = function(category, name, ...) return ekit._core.invoke(name, processCategory(category), ...) end;
ekit.attach = function(category, name, func) return ekit._core.attach(name, processCategory(category), func) end;
ekit.detach = function(category, name) return ekit._core.detach(name, processCategory(category)) end;
ekit.isAttached = function(category, name) return ekit._core.isAttached(name, processCategory(category)) end;
ekit.wait = function(category, name, waitAmount) return ekit._core.wait(name, processCategory(category), waitAmount) end;
ekit.getSignal = function(category, name) return ekit._core.getSignal(name, processCategory(category)) end;

local sharePrefix = `SDShared_`  -- The prefix that must be included in an event for it to be ran by the other sender type (client/server)
ekit.server = {
	unreliable = {
		fire = function(category, name, ...)
			return unreliableEvent:FireServer(category, name, ...)
		end;
	};
	fire = function(category, name, ...)
		return reliableEvent:FireServer(category, name, ...)
	end;
	connect = function(category, name, func, once, connectionInstance)
		assert(rs:IsClient(), `This function must be called by a client`)
		return ekit.connect(category, `{sharePrefix}{name}`, func, once, connectionInstance)
	end;
	invoke = function(category, name, ...)
		return reliableFunc:InvokeServer(category, name, ...)
	end;
	attach = function(category, name, func)
		assert(rs:IsClient(), `This function must be called by a client`)
		return ekit.attach(category, `{sharePrefix}{name}`, func)
	end;
};

ekit.client = {
	unreliable = {
		fire = function(plr: Player, category, name, ...)
			return unreliableEvent:FireClient(plr, category, name, ...)
		end;
		fireAll = function(category, name, ...)
			for _, plr in pairs(players:GetPlayers()) do
				ekit.client.unreliable.fire(plr, category, name, ...)
			end
		end;
	};
	fire = function(plr: Player, category, name, ...)
		return reliableEvent:FireClient(plr, category, name, ...)
	end;
	fireAll = function(category, name, ...)
		for _, plr in pairs(players:GetPlayers()) do
			ekit.client.fire(plr, category, name, ...)
		end
	end;
	connect = function(category, name, func: (Player, ...any?) -> nil, once, connectionInstance)
		assert(rs:IsServer(), `This function must be called by the server`)
		return ekit.connect(category, `{sharePrefix}{name}`, func, once, connectionInstance)
	end;
	
	invoke = function(plr: Player, category, name, ...)
		return reliableFunc:InvokeClient(plr, category, name, ...)
	end;
	-- Returns the result from each Client wrapped in a table (to support variadic variables)
	-- Note: this function is untested, but should work. It waits for every client's return
	invokeAll = function(category, name, ...)
		local variadics = {...}
		local result = {}
		local waitEv = Instance.new("BindableEvent")
		local sentToPlayers = players:GetPlayers()
		local receivedCnt = 0
		local function checkFunc()
			if #sentToPlayers ~= receivedCnt then return end
			waitEv:Fire()
		end
		
		for _, plr in pairs(players:GetPlayers()) do
			coroutine.wrap(function()
				result[plr] = {ekit.client.invoke(plr, category, name, table.unpack(variadics))}
				receivedCnt += 1
				checkFunc()
			end)()
		end
		waitEv.Event:Wait()
		waitEv:Destroy()
		return result
	end;
	attach = function(category, name, func: (Player, ...any?) -> nil)
		assert(rs:IsServer(), `This function must be called by the server`)
		return ekit.attach(category, `{sharePrefix}{name}`, func)
	end;
};

-- Global Tick
do
	local t = 0
	rs.PreSimulation:Connect(function(dt)
		t += dt
		if t < 6 then return end
		t = 0
		ekit.fire(script, `Tick`)
	end)
end

if game:GetService("RunService"):IsServer() then
	local function fireFunc(plr, typeInfo, name, ...)
		return ekit.fire(typeInfo, `{sharePrefix}{name}`, plr, ...)
	end
	reliableEvent.OnServerEvent:Connect(fireFunc)
	unreliableEvent.OnServerEvent:Connect(fireFunc)
	reliableFunc.OnServerInvoke = function(plr, typeInfo, name, ...)
		return ekit.invoke(typeInfo, `{sharePrefix}{name}`, plr, ...)
	end
else
	local function fireFunc(typeInfo, name, ...)
		return ekit.fire(typeInfo, `{sharePrefix}{name}`, ...)
	end
	reliableEvent.OnClientEvent:Connect(fireFunc)
	unreliableEvent.OnClientEvent:Connect(fireFunc)
	reliableFunc.OnClientInvoke = function(typeInfo, name, ...)
		return ekit.invoke(typeInfo, `{sharePrefix}{name}`, ...)
	end
end

return ekit
