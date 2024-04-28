local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local keyform = require("@packages/keyform")
local signal = require("@packages/signal")
local types = require("@shared/util/types")
local zap = require("@server/zap")

local template = require(script.template)

local name = if RunService:IsStudio() then "studio_data" else "data"
local store = keyform.createStore(name, template)

local Data = {}
Data.keys = {} :: { [Player]: keyform.key<template.Data> }
Data.hook = signal() :: signal.Signal<Player, template.Data>

function Data.start()
	Players.PlayerAdded:Connect(function(player)
		local key = store:loadKey(`player_{player.UserId}`)
		Data.keys[player] = key

		local successful_lock = key:lockAsync()
		if successful_lock then
			return
		end

		player:Kick("Session locked")
	end)

	Players.PlayerRemoving:Connect(function(player)
		if Data.keys[player] then
			Data.keys[player]:unlock()
			Data.keys[player]:remove()
		end
	end)

	Data.hook:Connect(zap.replicate_data.fire)
end

function Data.create_transform<T...>(
	f: (Data: template.Data, T...) -> template.Data
): (player: Player, T...) -> types.Either<nil, string>
	local transform = store:createTransform(function(data, player, ...)
		local new = f(data, ...)
		Data.hook:Fire(player, new)
		return new
	end)

	return function(player, ...)
		local key = Data.keys[player]
		if not key then
			return types.right("Can't find the key for the given player.")
		end

		transform(key, player, ...)

		return types.left(nil)
	end
end

return Data
