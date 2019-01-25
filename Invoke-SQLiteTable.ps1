Function Invoke-SQLiteTable {
 <#
    .SYNOPSIS 
        Bulk insert to SQLite Database

    .DESCRIPTION
        Bulk insert [System.Data.DataTable] to SQLite database using transaction.

    .INPUTS
        None. You cannot pipe objects to Invoke-SQLiteTable.

    .OUTPUTS
        Work in progress (maybe count of updates/inserts)

    .EXAMPLE
        PS C:\> Invoke-SQLiteTable [-conn] <SQLiteConnection> [-InputObject] <DataTable> [[-Name] <String>] 
	    Inserts or ignores records to database table.

    .EXAMPLE
        PS C:\> Invoke-SQLiteTable [-conn] <SQLiteConnection> [-InputObject] <DataTable> [[-Name] <String>] [[-Update] <Column>] 
        Inserts or ignores records then updates row where -Update <Column> = Row.Value
			
    .EXAMPLE
        PS C:\> Invoke-SQLiteTable [-conn] <SQLiteConnection> [-InputObject] <DataTable> [[-Name] <String>] [-Replace] 
        Inserts records or replaces row.
			
    .EXAMPLE
        PS C:\> Invoke-SQLiteTable [-conn] <SQLiteConnection> [-InputObject] <DataTable> [[-Name] <String>] [-WhatIf]
	    Shows import query, runs the import but rollsback the changes so no changes are made to database. (debug)

	.NOTES
	    Author: Proxx
	    Web:	www.Proxx.nl 
	    Date:	10-06-2015
			
    .LINK
        http://www.proxx.nl/Wiki/Invoke-SQLiteTable/
#>

	[cmdletbinding()]
	Param(
		[Parameter(
			Mandatory=$True,
			ValueFromPipeline=$False,
			HelpMessage='you need to associate a [System.Data.SQLite.SQLiteConnection] connection.'
		)][Alias('conn')][System.Data.SQLite.SQLiteConnection] $Connection = $null,
		[Parameter(
			Mandatory=$True,
			ValueFromPipeline=$False,
			HelpMessage='you need to specify a [System.Data.DataTable] to import.'
		)][Alias('Table')][System.Data.DataTable] $InputObject = $null
		,[String] $Name = $InputObject.TableName
		,[String] $Update = $null
		,[Switch] $Replace
		,[Switch] $Progress
		,[Switch] $Whatif
	)
	Begin {
		Write-Verbose -Message "Checking connection state"
		if ($Connection.State -ne "Open") { throw "connection is not open!"} 
		Write-Verbose -Message "Checking if table exists"
		if (((Read-SQLite -Connection $Connection -Query "SELECT name FROM sqlite_master WHERE type = 'table' AND name = '$Name'").Name).Count -lt 1) { Throw "Table ($Name) not found. you need to create a table before importing the data." }
		$Command = $Connection.CreateCommand()
		Write-Verbose -Message "Starting Transaction"
		$Transaction = $Connection.BeginTransaction()
		$Columns = $InputObject.Columns.ColumnName
		$Names = New-Object -TypeName System.Text.StringBuilder
		$Params = New-Object -TypeName System.Text.StringBuilder
		$UpdParams = New-Object -TypeName System.Text.StringBuilder
		$x = $false
		Write-Verbose -Message "Creating command text"
		ForEach($Column in $Columns) { 
			[Void]$command.Parameters.Add((New-Object -TypeName System.Data.SQLite.SQLiteParameter -ArgumentList ("@" + $Column.Replace(".",""))))
			if ($x)	{ 
				[Void]$Names.Append(", ``" + $Column + "``")
				[Void]$Params.Append(", @" + $Column.Replace(".",""))
				[Void]$UpdParams.Append(', "' + $Column + '" = @' + $Column.Replace(".",""))
			} else { 
				[Void]$Names.Append("``" + $Column + "``")
				[Void]$Params.Append("@" + $Column.Replace(".",""))
				[Void]$UpdParams.Append('"' + $Column + '" = @' + $Column.Replace(".",""))
				$x = $true 
			}
		}
		if ($Replace) { 
			$Insert = "INSERT OR REPLACE INTO " + $Name + " (" + $Names.ToString() + ") VALUES (" + $Params.ToString() + ");" 
		} Else { 
			$Insert = "INSERT OR IGNORE INTO " + $Name + " (" + $Names.ToString() + ") VALUES (" + $Params.ToString() + ");" 
		}
		if ($Update) {	$Insert += 'UPDATE "' + $Name + '" SET ' + $UpdParams.ToString() + " Where " + $Update + "=@" + $Update.Replace(".","") + ";"	} 
		$command.CommandText = $Insert
		if($Progress) { 
			[int]$Total = $InputObject.Rows.Count
			Write-Progress -Activity "Inserting rows to table: $Name" -Status "Processing:"
			$Sw = [System.Diagnostics.Stopwatch]::StartNew()
			[int]$c = 0
		}
		Write-Verbose -Message "Prepare Command"
		$command.Prepare()
		if ($Whatif) { $command.CommandText }
		Write-Verbose -Message "Importing DataTable to Sqlite"
	}
	Process {
		ForEach($Row in $InputObject.Rows) {
			ForEach($Column in $Columns) { 
				$Value = ($Row.$Column)
				if ($Value.GetType().Name -eq "DateTime") { $Value = $Value.ToString("yyyy-MM-dd HH:mm:ss")  }
				elseif ($Value.GetType().Name -eq "String") { $Value = $Value.Replace("'","''") }
				$command.Parameters["@" + $Column.Replace(".","")].Value = $Value
			}
			Try { [Void]$command.ExecuteNonQuery() } Catch { Write-Error -Message $_.Exception.Message; $command.CommandText }
			if ($Progress) { $c++;  if ($Sw.ElapsedMilliseconds -gt 1000) { $Sw.Restart(); Write-Progress -Activity "Inserting rows to table: $Name" -Status "Processing: ($c/$Total)" -PercentComplete ($c/$Total*100) }}
		}
	}
	End {
		if ($Whatif) { Write-Verbose -Message "Rollback transaction"; $Transaction.Rollback() } Else { Write-Verbose -Message "Commit transaction"; $Transaction.Commit() }
		if ($Progress) { $Sw.Stop(); Write-Progress -Activity "Inserting rows to table: $Name" -Status "Processing:" -PercentComplete 100 -Completed }
	}
}	
