using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsCommon.Undo, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class UndoSQLiteTransaction : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public SQLiteTransaction Transaction
        {
            get { return _Transaction; }
            set { _Transaction = value; }
        }
        private SQLiteTransaction _Transaction;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            _Transaction.Rollback();
        }
    }
}
