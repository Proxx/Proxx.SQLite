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
        [Alias("Conn")]
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
