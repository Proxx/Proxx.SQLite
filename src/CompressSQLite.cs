using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsData.Compress, "SQLite", SupportsShouldProcess = true)]
    public class CompressSQLite : PSCmdlet
    {

        private SQLiteConnection connection;
        private SQLiteCommand command;
        private string location;
        private bool passthru;


        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Path to SQLite database",
            ValueFromPipeline = true
        )]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(
            Mandatory = false,
            HelpMessage = "Passthru object"
        )]
        public SwitchParameter PassThru
        {
            get { return passthru; }
            set { passthru = value; }
        }

        protected override void ProcessRecord()
        {
            if (connection != null)
            {
                location = connection.ConnectionString.Replace("Data Source = ", "");
                if (connection.State.ToString().Equals("Open"))
                {
                    if (ShouldProcess("Database", "Compress"))
                    {
                        command = new SQLiteCommand("VACUUM;", connection);
                        command.ExecuteNonQuery();
                    }
                }
                else { WriteObject(connection.State); }
                if (passthru) { WriteObject(connection); }
            }
        }
    }
}
