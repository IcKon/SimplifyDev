# UtilKit
## Info
A Utility [Module](https://github.com/IcKon/SimplifyDev/tree/main/Modules/UtilKit/UtilKit.lua) full of functions that tend to get repeated a lot in code.
This Module is also the most used Dependency Module across the SimplifyDev projects.

## [Dependencies](https://github.com/IcKon/SimplifyDev/blob/main/GlobalNotes/DependencyLinking.md)
None

## Examples
```lua
local ukit = require(<Path>)  -- replace <Path> with the actual path of the Instance

-- The examples showcase one function from each category. There are a lot more, these are just random ones chosen for demonstrational purposes.

-- Randomizes the contents of the table.
print(ukit.table.randomize({1; 2; 3; 4; 5}))

-- Returns a text with the first letter of each word capitalized
print(ukit.string.capitalize("the text will be capitalized")) --> "The Text Will Be Capitalized"

-- Rounds a number to a certain amount of decimals.
print(ukit.number.round(1.116, 2)) --> 1.12

-- Creates a new Vector3 with the X value set.
print(ukit.vector3.newX(5)) --> Vector3(5, 0, 0)

-- Changes the Magnitude of a Vector2 to a set value.
print(ukit.vector2.scale(Vector2.new(5, 4), 2)) --> Vector2(~1.86, ~0.74)

-- Returns an average CFrame value
print(ukit.cframe.average(cf1, cf2, cf3, ..., cf4))

-- Returns the Instance of the caller source of this function
print(ukit.instance.caller())

-- Returns the sum of 2 UDim data objects
print(ukit.udim.add(UDim.new(1, 0), UDim.new(0, 5))) --> UDim(1, 5)

-- Returns a UDim2 data object with X scale and X offset (both optional) to another value
print(ukit.udim2.setX(UDim2.fromScale(1, 1), 0, 25)) --> UDim2(UDim(0, 25), UDim(1, 0))

-- Returns a number value uniquely identifies the specified Color3 data object. The number can be used to get the Color3 object again using .number.from(result)
print(ukit.color3.number.to(Color3.fromRGB(125, 92, 66))) --> 1236542

-- Disconnects all connections specified in a table
print(ukit.connection.disconnectTable({conn1; conn2; conn3})) --> true

-- Returns the time passed in seconds since the last ukit.elapsed.reset("Category1", "Jumped") call
print(ukit.elapsed.get("Category1", "Jumped"))

-- Formats the time passed in seconds into a nice string (supporting negatives)
print(ukit.date.formatTimePassed(120)) --> "in 2 minutes"
```