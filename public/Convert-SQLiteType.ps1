Function Convert-SQLiteType { 
<#
.Synopsis
   Converts PowerShell Types to SQLite type
#>
    [OutputType([String])]
    param(
        [Parameter(Position=0)]
        [String]$Type=$null
    ) 
 
 	[String]$Result = ""
 
	Switch($Type) {
		'Boolean' { [String]$Result = "BOOLEAN" }
		'Byte[]' { [String]$Result = "BLOB" } 
		'Byte' { [String]$Result = "BLOB" } 
		'Char' { [String]$Result = "TEXT" } 
		'Datetime' { [String]$Result = "DATETIME" } 
		'Decimal' { [String]$Result = "DECIMAL" }
		'Double' { [String]$Result = "INT" } 
		'Guid' { [String]$Result = "BLOB" } 
		'Int16' { [String]$Result = "INT" } 
		'Int32' { [String]$Result = "INT" } 
		'Int64' { [String]$Result = "INT" } 
		'Single' { [String]$Result = "NUMERIC" } 
		'String' { [String]$Result = "TEXT" } 
		'UInt16' { [String]$Result = "INT" } 
		'UInt32' { [String]$Result = "BIGINT" }
		'UInt64' { [String]$Result = "INT" }
		default { [String]$Result = "TEXT" }
	}
	Write-Output -InputObject $Result
}
