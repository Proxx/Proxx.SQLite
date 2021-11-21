Function Install-SQLiteDepends {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param()


    # get computer architecture
    $arch = $ENV:PROCESSOR_ARCHITECTURE

    $Root = Resolve-Path -Path "$PSScriptRoot\..\"

    Write-Host "Check if path $Root\x64 exists"
    if (-Not (Test-Path -PathType Container -Path "$Root\x64"))
    {
        Write-Host "Creating missing directory '$Root\x64 exists'"
        New-Item -Path "$Root\x64" -ItemType Directory | Out-Null
    }

    Write-Host "Check if path $Root\x86 exists"
    if (-Not (Test-Path -PathType Container -Path "$Root\x86"))
    {
        Write-Host "Creating missing directory '$Root\x86 exists'"
        New-Item -Path "$Root\x86" -ItemType Directory | Out-Null
    }
    
    # check if nuget source is installed
    $NugetSource = Get-PackageSource -Name nuget.org
    if (-Not $NugetSource)
    {
        Write-Warning -Message "Nuget Package source not installed"
        Register-PackageSource -Name nuget.org -Location https://www.nuget.org/api/v2        
    }

    # check if the nuget provider is installed
    $NugetProvider = Get-PackageProvider -Name NuGet
    if (-Not $NugetProvider)
    {
        Write-Warning -Message "Nuget provider not installed"
        Install-PackageProvider -Name "Nuget"
    }

    # download System.Data.SQLite package.
    $Package = Install-Package -Destination $ENV:TEMP System.Data.SQLite.Core -Source NuGet.org

    # Get Package location
    if (-not $Package) { throw "System.Data.SQLite not returned by Nuget.Org" }
    $PackagePath = Join-Path $ENV:TEMP $Package.PackageFilename.Replace('.nupkg', '')

    # create x86 folder
    New-Item -ItemType Directory "$PSScriptRoot\x86" | Out-Null

    # move x86 lib to destination
    Move-Item -Path "$PackagePath\runtimes\win-x64\native\netstandard2.0\runtimes\win-x86\native\netstandard2.0" -Destination "$PSScriptRoot\x86\"
    
    # create x64 folder
    New-Item -ItemType Directory "$PSScriptRoot\x64" | Out-Null

    # move x64 lib to destination
    Move-Item -Path "$PackagePath\runtimes\win-x64\native\netstandard2.0\runtimes\win-x64\native\netstandard2.0" -Destination "$PSScriptRoot\x64\"

    # move lib to root of module
    Move-Item -Path "$PackagePath\lib\netstandard2.0\lib\netstandard2.0" -Destination $PSScriptRoot
}

