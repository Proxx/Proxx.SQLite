Function Out-SQLiteTable {
 <#
            .SYNOPSIS 
            Creates a <SQLiteTable> from an object

            .DESCRIPTION
			Creates a <SQLiteTable> from an object,
            Accepts both values from pipe or direct.
			Works with DataTable and objects.

            .INPUTS
            <Object[]> or <DataTable>

            .OUTPUTS
            Success and Error count

            .EXAMPLE
            PS C:\> <Object> | Out-SQLiteTable [-Connection] <SQLiteConnection> [[-Name] <String>] 
			Inserts Object to table from Pipeline

            .EXAMPLE
            PS C:\> Out-SQLiteTable [-conn] <SQLiteConnection> [-InputObject] <DataTable> [[-Name] <String>] [[-Update] <Column>] 
            Inserts or ignores records then updates row where -Update <Column> = Row.Value
			
            .EXAMPLE
            PS C:\> Out-SQLiteTable [-conn] <SQLiteConnection> [-InputObject] <DataTable> [[-Name] <String>] [-Replace] 
            Inserts records or replaces row.
			
            .EXAMPLE
            PS C:\> Import-SQLiteTable [-conn] <SQLiteConnection> [-InputObject] <DataTable> [[-Name] <String>] [-WhatIf]
			Shows import query, runs the import but rollsback the changes so no changes are made to database. (debug)
			
			.NOTES

			Author: Proxx
			Web:	www.Proxx.nl 
			Date:	10-06-2015
						
			
            .LINK
            http://www.proxx.nl/Wiki/Out-SQLiteTable
#>
	[cmdletbinding()]
	Param(
		[Parameter(
			Mandatory=$True,
			HelpMessage='you need to associate a [System.Data.SQLite.SQLiteConnection] connection.'
		)][System.Data.SQLite.SQLiteConnection]$Connection,
		[Parameter(
			Mandatory=$True,
			ValueFromPipeline=$True,
			Position=0,
			HelpMessage='you need to specify a [System.Data.DataTable] to import.'
		)]
		[PSObject[]]$InputObject
		,[String] $Name=$null
		,[String] $Update=$null
		,[Switch] $Replace
		,[Switch] $Whatif
		,[Switch] $Force
	)
	Begin { 
		$Insert = New-Object -TypeName System.Text.StringBuilder
		$Names = New-Object -TypeName System.Text.StringBuilder
		$Parameters = New-Object -TypeName System.Text.StringBuilder
		$UpdParams = New-Object -TypeName System.Text.StringBuilder
	
		#Exclude Datatable colums
		$dtExclude = @("RowError", "RowState", "Table",	"ItemArray", "HasErrors")
		
		Write-Verbose -Message "Checking connection state"
		if ($Connection.State -ne "Open") { throw "connection is not open!"} 

		Write-Verbose -Message "Creating command and starting Transaction"
		$Transaction = $Connection.BeginTransaction()
		$Command = $Connection.CreateCommand()
		$x = $false
		$First = $true
		$Row = $false
		[int] $Count = 0
		[int] $Errors = 0
	}
	Process {
		ForEach($Object in $InputObject) {
			ForEach($Property in $Object.PSObject.Get_Properties()) {
				if ($Row) { if ($dtExclude -contains $Property.Name) { Continue }}
				If ($First) {
					if ($Object.GetType().Name -eq "DataRow") { $Row = $true }
					if ($Row) { if ($dtExclude -contains $Property.Name) { Continue }}
					[Void]$command.Parameters.Add((New-Object -TypeName System.Data.SQLite.SQLiteParameter -ArgumentList ("@" + ($Property.Name.ToString()).Replace(".",""))))
					if ($x)	{ 
						[Void]$Names.Append(", ``" + $Property.Name.ToString() + "``")
						[Void]$Parameters.Append(", @" + ($Property.Name.ToString()).Replace(".",""))
						[Void]$UpdParams.Append(', "' + $Property.Name.ToString() + '" = @' + ($Property.Name.ToString()).Replace(".",""))
					} else { 
						[Void]$Names.Append("``" + $Property.Name.ToString() + "``")
						[Void]$Parameters.Append("@" + ($Property.Name.ToString()).Replace(".",""))
						[Void]$UpdParams.Append('"' + $Property.Name.ToString() + '" = @' + ($Property.Name.ToString()).Replace(".",""))
						$x = $true 
					}
				}
				if ($Property.Value -isnot [System.DBNull] -and $null -ne $Property.Value) { 
					if ($Property.TypeNameOfValue -eq "System.DateTime") { $Value = ($Property.Value).ToString("yyyy-MM-dd HH:mm:ss")  }
					Elseif ($Property.TypeNameOfValue -eq "System.String") { $Value = ($Property.Value).Replace("'","''") }
					Else { $Value = $Property.Value.ToString() }
				} Else { $Value = [DBNull]::Value }
				$command.Parameters["@" + ($Property.Name.ToString()).Replace(".","")].Value = $Value
			}
			if ($First) {
				if ($Replace) { $Insert = 'INSERT OR REPLACE INTO "' + $Name + '" (' + $Names.ToString() + ") VALUES (" + $Parameters.ToString() + ");"} 
				Else { 			$Insert = 'INSERT OR IGNORE INTO "' + $Name + '" (' + $Names.ToString() + ") VALUES (" + $Parameters.ToString() + ");" }
				if ($Update) {	$Insert += 'UPDATE "' + $Name + '" SET ' + $UpdParams.ToString() + " Where " + $Update + "=@" + $Update.Replace(".","") + ";"	} 
				Write-Verbose -Message "Prepare Command"
				$command.CommandText = $Insert
				$command.Prepare()
				if ($Whatif) { $command.CommandText }
			}
			$First = $false
			$Count++
			Try { [Void]$command.ExecuteNonQuery() } Catch { $Count--; $Errors++; Write-Error -Message $_.Exception.Message; $command.CommandText }
		}
	}
	End {
		Write-Verbose -Message "Success: $Count Errors: $Errors"
		if (!($Force) -and ($Errors -gt 0)) { $Whatif = $true }
		if ($Whatif) { Write-Verbose -Message "Rollback transaction"; $Transaction.Rollback() } Else { Write-Verbose -Message "Commit transaction"; $Transaction.Commit() }
	}
}
