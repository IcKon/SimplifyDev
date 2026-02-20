local rateTracker = {}

export type CategoryType = string|Instance|nil
export type Category = {list: {[ObjType]: Obj}}
export type ObjType = string
export type Obj = {maxTime: number; timestamps: {}; cache: number; threshold: number?}

local prefix = `RateTracker`

local categoriesList = {}

local instanceId = 0
local function getCategoryIndex(category: CategoryType)
	local t = typeof(category)
	if t == `string` then
		return `S{category}`
	elseif t == `Instance` then
		local index = category:GetAttribute(`{prefix}Index`)
		if not index then
			instanceId += 1
			index = instanceId
			category:SetAttribute(`{prefix}Index`, index)
			category.Destroying:Once(function() rateTracker.clearCategory(category) end)
		end
		return `I{index}`
	elseif t == nil then
		return `G`
	end
	error(`Incorrect Category Type`)
end

local function categoryExists(category: CategoryType)
	if typeof(category) == `Instance` then return category:GetAttribute(`{prefix}Index`) ~= nil end
	return categoriesList[getCategoryIndex(category)] ~= nil
end

local function getCategory(category: CategoryType): Category?
	if not categoryExists(category) then return end
	return categoriesList[getCategoryIndex(category)]
end

rateTracker.clearCategory = function(category: CategoryType): boolean
	local index = getCategoryIndex(category)
	local data = categoriesList[index]
	if not data then return false end
	for objType, _ in pairs(data) do
		rateTracker.clear(category, objType)
	end
	table.clear(data)
	categoriesList[index] = nil
	return data
end

rateTracker.setupCategory = function(category: CategoryType): Category
	local index = getCategoryIndex(category)
	local data = categoriesList[index]
	if data then return data end
	data = {}
	categoriesList[index] = data
	return data
end

rateTracker.clear = function(category: CategoryType, objType: ObjType): boolean
	local categoryData = getCategory(category)
	if not categoryData then return false end
	local data: Obj = categoryData[objType]
	if not data then return false end
	for _, timestamp in pairs(data.timestamps) do table.clear(timestamp) end
	table.clear(data.timestamps)
	table.clear(data)
	categoryData[objType] = nil
	return true
end

rateTracker.setup = function(category: CategoryType, objType: ObjType, maxTime: number, threshold: number?): Obj
	local categoryData = rateTracker.setupCategory(category)
	local data: Obj = categoryData[objType]
	if data then
		if maxTime then data.maxTime = maxTime end
		if threshold then data.threshold = threshold end
		return data
	end
	assert(maxTime, `Please setup the "{objType}" ObjType in its category`)
	data = {maxTime = maxTime; timestamps = {}; cache = 0; threshold = threshold}
	categoryData[objType] = data
	return data
end

-- Yes... AI code... I am so sorry :[
local function binarySearchFirstUnavailable(timestamps, maxTime)
	local l = 1
	local r = #timestamps
	
	if r == 0 then return nil end
	
	while l < r do
		local mid = (l + r + 1) // 2

		if timestamps[mid][1] < maxTime then
			l = mid
		else
			r = mid - 1
		end
	end

	if timestamps[l][1] < maxTime then return l end
end


local function update(category: Category, objType: ObjType): {}
	local data = rateTracker.setup(category, objType)
	local now = tick()
	local timestamps = data.timestamps
	local maxTime = data.maxTime

	local firstUnavailable = nil
	firstUnavailable = binarySearchFirstUnavailable(timestamps, now - maxTime)
	if not firstUnavailable then return true end
	local newList = {}
	for i = firstUnavailable + 1, #timestamps do
		table.insert(newList, timestamps[i])
	end
	local newCache = data.cache
	for i = 1, firstUnavailable do
		newCache -= timestamps[i][2]
	end
	data.cache = newCache
	table.clear(timestamps)
	data.timestamps = newList
	return true
end

-- To avoid issues, please refrain from using floats for the change parameter
rateTracker.add = function(category: Category, objType: ObjType, change: number?)
	local data = rateTracker.setup(category, objType)
	update(category, objType)
	change = change or 1
	data.cache += change
	table.insert(data.timestamps, {tick(); change})
	return true
end

-- (<code>range</code> or maxTime) in seconds
rateTracker.get = function(category: Category, objType: ObjType, range: number?)
	local data = rateTracker.setup(category, objType)
	update(category, objType)

	local maxTime = data.maxTime
	range = range or maxTime
	if range >= maxTime then return data.cache end

	local sum = 0
	local now = tick()
	local timestamps = data.timestamps
	for i = #timestamps, 1, -1 do
		local eventData = timestamps[i]
		if (eventData[1] + range) < now then break end
		sum += eventData[2]
	end
	return sum
end

rateTracker.isThreshold = function(category: Category, objType: ObjType, range: number?)
	local threshold = rateTracker.setup(category, objType).threshold
	return rateTracker.get(category, objType, range) >= (threshold or math.huge)
end

return rateTracker
