# Dependency Linking
This is a common enough issue in this project that it got its own file.

The Modules need to communicate between each other. For that to happen, they need to know where each other Module is. For Utility Modules (such as [UtilKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/UtilKit) or [EventKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/EventKit)) - they're utility modules, they will be together with each other.

But for Wrapper/Handler Modules, those don't necessarily need to be in the same folder as the Utility Modules for better organization, so that brings a way bigger issue. At the moment, I (the person making and using them) put all of these into a Utility Folder, so they were also made with the intent to be in the same place. Unfortunately at the moment they don't work otherwise, unless manually modified.

At the moment, Server Modules (such as [PingKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/PingKit)) can find their dependencies either in a known directory (as a Child in game>ReplicatedStorage>Scripts) or each dependency has the tag of "SimplifyDev_{moduleName}".
I would still need to further look into solutions for it, but for now this is what we get.