Function Connect-SQLite {
<#
    .SYNOPSIS 
        Connect to SQLite Database file

    .DESCRIPTION
        Creates a SQLiteConnection Object.

    .EXAMPLE
        PS C:\> $conn = Connect-SQLite -Database <FilePath>

    .EXAMPLE
        PS C:\> $conn = Connect-SQLite -Database <FilePath> -Open
		PS C:\> $conn
			
		PoolCount         : 0
		ConnectionString  : Data Source = D:\database.db
		DataSource        : database
		Database          : main
		DefaultTimeout    : 30
		ParseViaFramework : False
		Flags             : Default
		DefaultDbType     : 
		DefaultTypeName   : 
		OwnHandle         : True
		ServerVersion     : 3.8.6
		LastInsertRowId   : 0
		Changes           : 0
		AutoCommit        : True
		MemoryUsed        : 69631
		MemoryHighwater   : 69673
		State             : Open
		ConnectionTimeout : 15
		Site              : 
		Container         : 
			
	.EXAMPLE
		PS C:\> $conn = Connect-SQLite -Open

		When run in Script the database file is located in $PSscriptRoot with the name: database.db
		But if you run this from Console the database file is located in $pwd location
			
    .EXAMPLE
        PS C:\> $conn = Connect-SQLite -Memory

		creates a SQLite database in memory

	.NOTES
		Author: Proxx
		Web:	www.Proxx.nl 
		Date:	10-06-2015
			 
    .LINK
        http://www.proxx.nl/Wiki/Connect-SQLite
#>
	[CmdletBinding(DefaultParameterSetName="Open")]
    [OutputType([System.Data.SQLite.SQLiteConnection])]
	Param(
        [ValidateScript({ 
            if (Test-Path -Path $_ -PathType Leaf) { $true }
            elseif ($_ -eq ":MEMORY:") { $true }
            elseif (Test-Path -Path (Split-Path -Path $_) -PathType Container) { $true }
        })]
        [Alias("Database")]
        [Parameter(ParameterSetName="File")]
        [String] $Path=$null,
        [Alias("Mem")]
        [Parameter(ParameterSetName="Memory")]
        [Switch] $Memory,
        [Parameter(ParameterSetName="File")]
        [Parameter(ParameterSetName="Memory")]
        [Parameter(ParameterSetName="Open")]
        [Switch] $Open
    )
    if ($Memory) 
    {
        $Path = ":Memory:"
            Write-Verbose -Message "Performing the operation 'Connect-SQLite' on target Memory."
    } 
    else
    {
        if (!$Path)
        {
            if ($MyInvocation.PSScriptRoot) { $Path = Join-path -Path $MyInvocation.PSScriptRoot -ChildPath "database.db" }
            else { $Path = Join-path -Path $PWD -ChildPath "database.db" }
        }
        Write-Verbose -Message "Performing the operation 'Connect' on target $Path."
    }

	$connStr = "Data Source = $Path"
	$conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection -ArgumentList $connStr
	if ($Open) {
        if ($Memory) { Write-Verbose -Message "Performing the operation 'Open' on Memory" }
        else { Write-Verbose -Message "Performing the operation 'Open' on $Path" }
        $conn.Open() 
    }
	Return $conn
}
