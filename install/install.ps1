#
# 'Borrowed' and adapted from posh-git installer. 
# Many thanks to Keith Dahlby and co for that piece of awesome.
#
param([switch]$WhatIf = $false)

# Adapted from http://www.west-wind.com/Weblog/posts/197245.aspx
function Get-FileEncoding($Path) {
    $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)

    if(!$bytes) { return 'utf8' }

    switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0],$bytes[1],$bytes[2],$bytes[3]) {
        '^efbbbf'   { return 'utf8' }
        '^2b2f76'   { return 'utf7' }
        '^fffe'     { return 'unicode' }
        '^feff'     { return 'bigendianunicode' }
        '^0000feff' { return 'utf32' }
        default     { return 'ascii' }
    }
}

function Update-ProfileWith($ScriptFile){
    $profileLine = ". '$ScriptFile'"
    if(Select-String -Path $PROFILE -Pattern $profileLine -Quiet -SimpleMatch) {
        Write-Host "$ScriptFile already sourced in profile, skipping..."
        return
    }

    Write-Host "Adding $ScriptFile to profile..."
@"
$profileLine
"@ | Out-File $PROFILE -Append -WhatIf:$WhatIf -Encoding (Get-FileEncoding $PROFILE)

}

if(!(Test-Path $PROFILE)) {
    Write-Host "Creating PowerShell profile...`n$PROFILE"
    New-Item $PROFILE -Force -Type File -ErrorAction Stop -WhatIf:$WhatIf > $null
}

$installDir = Join-Path (Split-Path $PROFILE -Parent) "DanstukenPS"
if(!(Test-Path $installDir)){
    Write-Host "Creating install folder...$installDir"
    New-Item $installDir -Type directory -ErrorAction Stop -WhatIf:$WhatIf > $null
}

#copy in/update the scripts
get-childitem  ..\src | foreach { 
    Copy-Item $_.FullName $installDir -Force -WhatIf:$WhatIf
    $installedFile = Join-Path $installDir $_.Name
    Update-ProfileWith $installedFile
}

Write-Host 'Scripts sucessfully installed!'
Write-Host 'Please reload your profile for the changes to take effect:'
Write-Host '    . $PROFILE'