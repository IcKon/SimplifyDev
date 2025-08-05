# SimplifyDev
A Github Repository made for our SimplifyDev Roblox Group.

Our main goal is to provide mainly free tools for development on Roblox.
Our Modules are targeted towards people trying to make simple projects or if they are fresh new beginners. Our plugins, kits and tools are targeted towards anyone, with its goal to offer simple features that can be annoying to set up yourself (hence the name).

For news about the development and new publishes, be sure to join our [Discord Server](https://discord.gg/EChnxk8kWf)!
We also try to post fun facts and quizzes about coding.

To show support it some other way, though joining the server is enough, a star for this repository would highly appreciate, giving us more motivation to work further on things for you guys.

# Documentation
Comprehensive documentation for each module.

## UtilKit
### Documentation
This is the main kit and is a common dependency among other kits later in the documentation.
Provides abundant amounts of functional and helpful utility tools, spanning across different object types such as:
- Tables - Dictionaries: moving; combining; clearing nil, duplicate or identical values; randomization; shuffling; freeze and deepfreeze; etc.
- String and Numbers: function mapping to strings; splitting strings; JSON encoding; is Nan (not a number); randomization; tweening; grid snapping; easign functions (sine, quad, quint, cubic,...); etc.
- Vector3 - Vector2 - CFrame: min - max of multiple vectors; clamp; rounding; safe unit conversion with fallball value; average, sum, rotations of CFrames; etc.
- Instances: dynamic instance manipulation.
Along with that, UtilKit also includes: UDim - UDim2 manipulation, color conversion, elapsed time data and date time formatting.

*Important Note: The features listed above do not cover the full UtilKit functionality, and therefore should be taken as a general guide to using UtilKit. A larger, more defined list of every function and method will be created at a later time.*

### Examples
*Note: this is only a simple example to showcase one of UtilKit's functionalities.*

```lua
local ukit = require(<Path>)

-- Rounds a number to a certain amount of decimals.
print(ukit.number.round(1.116), 2) -- Output: 1.12

-- Creates a new Vector3 with the X value set.
print(ukit.vector3.newX(5)) -- Output: 5, 0, 0
```

## EventKit
### Dependencies: UtilKit
### Documentation
A utility module for managing events, like RemoteEvents, UnreliableEvent, BindableFunctions. Supports at-runtime event creation, therefore you do not need to specify an event instance beforehand, instead a category and name. Categories and their respective enviroments include: nil - global event; string - categorized event; Instance - an event attached to an Instance (BasePart, ReplicatedStorage, etc).
Offers all the features RemoteEvents and BindableFunctions have, without the overhead of creating and managing multiple event instances, including but not limited to:
- Firing and Invoking events.
- Connecting, attaching and vice verse to an Instance.
- Getting RemoteEvent or BindableFunction metadata.
- Client side support.

*Important Note: features listed above only covers the surface level of EventKit's usability, similar to UtilKit.*

### Examples
#### Requiring the Module
*Note: The code shown in here are simplistic examples showcasing how you can use the module. More sophisticated implementation is recommended.*

```lua
local ekit = require(<Path>)
```

#### Connecting and Firing Test Events 
```lua
-- Uses a BindableEvent under the hood
ekit.connect("TestCategory", "Event1", function(param1, param2)
	print(param1, param2)
end)

ekit.fire("TestCategory", "Event1", 123, 456)
```

#### Attaching and Invoking Test Functions
```lua
-- Uses a BindableFunction under the hood
ekit.attach(nil, "DoRandomWait", function()
	print("Started Waiting")
	task.wait((math.random() * 2) + 1)
	print("Wait ended")
end)

ekit.invoke(nil, "DoRandomWait")
print("Passed Function")
```

#### Client-Server Communication
##### Server Script:
```lua
ekit.client.attach("Stats", "Request", function(plr: Player)
	return {
		killCount = plr:GetAttribute("")
	}
end)
```
##### Client Script:
```lua
local myStats = ekit.server.invoke("Stats", "Request")
print("Hey, mom, I have " .. myStats.killCount .. " in this game!")
```

## Keybind
### Dependencies: UtilKit, EventKit
### Documentation
Provides many functions and methods to quickly set up keybindings and input management, without the general overhead of UserInputService.
General features include: binding keys, multiple keys to one binding is supported; get metadata; etc.

### Examples
*Note: as stated before, these aren't the only functions in the Keybind module.*

#### Requiring the Module
```lua
local keybind = require(<Path>)
```

#### Adding Binds
```lua
keybind.bind.add("Jump", Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
```

#### Connecting Bind Press
```lua
keybind.connect.press.bind("Jump", function(keyUsed: EnumItem)
	print("Jumped using the " .. keyUsed.Name .. " key.")
end)
```

#### Force Press
*A hacky solution, but it is what is used for my project called Untitled Parkour Game for mobile players.*
```lua
-- When mobile button is pressed:
keybind.press.bind("Jump", Enum.UserInputType.Touch)

-- When mobile button released:
keybind.release.bind("Jump", Enum.UserInputType.Touch)
```

# Downloading Modules and Kits
Downloading these modules is fairly tedious, along with frequent updates and module publication, but still bearable. There are two methods currently.

## Method 1: Copy Paste
Navigate to the module file you want to use, copy and paste it into a ModuleScript in Roblox Studio, simple isn't it?
## Method 2: Downloading
Navigate to the module file you want to download, and press the button that says "Download raw file" and insert it as a script inside Roblox Studio.

This allows you to keep a consistent copy of the module.

# Additional Resources
These are other resources that new, or old, developers might need, including animation resources, plugins, etc.
## Animation
*You can find the resources for this in this [directory](Resources/Animating/)*
### Info
Have you ever tried making a game as a scripter and REALLY lacked the animations needed?
And does the normal Roblox animator feel too difficult to learn, that nothing turns out good? Not even template animations?
**(Of course, getting animators for a game is still useful, but)**

Here are some resources for animating in Blender!
(Now, don't worry. Blender is not as scary as it may seem. Some tutorials will get you on your feet)


### The Tools You Will Need:
#### A Roblox Plugin for Importing Blender Animations:
https://create.roblox.com/store/asset/16708835782/Blender-Animations-ultimate-edition


#### A Blender Addon for Exporting Blender Animations into Roblox:
You can either download the file attached to the Github [here](https://github.com/IcKon/SimplifyDev/tree/main/Resources/Animating/BlenderRobloxExporter.py), or get it from the [pastebin](https://pastebin.com/raw/V5aBemWL). It's all taken from [this post](https://devforum.roblox.com/t/blender-rig-exporteranimation-importer/34729), if you want to verify that (All the credit goes to the masterminds behind it). Make sure to rename it to something intuitive and change its file type to ".py".

Installation Process:
1. Get the file from the resources above. I suggest keeping it in a safe place, such as ".../Documents/Blender/Addons"
2. In blender, go to Edit > Preferences. In there open "Add-ons"
3. Click on that arrow down icon, and press "Install from Disk" and select that .py file.


#### A Rig for Blender Animation:
You don't have to worry about setting anything up, rather just start animating!
You can get the template R6 Rig [here](https://github.com/IcKon/SimplifyDev/blob/main/Resources/Animating/RobloxRigTemplate.zip) (the zip provided next to the README file), containing the Rig and a Texture for a clearer animating process (or follow what's written in [the same post](https://devforum.roblox.com/t/blender-rig-exporteranimation-importer/34729) for an R15/custom rig. If you need an IK/FK rig, you can take a combo from [this post](https://devforum.roblox.com/t/r6-ik-fk-blender-rig/3586405))


### The Animating Process
#### Start Animating
_Note: You shouldn't worry about it if you opened the provided .blend file from a new. You should be all ready to animate_
Ensure before you start animating (have the "Animation" tab selected), you have the rig's Armature selected. That is (from my understanding) the Animator Object.


#### Uhhh erm uhhh
Yeah, that's all you get for now. I will try adding more tips here some time in the future. From now on, learn Blender.

## Plugins
### StudBumpGenerator
A simplistic retro bump creator, looking like grass. Created for brick builders.

Download the plugin [here](https://create.roblox.com/store/asset/77542167686541).

Note: do not use it on parts with BIG areas. Running it on a 2048x2048 will effectively fully freeze your game.