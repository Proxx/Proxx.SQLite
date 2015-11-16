using System.Data;
using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsLifecycle.Invoke, "SQLiteFill", SupportsShouldProcess = true)]
    public class InvokeSQLiteFill : PSCmdlet
    {
        private SQLiteConnection connection;
        private DataTable inputobject;
        private string name;

        [Parameter(Mandatory = true)]
        [Alias("Conn")]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(Mandatory = false)]
        public SQLiteTransaction Transaction
        {
            get { return _Transaction; }
            set { _Transaction = value; }
        }
        private SQLiteTransaction _Transaction;
        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public DataTable InputObject
        {
            get { return inputobject; }
            set { inputobject = value; }
        }

        [Parameter(Mandatory = true)]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }
        protected override void ProcessRecord()
        {
            base.BeginProcessing();
            SQLiteCommand command = connection.CreateCommand();
            command.CommandText = "SELECT * FROM '" + name + "' LIMIT 1";

            if (ShouldProcess("Database", "BeginTransaction"))
            {
                if (_Transaction == null)
                {
                    command.Transaction = connection.BeginTransaction();
                }
                else
                {
                    command.Transaction = _Transaction;
                }
            }
            SQLiteDataAdapter adapter = new SQLiteDataAdapter(command);
            SQLiteCommandBuilder commandbuilder = new SQLiteCommandBuilder(adapter);
            adapter.InsertCommand = (SQLiteCommand)commandbuilder.GetInsertCommand().Clone();
            commandbuilder.DataAdapter = null;
            if (ShouldProcess("Database", "Update"))
            {
                foreach (DataRow row in inputobject.Rows)
                {
                    if (row.RowState == DataRowState.Unchanged)
                    {
                        row.SetAdded();
                    }
                }
                adapter.Update(inputobject);
            }
            if (ShouldProcess("Transaction", "Commit"))
            {
                if (command.Transaction != null)
                {
                    if (_Transaction == null)
                    {
                        command.Transaction.Commit();
                    }
                }
            }
            inputobject.AcceptChanges();
        }
    }
}
