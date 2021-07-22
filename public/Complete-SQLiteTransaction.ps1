Function Complete-SQLiteTransaction {
<#
.Synopsis
   End SQLite Transaction.
.DESCRIPTION
   invoked Commit on the transaction object.
.EXAMPLE
   $Transaction | Complete-SQLiteTransaction
.EXAMPLE
   Complete-SQLiteTransaction -Transaction $Transaction
.NOTES
   using the method 'Commit()' on the transaction object is shorter
   this function is to make the module as complete as possible.
.LINK
    http://www.proxx.nl/Module/SQLite/
#>
    Param(
        [ALias("trns")]
        [Parameter(ValueFromPipeline=$true, mandatory=$true)]
        [System.Data.SQLite.SQLiteTransaction] $Transaction
    )
    
    Return $Transaction.Commit()
}