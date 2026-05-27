# InstRepo
## Info
A Manager [Module](https://github.com/IcKon/SimplifyDev/tree/main/Modules/InstRepo/InstRepo.rbxm) for storing Instances, passing to specific clients and requesting from the server.

## [Dependencies](https://github.com/IcKon/SimplifyDev/blob/main/GlobalNotes/DependencyLinking.md)
[UtilKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/UtilKit), [EventKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/EventKit)

## Examples
```lua
local instRepo = require(<Path>)  -- replace <Path> with the actual path of the Instance

-- Let's say we want to save an Instance in the Repository we want to use later. In addition to that, let's say that it's quite literally the gear model to some item
local randomInst: Instance = workspace.Part1  -- a random Instance
instRepo.set("GearRandomModel", randomInst)

-- Later in the code or another script:
local theRandomInstThing = instRepo.getClone("GearRandomModel")

-- Another time, we want to change the base model:
instRepo.getBase("GearRandomModel").Transparency = .5
```


Requestion Instances as the client from the Server
### Server Side
```lua
local instRepo = require(<Path>)

instRepo.set("CertainModel", certainInstance)
instRepo.setShared("CertainModel", true)

-- The lines above can be simplified with:
instRepo.set("CertainModel", certainInstance, true)
```
### Client Side
```lua
local instRepo = require(<Path>)

local exists = instRepo.request("CertainModel")  -- The function waits until completion
if exists then
	local certainInstance = instRepo.getClone("CertainModel")
	certainInstance.Parent = workspace
	print("Wowie! I got an Instance:", certainInstance)
end
```


Passing Instances as the Server to the Client
### Client Side
```lua
local instRepo = require(<Path>)
instRepo.setupClient()
```
### Server Side
```lua
local instRepo = require(<Path>)
for _, plr in pairs(game.Players:GetPlayers()) do
	instRepo.passToClient(plr, game.ServerStorage.CertainAsset, "Id123")
	-- There are extra parameters you can play around with
end
```