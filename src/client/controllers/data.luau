local types = require("@shared/util/types")
local zap = require("@client/zap")

export type Data = zap.PlayerData

local Data = {}
Data.data = types.none() :: types.Option<Data>

function Data.start()
	zap.replicate_data.on(function(data)
		Data.data = types.some(data)
	end)
end

return Data
