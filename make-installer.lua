-- First remove the existing installer if it exists
if fs.exists("installer") then
	fs.delete("installer")
end

-- Then get the list of files marked for bundling in package.lua
local includedFiles = {}
local urlBase
if fs.exists("package.lua") then
	local file = fs.open("package.lua", "r")
	local data = file.readAll()
	file.close()

	local package = textutils.unserialise(data)
	includedFiles = package.files
	urlBase = package.contentBaseUrl
end

-- Convinence function for detecting if a file is included for bundling
local function fileMatchesPattern(file, pattern)
	return string.match(file, pattern) == file
end
local function fileIsIncluded(file)
	local fileName = file
	if fs.isDir(file) then
		fileName = fileName .. "/"
	end
	for _,pattern in pairs(includedFiles) do
		if fileMatchesPattern(fileName, pattern) then
			return true
		end
	end
	return false
end

local function buildMapForDirectory(path)
	local listing = fs.list(path)
	local map = {
		dirName = path,
		files = {},
	}

	-- For each file in the path
	for i,v in pairs(listing) do
		-- that is not ignored
		if fileIsIncluded(path .. v) then

			-- first check if the file is a directory, if it is recursively
			-- build a map for it
			if fs.isDir(path .. v) then
				table.insert(map.files, buildMapForDirectory(path .. v .. "/"))
			else
				-- Otherwise, add it to the file map
				table.insert(map.files, v)
			end
		end
	end

	return map
end

local fileMap = buildMapForDirectory("/")

local totalFiles = 0
local function generateInstallerChunk(map)
	local code = "-- Chunk for \"" .. map.dirName .. "\"\nmakeDirOrThrow(\"" .. map.dirName ..  "\")\n"

	for i,v in pairs(map.files) do
		if type(v) == "string" then
			code = code .. "getFile(\"" .. map.dirName .. v .. "\", urlBase)\n"
			totalFiles = totalFiles + 1
		elseif type(v) == "table" then
			code = code .. generateInstallerChunk(v)
		end
	end

	return code
end

local generatedInstallerCode = generateInstallerChunk(fileMap)

local installerBaseFile = fs.open("installer-util/installer-base.lua", "r")
local installerBase = installerBaseFile.readAll()
installerBaseFile.close()

local file = fs.open("installer", "w")
file.write(installerBase .. "\n\nsetTotalFiles(" .. totalFiles .. ")\n\nlocal urlBase = \"" .. urlBase .. "\"\n\n" .. generatedInstallerCode .. "\n\nclearUI()\n\n")
file.close()
