<#
.SYNOPSIS
    Test if all dependencies are met for using Proxx.SQLite PowerShell module
.DESCRIPTION
    Test dependencies
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

Function Test-SQLite {
    
    $Root = Resolve-Path "$PSScriptRoot\.."

    # Check if main dll is in the right place
    Write-Host -NoNewline -Object "File System.Data.SQLite.dll ... `t`t`t"
    if (Test-Path -Path "$Root\System.Data.SQLite.dll")
    {
        Write-Host -ForegroundColor Green 'Exists'
    }
    else
    {
        Write-Host -ForegroundColor Red 'Missing'
        $MissingSQLiteDLl = $true
    }
    Write-Host -NoNewline -Object "File SQLite.Interop.dll ... `t`t`t`t"
    if ($ENV:PROCESSOR_ARCHITECTURE -eq 'AMD64')
    {
        # check if the interop file exists
        if (Test-Path -Path "$Root\x64\SQLite.Interop.dll")
        {
            Write-Host -ForegroundColor Green "Exists"
        }
        else
        {
            Write-Host -ForegroundColor Red "Missing"
            #throw "Missing SQLite.Iterop.dll in $Root\x64\ `n Get the file from https://system.data.sqlite.org/"
            $MissingInterop = $true
        }
    }
    else
    {
        # check if the interop file exists
        if (Test-Path -Path "$Root\..\x86\SQLite.Interop.dll")
        {
            Write-Host -ForegroundColor Green "Exists"
        }
        else
        {
            Write-Host -ForegroundColor Red "Missing"
            $MissingInterop = $true
        }
    }
    Write-Host "SQLite version: $(Get-SQLiteVersion)"
    
    if ($Missing)
    {
        Write-Host -ForegroundColor Red "Missing some dependencies, you can download the packages from https://system.data.sqlite.org"
    }

}