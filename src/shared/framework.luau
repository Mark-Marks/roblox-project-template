export type Singleton = {
	start: (() -> ())?,

	[string]: any,
}

local Framework = {}
Framework.modules = {} :: { ModuleScript }
Framework.started = false

function Framework.add_module(module: ModuleScript)
	table.insert(Framework.modules, module)
end

function Framework.add_modules(parent: Folder)
	for _, child in parent:GetChildren() do
		if not child:IsA("ModuleScript") then
			continue
		end

		table.insert(Framework.modules, child)
	end
end

function Framework.start()
	local start = os.clock()

	for _, module in Framework.modules do
		local singleton = require(module) :: Singleton
		if not singleton.start then
			continue
		end

		singleton.start()
	end

	local took = os.clock() - start

	print(`✅ Took {took}s to load {#Framework.modules} modules`)
end

return Framework
