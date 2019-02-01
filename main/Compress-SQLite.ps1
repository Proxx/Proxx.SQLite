Function Compress-SQLite { 
<#
    .SYNOPSIS
        Compress a Sqlite database file

    .DESCRIPTION
        Calls VACUUM on a Sqlite database to remove empty spaces and shrink the file.

    .EXAMPLE
        PS C:\> Compress-SQLite -Connection <SQLiteConnection>
	    		
        Shrinked database with 36,65 MB

    .EXAMPLE
        PS C:\> <SQLiteConnection> | Compress-SQLite
			
    Shrinked database with 36,65 MB

    .EXAMPLE
        PS C:\> $conn = Connect-SQLite -path "$env:temp\database.db" | Compress-SQLite -PassThru
			
        this will open the database run the Vacuum method and return the object to the variable $conn

    .INPUTS
        SQLiteConnection

    .NOTES
        Author: Proxx
        Web:	www.Proxx.nl 
        Date:	10-06-2015


    .LINK
        http://www.proxx.nl/Wiki/Compress-SQLite
#>
    [cmdletbinding(SupportsShouldProcess=$true)]
	Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
        [ValidateScript({
            if ($_ -is [System.Data.SQLite.SQLiteConnection]) { 
                if ($_.State -eq "Open"){ $true } else { Throw "Connection has state $($_.State)! Open connection first." } 
            } else { Throw "The argument is null, empty, or an element of the argument collection contains a null value. Supply a collection that does not contain any null values and then try the command again." }    
        })]
        [System.Data.SQLite.SQLiteConnection] $Connection,
        [Switch] $PassThru
    )

    $Location = $Connection.ConnectionString.Replace("Data Source = ","")
    if ($Location.ToLower() -ne ":memory:") {
	    $Pre = (Get-ChildItem -Path $Location).Length
	    $command = $Connection.CreateCommand()
	    $command.CommandText = "VACUUM;"
        if ($PSCmdlet.ShouldProcess($Location, "Compress")) { 
            try { [Void]$command.ExecuteNonQuery() }
	        Catch {	Write-Error -Message $_.Exception.Message }
	        Finally { $command.Dispose() }
            $Cur= (Get-ChildItem -Path $Location).Length
        }
    }
    else { Write-Warning -Message "cannot compress memory object" }
    if ($PassThru) { Return $Connection }
    Write-Output -InputObject ([PSCustomObject] @{
        Path = [String] $Location
        Shrinked = [int]($Pre - $Cur)
    })
}

