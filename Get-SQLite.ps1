Function Get-SQLite {
<#
    .SYNOPSIS 
        Excutes SELECT query on the database

    .DESCRIPTION
        Reads through the data, writing it to a DataTable Object. Finally closes the SQLiteDataReader Object.

	.INPUTS
        System.String

    .PARAMETER ReturnObject
        Outputs records line by line this way its more pipeline aware but with a decrease in speed
			
    .EXAMPLE
        PS C:\> Read-SQLite [-Connection] <SQLiteConnection> [-Query] <String>
	    Runs the query on database and returns <DataTable> object

    .EXAMPLE
        PS C:\> "SELECT * FROM sqlite_master WHERE type='table';" | Read-SQLite [-Connection] <SQLiteConnection> 
	    Runs the query on database and returns <DataTable> object

	.NOTES
	    Author: Proxx
	    Web:	www.Proxx.nl 
	    Date:	10-06-2015
			
    .LINK
        http://www.proxx.nl/Wiki/Read-SQLite
#>
    [OutputType("DataTable", ParameterSetName="Table")]
    [OutputType("Object[]", ParameterSetName="Object")]
	param(
		[Parameter(ParameterSetName="Table", Mandatory=$True, ValueFromPipeline=$false)]
        [Parameter(ParameterSetName="Object", Mandatory=$True, ValueFromPipeline=$false)]
            [System.Data.SQLite.SQLiteConnection] $Connection,
		[Parameter(ParameterSetName="Table", Mandatory=$True, ValueFromPipeline=$True)]
        [Parameter(ParameterSetName="Object", Mandatory=$True, ValueFromPipeline=$True)]
            [String]$Query,
        [Parameter(ParameterSetName="Object", Mandatory=$True, ValueFromPipeline=$True)]
            [Switch] $ReturnObject,
            [Hashtable] $Parameters
    )
	
	if ($Connection.State -ne "Open") { Throw "Connection has state: " + $Connection.State + ". the connection must be Open in order to proceed" }
    #$datatSet = New-Object System.Data.DataSet
    
    $Command = $Connection.CreateCommand()
    $command.CommandText = $Query
    Write-Host $Query
    if ($PSBoundParameters.ContainsKey("Parameters"))
    {
        ForEach($Param in $Parameters.GetEnumerator())
        {
            [Void] $Command.Parameters.Add([System.Data.SQLite.SQLiteParameter]::new($Param.Key, $Param.Value))
        }
    }

    if ($ReturnObject) 
    {

        $Reader = $command.ExecuteReader()

        if ($Reader.HasRows) 
        {
            $FieldCount = $Reader.FieldCount
            While($Reader.Read()) {
                $Object = New-Object -TypeName PSObject -Property @{}
                for ([int] $i = 0; $i -lt $FieldCount; $i++) { 
                    Add-Member -InputObject $Object -Name $Reader.GetName($i) -Value $Reader.GetValue($i) -MemberType NoteProperty -Force
                }
                Write-Output -InputObject $Object
            }
        }
    }
    Else
    {
        $dataAdapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter
        $dataAdapter.SelectCommand = $Command
        
	    $dataTable = New-Object -TypeName System.Data.DataTable 
	    #[void]$dataAdapter.Fill($datatSet)
	    [void]$dataAdapter.Fill($dataTable) 

	    return @(,($DataTable))
    }
}