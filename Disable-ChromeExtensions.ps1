<#
  .SYNOPSIS
  Attempts to remove specified Chrome extension(s).
  .DESCRIPTION
  The Disable-ChromeExtensions.ps1 script takes comma separated extension codes as a parameter, searches
  the AppData\Local\Google\Chrome subdirectories for each Chrome profile for every user, and if it finds
  the specified extension(s) it deletes the folder.
  .PARAMETER ext
  Comma separated list of 32 character extension codes (ex: abcdefghijklmnopqrstuvwxyzabcdef,bcdefghijklmnopqrstuvwxyzabcdefg)
  .INPUTS
  None. You cannot pipe objects to Disable-ChromeExtensions.ps1.
  .OUTPUTS
  Results of attempted Chrome extension removal.
  .EXAMPLE
  PS> .\Disable-ChromeExtensions.ps1 -ext abcdefghijklmnopqrstuvwxyzabcdef
  .EXAMPLE
  PS> .\Disable-ChromeExtensions.ps1 -ext abcdefghijklmnopqrstuvwxyzabcdef,bcdefghijklmnopqrstuvwxyzabcdefg
#>

param(
    [Parameter(Mandatory=$true)]
    $ext = ""
)

$userdir = "$env:SystemDrive\Users\"
$users = Get-ChildItem $userdir
$cpuname = $env:COMPUTERNAME
$extensiontable = @()

$extarray = $ext.Split(",")

# Parse extensions in parameter
foreach($checkext in $extarray){
    if($checkext.length -ne 32){
        Write-Error "Extension $checkext is not 32 characters."
        Return
    }
}

# Check each user
Foreach($user in $users){
    $username_string = $user.Name
    $BaseDir = "$userdir$user\AppData\Local\Google\Chrome\User Data"

    Foreach($e in $extarray){
        try{
            # Find the specified extension folder inside \AppData\Local\Google\Chrome\User Data for each user. This works for multiple Chrome profiles. 
            $extensiondirs = Get-ChildItem $BaseDir -Recurse -Depth 2 -ErrorAction Stop | Where-Object { $_.PSIsContainer -and $_.Name.Equals($e) }
            if($extensiondirs.Exists){
                # Attempt to delete extension folder
                try{
                    Remove-Item $extensiondirs.FullName -Recurse -Force
                    $extensiontable += "Removed " + $extensiondirs.FullName
                }
                catch{
                    Write-Error "Deleting " + $extensiondirs.FullName + " failed."
                }
            }
        }
        catch{}
    }
}

# Output results
if($extensiontable.Length -gt 0){
    $extensiontable | ft
}
else{
    Write-Output "No matching extensions found."
}