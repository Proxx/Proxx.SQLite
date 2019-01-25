Describe "Connect-SQLite" {
    BeforeAll {
        $conn = Connect-SQLite -Memory -Open
    }
    AfterAll {
        $conn.close()
        $conn.Dispose()
        Remove-Variable -name conn -Force
    }
    It "does not Throw" {
        {Connect-SQLite -Memory -Open} | Should Not Throw
    }
    Context "Memory object" {
        BeforeAll {
            $conn = Connect-SQLite -Memory -Open
        }
        AfterAll {
            $conn.close()
            $conn.Dispose()
            Remove-Variable -name conn -Force
        }
        It "creates a sqlite connection object" {
            $conn -is [System.Data.SQLite.SQLiteConnection] | Should Be $true
        }
        
        It "has state 'Open'" {
            $conn.State | Should Be 'Open'
        }
        it "is connected to Memory database" {
            $conn.ConnectionString | Should Be "Data Source = :Memory:"
        }
    }
    Context "File object" {
        BeforeAll {
            $Location = Join-Path $TestDrive database.db 
            $conn = Connect-SQLite -Database $Location -Open
        }
        AfterAll {
            $conn.close()
            $conn.Dispose()
            Remove-Variable -name conn -Force
        }
        It "creates a sqlite connection object" {
            $conn -is [System.Data.SQLite.SQLiteConnection] | Should Be $true
        }
        
        It "has state 'Open'" {
            $conn.State | Should Be 'Open'
        }
        it "is connected to file database" {
            $conn.ConnectionString | Should Be "Data Source = $Location"
        }
    }
}
