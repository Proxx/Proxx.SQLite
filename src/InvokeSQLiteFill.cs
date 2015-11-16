using System.Data;
using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsLifecycle.Invoke, "SQLiteFill", SupportsShouldProcess = true)]
    public class InvokeSQLiteFill : PSCmdlet
    {
        private SQLiteConnection connection;
        private SQLiteCommand _command;
        private DataTable inputobject;
        private string name;
        
        [Parameter(Mandatory = true, ParameterSetName = "Connection")]
        [Alias("Conn")]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(Mandatory = true, ParameterSetName = "Transaction")]
        public SQLiteTransaction Transaction
        {
            get { return _Transaction; }
            set { _Transaction = value; }
        }
        private SQLiteTransaction _Transaction;
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Connection")]
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Transaction")]
        public DataTable InputObject
        {
            get { return inputobject; }
            set { inputobject = value; }
        }

        [Parameter(Mandatory = true, ParameterSetName = "Connection")]
        [Parameter(Mandatory = true, ParameterSetName = "Transaction")]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }
        protected override void ProcessRecord()
        {
            base.BeginProcessing();
            //SQLiteCommand command = connection.CreateCommand();
            

            if (ShouldProcess("Database", "BeginTransaction"))
            {
                if (_Transaction == null)
                {
                    _command = connection.CreateCommand();
                    _command.Transaction = connection.BeginTransaction();
                }
                else
                {
                    _command = _Transaction.Connection.CreateCommand();
                    _command.Transaction = _Transaction;
                }
            }
            _command.CommandText = "SELECT * FROM '" + name + "' LIMIT 1";
            SQLiteDataAdapter adapter = new SQLiteDataAdapter(_command);
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
                if (_command.Transaction != null)
                {
                    if (_Transaction == null)
                    {
                        _command.Transaction.Commit();
                    }
                }
            }
            inputobject.AcceptChanges();
        }
    }
}
