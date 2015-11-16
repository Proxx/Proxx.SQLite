using System.Management.Automation;
using System.Data.SQLite;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsCommon.New, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class NewSQLiteTransaction : PSCmdlet
    {
        private SQLiteConnection connection;

        [Parameter(
            Mandatory = true,
            Position = 0
        )]
        [Alias("Conn")]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            WriteObject(connection.BeginTransaction());
        }
    }
}
