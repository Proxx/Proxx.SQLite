Function Out-SQLiteTable {
 <#
    .SYNOPSIS 
        Imports data to SQLite table

    .DESCRIPTION
	    Imports data to SQLite table,
        Accepts both values from pipe or direct.
	    Works with DataTable and objects.

    .EXAMPLE
        PS C:\> $Object | Out-SQLiteTable -Connection $Conn -Name TableName 
	    Inserts Object to table from Pipeline

    .EXAMPLE
        PS C:\> Out-SQLiteTable -conn $conn -InputObject $DataTable -Name TableName -Update ColumnName 
        Inserts or ignores records then updates row where -Update <Column> = Row.Value
			
    .EXAMPLE
        PS C:\> Out-SQLiteTable -conn $conn -InputObject $DataTable -Name TableName
        Inserts records or replaces row.
	
    .NOTES	
	    Author: Proxx
	    Web:	www.Proxx.nl 
	    Date:	10-06-2015
			
    .LINK
        http://www.proxx.nl/Wiki/Out-SQLiteTable
#>
	 [cmdletbinding(SupportsShouldProcess=$true)]
	Param(
		[Parameter(
			Mandatory=$True,
			HelpMessage='you need to associate [System.Data.SQLite.SQLiteConnection] connection.'
		)]
        [ValidateScript({if ($_.State -ne "Open"){ Throw "Connection is $($_.State). you need to open the connection!" } else { $true }})]
        [System.Data.SQLite.SQLiteConnection]$Connection,
		[Parameter(
			Mandatory=$True,
			ValueFromPipeline=$True,
			Position=0,
			HelpMessage='you need to specify an Object to import.'
		)]
		[PSObject[]]$InputObject
		,[String] $Name=$null
		,[String] $Update=$null
		,[Switch] $Replace
	)
	Begin { 
		$Insert = New-Object -TypeName System.Text.StringBuilder
		$Names = New-Object -TypeName System.Text.StringBuilder
		$Parameters = New-Object -TypeName System.Text.StringBuilder
		$UpdParams = New-Object -TypeName System.Text.StringBuilder
	
		#Exclude Datatable colums
		$dtExclude = @("RowError", "RowState", "Table",	"ItemArray", "HasErrors")

		Write-Verbose -Message "Begin Transaction"
        $Transaction = $Connection.BeginTransaction()
        Write-Verbose -Message "Create Command"
		$Command = $Connection.CreateCommand()
		$x = ''
		$First = $true
		$Row = $false
		[int] $Count = 0
		[int] $Errors = 0
	}
	Process {
		ForEach($Object in $InputObject) {
			ForEach($Property in $Object.PSObject.Get_Properties()) {
				if ($Row) { 
                    if ($dtExclude -contains $Property.Name) { Continue }
                }
				If ($First) 
                {
					if ($Object.GetType().Name -eq "DataRow") { $Row = $true }
					if ($Row) { 
                        if ($dtExclude -contains $Property.Name) { Continue }
                    }
					[Void]$command.Parameters.Add((New-Object -TypeName System.Data.SQLite.SQLiteParameter -ArgumentList ("@" + ($Property.Name.ToString()).Replace(".",""))))
					if ($x)	
                    { 
						[Void]$Names.Append(", ")
						[Void]$Parameters.Append(", ")
						[Void]$UpdParams.Append(', ')
					} 

					[Void]$Names.Append('{0}"{1}"' -f $x, $Propery.Name.toString())
					[Void]$Parameters.Append('{0}@{1}' -f $x, $Property.Name.ToString().Replace('.', ''))
					[Void]$UpdParams.Append('{0}"{1}" = @{2}' -f $x, $Property.Name.toString(), $Property.Name.ToString()).Replace(".","")
					$x = ', '

				}
				if ($Property.Value -isnot [System.DBNull] -and $null -ne $Property.Value) 
                { 
					if ($Property.TypeNameOfValue -eq "System.DateTime") { $Value = ($Property.Value).ToString("yyyy-MM-dd HH:mm:ss")  }
					Elseif ($Property.TypeNameOfValue -eq "System.String") { $Value = ($Property.Value).Replace("'","''") }
					Else { $Value = $Property.Value.ToString() }
				} 
                Else { $Value = [DBNull]::Value }
				$command.Parameters["@" + ($Property.Name.ToString()).Replace(".","")].Value = $Value
			}
			if ($First) 
            {
				if ($Replace) { $Insert = 'INSERT OR REPLACE INTO "' + $Name + '" (' + $Names.ToString() + ") VALUES (" + $Parameters.ToString() + ");"} 
				Else { 			$Insert = 'INSERT OR IGNORE INTO "' + $Name + '" (' + $Names.ToString() + ") VALUES (" + $Parameters.ToString() + ");" }
				if ($Update) {	$Insert += 'UPDATE "' + $Name + '" SET ' + $UpdParams.ToString() + " Where " + $Update + "=@" + $Update.Replace(".","") + ";"	} 
				Write-Verbose -Message "Prepare Command"
				$command.CommandText = $Insert
				$command.Prepare()
			}
			$First = $false
			$Count++
			if ($PSCmdlet.ShouldProcess('Out-SQLiteTable', 'Execute'))
			{
				Try { [Void]$command.ExecuteNonQuery() } Catch { $Errors++; Write-Error -Message $_.Exception.Message; $command.CommandText }
			}
			else
			{
				$Insert
			}
			
		}
	}
	End {
        Write-Verbose -Message "Total: $Count Errors: $Errors"
		if ($PSCmdlet.ShouldProcess("Transaction", "Commit")) { 
            Write-Verbose -Message "Commit transaction"
			$Transaction.Commit()
            $Transaction.Dispose() 
        }
        Else 
        { 
            Write-Verbose -Message "Rollingback transaction"
            $Transaction.Rollback()
            $Transaction.Dispose() 
        }
	}
}
