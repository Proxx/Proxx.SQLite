Describe "SQLite Transactions" {
    BeforeAll {
        $Location = Join-Path $TestDrive database.db
        $conn = Connect-SQLite -Open -Database $Location
    }
    AfterAll {
        $conn | Disconnect-SQLite -Dispose
        Remove-Variable -Name conn -Force
    }
    It "Should not thow on New-SQLiteTransaction" {
        $transaction = New-SQLiteTransaction -Connection $conn
    }
    It "Should not throw when using pipeline input" {
        $conn | New-SQLiteTransaction
    }
    It "Should not throw on Complete-SQLiteTransaction" {
        Complete-SQLiteTransaction -Transaction $($conn | New-SQLiteTransaction)
    }
    It "Should not throw when using pipeline input" {
        $conn | New-SQLiteTransaction | Complete-SQLiteTransaction
    }
    It "Should not throw on Undo-SQLiteTransaction" {
        Undo-SQLiteTransaction -Transaction $($conn | New-SQLiteTransaction)
    }
    It "Should not throw when using pipeline input" {
        Undo-SQLiteTransaction -Transaction $($conn | New-SQLiteTransaction)
    }
}