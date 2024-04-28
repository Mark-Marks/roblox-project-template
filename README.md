# Roblox Project Template

A personal template for Roblox games.
Based on [grillme99's template](https://github.com/grilme99/roblox-project-template).

## Features

### Tools

-   [aftman](https://github.com/LPGhatguy/aftman), a toolchain manager
-   [lune](https://github.com/lune-org/lune), a standalone Luau runtime\
        As an alternative to keeping multiple versions of the same script to allow for cross platform use.
-   [pesde](https://github.com/daimond113/pesde), a modern package manager\
        Q: Why not wally?\
        A: Wally is borderline unmaintained, and pesde fixes all of the issues I personally have with Wally, such as lack of type support.
-   [darklua](https://github.com/seaofvoices/darklua), a Lua code transformer\
        As a way to remove dead code and allow for string requires.
-   [stylua](https://github.com/JohnnyMorganz/stylua), an opiniotated Lua code formatter
-   [selene](https://github.com/kampfkarren/selene), a Lua linter
-   [luau-lsp](https://github.com/JohnnyMorganz/luau-lsp), a Luau language server
        Q: Why not <\x>?\
        A: Luau Lsp uses Luau's own type system, instead of creating a new one.
-   [rojo](https://github.com/rojo-rbx/rojo), a code syncing tool
-   [zap](https://github.com/red-blox/zap), a modern Roblox networking cli
        Q: Why not <\x>?\
        A: The networking library / utility you want to use is all up to you.\
        Personally, I chose zap due to the ease of use and the extremely performant & bandwidth optimized code it generates, alongside full type support.\
        As an alternative that's a library instead of a cli, I recommend [ffrostfall's bytenet](https://github.com/ffrostflame/bytenet).
-   [Github Workflows](https://docs.github.com/en/actions/using-workflows), for easy CI pipelines

### Libraries

-   [ECR](https://github.com/centau/ecr), a sparse-set based ECS library
-   [keyForm](https://github.com/ffrostflame/keyform), a fully typed and maintained datastore library for Roblox
        Q: Why not <\x>?\
        A: I picked keyForm for it's active maintenance and out of the box type support.\
        I'd use ProfileService, if not for it's huge codebase and requirement to write a wrapper around it for a decent experience (and the lack of support for types without using a fork).
-   [framework](https://gist.github.com/Mark-Marks/dfa3542de15f8d9605493fa01d4ef81c), a tiny module loader with lifecycles for Roblox

Each one of these libraries is built into the template.

### Scripts

-   `scripts/analyze.luau`, for full code analysis with luau-lsp
-   `scripts/build.luau`, to build a game file from the codebase
-   `scripts/dev.luau`, to continously build the codebase and start rojo synchronization
-   `scripts/install-packages.luau`, to install all dependencies

To use them, run them with lune:
`lune run SCRIPT_PATH`

## Installation

To install the template, clone this github repository.

```sh
git clone https://github.com/mark-marks/roblox-project-template.git
```

Next, change the name of the project and it's scope in the following places:

-   pesde.yaml
-   default.project.json
-   build.project.json

## Usage

### String Requires

As mentioned before, darklua allows us to use string requires when developing for Roblox.\
This means than when requiring a module, you use the path relative to your scripting environment, not to the datamodel:

```lua
-- Normal requires
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local keyform = require(ReplicatedStorage.packages.keyform)

local ServerScriptService = game:GetService("ServerScriptService")
local data = require(ServerScriptService.services.data)
```

```lua
-- String requires without aliases
local keyform = require("packages/keyform")

local data = require("src/server/services/data")
```

```lua
-- String requires with aliases
local keyform = require("@packages/keyform")

local data = require("@services/data")
```

The only exception to this is when you're trying to require a child of the script you're currently working in.\
In vscode, the structure for a module with children looks like this:

```
module
 - init.luau
 - child_a.luau
 - child_b.luau
 - child_c.luau
```

Because of this, Luau thinks that the children are not children, but siblings of the module.

To solve this, you need to require like normal:

```lua
local child_a = require(script.child_a)
```

This template has the following require aliases:

-   `@packages` -> `packages/`
-   `@client` -> `src/client/`
-   `@controllers` -> `src/client/controllers/`
-   `@shared` -> `src/shared/`
-   `@server` -> `src/server/`
-   `@services` -> `src/server/services/`
-   `@components` -> `src/server/services/world/components`\
        Note: this leads directly to the `components` ModuleScript, not to a directory called `components`.\
        This is for easier access to components inside of ECS systems.

### Modules

All modules in `src/server/services/` and `src/client/controllers/` are automatically loaded by their respective main script using the framework.

To get started with creating a new module, create a new file ending with `.luau` inside one of the directories, and fill out this boilerplate:

```lua
local ModuleName = {}

function ModuleName.start()

end

return ModuleName
```

The start function will be ran by the framework, making it the start point for your module.

For example, to create a service that prints `Hello, World!` on the server, create a file named `hello_world.luau` under `src/server/services/`, and add this code:

```lua
local HelloWorld = {}

function HelloWorld.start()
    print("Hello, World!")
end

return HelloWorld
```

Now, if you test your game, `Hello, World!` should pop up in the developer console.

### Data

This template automatically handles loading, saving with keyForm and data replication with zap.\
To modify the default data for each player, you need to modify two files:

1. `src/services/data/template.luau`
    ```lua
    local template = {
        -- default data here
    }
    ```
2. `net.zap`
   `cfg
type PlayerData = struct {
    -- type of the data, following https://zap.redblox.dev/config/types.html
}
`
   And generate the zap files with `zap net.zap`

For example, if you wanted to add the player's time played and coins, you'd modify the files as following:

```lua
-- src/services/data/template.luau
local template = {
    seconds_played = 0,
    coins = 0,
}
```

```cfg
-- net.zap
type PlayerData = struct {
    seconds_played: u32,
    coins: u32
}
```

To modify the player's existing data, create a transform and call it:

```lua
local data = require("@services/data")

local increment_seconds_played = data.create_transform(function(data)
    data.seconds_played += 1
    return data
end)

while true do
    task.wait(1)
    increment_seconds_played(PLAYER)
end
```

You can also add arguments to the transform, to for example increment by a specific amount:

```lua
local data = require("@services/data")

local give_coins = data.create_transform(function(data, coins: number)
    data.coins += coins
    return data
end)

give_coins(PLAYER, 50)
```

### ECS

Before you start, read [ECR documentation](https://centau.github.io/ecr/tut/crash-course.html) to get a good understanding of it.

This template's ECS implementation is based around ECR and systems.

Systems are ran every Heartbeat, and modify the game state based on the state captured within the ECS.\
For example, let's create a system that updates the position of every entity, based on it's velocity:

```lua
-- src/server/services/world/systems/update_position.luau
local components = require("@components")
local ecr = require("@packages/ecr") -- for types

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
```

This system will:

1. Run every Heartbeat (every frame)
2. Increment the position of the entity with it's velocity multiplied by delta time so FPS doesn't matter
3. Update the position of the part bound to the entity

Systems can also have a priority, the lower it is the later it runs:

```lua
return {
    initializer = system,
    priority = 1, -- runs the latest
}

return {
    initializer = system,
    priority = 999, -- runs the earliest
}
```

### Networking

Before you start, read the [Zap documentation](https://zap.redblox.dev/intro/what-is-zap.html) to get a good understanding of it.

This template's networking is entirely based around Zap.

Zap is type safe, fast and boasts about 10x less bandwidth than just managing & firing RemoteEvents.

To use Zap, first create an event. For example:

```cfg
-- net.zap
event message = {
    from: Server, -- this event is Server -> Client
    type: Reliable, -- this event uses an unreliable RemoteEvent
    call: ManyAsync, -- this event can have multiple listeners
    data: string -- this event's payload is a string
}
```

Next, regenerate the zap outputted scripts:

```sh
zap net.zap
```

And finally, use the events:

```lua
-- server
local Players = game:GetService("Players")

local zap = require("@server/zap")

Players.PlayerAdded:Connect(function(player)
    zap.message.fire(player, "Hello, World!")
end)
```

```lua
-- client
local zap = require("@client/zap")

zap.message.on_event(function(message)
    print(message)
end)
```
