Describe "Compress-SQLite" {
    BeforeAll {
        $Location = Join-Path $TestDrive database.db
        $conn = Connect-SQLite -Open -Database $Location
    }
    AfterAll {
        $conn | Disconnect-SQLite -Dispose
        Remove-Variable -Name conn -Force
    }
    it "should not Throw" {
        Compress-SQLite -Connection $conn
    }
    it "returns an object" {
        (Compress-SQLite -Connection $conn) -is [Object] | Should Be $true
    }
    it "Contains Path property with value as string" {
        (Compress-SQLite -Connection $conn).Path -is [int] | Should not be $true
    }
    it "contains Shrinked property with value as integer" {
        (Compress-SQLite -Connection $conn).Shrinked -is [int] | Should be $true
    }
    Context "Passthru" {
        it "return sqlite connection object" {
            ($conn | Compress-SQLite -passthru) -is [System.Data.SQLite.SQLiteConnection] | Should Be $true
        }
    }
}