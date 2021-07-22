Function Get-SQLiteVersion {
    [CmdletBinding()]
    Param(
        $Path="$PSScriptRoot\..\System.Data.SQLite.dll"
    )

    (([reflection.assembly]::LoadFile("$PSScriptRoot\..\System.Data.SQLite.dll") | 
        Select-Object -ExpandProperty FullName) -split ', ' |
                Where-Object { $_ -like 'Version*' }) -replace 'Version=', ''
}