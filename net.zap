opt server_output = "src/server/zap.luau"
opt client_output = "src/client/zap.luau"
opt casing = "snake_case"

type PlayerData = struct {}

event replicate_data = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: PlayerData
}
