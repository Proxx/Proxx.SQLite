Function Stop-SQLiteTransaction {
<#
.Synopsis
   End SQLite Transaction.
.DESCRIPTION
   invoked method Commit or Rollback on the transaction object.
.EXAMPLE
   $Transaction | Stop-SQLiteTransaction -Rollback
.EXAMPLE
   Stop-SQLiteTransaction -Transaction $Transaction -Commit
.NOTES
   using the method 'Commit()' on the transaction object is shorter
   this function is to make the module as complete as possible.
.LINK
    http://www.proxx.nl/Module/SQLite/
#>
    Param(
        [ALias("trns")]
        [Parameter(ValueFromPipeline=$true, mandatory=$true)]
        [System.Data.SQLite.SQLiteTransaction] $Transaction,
        [Parameter(ParameterSetName="Commit", Mandatory=$true)]
        [Switch] $Commit,
        [Parameter(ParameterSetName="Rollback", Mandatory=$true)]
        [Switch] $Rollback
    )
    
    if ($Commit) {
        Return $Transaction.Commit()
    } elseif ($Rollback) {
        Return $Transaction.Rollback()
    }
}