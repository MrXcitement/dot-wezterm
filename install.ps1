# install.ps1 -- Install the WezTerm config files

# Mike Barker <mike@thebarkers.com>
# June 23rd, 2023

# Install-Item - Install a file/folder to the user's home folder
Function Install-Item([string]$source, [string]$target) {

    # Backup the source file/folder, if it exists and is not a link
    if ((Test-Path $source) -And (-Not (Test-SymbolicLink $source))) {
        # backup the file/folder
        Write-Warning "Backup ${source} ${source}.backup"
        Move-Item -Path ${source} -Destination "${source}.backup"
    }

    # Create a symlink to the target file/folder, if it does not exist
    if (-Not (Test-Path $source)) {
        Write-Output "Linking: ${source} to ${target}"
        New-SymbolicLink $source $target | Out-Null
    }
}

# New-SymbolicLink - Create a new symbolic link file
Function New-SymbolicLink([string]$link, [string]$target) {
    New-Item -ItemType SymbolicLink -Path $link -Value $target -Force
}

# Test-Elevated - Test if the current powershell session is being run with elevated permisions
Function Test-Elevated() {
    return [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'
}

# Test-SymbolicLink - Test if the path is a symbolic link file
Function Test-SymbolicLink([string]$path) {
    $file = Get-Item $path -Force -ea SilentlyContinue
    Return [bool]($file.LinkType -eq "SymbolicLink")
}

# Verify the script is being run with elevated permisions
if ($IsWindows -And (-Not (Test-Elevated))) {
    throw "This script must be run 'Elevated' as an Administrator"
}

# Determine user's config path
if ($IsWindows) {
    $CONFIG_PATH = "${Env:userprofile}\.config"
} else {
    $CONFIG_PATH = "${Env:HOME}\.config"
}

# Link file/folders in config to users config directory
New-Item -Path $CONFIG_PATH -ItemType Directory -ErrorAction Ignore
Install-Item "$CONFIG_PATH\wezterm" "${PSScriptRoot}\home\.config\wezterm"
