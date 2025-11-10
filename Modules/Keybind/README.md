# Keybind
## Info
A simple Key to Bind Handler [Module](https://github.com/IcKon/SimplifyDev/tree/main/Modules/Keybind/Keybind.lua), letting you easily setup input management in your projects.

## [Dependencies](https://github.com/IcKon/SimplifyDev/tree/main/GlobalNotes/DependencyLinking)
[UtilKit](Downloads: https://github.com/IcKon/SimplifyDev/tree/main/Modules/UtilKit), [EventKit](Downloads: https://github.com/IcKon/SimplifyDev/tree/main/Modules/EventKit)

## Examples
```lua
local keybind = require(<Path>)  -- replace <Path> with the actual path of the Instance

keybind.bind.add("Jump", Enum.KeyCode.Space, Enum.KeyCode.ButtonA)

keybind.connect.press.bind("Jump", function(keyUsed: EnumItem)
	print("Jumped using the " .. keyUsed.Name .. " key.")
end)
```

You can also manually invoke a Bind press using the following functions. This can be used for, for example, mobile buttons.
```lua
-- When mobile button is pressed:
keybind.press.bind("Jump", Enum.UserInputType.Touch)

-- When mobile button released:
keybind.release.bind("Jump", Enum.UserInputType.Touch)
```