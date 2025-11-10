local rkit = {}

export type CustomParams = {FilterType: Enum.RaycastFilterType; FilterDescendantsInstances: {Instance}; IgnoreWater: boolean; CollisionGroup: string; includeNonCollidable: boolean}
export type RayParams = RaycastParams|CustomParams

local recastCount = 100
local rendering = false
local renderLifetime = 1.5
local renderConnPresent = false
local renderEvent = Instance.new(`BindableEvent`)
rkit._core = {
	render = {
		-- Attemps to fire an event for rendering (managed by the developer)
		-- Fired using EventKit.fire("RayKit", "Render", ...) (does an invoke too)
		fire = function(rayType: string, ...)
			local params = {rayType, ...}
			if rendering then renderEvent:Fire(table.unpack(params)) end
			local ekitInst = script.Parent:FindFirstChild("EventKit")
			if ekitInst then
				local ekit = require(ekitInst)
				ekit.fire(`RayKit`, `Render`, table.unpack(params))
				if ekit.isAttached(`RayKit`, `Render`) then
					pcall(function() ekit.invoke(`RayKit`, `Render`, table.unpack(params)) end)
				end
			end
			return true
		end;
		
		-- Toggle the ray default renderer.
		-- In case you want a custom rendering functionality, look into the comments of the "fire" function above this one
		toggle = function(toggle: boolean, lifetime: number)
			if toggle == nil then toggle = not rendering
			elseif rendering == toggle then return end
			rendering = toggle
			if not toggle then return true end
			renderLifetime = lifetime or 1.5
			if not renderConnPresent then
				renderConnPresent = true
				renderEvent.Event:Connect(function(rayType: string, ...)
					rkit._core.render.template[rayType](...)
				end)
			end
			return true
		end;
		
		template = {
			_line = function(startPos: Vector3, finishPos: Vector3, width: number?, color: Color3?)
				width = width or 0.1

				local parentName = `RayKitRendering`
				local parent = workspace:FindFirstChild(parentName)
				if not parent then
					parent = Instance.new("Folder")
					parent.Name = parentName
					parent.Parent = workspace
				end

				local part = Instance.new("Part")
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Anchored = true
				part.Size = Vector3.new((finishPos - startPos).Magnitude, width, width)
				part.CFrame = CFrame.lookAt(startPos, finishPos)
				part.CFrame += part.CFrame.LookVector * 0.5 * part.Size.X
				part.CFrame *= CFrame.Angles(0, math.rad(90), 0)
				part.Shape = Enum.PartType.Cylinder
				part.Color = color or Color3.new(0, 0, 0)
				part.Transparency = 0.5
				part.Material = Enum.Material.Neon
				part.CastShadow = false
				part.Parent = parent
				if renderLifetime >= 0 then game.Debris:AddItem(part, renderLifetime) end

				return part
			end;
			
			-- A template render function for Raycasting
			Ray = function(origin: Vector3, direction: Vector3, hitPos: Vector3, params: RayParams)
				rkit._core.render.template._line(origin, hitPos, nil, Color3.new(1, 0, 0))
			end;
			
			-- A template render function for Spherecasting
			Sphere = function(origin: Vector3, radius: number, direction: Vector3, hitPos: Vector3, params: RayParams)
				local dirUnit = direction.Unit
				local realEndPos = dirUnit * (hitPos - origin):Dot(dirUnit) + origin
				rkit._core.render.template._line(origin, realEndPos, radius * 2, Color3.new(0, 1, 0))
			end;
			
			-- A template render function for Blockcasting
			-- TODO: Add a better visualizer
			Block = function(cframe: CFrame, size: Vector3, direction: Vector3, hitPos: Vector3, params: RayParams)
				local dirUnit = direction.Unit
				local realEndPos = dirUnit * (hitPos - cframe.Position):Dot(dirUnit) + cframe.Position
				rkit._core.render.template._line(cframe.Position, realEndPos, nil, Color3.new(0, 0, 1))
			end;
			
			-- A template render function for Shapecasting
			-- TODO: Add a better visualizer
			Shape = function(part: BasePart, direction: Vector3, hitPos: Vector3, params: RayParams)
				local dirUnit = direction.Unit
				local realEndPos = dirUnit * (hitPos - part.Position):Dot(dirUnit) + part.Position
				rkit._core.render.template._line(part.Position, realEndPos, nil, Color3.new(1, 0, 1))
			end;
		};
	};
	
	-- Checks if a ray should be casted again (i.e. skip a hit)
	recastCheck = function(result: RaycastResult?, params)
		-- Did we even hit something?
		if not result then return false end
		local recast = false
		
		-- Are we ignoring non-collidable
		recast = recast or (typeof(params) ~= "RaycastParams" and not params.includeNonCollidable and not result.Instance.CanCollide)
		
		-- TODO: Add a (optional) developer exclusive EventKit invoke here to check if it should be skipped or not
		-- TODO: Consider a full override for developers as an option
		
		-- Recast
		return recast
	end;
	
	-- Return new StartPos and Direction from the provided StartPos, Radius, Direction and EndPos
	-- Note: a radius for a: normal ray - 0, cube - pythagorean theorem, shape - unused
	getShift = function(startPos: Vector3, radius: number, direction: Vector3, endPos: Vector3)
		local dirUnit = direction.Unit
		local distTraveled = (endPos - startPos):Dot(dirUnit)
		local shift = dirUnit * math.max(0, distTraveled - radius - .001)
		return startPos + shift, direction - shift
	end;
	
	getBlockedRadius = function(size: Vector3)
		return math.sqrt((size.X ^ 2) + (size.Y ^ 2) + (size.Z ^ 2)) * .5
	end;
	
	param = {
		setup = function(isIncludeList: boolean?, excludeList: {Instance}?, collisionGroup: string?, includeNonCollidable: boolean?): CustomParams
			local params = {}
			params.FilterType = Enum.RaycastFilterType:FromValue(isIncludeList and 1 or 0)
			params.FilterDescendantsInstances = excludeList or {}
			params.IgnoreWater = true
			params.CollisionGroup = collisionGroup or "Default"
			params.includeNonCollidable = includeNonCollidable or false
			return params
		end;
		
		toDefault = function(customParams: RayParams)
			if typeof(customParams) == `RaycastParams` then return customParams end
			local params = RaycastParams.new()
			for paramName, paramVal in pairs(customParams) do if string.upper(paramName:sub(1, 1)) ~= paramName:sub(1, 1) then continue end params[paramName] = paramVal end
			return params
		end;
		
		copyDefault = function(toCopyParams: RaycastParams)
			if typeof(toCopyParams) ~= `RaycastParams` then return toCopyParams end
			local params = RaycastParams.new()
			params.CollisionGroup = toCopyParams.CollisionGroup
			params.FilterType = toCopyParams.FilterType
			params.FilterDescendantsInstances = toCopyParams.FilterDescendantsInstances
			params.IgnoreWater = toCopyParams.IgnoreWater
			params.BruteForceAllSlow = toCopyParams.BruteForceAllSlow
			params.RespectCanCollide = toCopyParams.RespectCanCollide
			return params
		end;
	};
	
	ray = function(origin: Vector3, direction: Vector3, params: RayParams): RaycastResult?
		local origOrigin, origDirection = origin, direction
		local defaultParams = rkit._core.param.toDefault(params)
		local result
		for i = 1, recastCount do
			if direction.Magnitude == 0 then break end
			result = workspace:Raycast(origin, direction, defaultParams)
			if not rkit._core.recastCheck(result, params) then break end
			defaultParams:AddToFilter(result.Instance)
			origin, direction = rkit._core.getShift(origin, 0, direction, result.Position)
		end
		rkit._core.render.fire(`Ray`, origOrigin, origDirection, result and result.Position or (origOrigin + origDirection), params)
		return result
	end;

	sphere = function(origin: Vector3, radius: number, direction: Vector3, params: RayParams): RaycastResult?
		local origOrigin, origDirection = origin, direction
		local defaultParams = rkit._core.param.toDefault(params)
		local result
		for i = 1, recastCount do
			if direction.Magnitude == 0 then break end
			result = workspace:Spherecast(origin, radius, direction, defaultParams)
			if not rkit._core.recastCheck(result, params) then break end
			defaultParams:AddToFilter(result.Instance)
			origin, direction = rkit._core.getShift(origin, radius, direction, result.Position)
		end
		rkit._core.render.fire(`Sphere`, origOrigin, radius, origDirection, result and result.Position or (origOrigin + origDirection), params)
		return result
	end;
	
	block = function(cframe: CFrame, size: Vector3, direction: Vector3, params: RayParams): RaycastResult?
		local origCframe, origDirection = cframe, direction
		local defaultParams = rkit._core.param.toDefault(params)
		local result
		for i = 1, recastCount do
			if direction.Magnitude == 0 then break end
			result = workspace:Blockcast(cframe, size, direction, defaultParams)
			if not rkit._core.recastCheck(result, params) then break end
			defaultParams:AddToFilter(result.Instance)
			local origin = cframe.Position
			origin, direction = rkit._core.getShift(origin, rkit._core.getBlockedRadius(size), direction, result.Position)
			cframe = cframe.Rotation + origin
		end
		rkit._core.render.fire(`Block`, origCframe, size, origDirection, result and result.Position or (origCframe.Position + origDirection), params)
		return result
	end;
	
	shape = function(part: BasePart, direction: Vector3, params: RayParams): RaycastResult?
		local defaultParams = rkit._core.param.toDefault(params)
		local result
		if direction.Magnitude == 0 then return end
		for i = 1, recastCount do
			result = workspace:Shapecast(part, direction, defaultParams)
			if not rkit._core.recastCheck(result, params) then break end
			defaultParams:AddToFilter(result.Instance)
		end
		rkit._core.render.fire(`Shape`, part, direction, result and result.Position or (part.Position + direction), params)
		return result
	end;
}

local defaultParams: RayParams = rkit._core.param.setup()
-- By default, all raycasting ignores non-collidable Instances
rkit.setDefaultParams = function(params: RayParams)
	defaultParams = params
end

rkit.templateRenderToggle = rkit._core.render.toggle

-- Sets up parameters for Raycasting
rkit.getParams = function(isIncludeList, excludeList, collisionGroup, includeNonCollidable): CustomParams
	return rkit._core.param.setup(isIncludeList, excludeList, collisionGroup, includeNonCollidable)
end

-- Casts a Ray
rkit.ray = function(origin, direction, params: RayParams?)
	return rkit._core.ray(origin, direction, rkit._core.param.copyDefault(params or defaultParams))
end

-- Casts a Sphere
rkit.sphere = function(origin, radius, direction, params: RayParams?)
	return rkit._core.sphere(origin, radius, direction, rkit._core.param.copyDefault(params or defaultParams))
end

-- Casts a Block
rkit.block = function(cframe, size, direction, params: RayParams?)
	return rkit._core.block(cframe, size, direction, rkit._core.param.copyDefault(params or defaultParams))
end

-- Casts a custom Shape
-- As of right now, the shifting optimization is not applied for shapes
rkit.shape = function(part, direction, params: RayParams?)
	return rkit._core.shape(part, direction, rkit._core.param.copyDefault(params or defaultParams))
end

return rkit
