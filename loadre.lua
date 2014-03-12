loadre = {_version = "1.0.1"}

local classname = "class"
-- the name you registered middleclass under, e.g.
-- class = require("middleclass")


local loadremixin = {
	Loadre = function(self, ...)
		loadre.makeSnapshot(self, unpack{...})
	end,

	__reload = function(self)
		loadre.pasteSnapshot(self)
	end,
}
local function _deepcopy_(t, seen)
	local seen = seen or {}
	local ttype = type(t)
	local copy

	if ttype == "table" then
		if seen[t] then return seen[t] else seen[t] = t end

		copy = {}

		for key, value in next, t, nil do
			copy[_deepcopy_(key, seen)] = _deepcopy_(value, seen)
		end

		setmetatable(copy, _deepcopy_(getmetatable(t), seen))
	else
	    copy = t
	end

	return copy
end

function loadre.init()
	assert(lurker, "lurker is required for loadre to work")

	loadre.snapshots 	= {}
	loadre.classlist	= {} 

	lurker.postswap = loadre.reload

	return loadremixin
end

function loadre.makeSnapshot(class, ...)
	-- called when the class first initializes

	for i, ref in ipairs(loadre.classlist) do
		if ref == class then
			table.remove(loadre.classlist, i)
		end
	end

	table.insert(loadre.classlist, class)
	loadre.snapshots[class] = {}
	loadre.snapshots[class].data = _deepcopy_(class)
	loadre.snapshots[class].args = {...}
end
function loadre.checkSnapshot(class, snap)
	local changes = {}

	for name, data in pairs(class) do
		if not snap[name] or data ~= snap[name] then
			if (type(data) == "table") then
				changes[name] = _deepcopy_(data)
			else
				changes[name] = data
			end
		end
	end

	return changes
end
function loadre.pasteSnapshot(class)
	if not loadre.snapshots[class] then return end

	local start = _deepcopy_(loadre.snapshots[class].data)
	local change = loadre.checkSnapshot(class, start)
	local new = {}

	class.class.initialize(class, unpack(loadre.snapshots[class].args))

	for k,v in pairs(class) do
		if v ~= start[k] then
			change[k] = v
		end
	end

	for k,v in pairs(change) do
		class[k] = v
	end
end

function loadre.reload()
	for _, class in ipairs(loadre.classlist) do
		loadre.pasteSnapshot(class)
	end
end

return loadre.init()
