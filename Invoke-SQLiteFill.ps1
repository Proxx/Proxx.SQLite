Function Invoke-SQLiteFill {
<#
            .SYNOPSIS 
            Bulk insert <DataTable> to SQLite Table.
			WARNING: this will overwrite all Rows in table

            .DESCRIPTION
            Bulk insert <DataTable> to SQLite Table.
			WARNING: this will overwrite all Rows in table

            .INPUTS
            None. You cannot pipe objects to Invoke-SQLiteFill.

            .OUTPUTS
           	Count of rows inserted to SQLite Table

            .EXAMPLE
            PS C:\> Invoke-SQLiteFill -conn <SQLiteConnection> -InputObject <DataTable> -Name <String>
			Fills Table in SQLite (WARNING: this will overwrite all Rows in table)
			
            .EXAMPLE
            PS C:\> Invoke-SQLiteFill -conn <SQLiteConnection> -InputObject <DataTable> -Name <String> -WhatIf
			Creates SQLite transaction inserts rows and then rollsback the transaction

			.NOTES

			Author: Proxx
			Web:	www.Proxx.nl 
			Date:	10-06-2015
			 
            .LINK
            http://www.proxx.nl/Wiki/Invoke-SQLiteFill
#>
	Param(
		[cmdletbinding()]
		[Parameter(Mandatory=$true)] [System.Data.SQLite.SQLiteConnection] $Connection, 
		[Parameter(Mandatory=$true)] [System.Data.DataTable] $InputObject,
		[Parameter(Mandatory=$true)] [System.String] $Name,
		[Parameter(Mandatory=$false)][Switch] $Whatif
	)
	Write-Verbose -Message "Begin Transaction"
	$Transaction = $Connection.BeginTransaction()
	$Command = $Connection.CreateCommand()
	$Command.Transaction = $Transaction
	Write-Verbose -Message "Get database schema"
	$Command.CommandText = "SELECT * FROM " + $Name + " LIMIT 1"
	$Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter -ArgumentList $Command
	$commandBuilder = New-Object -TypeName System.Data.SQLite.SQLiteCommandBuilder -ArgumentList $Adapter
	$Adapter.InsertCommand = $commandBuilder.GetInsertCommand().Clone()
	$commandBuilder.DataAdapter = $null
	Write-Verbose -Message "Change the Added parameter for all rows to True"
	ForEach($Row in $InputObject.Rows) { $Row.SetAdded() }
	$Adapter.Update($InputObject)
	if ($Whatif) { Write-Verbose -Message "Revert all Changes (Rollback)"; $Command.Transaction.Rollback() } Else { $Command.Transaction.Commit() }
	$InputObject.AcceptChanges()
}
