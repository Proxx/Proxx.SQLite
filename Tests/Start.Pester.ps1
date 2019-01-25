# This script will invoke pester tests
# It should invoke on PowerShell v2 and later
# We serialize XML results and pull them in appveyor.yml
# Based on: RamblingCookieMonster/PSDiskPart/master/Tests/appveyor.pester.ps1

#Initialize some variables, move to the project root
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResultsPS$PSVersion.xml"
    if ($ENV:APPVEYOR_BUILD_FOLDER) {
        $ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
    } else {
        $ProjectRoot = Split-Path $PSScriptRoot
    }
    Set-Location $ProjectRoot
 
Get-ChildItem -Path "$ProjectRoot\Tests\*.helper.ps1" | foreach { . $_ }

#Run a test with the current version of PowerShell
        "`n`tSTATUS: Testing with PowerShell $PSVersion`n"
    
Import-Module Pester
if (Get-Module -Name Proxx.SQLite) { Remove-Module Proxx.SQLite -Force }
Import-Module $ProjectRoot\Proxx.SQLite.psd1 -Force

Invoke-Pester -Path "$ProjectRoot\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru | Export-Clixml -Path "$ProjectRoot\PesterResults$PSVersion.xml"



#Show status...
$AllFiles = Get-ChildItem -Path $ProjectRoot\*Results*.xml | Select -ExpandProperty FullName
"`n`tSTATUS: Finalizing results`n"
"COLLATING FILES:`n$($AllFiles | Out-String)"

#Upload results for test page
if ($ENV:APPVEYOR_BUILD_FOLDER) {
    Get-ChildItem -Path "$ProjectRoot\TestResultsPS*.xml" | Foreach-Object {
        
        $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
        $Source = $_.FullName

        "UPLOADING FILES: $Address $Source"

        (New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )
    }
}

#What failed?
$Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Import-Clixml )
            
$FailedCount = $Results |
    Select -ExpandProperty FailedCount |
    Measure-Object -Sum |
    Select -ExpandProperty Sum
    
if ($FailedCount -gt 0) {

    $FailedItems = $Results |
        Select -ExpandProperty TestResult |
        Where {$_.Passed -notlike $True}

    "FAILED TESTS SUMMARY:`n"
    $FailedItems | ForEach-Object {
        $Test = $_
        [pscustomobject]@{
            Describe = $Test.Describe
            Context = $Test.Context
            Name = "It $($Test.Name)"
            Result = $Test.Result
        }
    } |
        Sort Describe, Context, Name, Result |
        Format-List

    throw "$FailedCount tests failed."
}