Function New-SQLiteTable {
 <#
    .SYNOPSIS 
    Create new SQLite table based on InputObject.

    .DESCRIPTION
    Create new SQLite table based on InputObject: <Object> or <DataTable>

    .INPUTS
    System.Object or System.Data.DataTable

	.PARAMETER AllText
		Sets Column types to TEXT instead of original type (ADO.net truncates decimals this is a way to prevent this)
        in most cases SQLite is smart enough to process TEXT field with numeric values as such ( 1(TEXT) + 1(TEXT)  = 2 and not "11")

	.PARAMETER Unique
		Sets Column as Unique in database.
				
	.EXAMPLE
        PS C:\> New-SQLiteTable -conn <SQLiteConnection> -InputObject <Object> -Name <TableName>
        Create Sqlite Table from InputObject with Name: <TableName>
			
	.EXAMPLE
        PS C:\> New-SQLiteTable -conn <SQLiteConnection> -InputObject <Object> -Name <TableName> -Unique <Unique column>
		Create Sqlite Table from InputObject with Name: <TableName> with Column <Unique column> as Unique.
			
	.EXAMPLE
        PS C:\> New-SQLiteTable -conn <SQLiteConnection> -InputObject <Object> -Name <TableName> -WhatIf
		Shows what Query would have been processed without really sending to database (Debug).
			
	.EXAMPLE
        PS C:\> $Object | New-SQLiteTable -conn <SQLiteConnection> -Name <TableName>
		Create Sqlite Table from Pipeline with Name: <TableName>

	.NOTES
		Author: Proxx
		Web:	www.Proxx.nl 
		Date:	10-06-2015
			
	.LINK
		http://www.proxx.nl/Wiki/New-SQLiteTable
#>

	Param(
		[Parameter(Mandatory=$False)][switch] $AllText,
		[Parameter(Mandatory=$True, ValueFromPipeline=$true)] $InputObject=$null,
		[Parameter(Mandatory=$True)] [String]$Name=$InputObject.TableName,
		[Parameter(Mandatory=$True)] [System.Data.SQLite.SQLiteConnection]$Connection=$null,
		[Parameter(Mandatory=$False)][Array] $Unique=$null,
		[Parameter(Mandatory=$False)][switch] $WhatIf,
		[Parameter(Mandatory=$False)][switch] $PassThru
	)
	
	
	Begin {
		$x = $false
		$Cols = New-Object -TypeName System.Text.StringBuilder 
		$dtExclude = @("RowError", "RowState", "Table",	"ItemArray", "HasErrors")
		$First = $true
       [Boolean] $Exists = $False
        $State = $True
		if ((Read-SQLite -Connection $Connection -Query "select name from sqlite_master WHERE type = 'table' AND name = '$name'").Name) { [Boolean] $Exists = $true }

	}
	Process {
		ForEach($Object in $InputObject) {
			if (!($Exists)) 
			{
				if ($First)
				{
					ForEach($Property in $Object.PSObject.Get_Properties()) {
						if ($Object.GetType().Name -eq "DataRow") { if ($dtExclude -contains $Property.Name) { Continue }}
						if ($x) { [Void]$Cols.Append(", ") }
						[Void]$Cols.Append("``" + $Property.Name.ToString() + "`` ")
						if ($AllText) { $Type = "TEXT " } Else { $Type = Convert-SQLiteType -Type $Property.TypeNameOfValue }
						if ($Unique -contains $Property.Name.ToString()) { [Void]$Cols.Append($Type + " UNIQUE") } Else { [Void]$Cols.Append($Type) }
						$x = $true
					}
					$Query = 'CREATE TABLE "{0}" ({1});'  -f $Name, $Cols.ToString()
					if ($WhatIf) { Return $Query }
					$Command = $Connection.CreateCommand()
					$Command.CommandText = $Query
                    Try { [Void]$Command.ExecuteNonQuery() } Catch { $State  = $false }
					
				}
				$First = $false
			}
			if ($PassThru) { Write-Output -NoEnumerate -InputObject $Object }
            else { Write-Output -InputObject $State }
		}
	}
}
