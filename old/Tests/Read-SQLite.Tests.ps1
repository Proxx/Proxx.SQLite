Describe "Read-SQL" {
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
    It "should not throw" {
        { Read-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 3;"  } | Should Not Throw
    }
    It "returns datatable type" {
        (Read-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 3;") -is [System.Data.DataTable] | Should Be $true
    }
    It "datatable should contain 20 rows" {
        (Read-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 20;").Rows.Count | Should Be 20
    }
    it "should throw when connection is not SQLiteConnection type" {
        { Read-SQLite -connection "test" -Query "" } | Should Throw
    }
    Context "ReturnObject" {
        BeforeAll {
            $conn = Connect-SQLite -Memory -Open
            Write-SQLite -Connection $conn -Query "CREATE TABLE a (x TEXT, y, z);"
            $trans = $conn.BeginTransaction()
            1..20 | %{ Write-SQLite -Connection $conn -Query "INSERT INTO a ('x','y','z') VALUES ('1','2','3');" | Out-Null }
            $trans.Commit()
        }
        AfterAll {
            $conn.close()
            $conn.Dispose()
            Remove-Variable -name conn -Force
        }
        it "returns Object when switch ReturnObject is used" {
            (Read-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 3;" -ReturnObject) -is [System.Object] | Should Be $true
        }
        it "should read 20 rows from table" {
            (Read-SQLite -Connection $conn -Query "SELECT x FROM A LIMIT 20;" -ReturnObject).Count | Should Be 20
        }
    }
}
