local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local ecr = require("@packages/ecr")
local signal = require("@packages/signal")

local components = require(script.components)

export type System = {
	initializer: (registry: ecr.Registry) -> (delta: number) -> (),
	priority: number?,
}

local loop: signal.Signal<number> = signal()

local World = {}
World.registry = ecr.registry()

function World.start()
	RunService.Stepped:Connect(function(delta)
		loop:Fire(delta)
	end)

	local systems: { System } = {}

	for _, child in script.systems:GetChildren() do
		if not child:IsA("ModuleScript") then
			continue
		end

		local system = require(child) :: any

		if not system.priority then
			system.priority = 1
		end

		table.insert(systems, system)
	end

	table.sort(systems, function(a, b)
		if a.priority > b.priority then
			return true
		end
		return false
	end)

	for _, system in systems do
		local callback = system.initializer(World.registry)

		loop:Connect(callback)
	end

	local function tagged(instance: Instance)
		if not instance.Parent then
			return
		end
		if not instance:IsA("BasePart") then
			return
		end

		local entity = World.create(instance)
		instance:SetAttribute("id", entity)
	end

	local function untagged(entity: Instance)
		local id = entity:GetAttribute("id")
		if not id then
			return
		end
		if typeof(id) ~= "number" then
			return
		end

		World.registry:destroy(id)
	end

	CollectionService:GetInstanceAddedSignal("entity"):Connect(tagged)
	CollectionService:GetInstanceRemovedSignal("entity"):Connect(untagged)

	for _, instance in CollectionService:GetTagged("entity") do
		tagged(instance)
	end
end

function World.create(part: BasePart): number
	local entity = World.registry:create()
	World.registry:set(entity, components.part, part)
	return entity
end

function World.create_with_handle(part: BasePart): ecr.Handle
	local entity = World.create(part)
	return World.registry:handle(entity)
end

return World
