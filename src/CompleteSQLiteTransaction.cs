using System.Data.SQLite;
using System.Management.Automation;


namespace Proxx.SQLite
{
    [Cmdlet(VerbsLifecycle.Complete, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class CompleteSQLiteTransaction : PSCmdlet
    {
        private SQLiteTransaction transaction;

        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true
        )]
        public SQLiteTransaction Transaction
        {
            get { return transaction; }
            set { transaction = value; }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            transaction.Commit();
        }
    }
}
