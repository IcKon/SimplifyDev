# RateTracker
## Info
A Utility [Module](https://github.com/IcKon/SimplifyDev/tree/main/Modules/RateTracker/RateTracker.lua) categorized, optimized frequency counter for custom actions within a specified time period.

## [Dependencies](https://github.com/IcKon/SimplifyDev/blob/main/GlobalNotes/DependencyLinking.md)
None

## Examples
```lua
local rateTracker = require(<Path>)  -- replace <Path> with the actual path of the Instance

-- 12 - time window size; 35 - the threshold.
rateTracker.setup("API", "Usage", 12, 35)

certainEventThatGetsCalledOnEachUsageOfThatAPI.Event:Connect(function(usages: number?)
	rateTracker.add("API", "Usage", usages)
end)

while task.wait(3) do
	print("Rate in the time period + has threshold reached")
	print(rateTracker.get("API", "Usage")) -- rate in the past 12 seconds
	print(rateTracker.isTreshold("API", "Usage")) -- have I reached 35
end
```