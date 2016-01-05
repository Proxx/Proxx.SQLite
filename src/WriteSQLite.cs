using System;
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
    [Cmdlet(VerbsCommunications.Write, "SQLite", SupportsShouldProcess = true)]
    public class WriteSQLite : PSCmdlet
    {
        private SQLiteCommand _Command;
        private SQLiteConnection _Connection;
        private string[] _Query;

        [Parameter(Mandatory = true, ParameterSetName = "Connection")]
        [Alias("Conn")]
        public SQLiteConnection Connection
        {
            get { return _Connection; }
            set { _Connection = value; }
        }
        [Parameter(Mandatory = true, ParameterSetName = "Transaction")]
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
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "Connection"
        )]
        [Parameter(
            Mandatory = true,
            HelpMessage = "SQLite Query",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "Transaction"
        )]
        public string[] Query
        {
            get { return _Query; }
            set { _Query = value; }
        }

        [Parameter(
            Mandatory = false,
            HelpMessage = "Returns Boolean value on succes or failure",
            ParameterSetName = "Connection"
        )]
        [Parameter(
            Mandatory = false,
            HelpMessage = "Returns Boolean value on succes or failure",
            ParameterSetName = "Transaction"
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
            foreach (string qry in _Query)
            {
                bool _Result = true;
                try
                {
                    _Command = new SQLiteCommand(qry, _Connection);
                    if (_Transaction == null) {
                        _Command = new SQLiteCommand(qry, _Connection);
                    }
                    else
                    {
                        _Command = new SQLiteCommand(qry, _Transaction.Connection);
                        _Command.Transaction = _Transaction;
                    }
                    _Command.ExecuteNonQuery();
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
