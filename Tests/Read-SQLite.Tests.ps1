Describe "Get-SQLite" {
    BeforeAll {
        $conn = Connect-SQLite -Memory -Open
        Write-SQLite -Connection $conn -Query "CREATE TABLE a (x TEXT, y, z);" | Out-Null
        $trans = $conn.BeginTransaction()
        1..20 | %{ Write-SQLite -Connection $conn -Query "INSERT INTO a ('x','y','z') VALUES ('1','2','3');" | Out-Null }
        $trans.Commit()
    }
    AfterAll {
        $conn.close()
        $conn.Dispose()
        Remove-Variable -name conn -Force
    }
    It "Should not throw" {
        { Get-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 3;"  } | Should Not Throw
    }
    It "Returns DataTable type" {
        (Get-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 3;" -ReturnDataTable) -is [System.Data.DataTable] | Should Be $true
    }
    It "Returns PSObject type" {
        (Get-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 3;") -is [System.Object] | Should Be $true
    }
    It "PSObject should contain 20 rows" {
        (Read-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 20;").Count | Should Be 20
    }
    it "Should throw when connection is not SQLiteConnection type" {
        { Read-SQLite -connection "test" -Query "" } | Should Throw
    }
    it "Should throw when connection is not Open" {
        $conn.Close()
        { Read-SQLite -connection $conn -Query "SELECT" } | Should Throw
    }
}
