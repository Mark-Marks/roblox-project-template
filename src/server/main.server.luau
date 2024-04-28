local ServerScriptService = game:GetService("ServerScriptService")
local framework = require("@shared/framework")

framework.add_modules(ServerScriptService.services)

framework.start()
