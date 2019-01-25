Function Invoke-SQLiteFill {
<#
    .SYNOPSIS 
        Bulk insert <DataTable> to SQLite Table.
	    WARNING: this will overwrite all Rows in table

    .DESCRIPTION
        Bulk insert <DataTable> to SQLite Table.
	    WARNING: this will overwrite all Rows in table

    .INPUTS
        System.Data.DataTable

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
    [cmdletbinding(SupportsShouldProcess=$true)]
	Param(
		[Parameter(Mandatory=$true)] 
            [System.Data.SQLite.SQLiteConnection] $Connection, 
		[Parameter(Mandatory=$true)] 
            [System.Data.DataTable] $InputObject,
		[Parameter(Mandatory=$true)] 
            [System.String] $Name
	)
    if ($PSCmdlet.ShouldProcess("Database","Begin Transaction")) { 
	    $Transaction = $Connection.BeginTransaction()
    }
	$Command = $Connection.CreateCommand()
	$Command.Transaction = $Transaction
    if ($PSCmdlet.ShouldProcess("Database", "GetSchema")) 
    {
    	$Command.CommandText = "SELECT * FROM " + $Name + " LIMIT 1"
	    $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter -ArgumentList $Command
	    $commandBuilder = New-Object -TypeName System.Data.SQLite.SQLiteCommandBuilder -ArgumentList $Adapter
	    $Adapter.InsertCommand = $commandBuilder.GetInsertCommand().Clone()
	    $commandBuilder.DataAdapter = $null
        if ($PSCmdlet.ShouldProcess("Database", "Update")) 
        {
            ForEach($Row in $InputObject.Rows) { if ($Row.RowState -eq "Unchanged") { [Void] $Row.SetAdded() }}
	        [Void] $Adapter.Update($InputObject)
	        if ($PSCmdlet.ShouldProcess("Database", "Transaction Commit")) 
            { 
               $Command.Transaction.Commit() 
            } 
            else
            {
                Write-Verbose -Message 'Performing the operation "Transaction Rollback" on target "Database".'
                $Command.Transaction.Rollback()
            }
	        $InputObject.AcceptChanges()
        }
        else { Write-Verbose -Message "Operation Cancelled at Users Request" }
    }
    else { Write-Verbose -Message "Operation Cancelled at Users Request" }
}
