﻿using System.Data.SQLite;
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
    [Cmdlet(VerbsLifecycle.Complete, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class CompleteSQLiteTransaction : PSCmdlet
    {
        private SQLiteTransaction transaction;

        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true
        )]
        public SQLiteTransaction Transaction
        {
            get { return transaction; }
            set { transaction = value; }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            transaction.Commit();
        }
    }
}
