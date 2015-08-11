Function Read-SQLite {
<#
            .SYNOPSIS 
            Excutes SELECT query on the database

            .DESCRIPTION
           	Reads through the data, writing it to a DataTable Object. Finally closes the SQLiteDataReader Object.

			.INPUTS
            <String>

            .OUTPUTS
           	<DataTable>
			
            .EXAMPLE
            PS C:\> Read-SQLite [-Connection] <SQLiteConnection> [-Query] <String>
			Runs the query on database and returns <DataTable> object

            .EXAMPLE
            PS C:\> "SELECT * FROM sqlite_master WHERE type='table';" | Read-SQLite [-Connection] <SQLiteConnection> 
			Runs the query on database and returns <DataTable> object

			.NOTES

			Author: Proxx
			Web:	www.Proxx.nl 
			Date:	10-06-2015
			
            .LINK
            http://www.proxx.nl/Wiki/Read-SQLite
#>
	param(
		[Parameter(Mandatory=$True, ValueFromPipeline=$false)][System.Data.SQLite.SQLiteConnection] $Connection
		,[Parameter(Mandatory=$True, ValueFromPipeline=$True)][String]$Query)
	
	if ($Connection.State -ne "Open") { Throw "Connection has state: " + $Connection.State + ". the connection must be Open in order to proceed" }
	#$datatSet = New-Object System.Data.DataSet
	$dataAdapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter -ArgumentList $Query,$Connection
	$dataTable = New-Object -TypeName System.Data.DataTable 
	#[void]$dataAdapter.Fill($datatSet)
	[void]$dataAdapter.Fill($dataTable) 

	return @(,($DataTable))
}
