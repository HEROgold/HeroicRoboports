
require("__heroic-library__.vars.words")
-- Add the replaceable_group to vanilla roboport
if data.raw[Roboport][Roboport] then
	data.raw[Roboport][Roboport].fast_replaceable_group = Roboport
	-- if "upgrade modded" then
	--     for a, b in pairs(data.raw[Roboport]) do
	--         data.raw[Roboport][a].fast_replaceable_group = a
	--     end
	-- end
end

