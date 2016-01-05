using System;
using System.Linq;
using System.Text;
using System.Data.SQLite;
using System.Management.Automation;
using System.Collections;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsCommon.New, "SQLiteTable", SupportsShouldProcess = true)]
    public class NewSQLiteTable : PSCmdlet
    {
        #region NewSQLite variables
        private string unique;
        private bool text;
        private string name;
        private bool first;
        private PSObject[] inputobject;
        private StringBuilder columns;
        private SQLiteConnection connection;
        private SQLiteCommand command;
        private ArrayList param;
        private string x;
        private SwitchParameter passthru;
        private string[] Exclude;
        private SwitchParameter _temp;
        #endregion

        #region NewSQLiteTable Parameters
        [Parameter(Mandatory = true, ParameterSetName = "Connection")]
        [Alias("Conn")]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(Mandatory = false, ParameterSetName = "Transaction")]
        public SQLiteTransaction Transaction
        {
            get { return _Transaction; }
            set { _Transaction = value; }
        }
        private SQLiteTransaction _Transaction;
        [Parameter(Mandatory = false, ValueFromPipeline = true, ParameterSetName = "Connection")]
        [Parameter(Mandatory = false, ValueFromPipeline = true, ParameterSetName = "Transaction")]
        public PSObject[] InputObject
        {
            get { return inputobject; }
            set { inputobject = value; }
        }
        [Parameter(Mandatory = true, ParameterSetName = "Connection")]
        [Parameter(Mandatory = true, ParameterSetName = "Transaction")]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }
        [Parameter(Mandatory = false, ParameterSetName = "Connection")]
        [Parameter(Mandatory = false, ParameterSetName = "Transaction")]
        public string Unique
        {
            get { return unique; }
            set { unique = value; }
        }
        [Parameter(Mandatory = false, ParameterSetName = "Connection")]
        [Parameter(Mandatory = false, ParameterSetName = "Transaction")]
        public SwitchParameter Text
        {
            get { return text; }
            set { text = value; }
        }
        [Parameter(Mandatory = false, ParameterSetName = "Connection")]
        [Parameter(Mandatory = false, ParameterSetName = "Transaction")]
        public SwitchParameter PassThru
        {
            get { return passthru; }
            set { passthru = value; }
        }
        [Parameter(Mandatory = false, ParameterSetName = "Connection")]
        [Parameter(Mandatory = false, ParameterSetName = "Transaction")]
        public SwitchParameter Temp
        {
            get { return _temp; }
            set { _temp = value; }
        }
        #endregion

        protected override void BeginProcessing()
        {
            if (connection.State.ToString().Equals("Open"))
            {
                first = true;
                
                columns = new StringBuilder();
                param = new ArrayList();
                x = "";
                if (_Transaction != null)
                {
                    command = _Transaction.Connection.CreateCommand();
                    command.Transaction = _Transaction;
                }
                else
                {
                    command = connection.CreateCommand();
                }
            }
            else
            {
                ThrowTerminatingError(new ErrorRecord(new Exception("Connection is not open"), "", ErrorCategory.OpenError, ""));
            }
            Exclude = new string[] { "RowError", "RowState", "Table", "ItemArray", "HasErrors" };
        }

        protected override void ProcessRecord()
        {
            foreach (PSObject row in inputobject)
            {
                if (first)
                {
                    foreach (PSPropertyInfo property in row.Properties)
                    {
                        if (Exclude.Contains(property.Name.ToString())) { continue; }
                        if (first)
                        {
                            if (param.Contains(property.Name.ToString()))
                            {
                                ThrowTerminatingError(new ErrorRecord(new Exception("Duplicated Column: " + property.Name.ToString()), "", ErrorCategory.SyntaxError, ""));
                            }
                            param.Add(property.Name.ToString());
                            columns.Append(x + " `" + property.Name.ToString() + "`");
                            x = ",";
                            string type = "";
                            if (text)
                            {
                                type = "TEXT";
                            }
                            else
                            {
                                switch (property.TypeNameOfValue)
                                {
                                    case "System.Boolean": type = "BOOLEAN"; break;
                                    case "System.Byte": type = "BLOB"; break;
                                    case "System.Byte[]": type = "BLOB"; break;
                                    case "System.DateTime": type = "DATETIME"; break;
                                    case "System.Decimal": type = "DECIMAL"; break;
                                    case "System.Double": type = "INT"; break;
                                    case "System.Guid": type = "BLOB"; break;
                                    case "System.Int16": type = "INT"; break;
                                    case "System.Int32": type = "INT"; break;
                                    case "System.Int64": type = "INT"; break;
                                    case "System.Single": type = "NUMERIC"; break;
                                    case "System.Uint16": type = "INT"; break;
                                    case "System.Uint32": type = "BIGINT"; break;
                                    case "System.Uint64": type = "BIGINT"; break;
                                    default: type = "TEXT"; break;
                                }
                            }
                            columns.Append(" " + type);
                            if (unique != null)
                            {
                                if (unique.Equals(property.Name.ToString())) { columns.Append(" UNIQUE"); }
                            }
                        }
                    }
                    if (_temp)
                    {
                        command.CommandText = string.Format("CREATE TEMP TABLE '{0}' ({1});", name, columns.ToString());
                    }
                    else
                    {
                        command.CommandText = string.Format("CREATE TABLE '{0}' ({1});", name, columns.ToString());
                    }
                    WriteDebug("Executing Query: " + command.CommandText);
                    try { command.ExecuteNonQuery(); } catch (Exception ec) { WriteError((new ErrorRecord(ec, "", ErrorCategory.SyntaxError, ""))); }
                    first = false;
                }
                else
                {

                    if (passthru)
                    {
                        WriteObject(row);
                    }
                    else
                    {
                        
                        break;
                    }
                }
            }
        }
    }
}
