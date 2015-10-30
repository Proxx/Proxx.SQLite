using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsCommunications.Disconnect, "SQLite", SupportsShouldProcess = true)]
    public class DisconnectSQLite : PSCmdlet
    {

        private SQLiteConnection connection;
        private string location;
        private bool dispose;
        private bool passthru;

        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true
        )]
        //[ValidateNotNullOrEmpty]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(
            Mandatory = false,
            HelpMessage = "Dispose connection"
        )]
        public SwitchParameter Dispose
        {
            get { return dispose; }
            set { dispose = value; }
        }

        protected override void ProcessRecord()
        {
            if (connection != null)
            {
                location = connection.ConnectionString.Replace("Data Source = ", "");
                if (connection.State.ToString().Equals("Open"))
                {
                    if (ShouldProcess(location, "Close")) { connection.Close(); }
                }
                else { WriteObject(connection.State); }
                if (dispose)
                {
                    if (ShouldProcess(location, "Dispose")) { connection.Dispose(); }
                }
            }
        }
    }
}
