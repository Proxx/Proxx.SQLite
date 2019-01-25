Function Get-SQLiteTable {
<#
    .Synopsis
       Gets all sqlite tables in database
    .DESCRIPTION
       Gets all sqlite tables in database
    .EXAMPLE
       PS C:\> Connect-SQLite -Database .\database.db -Open | Get-SQLiteTables   

       type     : table
       name     : TEST
       tbl_name : TEST
       rootpage : 2
       sql      : CREATE TABLE "TEST" (`Name` TEXT , `Length` TEXT )

	.NOTES
		Author: Proxx
		Web:	www.Proxx.nl 
		Date:	19-08-2015

    .LINK
        http://www.proxx.nl/Wiki/Get-SQLiteTable

#>
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
        [System.Data.SQLite.SQLiteConnection] $Connection
    )

    Write-Output -InputObject (Read-SQLite -Connection $Connection -Query "SELECT Type, Name, Tbl_Name, Rootpage, SQL FROM sqlite_master WHERE type='table'" -ReturnObject)
}

