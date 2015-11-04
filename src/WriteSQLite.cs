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

        [Parameter(
            Mandatory = true
        )]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(
            Mandatory = false,
            HelpMessage = "SQLite Query",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true

        )]
        public string[] Query
        {
            get { return query; }
            set { query = value; }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            foreach (string qry in query)
            {
                command = new SQLiteCommand(qry, connection);
                command.ExecuteNonQuery();
            }
        }
    }
}
