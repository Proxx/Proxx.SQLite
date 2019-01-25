Function Get-SQLite {
<#
    .SYNOPSIS 
        Excutes SELECT query on the database

    .DESCRIPTION
        Reads through the data, writing it to a DataTable Object. Finally closes the SQLiteDataReader Object.

	.INPUTS
        System.String

    .PARAMETER ReturnDataTable
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
        [Parameter(ParameterSetName="Table", Mandatory=$True, ValueFromPipeline=$True)]
            [Switch] $ReturnDataTable,
        [Parameter(ParameterSetName="Table", Mandatory=$True, ValueFromPipeline=$True)]
        [Parameter(ParameterSetName="Object", Mandatory=$True, ValueFromPipeline=$True)]
            [Hashtable] $Parameters,

    )
	# Throw when there is no connection to database
	if ($Connection.State -ne "Open") { Throw "Connection has state: " + $Connection.State + ". the connection must be Open in order to proceed" }

    # Create SQLite command
    $Command = $Connection.CreateCommand()

    # add Query to command
    $command.CommandText = $Query

    if ($PSBoundParameters.ContainsKey("Parameters"))
    {
        ForEach($Param in $Parameters.GetEnumerator())
        {
            # add all defined parameters from hashtable to command.
            [Void] $Command.Parameters.Add([System.Data.SQLite.SQLiteParameter]::new($Param.Key, $Param.Value))
        }
    }

    # Return DataTable object instead of PSObject to pipe
    if ($ReturnDataTable)
    {
        # create SQLiteDataAdapter object
        $dataAdapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter

        # add command to adapter
        $dataAdapter.SelectCommand = $Command
        
        # create new empty DataTable object
	    $dataTable = New-Object -TypeName System.Data.DataTable 

        # fill DataTable with data returned by the adapter.
	    [void]$dataAdapter.Fill($dataTable) 

        # return
	    return @(,($DataTable))
    }
    Else
    {
        # Execute the command
        $Reader = $command.ExecuteReader()

        # check if the command returned any rows.
        if ($Reader.HasRows) 
        {
            $FieldCount = $Reader.FieldCount
            While($Reader.Read()) {
                # create empty PSObject
                $Object = New-Object -TypeName PSObject -Property @{}

                # loop trough fields
                for ([int] $i = 0; $i -lt $FieldCount; $i++) { 
                    # add members to PSobject
                    Add-Member -InputObject $Object -Name $Reader.GetName($i) -Value $Reader.GetValue($i) -MemberType NoteProperty -Force
                }
                # write output to pipe.
                Write-Output -InputObject $Object
            }
        }
    }
}