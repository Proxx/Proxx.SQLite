Describe "Write-SQLite" {

    BeforeAll {
        $conn = Connect-SQLite -Memory -Open
    }
    AfterAll {
        $conn.close()
        $conn.Dispose()
        Remove-Variable -name conn -Force
    }
    It "should return Boolean values" { 
        Write-SQLite -Connection $conn -Query 'CREATE TABLE a (x TEXT, y, z);' -Bool | Should Be $true
        Write-SQLite -Connection $conn -Query 'CREATE TABLE b (x TEXT, y, z);' -Bool | Should Not Be $false
    }
    it "should throw when connection is not SQLiteConnection type" {
        { Write-SQLite -connection "test" -Query "" } | Should Throw
    }
    Context "Closed connection" {
        BeforeAll {
            $conn = Connect-SQLite -Memory
        }
        AfterAll {
            $conn.Dispose()
            Remove-Variable -Name conn -Force
        }
        It "Should throw when connection is not open" {
            { Write-SQLite -Connection $conn -Query "" } | Should Throw
        }
    }

}
