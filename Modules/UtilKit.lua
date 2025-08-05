local ukit = {}

local ts = game:GetService("TweenService")

ukit.table = {
	-- A shorter way of performing <code>table.move()</code>
	move = function(from: {}, to: {})
		table.move(from, 1, #from, #to + 1, to)
		return to
	end;

	-- Moves a dictionary <code>fromTable</code> into <code>tabl</code>
	moveDict = function(dict: {}, tabl: {})
		for i, v in pairs(dict) do
			if type(i) == "number" then table.insert(tabl, v) continue end
			tabl[i] = v
		end
		return tabl
	end;

	combine = function(...: {})
		local result = {}
		for _, t in pairs({...}) do ukit.table.moveDict(t, result) end
		return result
	end;

	randomize = function(t: {})
		for i = #t, 2, -1 do
			local j = math.random(i)
			t[i], t[j] = t[j], t[i]
		end
		return t
	end;

	-- Returns a list of the keys from the input table
	-- <code>saveValue</code> means it marks each element in the table with the key of the previous one's value
	keysList = function(tabl: {[any]: any}, saveValue: boolean?, ignoreNil: boolean?): {any}
		local result = {}
		if saveValue then
			for key, val in pairs(tabl) do
				if ignoreNil and val == nil then continue end
				result[val] = key
			end
		else
			for key, val in pairs(tabl) do
				if ignoreNil and val == nil then continue end
				table.insert(result, key)
			end
		end
		return result
	end;

	-- Clears all keys with the value of nil. Good for clearing up memory in a dictionary
	-- Note: this returns a new table
	clearNil = function(tabl: {[any]: any|nil})
		local result = {}
		for i, j in pairs(tabl) do
			if j == nil then continue end
			result[i] = j
		end
		return result
	end;

	-- Returns the true length of a table/dictionary
	length = function(tabl: {any})
		local len = 0
		for i, _ in pairs(tabl) do if i == nil then continue end len += 1 end
		return len
	end;

	sum = function(tabl: {any})
		local sum = 0
		for _, val in pairs(tabl) do sum += val end
		return sum
	end;

	removeDuplicates = function(tabl: {})
		local dupes = {}
		for i, val in pairs(tabl) do
			if table.find(dupes, val) ~= nil then
				table.remove(tabl, i)
				continue
			end
			table.insert(dupes, val)
		end
		return tabl
	end;
	
	dictFind = function(tabl: {string}, search: any)
		for i, v in pairs(tabl) do if v == search then return i end end
	end;

	-- Removes same values from the <code>tabl</code> which is also within the <code>removerTable</code>
	removeIdentical = function(tabl, removerTable)
		for i, j in pairs(removerTable) do
			if type(j) == "table" then
				ukit.table.removeIdentical(tabl[i], j)
				continue
			end
			if tabl[i] ~= j then continue end
			if type(i) == "number" then
				table.remove(tabl, i)
			else
				tabl[i] = nil
			end
		end
		return tabl
	end;

	removeSameValues = function(tabl: {}, removerTable: {}, allowSubTables: boolean?)
		for i, j in pairs(removerTable) do
			if type(j) == "table" then
				if not allowSubTables then continue end
				ukit.table.removeSameValues(tabl[i], j, allowSubTables)
				continue
			end
			ukit.table.remove(tabl, j)
		end
		return tabl
	end;
	
	-- Returns a random value from a table
	getRandom = function(tabl: {any}) return tabl[math.random(1, #tabl)] end;
	
	-- Removes a value in a table with true as a return
	remove = function(tabl: {any}, val: any, all: boolean?)
		if all == true then
			local amntDeleted = 0
			while true do
				if not ukit.table.remove(tabl, val) then break end
				amntDeleted += 1
			end
			return amntDeleted > 0
		end
		local foundId = table.find(tabl, val)
		if foundId then table.remove(tabl, foundId) return true end
		return false
	end;
	
	-- a 'set' in Python is a list with no repeatable items
	setAdd = function(tabl: {any}, addVal: any)
		if not table.find(tabl, addVal) then table.insert(tabl, addVal) return true end
	end;
	
	-- Checks if an element exists in a table
	has = function(tabl: {any}, val: any) return table.find(tabl, val) ~= nil end;

	-- Removes an element from a table, returning its value with it
	pop = function(tabl: {any}, i: number?)
		if i == nil then i = #tabl end
		local val = tabl[i]
		table.remove(tabl, i)
		return val
	end;
	
	reverse = function(t: {})
		local reversedTable = {}
		for i = #t, 1, -1 do table.insert(reversedTable, t[i]) end
		return reversedTable
	end;
	
	deep = {
		-- Freezes the table and all sub-tables.
		-- <code>unfreezeCheck</code> checks if a table to be frozen has the "!freeze{}" string in it, stopping further freezing for that table.
		freeze = function(tabl: {}, unfreezeCheck: boolean?)
			for _, obj in pairs(tabl) do
				if typeof(obj) == "table" then
					if unfreezeCheck then
						local foundIdx = table.find(obj, "!freeze{}")
						if foundIdx then table.remove(obj, foundIdx) continue end
					end
					ukit.table.deep.freeze(obj, unfreezeCheck)
				end
			end
			if not table.isfrozen(tabl) then table.freeze(tabl) end
			return tabl
		end;

		-- Preforms a deep clone on a table. This can also be used to unfreeze a table.
		clone = function(tabl: {})
			local coppiedTable = {}
			for i, obj in pairs(tabl) do
				if typeof(obj) == "table" then
					coppiedTable[i] = ukit.table.deep.clone(obj)
				else coppiedTable[i] = obj end
			end
			return coppiedTable
		end;

		-- Performs table.clear on all sub-tables in a table
		clear = function(tabl: {})
			for i, obj in pairs(tabl) do
				if typeof(obj) ~= "table" then continue end
				ukit.table.deep.clear(obj)
			end
			if not table.isfrozen(tabl) then table.clear(tabl) end
			return tabl
		end;
	};
};

ukit.string = {
	symbols = {
		symbols = string.split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-=!@#%^&*()[]{}<>,./\\|:;_+", "");
		letters = string.split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", "");
		numbers = string.split("1234567890", "");
		other = string.split("-=!@#%^&*()[]{}<>,./\\|_+", "");
	};
	
	--Iterates through a string and calls a function for each letter
	iterateLetters = function(str: string, func: (letter: string) -> nil, delayTime: number?)
		delayTime = delayTime or 0
		
		local index = 0
		local chars = string.split(str, "")

		local timer = 0
		local conn: RBXScriptConnection
		conn = game:GetService("RunService").Stepped:Connect(function(_, dt)
			timer += dt
			while timer >= delayTime do
				index += 1
				timer -= delayTime
				func(chars[index])
				if index >= #chars then ukit.connection.disconnect(conn) break end
			end
		end)

		return conn
	end;

	-- Returns a sequence of random characters from within <code>ukit.string.symbols</code>
	random = function(length: number, tableName: string)
		local tabl = ukit.string.symbols[ukit.defaultTo(tableName, "all")]
		local str = ""
		for i = 1, length do str ..= ukit.table.getRandom(tabl) end
		return str
	end;

	compareBegin = function(str: string, compareStr: string, offset: (number | string)?)
		if type(offset) == "string" then offset = string.len(offset) end
		offset = math.max(0, offset or 0) + 1
		return string.sub(str, offset, math.max(string.len(compareStr) + offset - 1, offset)) == compareStr
	end;

	-- Splits a string into two tables based on the character id in the string
	splitId = function(str: string, id: number)
		if id < 2 or id > #str - 1 then
			if id == 1 then return {``; str:sub(2)} end
			if id == #str then return {str:sub(1, -2); ``} end
			return {str}
		end
		return {str:sub(1, id - 1); str:sub(id + 1)}
	end;

	trim = function(str: string) return str:match("^%s*(.-)%s*$") end;
	
	-- Checks if a string can be converted to a JSON Format
	canJson = function(str: string)
		return ({pcall(function() game:GetService("HttpService"):JSONEncode(str) end)})[1]
	end;

	capitilize = function(str: string)
		local result = ``
		local wasSpace = true
		for _, char in pairs(str:lower():split(``)) do
			result ..= wasSpace and char:upper() or char
			if char == ` ` then wasSpace = true else wasSpace = false end
		end
		return result
	end;

	-- Returns (if found) the assetId, the prefix used (optional) and the id of that prefix in the look-up list (optional) of an asset id
	getAssetId = function(assetStr: string, includePrefix: boolean?, includePrefixId: boolean?): (number, string?, number?)
		local prefixes = {
			"rbxassetid://";
			"http://www.roblox.com/asset/?id=";
			"rbxasset://textures/";
		}
		for i, prefix in pairs(prefixes) do
			local split = assetStr:split(prefix)
			if #split ~= 2 then continue end
			local id = tonumber(split[2]) or split[2]
			if not id then continue end
			local result = {id}
			if includePrefix then table.insert(result, prefix) end
			if includePrefixId then table.insert(result, i) end
			return table.unpack(result)
		end
		return nil
	end;
};

ukit.number = {
	-- Returns true if a number is Nan (Not A Number)
	isNan = function(num: number) return num ~= num end;

	-- Returns a random number with a given amount of decimal places
	random = function(min: number, max: number, decimals: number?)
		if decimals == nil then return math.random(min, max) end
		local precision = 10 ^ decimals
		return math.random(min * precision, max * precision) / precision 
	end;

	sum = function(...: number) return ukit.table.sum({...}) end;

	average = function(...: number)
		local result = 0
		local variadics = {...}
		for _, num in pairs(variadics) do result += num / #variadics end
		return result
	end;

	-- Performs a tween on a number
	tween = function(beginVal: number, targetVal: number, tweenInfo: TweenInfo, onChangeFunc: (newValue: number, changedBy: number) -> nil, onEndFunc: (endValue: number) -> nil): Tween
		local numberVal = Instance.new("NumberValue")
		numberVal.Value = beginVal

		local prevV = beginVal
		local numberConn = numberVal.Changed:Connect(function()
			onChangeFunc(numberVal.Value, numberVal.Value - prevV)
			prevV = numberVal.Value
		end)

		local tw = ts:Create(numberVal, tweenInfo, {Value = targetVal})
		tw.Completed:Once(function()
			numberConn:Disconnect()
			if onEndFunc ~= nil then onEndFunc(targetVal) end
			task.wait()
			numberVal:Destroy()
		end)
		tw:Play()
		return tw
	end;

	-- Rounds the number with a given amount of decimal places
	round = function(num: number, decimals: number?)
		if decimals == nil then decimals = 0 end
		local precision = 10 ^ math.floor(decimals)
		return math.round(num * precision) / precision
	end;

	inverseLerp = function(from, to, value) return (value - from) / (to - from) end;

	-- num < target -> 1<br>num > target -> -1<br>num == target -> 0
	pointToTarget = function(num, target) return math.sign(target - num) end;

	inRange = function(num: number, n1: number, n2: number)
		return math.clamp(num, math.min(n1, n2), math.max(n1, n2)) == num
	end;

	toGrid = function(v: number, chunkSize: number)
		return math.floor((v + (chunkSize * .5)) / chunkSize) * chunkSize
	end;

	-- Makes the number go towards the <code>stepTo</code> using the given <code>stepSize</code>
	moveTowards = function(from: number, to: number, stepSize: number, canPass: boolean?)
		stepSize = math.abs(stepSize)
		if from > to then
			from -= stepSize
			if from <= to then return canPass and from or to end
		elseif from < to then
			from += stepSize
			if from >= to then return canPass and from or to end
		end
		return from
	end;

	-- Maps a number from one range to another
	map = function(value, inMin, inMax, outMin, outMax)
		return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
	end;

	-- Swings a number from 0 to 1, from 1 to 0, etc...
	alternate = function(num: number)
		local a = num % 2
		if a > 1 then return 2 - a end
		return a
	end;

	-- Returns the decimal part of the number as a string
	decimal = function(num: number): string?
		return string.format(`%f`, num):split(".")[2]
	end;

	list = {
		-- Turns a list of numbers into a single number
		-- The numbers in the list must NOT be negative
		-- The <code>toString</code> parameter keeps the encoded value a string, saving its precision
		encode = function(nums: {number}, toString: boolean?): number
			local result = {}
			for _, num in pairs(nums) do
				local str = ukit.number.base.fromTen(math.floor(math.abs(num)), 9)
				if str == `0` then str = `` end
				table.insert(result, str)
			end
			local str = table.concat(result, `9`)
			if toString then return str end
			return tonumber(str)
		end;

		-- Turns a number into a list of numbers
		decode = function(num: number): {number}
			local result = {}
			local strThing = string.format(`%f`, num):split(".")[1]
			for _, numB9 in pairs(string.split(strThing, "9")) do
				table.insert(result, ukit.number.base.toTen(numB9, 9))
			end
			return result
		end;
	};
	
	base = {
		_digits = `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()_+`;

		-- Converts base 10 into the <code>targetBase</code>
		-- Supports bases 2-74. Symbols until 62 are the standard 0-9,A-Z,a-z
		-- <strong>Notes:</strong>
		-- 1. Negative numbers will also have a negative sign in all different bases
		-- 2. Decimals and Negative Numbers were done with a custom approach, and are not universal.
		fromTen = function(number: number, toBase: number, customDigits: string?, customImplementation: boolean?): string
			local digits = customDigits or ukit.number.base._digits
			if toBase < 2 or toBase > #digits then
				error(`Target base is out of the defined range ({toBase < 2 and "Under" or "Above"})`)
			end
			local negative = number < 0 and customImplementation
			if negative then number *= -1 end
			local symbolsShift = 0
			local symbolsShiftStr = ""
			if customImplementation then
				local decimal = ukit.number.decimal(number)
				if decimal then
					symbolsShift = #decimal
					number = tonumber(table.concat(string.split(tostring(number), "."), ""))
					if symbolsShift > 1 then
						symbolsShiftStr = `.{ukit.number.base.fromTen(symbolsShift - 2, toBase, false, customDigits)}`
					else
						symbolsShiftStr = "."
					end
				end
			else
				number = math.floor(number)
			end

			local result = ""

			while number > 0 do
				local remainder = number % toBase
				result = digits:sub(remainder + 1, remainder + 1) .. result
				number = math.floor(number / toBase)
			end

			return `{negative and "-" or ""}{result ~= "" and result or digits:sub(1, 1)}{symbolsShiftStr}`
		end;

		toTen = function(numberStr: string, fromBase: number, customDigits: string?, customImplementation: boolean?): number
			local digits = customDigits or ukit.number.base._digits
			if fromBase < 2 or fromBase > #digits then
				error(`The base the number is from is outside the defined range ({fromBase < 2 and "Under" or "Above"})`)
			end

			local negative = false
			local offset = 0
			if customImplementation then
				negative = string.sub(numberStr, 1, 1) == "-"
				if negative then numberStr = string.sub(numberStr, 2) end
				local dotSplit = string.split(numberStr, ".")
				if #dotSplit == 2 then
					offset = ukit.number.base.toTen(dotSplit[2] ~= "" and dotSplit[2] or `-{customDigits:sub(2, 2)}`, fromBase, customDigits) + 2
					numberStr = dotSplit[1]
				end
			end
			local result = 0

			for i = 1, #numberStr do
				local char = numberStr:sub(i, i)
				local value = digits:find(char, 1, true) - 1 -- Get the numeric value of the character
				assert(value and value < fromBase, `Invalid digit '{char}' from base {fromBase}`)
				result = result * fromBase + value
			end

			return (result / (10 ^ offset)) * (negative and -1 or 1)
		end;
	};

	-- All functions are thanks to https://easings.net/
	easing = {
		sine = {
			In = function(x: number)
				return 1 - math.cos((x * math.pi) / 2);
			end;

			Out = function(x: number)
				return math.sin((x * math.pi) / 2);
			end;

			InOut = function(x: number)
				return -(math.cos(math.pi * x) - 1) / 2;
			end;
		};

		quad = {
			-- x * x
			In = function(x: number)
				return x * x
			end;

			Out = function(x: number)
				return 1 - (1 - x) * (1 - x)
			end;

			InOut = function(x: number)
				if x < .5 then return 2 * x * x end
				return 1 - math.pow(-2 * x + 2, 2) / 2
			end;
		};

		cubic = {
			-- x ^ 3
			In = function(x: number)
				return x * x * x
			end;

			Out = function(x: number)
				return 1 - math.pow(1 - x, 3)
			end;

			InOut = function(x: number)
				if x < .5 then return 4 * x * x * x end
				return 1 - math.pow(-2 * x + 2, 3) / 2
			end;
		};

		quart = {
			-- x ^ 4
			In = function(x: number)
				return x * x * x * x
			end;

			Out = function(x: number)
				return 1 - math.pow(1 - x, 4)
			end;

			InOut = function(x: number)
				if x < .5 then return 8 * x * x * x * x end
				return 1 - math.pow(-2 * x + 2, 4) / 2
			end;
		};

		quint = {
			-- x ^ 5
			In = function(x: number)
				return x * x * x * x * x
			end;

			Out = function(x: number)
				return 1 - math.pow(1 - x, 5)
			end;

			InOut = function(x: number)
				if x < .5 then return 16 * x * x * x * x * x end
				return 1 - math.pow(-2 * x + 2, 5) / 2
			end;
		};

		expo = {
			In = function(x: number)
				if x == 0 then return 0 end
				return math.pow(2, 10 * x - 10);
			end;

			Out = function(x: number)
				if x == 1 then return 1 end
				return 1 - math.pow(2, -10 * x)
			end;

			InOut = function(x: number)
				if x == 0 then return 0 end
				if x == 1 then return 1 end
				if x < .5 then return math.pow(2, 20 * x - 10) / 2 end
				return (2 - math.pow(2, -20 * x + 10)) / 2;
			end;
		};

		circ = {
			In = function(x: number)
				return 1 - math.sqrt(1 - math.pow(x, 2))
			end;

			Out = function(x: number)
				return math.sqrt(1 - math.pow(x - 1, 2))
			end;

			InOut = function(x: number)
				if x < .5 then return (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2 end
				return (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2;
			end;
		};

		back = {
			In = function(x: number)
				return 2.70158 * x * x * x - 1.70158 * x * x
			end;

			Out = function(x: number)
				return 1 + 2.70158 * math.pow(x - 1, 3) + 1.70158 * math.pow(x - 1, 2)
			end;

			InOut = function(x: number)
				if x < .5 then return (math.pow(2 * x, 2) * (3.5949095 * 2 * x - 2.5949095)) / 2 end
				return (math.pow(2 * x - 2, 2) * (3.5949095 * (x * 2 - 2) + 2.5949095) + 2) / 2
			end;
		};

		elastic = {
			In = function(x: number)
				if x == 0 then return 0 end
				if x == 1 then return 1 end
				return -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * ((2 * math.pi) / 3));
			end;

			Out = function(x: number)
				if x == 0 then return 0 end
				if x == 1 then return 1 end
				return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * ((2 * math.pi) / 3)) + 1;
			end;

			InOut = function(x: number)
				if x == 0 then return 0 end
				if x == 1 then return 1 end
				local c5 = (2 * math.pi) / 4.5;
				if x < .5 then return -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2 end
				return (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1;
			end;
		};

		bounce = {
			In = function(x: number)
				return 1 - ukit.number.easing.bounce.Out(1 - x);
			end;

			Out = function(x: number)
				if (x < 1 / 2.75) then
					return 7.5625 * x * x
				elseif (x < 2 / 2.75) then
					x -= 1.5 / 2.75
					return 7.5625 * x * x + 0.75
				elseif (x < 2.5 / 2.75) then
					x -= 2.25 / 2.75
					return 7.5625 * x * x + 0.9375
				end
				x -= 2.625 / 2.75
				return 7.5625 * x * x + 0.984375
			end;

			InOut = function(x: number)
				if x < .5 then return (1 - ukit.number.easing.bounce.Out(1 - 2 * x)) / 2 end
				return (1 + ukit.number.easing.bounce.Out(2 * x - 1)) / 2;
			end;
		};

		bubble = {
			In = function(x: number)
				return x^2 + 0.2 * math.sin(10 * math.pi * x) * (1 - x)
			end;
		};

		flash = {
			Out = function(x: number)
				return 1 - (1 - x)^3 + 0.1 * math.sin(20 * math.pi * x)
			end;
		};

		linear = {
			-- The most craziest and complex function known to mankind. Be careful using it
			In = function(x: number)
				return x
			end;

			Out = function(x: number)
				return x
			end;

			InOut = function(x: number)
				return x
			end;
		};
	};
};

ukit.vector3 = {
	huge = Vector3.one * math.huge;
	noX = function(vec: Vector3) return Vector3.new(0, vec.Y, vec.Z) end;
	noY = function(vec: Vector3) return Vector3.new(vec.X, 0, vec.Z) end;
	noZ = function(vec: Vector3) return Vector3.new(vec.X, vec.Y, 0) end;
	onlyX = function(vec: Vector3) return Vector3.new(vec.X, 0, 0) end;
	onlyY = function(vec: Vector3) return Vector3.new(0, vec.Y, 0) end;
	onlyZ = function(vec: Vector3) return Vector3.new(0, 0, vec.Z) end;
	newX = function(xVal: number) return Vector3.new(xVal, 0, 0) end;
	newY = function(yVal: number) return Vector3.new(0, yVal, 0) end;
	newZ = function(zVal: number) return Vector3.new(0, 0, zVal) end;
	swapXY = function(vec: Vector3) return Vector3.new(vec.Y, vec.X, vec.Z) end;
	swapXZ = function(vec: Vector3) return Vector3.new(vec.Z, vec.Y, vec.X) end;
	swapYZ = function(vec: Vector3) return Vector3.new(vec.X, vec.Z, vec.Y) end;
	setX = function(vec: Vector3, newX: number) return Vector3.new(newX, vec.Y, vec.Z) end;
	setY = function(vec: Vector3, newY: number) return Vector3.new(vec.X, newY, vec.Z) end;
	setZ = function(vec: Vector3, newZ: number) return Vector3.new(vec.X, vec.Y, newZ) end;
	scale = function(vec: Vector3, newMagnitude: number, failVec: Vector3?)
		if vec.Magnitude == 0 then
			if not failVec then return Vector3.zero end
			return ukit.vector3.scale(failVec, newMagnitude)
		end
		return vec.Unit * newMagnitude
	end;
	
	min = function(...: Vector3)
		local variadics = {...}
		local smallest = variadics[1]
		for i = 2, #variadics do
			local vec = variadics[i]
			smallest = smallest.Magnitude > vec.Magnitude and vec or smallest
		end
		return smallest
	end;
	
	max = function(...: Vector3)
		local variadics = {...}
		local largest = variadics[1]
		for i = 2, #variadics do
			local vec = variadics[i]
			largest = largest.Magnitude < vec.Magnitude and vec or largest
		end
		return largest
	end;
	
	distance = function(vec1: Vector3, vec2: Vector3) return (vec1 - vec2).Magnitude end;
	
	round = function(vec: Vector3, decimals: number?) return Vector3.new(ukit.num.round(vec.X, decimals), ukit.num.round(vec.Y, decimals), ukit.num.round(vec.Z, decimals)) end;
	
	clamp = function(vec: Vector3, minVec: Vector3, maxVec: Vector3) return Vector3.new(math.clamp(vec.X, minVec.X, maxVec.X), math.clamp(vec.Y, minVec.Y, maxVec.Y), math.clamp(vec.Z, minVec.Z, maxVec.Z)) end;
	
	project = function(vec: Vector3, projectionVec: Vector3) return vec:Dot(projectionVec.Unit) * projectionVec.Unit end;

	safeUnit = function(vec: Vector3, failVal: Vector3?)
		if vec.Magnitude == 0 then return failVal or Vector3.zero end
		return vec.Unit
	end;
	
	reflect = function(vec: Vector3, normal: Vector3)
		return vec - 2 * normal * vec:Dot(normal)
	end;
};

ukit.vector2 = {
	noX = function(vec: Vector2) return Vector2.new(0, vec.Y) end;
	noY = function(vec: Vector2) return Vector2.new(vec.X, 0) end;
	newX = function(num: number) return Vector2.new(num, 0) end;
	newY = function(num: number) return Vector2.new(0, num) end;
	swapXY = function(vec: Vector2) return Vector2.new(vec.Y, vec.X) end;
	setX = function(vec: Vector2, newX) return Vector2.new(newX, vec.Y) end;
	setY = function(vec: Vector2, newY) return Vector2.new(vec.X, newY) end;
	scale = function(vec: Vector2, newMagnitude: number, failVec: Vector2?)
		if vec.Magnitude == 0 then
			if not failVec then return Vector2.zero end
			return ukit.vector2.scale(failVec, newMagnitude)
		end
		return vec.Unit * newMagnitude
	end;
	
	min = function(...: Vector2): Vector2 return ukit.vector3.min(...) end;
	max = function(...: Vector2): Vector2 return ukit.vector3.max(...) end;
	
	round = function(vec: Vector2, decimals: number?) return Vector2.new(ukit.num.round(vec.X, decimals), ukit.num.round(vec.Y, decimals)) end;
	
	safeUnit = function(vec: Vector2, failVal: Vector2?): Vector2 return ukit.vector3.safeUnit(vec, failVal or Vector2.zero) end;
	
	distance = function(vec1: Vector3, vec2: Vector3) return (vec1 - vec2).Magnitude end;
	
	toVector3 = {
		y = function(vec: Vector2, defaultZ: number?) return Vector3.new(vec.X, vec.Y, defaultZ or 0) end;
		z = function(vec: Vector2, defaultY: number?) return Vector3.new(vec.X, defaultY or 0, vec.Y) end;
	};
};

ukit.cframe = {
	sum = function(...: CFrame)
		local result = CFrame.new()
		for _, cf in pairs({...}) do result *= cf end
		return result
	end;
	
	average = function(...: CFrame)
		local variadics = {...}
		if #variadics == 0 then return CFrame.new() end

		local pos = Vector3.zero
		local rot = Vector3.zero
		local alpha = 1 / #variadics
		for _, cf in pairs(variadics) do
			pos += cf.Position * alpha
			rot += Vector3.new(cf.Rotation:ToOrientation()) * alpha
		end
		return ukit.cframe.rotation.fromOrientationVector(rot) + pos
	end;
	
	-- First 3 parameters are positions of the CFrame
	-- Last 3 parameters are the Angle rotation in degrees
	new = function(x, y, z, rx, ry, rz)
		return ukit.cframe.rotation.fromDegrees(rx, ry, rz) + Vector3.new(x, y, z)
	end;
	
	rotation = {
		fromDegrees = function(x: number, y: number, z: number)
			return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
		end;
		
		fromOrientationVector = function(rotation: Vector3)
			return CFrame.fromOrientation(rotation.X, rotation.Y, rotation.Z)
		end;
	};
};

ukit.instance = {
	new = function(class: string, properties: {[string]: any}?)
		local inst: Instance = Instance.new(class)
		for name, value in pairs(properties or {}) do inst[name] = value end
		return inst
	end;
	
	-- Safely destroys an Instance
	destroy = function(inst: Instance?)
		if not inst then return false end
		local result = {pcall(function()
			inst:Destroy()
			return true
		end)}
		return result[2] == true
	end;
	
	-- Returns an Instance under the selected parent with said name. Creates one with a specified class if absent
	get = function(class: string, name: string, parent: Instance)
		return parent:FindFirstChild(name) or ukit.instance.new(class, {Name = name; Parent = parent})
	end;
	
	-- Returns the Instance that has called a function
	caller = function(levelOffset: number?)
		local fullPath = debug.info(3 + (levelOffset or 0), "s")
		if not fullPath then return nil end
		local currentDirectory = game
		for _, str in pairs(string.split(fullPath, ".")) do
			currentDirectory = currentDirectory:FindFirstChild(str)
			if not currentDirectory then return nil end
		end
		return currentDirectory
	end;
	
	directory = {
		-- Returns a string which defines the path towards a specified Instances located in the root (Default: game)
		-- Default separator: "/"
		to = function(inst: Instance, separator: string?, root: Instance?): string?
			root = root or game
			if not inst:IsDescendantOf(root) then return end
			local result = {inst.Name}
			local currentInst = inst
			while currentInst.Parent ~= root do
				currentInst = currentInst.Parent
				table.insert(result, currentInst.Name)
			end
			return table.concat(ukit.table.reverse(result), separator or `/`)
		end;

		-- Returns an Instance from a specified path located in the root Instance (Default: game)
		-- Default separator: "/"
		from = function(path: string, separator: string?, root: Instance?)
			local currentInst = root or game
			for _, search in pairs(path:split(separator or `/`)) do
				currentInst = currentInst:FindFirstChild(search)
				if not currentInst then return end
			end
			return currentInst
		end;
	};
	
	tag = {
		set = function(inst: Instance, tagName: string, tagValue: boolean): boolean
			local was = inst:HasTag(tagName)
			if tagValue then inst:AddTag(tagName)
			else inst:RemoveTag(tagName) end
			return tagValue ~= was
		end;
	};
	
	attribute = {
		list = {
			-- Adds a value to the end of the attribute list
			insert = function(inst: Instance, name: string, value: string)
				local list = ukit.instance.attribute.list.get(inst, name)
				table.insert(list, value)
				inst:SetAttribute(name, table.concat(list, `/`))
				return true
			end;
			
			remove = function(inst: Instance, name: string, pos: number)
				local list = ukit.instance.attribute.list.get(inst, name)
				table.remove(list, pos)
				inst:SetAttribute(name, #list > 0 and table.concat(list, `/`) or nil)
				return true
			end;
			
			-- Returns the index of said value inside the attribute list
			find = function(inst: Instance, name: string, value: string)
				return table.find(ukit.instance.attribute.list.get(inst, name), value)
			end;
			
			has = function(inst: Instance, name: string, value: string)
				return ukit.instance.attribute.list.find(inst, name, value) ~= nil
			end;
			
			clear = function(inst: Instance, name: string)
				local prevVal = inst:GetAttribute(name)
				inst:SetAttribute(name, nil)
				return prevVal
			end;
			
			-- Returns the table of the elements
			get = function(inst: Instance, name: string)
				local data: string? = inst:GetAttribute(name)
				if not data then return {} end
				return data:split(`/`)
			end;
		};
	};
	
	weld = {
		keepOffset = function(part0: Part, part1: Part)
			local weld = Instance.new("Weld")
			weld.Parent = part0
			weld.C0 = part0.CFrame:Inverse() * part1.CFrame
			weld.Part0 = part0
			weld.Part1 = part1
			return weld
		end;
	};
	
	value = {
		-- A safe get for a ValueBase Instance
		-- <code>default</code> parameter is what gets returned if the ValueBase's Value property is <strong>nil</strong>
		get = function(inst: ValueBase?, default: any?)
			if not inst then return default end
			return ukit.defaultTo(inst.Value, default)
		end;

		-- A safe set for a ValueBase Instance
		set = function(inst: ValueBase?, value: any)
			if not inst then return false end
			inst.Value = value
			return true
		end;
	};
};

ukit.udim = {
	add = function(ud1: UDim, ud2: UDim) return UDim.new(ud1.Scale + ud2.Scale, ud1.Offset + ud2.Offset) end;
	subtract = function(ud1: UDim, ud2: UDim) return UDim.new(ud1.Scale - ud2.Scale, ud1.Offset - ud2.Offset) end;
	multiply = function(ud: UDim, mul: number) return UDim.new(ud.Scale * mul, ud.Offset * mul) end;
};

ukit.udim2 = {
	add = function(ud1: UDim2, ud2: UDim2) return UDim2.new(ukit.udim.add(ud1.X, ud2.X), ukit.udim.add(ud1.Y, ud2.Y)) end;
	subtract = function(ud1: UDim2, ud2: UDim2) return UDim2.new(ukit.udim.subtract(ud1.X, ud2.X), ukit.udim.subtract(ud1.Y, ud2.Y)) end;
	multiply = function(ud: UDim2, mul: number) return UDim2.new(ukit.udim.multiply(ud.X, mul), ukit.udim.multiply(ud.Y, mul)) end;
	setX = function(ud: UDim2, newScale: number?, newOffset: number?)
		if newScale == nil then newScale = ud.X.Scale end
		if newOffset == nil then newOffset = ud.X.Offset end
		return UDim2.new(newScale, newOffset, ud.Y.Scale, ud.Y.Offset)
	end;
	setY = function(ud: UDim2, newScale: number?, newOffset: number?)
		if newScale == nil then newScale = ud.Y.Scale end
		if newOffset == nil then newOffset = ud.Y.Offset end
		return UDim2.new(ud.X.Scale, ud.X.Offset, newScale, newOffset)
	end;
	noX = function(ud: UDim2) return UDim2.new(0, 0, ud.Y.Scale, ud.Y.Offset) end;
	noY = function(ud: UDim2) return UDim2.new(ud.X.Scale, ud.X.Offset, 0, 0) end;
};

ukit.color3 = {
	number = {
		-- The precision gets lost a little bit, the saturation and value, to be exact
		to = function(color: Color3)
			local h, s, v = color:ToHSV()
			local hScaled = math.round(h * 1024)  -- 10 bits (0-1023)
			local sScaled = math.round(s * 127)   -- 7 bits (0-127)
			local vScaled = math.round(v * 127)
			return bit32.bor(bit32.lshift(hScaled, 14), bit32.lshift(sScaled, 7), vScaled)
		end;

		from = function(number: number)
			local hScaled = math.floor(bit32.rshift(number, 14))
			local sScaled = bit32.rshift(bit32.band(number, 0x3F80), 7)  -- Mask 0b0011111110000000
			local vScaled = bit32.band(number, 0x7F)                     -- Mask 0b0000000001111111
			return Color3.fromHSV(hScaled / 1024, sScaled / 127, vScaled / 127)
		end;
	};
};

ukit.connection = {
	active = function(conn: RBXScriptConnection?) return conn ~= nil and conn.Connected end;
	disconnect = function(...: RBXScriptConnection?)
		local wasDisconnected = false
		for _, conn in pairs({...}) do
			if ukit.connection.active(conn) then conn:Disconnect() wasDisconnected = true end
		end
		return wasDisconnected
	end;
	-- Disconnects all connections within a table of connections
	disconnectTable = function(connTable: {RBXScriptConnection}?)
		if not connTable then return false end
		for _, conn in pairs(connTable) do conn:Disconnect() end
		table.clear(connTable)
		return true
	end;
	-- Disconnects all connections within each table in the provided table of connections
	deepDisconnectTable = function(connTable: {RBXScriptConnection|{RBXScriptConnection}}?)
		if not connTable then return false end
		for _, element in pairs(connTable) do
			
			if type(element) == "table" then
				ukit.connection.deepDisconnectTable(element)
				continue
			end
			
			ukit.connection.disconnect(element)
			
		end
		table.clear(connTable)
		return true
	end;
};

export type ElapsedCategory = nil|string|Instance
local elapsedData = {}
ukit.elapsed = {
	-- Resets the time passed since any custom-defined event with an optional offset parameter
	-- Returns the passed time right before the update
	reset = function(category: ElapsedCategory, name: string, offset: number?)
		category = category or script
		offset = offset or 0
		if not elapsedData[category] then
			elapsedData[category] = {}
			if typeof(category) == `Instance` then
				category.Destroying:Once(function()
					table.clear(elapsedData[category])
					elapsedData[category] = nil
				end)
			end
		end
		local origPassed = ukit.elapsed.get(category, name)
		elapsedData[category][name] = tick() + offset
		return origPassed
	end;

	-- Offsets the time passed by a specified change
	change = function(category: ElapsedCategory, name: string, change)
		category = category or script
		return ukit.elapsed.reset(category, name, ukit.elapsed.getTick(category, name) - tick() + change)
	end;

	-- Returns the time passed since any custom-defined event
	get = function(category: ElapsedCategory, name: string)
		return tick() - ukit.elapsed.getTick(category or script, name)
	end;
	
	getTick = function(category: ElapsedCategory, name: string)
		local data = elapsedData[category or script]
		if not data then return -math.huge end
		return data[name] or -math.huge
	end;

	remove = function(category: ElapsedCategory, name: string)
		category = category or script
		if not elapsedData[category] then return false end
		elapsedData[category][name] = nil
		return true
	end;

	-- Returns the time passed since the UnixTimestamp in seconds, including milliseconds
	unix = function() return DateTime.now().UnixTimestampMillis * .001 end;
};

ukit.date = {
	formatTimePassed = function(passed: number)
		if passed == -1 then return "Forever" end
		if passed < 0 then return `{ukit.date.formatTimePassed(-passed):split(4)} ago` end
		local divResult: number
		local function try(num: number)
			divResult = passed / num
			if divResult < 1 then return false end
			divResult = ukit.number.round(divResult, 1)
			return true
		end
		local result = ``
		if try(60 * 60 * 24 * 365.25) then result = `{divResult} year` 
		elseif try(60 * 60 * 24 * 30.437) then result = `{divResult} month`
		elseif try(60 * 60 * 24) then result = `{divResult} day`
		elseif try(60 * 60) then result = `{divResult} hour`
		elseif try(60) then result = `{divResult} minute`
		else
			divResult = ukit.number.round(passed, 1)
			result = `{divResult} second`
		end
		return `in {result}{divResult ~= 1 and "s" or ""}`
	end;
};

-- Returns the first non-nil parameter
ukit.defaultTo = function(...: any): any?
	for _, default in pairs({...}) do
		if default ~= nil then return default end
	end
end

return ukit
