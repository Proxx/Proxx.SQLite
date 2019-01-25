Function Write-SQLite {
<#
    .SYNOPSIS 
        Excutes query on the database

    .DESCRIPTION
        Excutes query on the database

	.INPUTS
        System.String
			
    .EXAMPLE
        PS C:\> Write-SQLite [-Connection] <SQLiteConnection> [-Query] <String>
	    Runs the query on database and return $true or $false

    .EXAMPLE
        PS C:\> Write-SQLite [-Connection] <SQLiteConnection> [-Query] <String> -Whatif
	    Runs the query on database then rollsback the transaction.

	    WARNING: Whatif only works with "INSERT, UPDATE, and DELETE"!!!!!!
			
	.NOTES
	    Author: Proxx
	    Web:	www.Proxx.nl 
	    Date:	10-06-2015

    .EXAMPLE
        PS C:\> "INSERT INTO TABLE_NAME (column1, column2, column3,...columnN) VALUES (value1, value2, value3,...valueN);" | Write-SQLite [-Connection] <SQLiteConnection> 
			
    .LINK
        http://www.proxx.nl/Wiki/Write-SQLite
#>
    [OutputType([System.Boolean])]
	Param(
		[cmdletbinding()]
		[Parameter(Mandatory=$true)][System.Data.SQLite.SQLiteConnection]$Connection,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]$Query,
		[Parameter(Mandatory=$false, ValueFromPipeline=$false)][Switch]$Whatif
	)
	

	if ($Connection.State -ne "Open") { Throw "Connection has state: " + $Connection.State + ". the connection must be Open in order to proceed" }
	if ($Whatif) {
		if ($Query -like "*DROP TABLE*" -OR $Query -like "*CREATE TABLE*") { Throw "Whatif parameter cannot be used with DROP or CREATE statements." }
		$Transaction = $Connection.BeginTransaction() 
	}
	$command = $Connection.CreateCommand()
	$command.CommandText = $Query
	$Result = $true
	if ($Transaction)
	{
		$Transaction = $Connection.BeginTransaction()
	}
	try { [Void] $command.ExecuteNonQuery() }
	Catch {	$Result = $false; Write-Error -Message $_.Exception.Message }
	Finally { 
		if ($Whatif) { $Transaction.Rollback() } Else { $Transaction.Commit() }
		$command.Dispose() 
	}
	Return $Result
}
