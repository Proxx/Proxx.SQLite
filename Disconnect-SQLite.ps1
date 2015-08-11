Function Disconnect-SQLite {
<#
            .SYNOPSIS 
            Disconnects from database file

            .DESCRIPTION
			Disconnects from database file and disposes connection.

			.INPUTS
            <SQLiteConnection>
			
            .OUTPUTS
           	None.

            .EXAMPLE
            PS C:\> Disconnect-SQLite <System.Data.SQLite.SQLiteConnection>
			
            .EXAMPLE
            PS C:\> Disconnect-SQLite -Connection <System.Data.SQLite.SQLiteConnection> -Dispose
			Close the connection and disposes the object.

            .EXAMPLE
            PS C:\> <SQLiteConnection> | Disconnect-SQLite

			.NOTES

			Author: Proxx
			Web:	www.Proxx.nl 
			Date:	10-06-2015
			 
            .LINK
            http://www.proxx.nl/Wiki/Disconnect-SQLite
#>
	Param([Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)][System.Data.SQLite.SQLiteConnection]$Connection, [Switch]$Dispose)
	$Connection.Close()
	if ($Dispose) { $Connection.Dispose() }
}
