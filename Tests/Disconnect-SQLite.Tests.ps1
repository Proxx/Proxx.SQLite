Describe "Disconnect-SQLite" {
    Context "Pipeline" {
        BeforeAll {
            New-Variable -Name conn -Scope Global -Value (Connect-SQLite -Memory -Open) -Force
        }
        AfterAll {
            if ($conn.State -eq 'Open') { $Global:conn.Close() }
            if ($conn.State -eq 'Closed') { $Global:conn.Dispose() }
            Remove-Variable -Name conn -Scope Global -ErrorAction SilentlyContinue -Force
        }
        It "closed piped object" {
            $Global:conn | Disconnect-SQLite
            $Global:conn.State | Should Be 'Closed'
        }
        It "disposed piped object" {
            $Global:conn | Disconnect-SQLite -Dispose
            $Global:conn.State | Should Be $null
        
        }
    }
    Context "InputObject" {
        BeforeAll {
            New-Variable -Name conn -Scope Global -Value (Connect-SQLite -Memory -Open) -Force
        }
        AfterAll {
            if ($conn.State -eq 'Open') { $Global:conn.Close() }
            if ($conn.State -eq 'Closed') { $Global:conn.Dispose() }
            Remove-Variable -Name conn -Scope Global -ErrorAction SilentlyContinue -Force
        }
        it "closed input object" {
            Disconnect-SQLite -Connection $Global:conn
            $Global:conn.State | Should Be 'Closed'
        }
        it "disposed input object" {
            Disconnect-sqlite -Connection $Global:conn -Dispose
            $Global:conn.State | Should Be $null
        }
    }
}