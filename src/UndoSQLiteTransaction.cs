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
    [Cmdlet(VerbsCommon.Undo, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class UndoSQLiteTransaction : PSCmdlet
    {

        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public SQLiteTransaction Transaction
        {
            get { return _Transaction; }
            set { _Transaction = value; }
        }
        private SQLiteTransaction _Transaction;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            _Transaction.Rollback();
        }
    }
}
