using System;
using System.Collections;
using System.Data.SQLite;
using System.Linq;
using System.Management.Automation;
using System.Text;

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
    [Cmdlet(VerbsData.Out, "SQLiteTable", SupportsShouldProcess = true)]
    public class OutSQLiteTable : PSCmdlet
    {
        #region OutSQLite variables

        private SQLiteCommand _Command;
        private string[] _Exclude;
        private bool _First;
        private bool _HasError;
        private StringBuilder _InsertNames;
        private StringBuilder _InsertParam;
        private ArrayList _Param;
        private string _ParamName;
        private StringBuilder _UpdateParam;
        private string _Query;
        private string _x;

        #endregion

        #region OutSQLite Parameters
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
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Connection")]
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Transaction")]
        public PSObject[] InputObject
        {
            get { return inputobject; }
            set { inputobject = value; }
        }
        private PSObject[] inputobject;

        [Parameter(Mandatory = true, ParameterSetName = "Connection")]
        [Parameter(Mandatory = true, ParameterSetName = "Transaction")]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }
        private string name;
        
        [Parameter(Mandatory = false, ParameterSetName = "Connection")]
        [Parameter(Mandatory = false, ParameterSetName = "Transaction")]
        public string Update
        {
            get { return update; }
            set { update = value; }
        }
        private string update;

        [Parameter(Mandatory = false, ParameterSetName = "Connection")]
        [Parameter(Mandatory = false, ParameterSetName = "Transaction")]
        public string Replace
        {
            get { return replace; }
            set { replace = value; }
        }
        private string replace;

        [Parameter(Mandatory = false, ParameterSetName = "Connection")]
        [Parameter(Mandatory = false, ParameterSetName = "Transaction")]
        [Alias("Bool")]
        public SwitchParameter Boolean
        {
            get { return _Bool; }
            set { _Bool = value; }
        }
        private bool _Bool;
        #endregion

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            _HasError = false;
            
            if (ShouldProcess("Transaction", "Begin"))
            {
                if (_Transaction != null)
                {
                    _Command = _Transaction.Connection.CreateCommand();
                    _Command.Transaction = _Transaction;
                }
                else
                {
                    _Command = _Connection.CreateCommand();
                    _Command.Transaction = _Connection.BeginTransaction();
                }
            }
            _Exclude = new string[] { "RowError", "RowState", "Table", "ItemArray", "HasErrors" };
            _InsertNames = new StringBuilder();
            _InsertParam = new StringBuilder();
            _UpdateParam = new StringBuilder();
            _Param = new ArrayList();
            _First = true;
            _x = "";
        }
        protected override void ProcessRecord()
        {
            foreach (PSObject item in inputobject)
            {
                foreach (PSPropertyInfo property in item.Properties)
                {
                    if (_Exclude.Contains(property.Name.ToString())) { continue; }
                    _ParamName = "@__" + property.Name.ToString().Replace(".", "");
                    if (_First)
                    {
                        if (_Param.Contains(_ParamName))
                        {
                            _Command.Transaction.Rollback();
                            ThrowTerminatingError(new ErrorRecord(new Exception("Duplicated Parameter: " + property.Name.ToString()), "", ErrorCategory.SyntaxError, ""));
                        }
                        _Param.Add(_ParamName);
                        _Command.Parameters.Add(new SQLiteParameter(_ParamName));

                        _InsertNames.Append(_x + " '" + property.Name.ToString() + "'");
                        _InsertParam.Append(_x + " " + _ParamName);
                        _UpdateParam.Append(_x + " '" + property.Name.ToString() + "' = " + _ParamName);
                        _x = ",";
                    }
                    object value = "";
                    if (property.Value == null || string.IsNullOrWhiteSpace(property.Value.ToString())) { value = DBNull.Value; }
                    else
                    {
                        switch (property.TypeNameOfValue)
                        {
                            case "System.DateTime":
                                value = DateTime.Parse(property.Value.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
                                break;
                            case "System.String":
                                value = property.Value.ToString().Replace("'", "''");
                                break;
                            default:
                                value = property.Value;
                                break;
                        }
                    }
                    _Command.Parameters[_ParamName].Value = value;
                }
                if (_First)
                {
                    if (Replace != null) { _Query = "INSERT OR REPLACE INTO '" + name + "' (" + _InsertNames.ToString() + ") VALUES (" + _InsertParam.ToString() + ");"; }
                    else { _Query = "INSERT OR IGNORE INTO '" + name + "' (" + _InsertNames.ToString() + ") VALUES (" + _InsertParam.ToString() + ");"; }
                    if (Update != null) { _Query += "UPDATE '" + name + "' SET " + _UpdateParam.ToString() + " Where " + update + "=@__" + update.Replace(".", "") + ";"; }
                    _Command.CommandText = _Query;
                    WriteVerbose(_Query);
                    _Command.Prepare();
                }
                _First = false;
                try { _Command.ExecuteNonQuery(); }
                catch (Exception ec)
                {
                    WriteError((new ErrorRecord(ec, "", ErrorCategory.SyntaxError, "")));
                    _HasError = true;
                    break;
                }
            }
        }
        protected override void EndProcessing()
        {
            base.EndProcessing();
            if (_HasError)
            {
                if (_Transaction == null) { _Command.Transaction.Rollback(); }
                if (_Bool) { WriteObject(false); }
            }
            else
            {
                if (ShouldProcess("Transaction", "Commit"))
                {
                    if (_Bool) { WriteObject(true); }
                    if (_Transaction == null)
                    {
                        _Command.Transaction.Commit();
                    }
                }
            }
        }
    }
}
