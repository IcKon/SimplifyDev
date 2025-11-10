# PingKit

## Info
A wrapper [Module](https://github.com/IcKon/SimplifyDev/tree/main/Modules/PingKit/PingKit.lua) for MessagingService, communication between servers of the game.
A speciality is the .get function, receiving the responses from all the servers connected to that topic.
**Note: This Module will be reworked. There will be some different behavior in regards to sending a GET request to other servers**

## [Dependencies](https://github.com/IcKon/SimplifyDev/tree/main/GlobalNotes/DependencyLinking)
[UtilKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/UtilKit), [EventKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/EventKit)

## Examples
```lua
local pingKit = require(<Path>)  -- replace <Path> with the actual path of the Instance

-- A simple example of just sending a message
pingKit.subscribe("Topic1")

pingKit.connect.topic("Topic1", function(msgData)
	
end)

pingKit.post("Topic1", "RandomInfoThatWillBeRanThroughJSONEncode")

-- The example below showcases an example 
pingKit.subscribe("WelcomeServer")

pingKit.attach.type("WelcomeServer", "Get", function(msgData)
	print("Got a message from the server:", msgData.recipient)
	return {msg = "Hallo!"; valuableInformation = math.random(1, 10)}
end)

local results = pingKit.get("WelcomeServer", 123)
for serverId, msgData in pairs(results) do
	local data = msgData.message
	print("I got a message from:", serverId, "| Data:", data)
end
```