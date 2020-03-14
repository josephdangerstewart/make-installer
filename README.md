# make-installer

A simple project for creating installers for larger computercraft projects hosted in a github repository. This project was used to make its own installer. It's intended mostly for larger projects that are comprised of many files or that are on github anyways. **Your project must be in github in order to use this**

# Installation

To install, run the following command

`pastebin run 3grRYNhc`

# Usage

When you have your `package.lua` file written (see below), just run `make-installer.lua` and it will generate a file called `installer` which you can then publish to pastebin using `pastebin put installer`

## Package.lua

Make-installer depends on a file name `package.lua` being present which contains the data about which files should be downloaded by the generated installer. The file is just a simple lua table with the following shape

```lua
{
	name = "Your project name",
	author = "Your Display Name",
	files = {
		"filenamepattern",
	},
	ignoredFiles = {
		"filenamepattern",
	},
	githubUserName = "your-github-username",
	githubRepository = "your-repo-name",
	branch = "branch-name-to-install-from"
}
```

If you want to see an actual example, checkout the [`package.lua`](./package.lua) for this project.

### Properties

* `name` - This will be displayed as the project being installed in the installer GUI
* `author` *(optional- defaults to githubUserName)* - This will be displayed as the author of the project
* `files` - The list of files that will be downloaded from the github repository. It is a table of string [patterns](https://www.lua.org/pil/20.2.html) used to match file paths. So if you want to bundle an entire directory called `my-directory` you would add `"/my%-directory/.*"` and it will match every file contained in the directory. (Note that the "%" is added to escape "-" which is a reserved character for lua patterns)
* `ignoredFiles` *(optional)* - The opposite of `files`, it will exclude files paths that match any of the patterns in the table.
* `githubUserName` - The username on github that owns the repo to download from
* `githubRepository` - The name of the repository to download from
* `branch` *(optional- defaults to "master")* - The git branch that the files will be downloaded from
