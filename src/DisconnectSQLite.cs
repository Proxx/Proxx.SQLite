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
    [Cmdlet(VerbsCommunications.Disconnect, "SQLite", SupportsShouldProcess = true)]
    public class DisconnectSQLite : PSCmdlet
    {

        private SQLiteConnection connection;
        private string location;
        private bool dispose;
        /// <summary>
        /// <para type="description">Specifies the Connection object.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true
        )]
        [Alias("Conn")]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        /// <summary>
        /// <para type="description">Disposes the SQLite connection object.</para>
        /// </summary>
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
