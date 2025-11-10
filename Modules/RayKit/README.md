# RayKit

## Info
A simple wrapper [Module](https://github.com/IcKon/SimplifyDev/tree/main/Modules/RayKit/RayKit.lua) containing all Raycasting methods under Workspace. All in one simple place.

## [Dependencies](https://github.com/IcKon/SimplifyDev/blob/main/GlobalNotes/DependencyLinking.md)
Optional: [EventKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/EventKit)

## Notes
The EventKit Module in this case is not necessary for this module to function. It is used only for letting the user have a custom function run after a ray is shot. (easier way to use that will be added later)

## Examples
```lua
local rkit = require(<Path>)  -- replace <Path> with the actual path of the Instance

-- Every next raycast shot will use this as its default parameter
-- Note: the rkit.getParams returns a custom table-like parameters data which, by default, ignores non-collidable objects. Generally it is more useful
local params = rkit.getParams(false, nil, "Player")
rkit.setDefaultParams(params)

-- Equivalent to using 
local result = rkit.ray(playerPos, rayDirection)
local didHit = result ~= nil
if didHit then
	print("I hit the funny part:", result.Instance)
	print("Also the normal vector is:", result.Normal)
end

local result = rkit.sphere(playerPos, .5, rayDirection)
-- TODO: Add funny prints here or whatever

local result = rkit.block(playerCFrame, rootSize, rayDirection)
-- TODO: Overexplain everything for the 3rd time

local randomCustomParams = rkit.getParams(false, nil, "Bullet")
local result = rkit.shape(partInst, rayDirection, randomCustomParams)
-- TODO: Bake a cake
```