using System;
using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsCommunications.Write, "SQLite", SupportsShouldProcess = true)]
    public class WriteSQLite : PSCmdlet
    {
        private SQLiteCommand command;
        private SQLiteConnection connection;
        private string[] query;

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
        [Parameter(
            Mandatory = true,
            HelpMessage = "SQLite Query",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true

        )]
        public string[] Query
        {
            get { return query; }
            set { query = value; }
        }

        [Parameter(
            Mandatory = false,
            HelpMessage = "Returns Boolean value on succes or failure"
        )]
        [Alias("Bool")]
        public SwitchParameter Boolean
        {
            get { return _Bool; }
            set { _Bool = value; }
        }
        private bool _Bool;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            foreach (string qry in query)
            {
                bool _Result = true;
                try
                {
                    command = new SQLiteCommand(qry, connection);
                    if (_Transaction != null) { command.Transaction = _Transaction; }
                    command.ExecuteNonQuery();
                }
                catch(Exception ex)
                {
                    if (_Bool)
                    {
                        _Result = false;
                    }
                    WriteError(new ErrorRecord(ex, ex.HResult.ToString(), ErrorCategory.InvalidResult, null));
                }
                finally
                {
                    if (_Bool) { WriteObject(_Result); }
                }
            }
        }
    }
}
