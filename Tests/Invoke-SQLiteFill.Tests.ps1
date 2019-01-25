
Describe "Invoke-SQLiteFill" {
    BeforeAll {
        $conn = Connect-SQLite -Memory -Open
        Get-ChildItem | select Name, Length | New-SQLiteTable -Name cgi -AllText -Connection $conn -PassThru | Out-SQLiteTable -Connection $conn -Name cgi
    }
    It "Should not throw" {
        { $db = Get-SQLite -Connection $conn -Query "select * from cgi" -ReturnDataTable
        $test = $db.NewRow()
        $test.Name = "test"
        $test.Length = "length"
        $db.rows.Add($test)

        Invoke-SQLiteFill -Connection $conn -InputObject $db -Name cgi } | Should not Throw
    }
}


