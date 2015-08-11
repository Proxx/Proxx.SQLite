Function Compress-SQLite { 
	<#
		.SYNOPSIS
			Compress a Sqlite database file

		.DESCRIPTION
			Calls VACUUM on a Sqlite database to remove empty spaces and shrink the file.

		.EXAMPLE
			PS C:\> Compress-SQLite -Connection <SQLiteConnection>
			
			Shrinked database with 36,65 MB

		.EXAMPLE
			PS C:\> <SQLiteConnection> | Compress-SQLite
			
			Shrinked database with 36,65 MB

		.INPUTS
			SQLiteConnection

		.OUTPUTS
			System.String

		.NOTES
			Returns: Shrinked database with <int> MB

		Author: Proxx
		Web:	www.Proxx.nl 
		Date:	10-06-2015


		.LINK
			http://www.proxx.nl/Compress-SQLite
	#>
	Param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Data.SQLite.SQLiteConnection]$Connection)

	if ($Connection.State -ne "Open") { Throw "Connection has state: $Connection.State. Open connection first." }
	$dbpre = (Get-ChildItem -Path $Connection.ConnectionString.Split("=").Trim()[1]).Length
		
	$command = $Connection.CreateCommand()
	$command.CommandText = "VACUUM;"
	try { [Void]$command.ExecuteNonQuery() }
	Catch {	Write-Error -Message $_.Exception.Message }
	Finally { $command.Dispose() }
	Return "Shrinked database with {0}" -f (Convert-Size -Size ($dbpre - (Get-ChildItem -Path $Connection.ConnectionString.Split("=").Trim()[1]).Length))
}
