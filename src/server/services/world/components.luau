local ecr = require("@packages/ecr")

return {
	part = ecr.component() :: BasePart,
	position = ecr.component() :: Vector3,
	velocity = ecr.component() :: Vector3,
}
