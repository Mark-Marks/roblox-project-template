--!nocheck
local fs = require("@lune/fs")
local process = require("@lune/process")

if fs.metadata("Packages").exists == false then
	process.spawn("lune", {
		"run",
		"scripts/install-packages.luau",
	})
end

process.spawn("rojo", {
	"sourcemap",
	"default.project.json",
	"-o",
	"sourcemap.json",
})

process.spawn("curl", {
	"-O",
	"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau",
})

process.spawn("luau-lsp", {
	"analyze",
	"--definitions=globalTypes.d.luau",
	"--base-luaurc=src/.luaurc",
	"--sourcemap=sourcemap.json",
	"--settings=.vscode/settings.json",
	"--no-strict-dm-types",
	"--ignore Packages/**/*.lua",
	"--ignore Packages/**/*.luau",
	"src/",
})
