using System;
using System.Data;
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
    [Cmdlet(VerbsCommon.Get, "SQLite", SupportsShouldProcess = true)]
    public class GetSQLite : PSCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the Connection object.</para>
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "Connection")]
        [Alias("Conn")]
        public SQLiteConnection Connection
        {
            get { return _Connection; }
            set { _Connection = value; }
        }
        private SQLiteConnection _Connection;
        /// <summary>
        /// <para type="description">Specifies an Transaction object.</para>
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "Transaction")]
        public SQLiteTransaction Transaction
        {
            get { return _Transaction; }
            set { _Transaction = value; }
        }
        private SQLiteTransaction _Transaction;
        /// <summary>
        /// <para type="description">Specify the query in string format.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            HelpMessage = "SQLite select Query",
            ValueFromPipeline = true,
            ParameterSetName = "Connection"
        )]
        [Parameter(
            Mandatory = true,
            HelpMessage = "SQLite select Query",
            ValueFromPipeline = true,
            ParameterSetName = "Transaction"
        )]
        public string Query
        {
            get { return _Query; }
            set { _Query = value; }
        }
        private string _Query;
        /// <summary>
        /// <para type="description">Ouputs an Object instead of a DataTable</para>
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "return object instead of DataTable",
            ParameterSetName = "Connection"
        )]
        [Parameter(
            Mandatory = false,
            HelpMessage = "return object instead of DataTable",
            ParameterSetName = "Transaction"
        )]
        public SwitchParameter ReturnObject
        {
            get { return _ReturnObject; }
            set { _ReturnObject = value; }
        }
        private bool _ReturnObject;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            SQLiteConnection conn = null;
            if (_Transaction == null)
            {
                conn = _Connection;
            }
            else
            {
                conn = _Transaction.Connection;
            }
            if (conn.State.ToString().Equals("Open"))
            {
                SQLiteCommand command = new SQLiteCommand(_Query, conn);
                if (_ReturnObject)
                {
                    SQLiteDataReader reader = command.ExecuteReader();
                    if (reader.HasRows)
                    {
                        int fc = reader.FieldCount;
                        while (reader.Read())
                        {
                            PSObject obj = new PSObject();
                            for (int i = 0; i < fc; i++)
                            {
                                obj.Members.Add(new PSNoteProperty(reader.GetName(i), reader.GetValue(i)));
                            }
                            WriteObject(obj);
                        }
                    }
                }
                else
                {
                    DataTable dt = new DataTable();
                    SQLiteDataAdapter adapter = new SQLiteDataAdapter(command);
                    adapter.Fill(dt);
                    WriteObject(dt);
                }
            }
            else
            {
                ThrowTerminatingError(new ErrorRecord(new Exception("Connection is not open"), "", ErrorCategory.OpenError, ""));
            }
        }
    }

}
