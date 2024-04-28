local components = require("@components")
local ecr = require("@packages/ecr")

local function system(registry: ecr.Registry)
	return function(delta: number)
		for id, position: Vector3, velocity: Vector3, part: BasePart in
			registry:view(components.position, components.velocity, components.part)
		do
			local new_position = position + velocity * delta
			registry:set(id, components.position, new_position)
			part.Position = new_position
		end
	end
end

return {
	initializer = system,
}
