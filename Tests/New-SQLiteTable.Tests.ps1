Get-childitem -path $PSScriptRoot -include "*.Helper.ps1" | ForEach { . $_ }


Describe "New-SQLiteTable" {
    BeforeAll {
        $Location = Join-Path $TestDrive database.db
        $conn = Connect-SQLite -Database $Location -Open
        $Data = Get-RandomList -Count 100
    }
    AfterAll {
        $Conn.Close()
        $conn.Dispose()
        Remove-Variable -Name conn
    }
    It "should not throw" {
        { $Data | New-SQLiteTable -Connection $conn -Name Test } | Should Not Throw
    }
    it "returns True on success" {
        $Data | New-SQLiteTable -Connection $conn -Name Test | Should Be $true
    }
    Context "PassThru" {
        BeforeAll {
            $Location = Join-Path $TestDrive database.db
            $conn = Connect-SQLite -Database $Location -Open
            $Data = Get-RandomList -Count 100
        }
        AfterAll {
            $Conn.Close()
            $conn.Dispose()
            Remove-Variable -Name conn
        }
        it "shoud pass all values trough the pipe" {
            Compare-Object -DifferenceObject ($Data | New-SQLiteTable -Connection $conn -Name Test -PassThru) -ReferenceObject $Data | Should BeNullOrEmpty
        }
    }
}













<#

    New-sqlitable
        should not throw
        passthru
            outputs unmodified data
        AllText
            







#>