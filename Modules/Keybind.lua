local Keybind = {}

local ukit = require(script.Parent:WaitForChild("UtilKit"))
local ekit = require(script.Parent:WaitForChild("EventKit"))
local globalConns: {RBXScriptConnection} = {}

export type Key = Enum.KeyCode|Enum.UserInputType

local bindData = {
	list = {} :: {[string]: {Key}};
	pressed = {} :: {string};
	funcs = {} :: {(() -> nil)|BindableFunction};
}
local keyData = {
	list = {} :: {[Key]: {string}};
	pressed = {} :: {Key};
	funcs = {} :: {(() -> nil)|BindableFunction};
}

-- Creates a new keybind and sets it up properly
-- It's unnecessary to call this function. It gets done automatically upon adding a key to a bind
Keybind.register = function(bind: string)
	bindData.list[bind] = {}
end

Keybind._core = {
	event = {
		key = function(key: Key, suffix: string)
			return ekit.fire(script, `Key_{Keybind.get.key._prefix(key)}{key.Value}_{suffix}`)
		end;
		
		bind = function(bind: string, suffix: string, ...: any?)
			return ekit.fire(script, `Bind_{bind}_{suffix}`, ...)
		end;
	};
};

Keybind.press = {
	key = function(key: Key)
		if Keybind.is.pressed.key(key) then return false end
		table.insert(keyData.pressed, key)
		Keybind._core.event.key(key, "Press")
		local binds = Keybind.get.bind.fromKey(key)
		for _, bind in pairs(binds) do
			Keybind.press.bind(bind, key)
		end
		local conns: {RBXScriptConnection} = {}
		local name = `Key_{Keybind.get.key._prefix(key)}{key.Value}_Hold_`
		table.insert(conns, game:GetService("RunService").Stepped:Connect(function(_, dt)
			ekit.fire(script, `{name}Stepped`, dt)
		end))
		table.insert(conns, game:GetService("RunService").Heartbeat:Connect(function(dt)
			ekit.fire(script, `{name}Heartbeat`, dt)
		end))
		table.insert(conns, game:GetService("RunService").RenderStepped:Connect(function(dt)
			ekit.fire(script, `{name}RenderStepped`, dt)
		end))
		keyData.funcs[key] = function()
			keyData.funcs[key] = nil
			ukit.connection.disconnectTable(conns)
			conns = nil
		end
		-- Just do .Name for this one
		ukit.elapsed.reset(script, `Click_Key_{Keybind.get.key._prefix(key)}{key.Value}`)
		return true
	end;
	
	-- Please do not use this function
	bind = function(bind: string, keyUsed: Key)
		if Keybind.is.pressed.bind(bind) then return false end
		table.insert(bindData.pressed, bind)
		Keybind._core.event.bind(bind, "Press", keyUsed)
		local conns: {RBXScriptConnection} = {}
		local name = `Bind_{bind}_Hold_`
		table.insert(conns, game:GetService("RunService").Stepped:Connect(function(_, dt)
			ekit.fire(script, `{name}Stepped`, dt, keyUsed)
		end))
		table.insert(conns, game:GetService("RunService").Heartbeat:Connect(function(dt)
			ekit.fire(script, `{name}Heartbeat`, dt, keyUsed)
		end))
		table.insert(conns, game:GetService("RunService").RenderStepped:Connect(function(dt)
			ekit.fire(script, `{name}RenderStepped`, dt, keyUsed)
		end))
		bindData.funcs[bind] = function()
			bindData.funcs[bind] = nil
			ukit.connection.disconnectTable(conns)
			conns = nil
		end
		ukit.elapsed.reset(script, `Click_Bind_{bind}`)
		return true
	end;
}

Keybind.release = {
	key = function(key: Key)
		if not Keybind.is.pressed.key(key) then return false end
		table.remove(keyData.pressed, table.find(keyData.pressed, key))
		Keybind._core.event.key(key, "Release")
		local binds = Keybind.get.bind.fromKey(key)
		for _, bind in pairs(binds) do
			Keybind.release.bind(bind, key)
		end
		if keyData.funcs[key] then keyData.funcs[key]() end
		return true
	end;
	
	bind = function(bind: string, keyUsed: Key)
		if not Keybind.is.pressed.bind(bind) then return false end
		table.remove(bindData.pressed, table.find(bindData.pressed, bind))
		Keybind._core.event.bind(bind, "Release", keyUsed)
		if bindData.funcs[bind] then bindData.funcs[bind]() end
		return true
	end;
}

Keybind.is = {
	pressed = {
		bind = function(bind: string)
			return ukit.table.has(bindData.pressed, bind)
		end;
		
		key = function(key: Key)
			return ukit.table.has(keyData.pressed, key)
		end;
	};
}

Keybind.bind = {
	add = function(bind: string, ...: Key)
		if not bindData.list[bind] then Keybind.register(bind) end
		local added = 0
		for _, input in pairs({...}) do
			if not keyData.list[input] then keyData.list[input] = {} end
			ukit.table.setAdd(keyData.list[input], bind)
			added += ukit.table.setAdd(bindData.list[bind], input) and 1 or 0
		end
		return added
	end;
	
	remove = function(bind: string, ...: Key)
		if not bindData.list[bind] then return false end
		local removed = 0
		for _, input in pairs({...}) do
			ukit.table.remove(keyData.list[input], bind)
			if #keyData.list[input] == 0 then keyData.list[input] = nil end
			removed += ukit.table.remove(bindData.list[bind], input) and 1 or 0
		end
		return removed
	end;
	
	replace = function(bind: string, fromInput: Key, toInput: Key)
		Keybind.bind.remove(bind, fromInput)
		return Keybind.bind.add(bind, toInput)
	end;
	
	clear = function(bind: string)
		if not bindData.list[bind] then return false end
		-- reversing it to remove it from the end each time (faster) instead of the start (laggier)
		for _, input in pairs(ukit.table.reverse(bindData.list[bind])) do
			Keybind.bind.remove(bind, input)
		end
		return true
	end;
	
	has = function(bind: string, ...: Key)
		local keys = {...}
		local hasAmnt = 0
		for _, input in pairs(keys) do
			hasAmnt += ukit.table.has(bindData.list[bind], input) and 1 or 0
		end
		return hasAmnt == #keys
	end;
}

Keybind.key = {
	has = function(key: Key, ...: string)
		local binds = {...}
		local hasAmnt = 0
		for _, bind in pairs(binds) do
			if not keyData.list[bind] then break end
			hasAmnt += ukit.table.has(keyData.list[key], bind) and 1 or 0
		end
		return hasAmnt == #binds
	end;
}

Keybind.get = {
	bind = {
		elapsed = {
			down = function(bind: string)
				return ukit.elapsed.get(script, `Click_Bind_{bind}`)
			end;
		};
		
		fromKey = function(key: Key): {string}
			return keyData.list[key] or {}
		end;
		
		-- Returns a list of pressed binds
		pressed = function()
			return table.clone(bindData.pressed)
		end;
	};
	
	key = {
		elapsed = {
			down = function(key: Key)
				return ukit.elapsed.get(script, `Click_Key_{Keybind.get.key._prefix(key)}{key.Value}`)
			end;
		};
		
		-- Returns a list of pressed binds
		pressed = function()
			return table.clone(keyData.pressed)
		end;
		
		fromBind = function(bind: string): {Key}
			return bindData.list[bind]
		end;
		
		fromInputObject = function(input: InputObject): Key
			return input.KeyCode == Enum.KeyCode.Unknown and input.UserInputType or input.KeyCode
		end;
		
		_prefix = function(key: Key)
			return key.EnumType == Enum.KeyCode and "1" or "2"
		end;
	}
}

Keybind.connect = {
	_core = {
		bind = function(bind: string, suffix: string, func: () -> nil, once, stopOnInstDel: Instance?)
			return ekit.connect(script, `Bind_{bind}_{suffix}`, func, once, ukit.defaultTo(stopOnInstDel, ukit.instance.caller(1)))
		end;
		
		key = function(key: Key, suffix: string, func: () -> nil, once, stopOnInstDel)
			return ekit.connect(script, `Key_{Keybind.get.key._prefix(key)}{key.Value}_{suffix}`, func, once, ukit.defaultTo(stopOnInstDel, ukit.instance.caller(1)))
		end;
	};
	
	press = {
		bind = function(bind: string, func: (keyUsed: Key) -> nil, once, stopOnInstDel)
			return Keybind.connect._core.bind(bind, "Press", func, once, stopOnInstDel)
		end;
		
		key = function(key, func, once, stopOnInstDel)
			return Keybind.connect._core.key(key, "Press", func, once, stopOnInstDel)
		end;
	};
	
	hold = {
		_core = {
			bind = function(bind: string, signal: string, func: (dt: number) -> nil, once, stopOnInstDel)
				return Keybind.connect._core.bind(bind, `Hold_{signal}`, func, once, ukit.defaultTo(stopOnInstDel, ukit.instance.caller(1)))
			end;

			key = function(key, signal: string, func: (dt: number) -> nil, once, stopOnInstDel)
				return Keybind.connect._core.key(key, `Hold_{signal}`, func, once, ukit.defaultTo(stopOnInstDel, ukit.instance.caller(1)))
			end;
		};
		
		renderStepped = {
			bind = function(bind, func: (dt: number, keyUsed: Key) -> nil, once, stopOnInstDel)
				return Keybind.connect.hold._core.bind(bind, `RenderStepped`, func, once, stopOnInstDel)
			end;

			key = function(key, func: (dt: number) -> nil, once, stopOnInstDel)
				return Keybind.connect.hold._core.key(key, `RenderStepped`, func, once, stopOnInstDel)
			end;
		};
		
		heartbeat = {
			bind = function(bind, func: (dt: number, keyUsed: Key) -> nil, once, stopOnInstDel)
				return Keybind.connect.hold._core.bind(bind, `Heartbeat`, func, once, stopOnInstDel)
			end;

			key = function(key, func: (dt: number) -> nil, once, stopOnInstDel)
				return Keybind.connect.hold._core.key(key, `Heartbeat`, func, once, stopOnInstDel)
			end;
		};
		
		-- Fires every frame on "Stepped" event
		bind = function(bind, func: (dt: number, keyUsed: Key) -> nil, once, stopOnInstDel)
			return Keybind.connect.hold._core.bind(bind, `Stepped`, func, once, stopOnInstDel)
		end;

		key = function(key, func: (dt: number) -> nil, once, stopOnInstDel)
			return Keybind.connect.hold._core.key(key, `Stepped`, func, once, stopOnInstDel)
		end;
	};
	
	release = {
		bind = function(bind: string, func: (keyUsed: Key) -> nil, once, stopOnInstDel)
			return Keybind.connect._core.bind(bind, "Release", func, once, stopOnInstDel)
		end;

		key = function(key, func, once, stopOnInstDel)
			return Keybind.connect._core.key(key, "Release", func, once, stopOnInstDel)
		end;
	};
}

if game:GetService("RunService"):IsClient() then
	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed and input.KeyCode ~= Enum.KeyCode.ButtonA then return end
		Keybind.press.key(Keybind.get.key.fromInputObject(input))
	end)
	
	game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
		Keybind.release.key(Keybind.get.key.fromInputObject(input))
	end)
end

return Keybind
