using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsCommon.Undo, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class UndoSQLiteTransaction : PSCmdlet
    {
        private SQLiteTransaction transaction;

        [Parameter(
            Mandatory = true,
            Position = 0
        )]
        public SQLiteTransaction Transaction
        {
            get { return transaction; }
            set { transaction = value; }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            transaction.Rollback();
        }
    }
}
