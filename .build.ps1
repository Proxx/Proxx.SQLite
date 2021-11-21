[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string[]]$Tasks = "*"
)

$Script:Options = @{
    Name        = $($PSScriptRoot | Get-Item).Name
    Repository  = "PSKobe"
    Public      = "Public"
    FileList    = @( 
        "$BuildRoot\Public"
        "$BuildRoot\Private"
        "$BuildRoot\types"
    )
    Formats = "types"
    Destination = "G:\Mijn Drive\PowerShell\PSModule" | Get-Item
    Manifest    = Test-ModuleManifest -Path $(($PSScriptRoot | Get-Item).Name + ".psd1")
    UpdateModuleParameters = @{}
    OutputPath = $null
}

$Script:UpdatedParameters = @{}

# call the build engine with this script and return
if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    Invoke-Build validateOptions, * $MyInvocation.MyCommand.Path @PSBoundParameters 
    return
}

task validateOptions {

    @('Name', 'Repository', 'Public', 'Manifest', 'Destination') | ForEach-Object {
        if (-Not $Options.ContainsKey) { throw }
    }
}

Function Get-FunctionFromFile {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [System.IO.FileInfo] $FilePath = '.\public\Connect-ExchangeManagementShell.ps1'
    )
    
    Process {
        $Functions = @{}
        $ParsedFile = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$null, [ref]$null)
    
        forEach ($Statement in $ParsedFile.EndBlock.Statements) {
            if ($Statement.Name) {
                $ParamBlock = $Statement.Body.ParamBlock.Parameters
                $Parameters = @{}

                forEach ($Param in $ParamBlock) {
                    #$Param | Out-String | Write-Host
                    $Parameters.Item($Param.Name.ToString().substring(1)) = @{
                        DefaultValue = $Param.DefaultValue
                        Type         = $Param.StaticType
                    }

                }
                $Functions.Add($Statement.Name, $Parameters)
            }   
        }
        $Functions | Write-Output
    }
}

task FunctionsToExport {
    
    if (-Not $Options.Public) {
        throw
    }
    
    $PublicFunctions = Join-Path $BuildRoot -ChildPath $Options.Public | Get-ChildItem -Filter *.ps1 | Get-FunctionFromFile
    $ManifestFunctions = $Manifest.ExportedFunctions
    $NewFunctions = @()
    ForEach ($Function in $PublicFunctions.Keys) {
        if (-Not $ManifestFunctions) {
            Write-Build Green $("{0} not found in current module manifest" -f $Function)
        }
        else {
            Write-Build Green $("{0} found in current modulemanifest" -f $Function)
        }
        $NewFunctions += $Function
    }
    if ($NewFunctions)
    {
        $Script:UpdatedParameters['FunctionsToExport'] = $NewFunctions
    }
}
task FormatsToProcess {

    $FormatTypes = $()
    $FormatTypes += $BuildRoot | 
        Join-Path -ChildPath 'types' | 
        Join-Path -ChildPath "*.ps1xml" | 
        Resolve-Path -Relative -ErrorAction SilentlyContinue

    if ($FormatTypes)
    {
        $Script:UpdatedParameters['FormatsToProcess'] = $FormatTypes
    }
}

task UpdateVersion {

    $Manifest = $Options.Manifest
    $NewVersion = $Options.NextVersion

    $Version = $Manifest.Version
    $Now = [DateTime]::now

    Switch ($Version) {
        { $_.Major -ne $now.Year -or $_.Minor -ne $now.Month } { $build = 1 }
        default { $build = $Version.Build + 1 }
    }
    $NewVersion = [Version]::new($now.Year, $Now.Month, $build)

    Write-Host "$Version -> $NewVersion"
    $Script:UpdatedParameters['ModuleVersion'] = $NewVersion
}



Task FileList {
    
    $FileList = @()
    $FileList += Get-ChildItem "$BuildRoot\Public" -Recurse -ErrorAction SilentlyContinue | Resolve-Path -Relative
    $FileList += Get-ChildItem "$BuildRoot\Private" -Recurse -ErrorAction SilentlyContinue | Resolve-Path -Relative
    $FileList += Get-ChildItem "$BuildRoot\types" -Recurse -ErrorAction SilentlyContinue | Resolve-Path -Relative
    $FileList += Get-ChildItem "$BuildRoot\*" -Include *.psm1, *.psd1, LICENSE, README.md -ErrorAction SilentlyContinue | Resolve-Path -Relative
    if ($FileList)
    {
        $Script:UpdatedParameters['FileList'] = $FileList
    }
    
    
}

Task UpdateModuleManifest {
    $backupManifest = [System.IO.Path]::ChangeExtension($Options.Manifest.Path, "backup")

    Copy-Item $Options.Manifest.Path $backupManifest -Force
    try {
        Update-ModuleManifest -Path $Options.Manifest.Path @UpdatedParameters -ErrorAction Stop
    }
    catch {
        Write-Build Red "Update-ModuleManifest failed."
        Copy-Item -Path $backupManifest -Destination $Options.Manifest.Path -verbose
        Remove-item $backupManifest
        throw $_
    }

    $Script:UpdatedManifest = Test-ModuleManifest -Path $Options.Manifest.Path 
    
}
Task PrepareDestination {
    $DestinationExists = Test-Path -Path $options.Destination -PathType Container

    if (-Not $DestinationExists) { throw "$Destination path not found" }
    if (-Not $UpdatedManifest) { throw "No '`$options.NewManifest' variable found"}
    $Script:ModuleDestination = $options.Destination | Join-Path -ChildPath $UpdatedManifest.Name | Join-Path -ChildPath $UpdatedManifest.Version

    if (-Not (Test-Path -Path $Script:ModuleDestination -IsValid)) { throw "`$ModuleDestination: $Script:ModuleDestination not valid"}

    $Script:ModuleDestination | New-Item -Path $ModuleDestination -ItemType Directory -Force

}
Task Build {

    Copy-Item "$BuildRoot\Public"  -Recurse -Destination $Script:ModuleDestination -Force
    Copy-Item "$BuildRoot\Private" -Recurse -Destination $Script:ModuleDestination -Force
    Copy-Item "$BuildRoot\*" -Include *.psm1, *.psd1, LICENSE, README.md, *.dll -Destination $Script:ModuleDestination -Force

    if (Test-Path "$BuildRoot\types")
    {
        Copy-Item "$BuildRoot\types" -Recurse -Destination $Script:ModuleDestination -Force
    }
}

Task NewManifest {
    $ManifestFile = $UpdatedManifest | Split-Path -Leaf

    $OutputManifestPath = $ModuleDestination | Join-Path -ChildPath $ManifestFile

    $null = Test-ModuleManifest -Path  $OutputManifestPath
}

Task Publish {
    if (-Not $Options.Repository) { throw "No Repository in `$Options" }
    $Repository = "PSKobe"
    
    $NewModule = Import-Module -Name $UpdatedManifest.Name -Version $UpdatedManifest.Version -Global -PassThru
    #Publish-Module -Name $NewModule.Name -RequiredVersion $UpdatedManifest.Version -Repository $Repository
}
