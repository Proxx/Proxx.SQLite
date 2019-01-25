Function Undo-SQLiteTransaction {
<#
.Synopsis
   End SQLite Transaction.
.DESCRIPTION
   Invoke Rollback on the transaction object.
.EXAMPLE
   $Transaction | Undo-SQLiteTransaction -Rollback
.EXAMPLE
   Undo-SQLiteTransaction -Transaction $Transaction
.NOTES
   using the method 'Rollback()' on the transaction object is shorter
   this function is to make the module as complete as possible.
.LINK
    http://www.proxx.nl/Module/SQLite/
#>
    Param(
        [ALias("trns")]
        [Parameter(ValueFromPipeline=$true, mandatory=$true)]
        [System.Data.SQLite.SQLiteTransaction] $Transaction
    )
    
    Return $Transaction.Rollback()
}