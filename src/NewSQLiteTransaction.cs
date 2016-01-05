using System.Management.Automation;
using System.Data.SQLite;

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
    [Cmdlet(VerbsCommon.New, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class NewSQLiteTransaction : PSCmdlet
    {
        private SQLiteConnection connection;
        /// <summary>
        /// <para type="description">Specifies the Connection object.</para>
        /// </summary>
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
