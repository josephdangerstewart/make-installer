local totalFiles = 0
local filesDownloaded = 0

local titleText = "Installing application..."
local progressTemplate = "%s / %s files downloaded"

local function setTotalFiles(n)
	totalFiles = n
end

local function clearUI(isError)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1, 1)
	if not isError then
		print("Application is installed!")
	end
end

local function updateUI()
	local w, h = term.getSize()

	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
	term.clear()

	local progressText = string.format(progressTemplate, filesDownloaded, totalFiles)
	local titleTextLength = #titleText
	local progressTextLength = #progressText

	term.setCursorPos(w / 2 - titleTextLength / 2, h / 2 - 1)
	term.write(titleText)
	term.setCursorPos(w / 2 - progressTextLength / 2, h / 2)
	term.write(progressText)
end

local function getFile(filePath, urlBase)
	if fs.exists(filePath) then
		clearUI(true)
		error(filePath .. " already exists")
	end

	local response = http.get(urlBase .. filePath)
	local fileContent = response.readAll()
	response.close()

	local file = fs.open(filePath, "w")
	file.write(fileContent)
	file.close()

	filesDownloaded = filesDownloaded + 1
	updateUI()
end

local function makeDirOrThrow(dir)
	if dir == "/" then
		return
	end

	if fs.exists(dir) then
		clearUI(true)
		error(dir .. " already exists")
	else
		fs.makeDir(dir)
	end
end

updateUI()