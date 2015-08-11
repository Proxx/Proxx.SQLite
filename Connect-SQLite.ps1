Function Connect-SQLite {
<#
            .SYNOPSIS 
            Connect to SQLite Database file

            .DESCRIPTION
            Creates a SQLiteConnection Object.

			.INPUTS
            None. You cannot pipe objects to Connect-SQLite

            .OUTPUTS
           	<SQLiteConnection>

            .EXAMPLE
            PS C:\> $conn = Connect-SQLite -Database <FilePath>

            .EXAMPLE
            PS C:\> $conn = Connect-SQLite -Database <FilePath> -Open
			PS C:\> $conn
			
			PoolCount         : 0
			ConnectionString  : Data Source = D:\database.db
			DataSource        : database
			Database          : main
			DefaultTimeout    : 30
			ParseViaFramework : False
			Flags             : Default
			DefaultDbType     : 
			DefaultTypeName   : 
			OwnHandle         : True
			ServerVersion     : 3.8.6
			LastInsertRowId   : 0
			Changes           : 0
			AutoCommit        : True
			MemoryUsed        : 69631
			MemoryHighwater   : 69673
			State             : Open
			ConnectionTimeout : 15
			Site              : 
			Container         : 
			
			.EXAMPLE
			PS C:\> $conn = Connect-SQLite -Open
			When run in Script the database file is located in $PSscriptRoot with the name: database.db
			But if you run this from Console the database file is located in $pwd location
			
            .EXAMPLE
            PS C:\> $conn = Connect-SQLite -Database :MEMORY:
			(creates a SQLite database in memory)

			.NOTES

			Author: Proxx
			Web:	www.Proxx.nl 
			Date:	10-06-2015
			 
            .LINK
            http://www.proxx.nl/Wiki/Connect-SQLite
#>
	
	Param(
        [String] $Database=$null,
        [Switch] $Open
    )

	if (!$Database)
    {
        if ($MyInvocation.PSScriptRoot) {
            $Database = Join-path -Path $MyInvocation.PSScriptRoot -ChildPath "database.db"
        }
        else
        {
            $Database = Join-path -Path $PWD.Path -ChildPath  "database.db"
        }
    }
    else
    {
        if (!(Test-Path -Path $Database -PathType Leaf)) {
            Throw "you must specify a valid database path"
        }
    }
	
	$connStr = "Data Source = $database"
	$conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection -ArgumentList $connStr
	if ($Open) { $conn.Open() }
	Return $conn
}
