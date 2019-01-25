Describe "Write-SQLite" {

    BeforeAll {
        $conn = Connect-SQLite -Memory -Open
    }
    AfterAll {
        $conn.close()
        $conn.Dispose()
        Remove-Variable -name conn -Force
    }
    It "should return True" { 
        Write-SQLite -Connection $conn -Query 'CREATE TABLE a (x TEXT, y, z);' | Should Be $true
        Write-SQLite -Connection $conn -Query 'CREATE TABLE b (x TEXT, y, z);' | Should Not Be $false
    }
    it "should throw when connection is not SQLiteConnection type" {
        { Write-SQLite -connection "test" -Query "" } | Should Throw
    }

}
