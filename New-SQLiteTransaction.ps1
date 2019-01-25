Function New-SQLiteTransaction {
<#
.Synopsis
   Begins SQLite Transaction.
.DESCRIPTION
   invoked method BeginTransaction on Connection object.
   returning the transaction object.
.EXAMPLE
   $Transaction = $conn | Start-SQLiteTransaction
.EXAMPLE
   $Transaction = Start-SQLiteTransaction -Connection $conn

.NOTES
   using the method 'begintransaction()' on the connection object is shorter
   but to make this module as complete as possible i added this function!
.LINK
    http://www.proxx.nl/Module/SQLite/
#>

    [OutputType([System.Data.SQLite.SQLiteTransaction])]
    Param(
        [ALias("conn")]
        [parameter(ValueFromPipeline=$true, mandatory=$true)]
        [System.Data.SQLite.SQLiteConnection] $Connection
    )

    Return $Connection.BeginTransaction()
}