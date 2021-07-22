
$Root = Split-Path $PSScriptRoot -Parent

$Path = "$Root\System.Data.SQLite.dll"



if (Test-Path $Path)
{
    Write-Verbose -Message "[Proxx.SQLite] Loading resource 'System.Data.SQLite.dll'" -Verbose
    Add-Type -Path "$Root\System.Data.SQLite.dll" -Verbose
}
else
{

    Write-Verbose -Message "[Proxx.SQLite] Initializing dependecies" -Verbose

    # get computer architecture
    $arch = $ENV:PROCESSOR_ARCHITECTURE

    # Write-Host "Check if path $Root\x64 exists"
    # if (-Not (Test-Path -PathType Container -Path "$Root\x64"))
    # {
    #     Write-Host "Creating missing directory '$Root\x64 exists'"
    #     New-Item -Path "$Root\x64" -ItemType Directory | Out-Null
    # }

    # Write-Host "Check if path $Root\x86 exists"
    # if (-Not (Test-Path -PathType Container -Path "$Root\x86"))
    # {
    #     Write-Host "Creating missing directory '$Root\x86 exists'"
    #     New-Item -Path "$Root\x86" -ItemType Directory | Out-Null
    # }
    
    # check if nuget source is installed
    $NugetSource = Get-PackageSource -Name nuget.org -ErrorAction SilentlyContinue
    if (-Not $NugetSource)
    {
        Write-Warning -Message "Nuget Package source not installed"

        Register-PackageSource -Name nuget.org -Location https://www.nuget.org/api/v2 -ProviderName NuGet
    }

    # check if the nuget provider is installed
    $NugetProvider = Get-PackageProvider -Name NuGet
    if (-Not $NugetProvider)
    {
        Write-Warning -Message "Nuget provider not installed"
        Install-PackageProvider -Name "Nuget"
    }

    # download System.Data.SQLite package.
    $Package = Install-Package -Destination $ENV:TEMP System.Data.SQLite.Core -Source NuGet.org -Force -ForceBootstrap -Verbose

    # get Package pathname
    $PackagePath = Join-Path $env:TEMP ($Package | Where-Object { $_.Name -Like "*Standard*"}).PackageFilename.replace('.nupkg', '')

    # select lates dotNet core System.Data.SQLite.dll
    $SQLiteDll = resolve-path "$PackagePath\lib\*\system.data.sqlite.dll" | Sort-Object -Property Path | Select-Object -Last 1

    # Copy System.Data.SQLite.dll
    Move-Item -Path $SQLiteDll -Destination $Root -Force -Verbose

    # create x64 folder
    New-Item -ItemType Directory "$Root\x64" -ErrorAction SilentlyContinue | Out-Null

    $x64Path = Join-Path -Path $PackagePath -ChildPath "\runtimes\win-x64\native\SQLite.Interop.dll"

    # move x86 lib to destination
    Move-Item -Path $x64Path -Destination "$Root\x86\" -Force -Verbose
  
    # create x86 folder
    New-Item -ItemType Directory "$Root\x86" -ErrorAction SilentlyContinue  | Out-Null

    $x86Path = Join-Path -Path $PackagePath -ChildPath "\runtimes\win-x86\native\SQLite.Interop.dll"

    # move x86 lib to destination
    Move-Item -Path $x86Path -Destination "$Root\x64\" -Force -Verbose

}

