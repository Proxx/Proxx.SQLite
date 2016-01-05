using System.Data;
using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
    /// <list type="alertSet">
    ///   <item>
    ///     <term>Proxx.SQLite</term>
    ///     <description>
    ///     Author: Marco van G. (Proxx)
    ///     Website: www.Proxx.nl
    ///     </description>
    ///   </item>
    /// </list>
    /// <summary>
    ///   <para type="link">Proxx.nl</para>
    /// </summary>
    [Cmdlet(VerbsLifecycle.Invoke, "SQLiteFill", SupportsShouldProcess = true)]
    public class InvokeSQLiteFill : PSCmdlet
    {
        private SQLiteConnection connection;
        private SQLiteCommand _command;
        private DataTable inputobject;
        private string name;

        /// <summary>
        /// <para type="description">Specifies the Connection object.</para>
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "Connection")]
        [Alias("Conn")]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        /// <summary>
        /// <para type="description">Specifies an Transaction object.</para>
        /// </summary>
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
        /// <summary>
        /// <para type="description">Specifies the name of the SQLite table.</para>
        /// </summary>
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
