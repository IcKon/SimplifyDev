# SequenceKit
## Info
A Utility [Module](https://github.com/IcKon/SimplifyDev/tree/main/Modules/SequenceKit/SequenceKit.rbxm) for managing sequences (Number/Color Sequences).

## [Dependencies](https://github.com/IcKon/SimplifyDev/blob/main/GlobalNotes/DependencyLinking.md)
[UtilKit](https://github.com/IcKon/SimplifyDev/tree/main/Modules/UtilKit)

## Examples
```lua
local sequenceKit = require(<Path>)  -- replace <Path> with the actual path of the Instance

-- Getting the sequence that is "in between" the two given sequences
local resultSequence = sequenceKit.lerp(seq1, seq2, 0.5)

local tween = sequenceKit.tween(seq1, tInfo, seq2, function(newSeq)
	-- onChange
	print(newSeq)  -- you could update the gradient here or do anything with the newSeq result
end, function(finalSeq)
	-- onEnd
	-- Unnecessary function, as onChange gets fired with the finalSeq too. Perform clean-up here if necessary
end)

-- Clean up unnecessary keypoints inside a sequence, which change is inside a specified epsilon (or default: 0.01) error term.
local optimizedSeq = sequenceKit.optimize(bloatedSeq)

-- Performing tween internally always calls lerp, and lerp needs to have the two sequences match keypoints. Optimizing your sequences is generally a good thing to do, but may be omitted.
```