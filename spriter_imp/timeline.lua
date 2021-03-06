--- Spriter timeline logic.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Standard library imports --
local tonumber = tonumber

-- Modules --
local object = require("spriter_imp.object")
local utils = require("spriter_imp.utils")

-- Exports --
local M = {}

-- --
local TimelineKey = utils.FuncTable()

--
function TimelineKey:bone (bprops, object_type)
  return object.LoadPass(bprops, object_type)
end

--
function TimelineKey:object (oprops, object_type)
	return object.LoadPass(oprops, object_type)
end

-- --
local UsageDefs = { box = "collision", point = "neither", entity = "display", sprite = "display" }

--- DOCME
-- @ptable timeline
-- @ptable animation
function M.LoadPass (timeline)
	local timeline_data, tprops = {}, timeline.properties

	--
	local object_type, usage = tprops.object_type or "sprite"

	if object_type ~= "sound" then
    -- Get usage if the object type supports it
    -- If not present, get default from UsageDefs
		if object_type ~= "variable" then
			usage = tprops.usage or UsageDefs[object_type]
		end

    -- Get name if this is not a sprite or sound
    -- OR if this is a sprite with usage "collision" or "both"
		if object_type ~= "sprite" or (usage == "collision" or usage == "both") then
			timeline_data.name = tprops.name
		end

    -- Get variable type if this is a variable
		if object_type == "variable" then
			timeline_data.variable_type = tprops.variable_type or "string"
		end
	end

	timeline_data.object_type = object_type
	timeline_data.usage = usage

	-- Get the keys in this timeline
	for _, key, kprops in utils.Children(timeline) do
		local key_data

		for _, child, cprops in utils.Children(key) do
			key_data = TimelineKey(child, cprops, object_type)
		end

		key_data.curve_type = kprops.curve_type or "linear"
		key_data.spin = tonumber(kprops.spin) or 1
		key_data.time = tonumber(kprops.time) or 0

		utils.AddByID(timeline_data, key_data, kprops)
	end

  return timeline_data
end

--- DOCME
-- @ptable data
-- @ptable animation
function M.Process (data, animation)
	for _, timeline_data in ipairs(animation) do
		for _, key_data in ipairs(timeline_data) do
			-- Resolve object properties (file, default values)
			if key_data.file then
				object.Process(data, key_data)

			-- TODO: bone, variable?
			else
				-- ??
			end
		end
	end
end

-- Export the module.
return M