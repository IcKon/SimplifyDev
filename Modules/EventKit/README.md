# EventKit
## Info
A Utility [Module](https://github.com/IcKon/SimplifyDev/tree/main/Modules/EventKit/EventKit.rbxm), allowing you to connect/attach functions globally, to a string category or an Instance without having to worry about creating those Instances. It also optionally allows for Client-Server communication.
You will need this for using almost any other Module by SimplifyDev.

## [Dependencies](https://github.com/IcKon/SimplifyDev/blob/main/GlobalNotes/DependencyLinking.md)
[UtilKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/UtilKit)

## Examples
```lua
local ekit = require(<Path>)  -- replace <Path> with the actual path of the Instance

-- FIRE/CONNECT
ekit.connect("TestCategory", "Event1", function(param1, param2)
	print(param1, param2)
end)

-- Uses a BindableEvent under the hood
ekit.fire("TestCategory", "Event1", 123, 456)


-- INVOKE/ATTACH
-- Uses a BindableFunction under the hood
ekit.attach(nil, "DoRandomWait", function()
	print("Started Waiting")
	task.wait((math.random() * 2) + 1)
	print("Wait ended")
end)

-- Uses a BindableFunction under the hood
ekit.invoke(nil, "DoRandomWait")
print("Passed Function")
```


The Module also supports Server-Client communication
#### Server Script:
```lua
ekit.client.attach("Stats", "Request", function(plr: Player)
	return {
		killCount = plr:GetAttribute("")
	}
end)
```

#### Client Script:
```lua
-- Uses RemoteFunctions under the hood
local myStats = ekit.server.invoke("Stats", "Request")
print("Hey, mom, I have " .. myStats.killCount .. " in this game!")
```