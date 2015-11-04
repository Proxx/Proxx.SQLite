using System;
using System.Collections;
using System.Data.SQLite;
using System.Linq;
using System.Management.Automation;
using System.Text;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsData.Out, "SQLiteTable", SupportsShouldProcess = true)]
    public class OutSQLiteTable : PSCmdlet
    {
        #region OutSQLite variables

        private SQLiteCommand command;
        private string[] Exclude;
        private bool first;
        private bool HasError;
        private StringBuilder insertnames;
        private StringBuilder insertparam;
        private ArrayList param;
        private string paramname;
        private StringBuilder updateparam;
        private string query;
        private string x;

        #endregion

        #region OutSQLite Parameters
        [Parameter(
            Mandatory = true
        )]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        private SQLiteConnection connection;

        [Parameter(
            Mandatory = false,
            ValueFromPipeline = true
        )]
        public PSObject[] InputObject
        {
            get { return inputobject; }
            set { inputobject = value; }
        }
        private PSObject[] inputobject;

        [Parameter(
            Mandatory = false
        )]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }
        private string name;

        [Parameter(
            Mandatory = false
        )]
        public string Update
        {
            get { return update; }
            set { update = value; }
        }
        private string update;

        [Parameter(
            Mandatory = false
        )]
        public string Replace
        {
            get { return replace; }
            set { replace = value; }
        }
        private string replace;

        [Parameter(
            Mandatory = false
        )]
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
            HasError = false;
            command = Connection.CreateCommand();
            if (ShouldProcess("Transaction", "Begin"))
            {
                command.Transaction = connection.BeginTransaction();
            }
            Exclude = new string[] { "RowError", "RowState", "Table", "ItemArray", "HasErrors" };
            insertnames = new StringBuilder();
            insertparam = new StringBuilder();
            updateparam = new StringBuilder();
            param = new ArrayList();
            first = true;
            x = "";
        }
        protected override void ProcessRecord()
        {
            foreach (PSObject item in inputobject)
            {
                foreach (PSPropertyInfo property in item.Properties)
                {
                    if (Exclude.Contains(property.Name.ToString())) { continue; }
                    paramname = "@__" + property.Name.ToString().Replace(".", "");
                    if (first)
                    {
                        if (param.Contains(paramname))
                        {
                            command.Transaction.Rollback();
                            ThrowTerminatingError(new ErrorRecord(new Exception("Duplicated Parameter: " + property.Name.ToString()), "", ErrorCategory.SyntaxError, ""));
                        }
                        param.Add(paramname);
                        command.Parameters.Add(new SQLiteParameter(paramname));

                        insertnames.Append(x + " '" + property.Name.ToString() + "'");
                        insertparam.Append(x + " " + paramname);
                        updateparam.Append(x + " '" + property.Name.ToString() + "' = " + paramname);
                        x = ",";
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
                    command.Parameters[paramname].Value = value;
                }
                if (first)
                {
                    if (Replace != null) { query = "INSERT OR REPLACE INTO '" + name + "' (" + insertnames.ToString() + ") VALUES (" + insertparam.ToString() + ");"; }
                    else { query = "INSERT OR IGNORE INTO '" + name + "' (" + insertnames.ToString() + ") VALUES (" + insertparam.ToString() + ");"; }
                    if (Update != null) { query += "UPDATE '" + name + "' SET " + updateparam.ToString() + " Where " + update + "=@__" + update.Replace(".", "") + ";"; }
                    command.CommandText = query;
                    WriteVerbose(query);
                    command.Prepare();
                }
                first = false;
                try { command.ExecuteNonQuery(); }
                catch (Exception ec)
                {
                    WriteError((new ErrorRecord(ec, "", ErrorCategory.SyntaxError, "")));
                    HasError = true;
                    break;
                }
            }
        }
        protected override void EndProcessing()
        {
            base.EndProcessing();
            if (HasError)
            {
                command.Transaction.Rollback();
                if (_Bool) { WriteObject(false); }
            }
            else
            {
                if (ShouldProcess("Transaction", "Commit"))
                {
                    if (_Bool) { WriteObject(true); }
                    command.Transaction.Commit();
                }
            }
        }
    }
}
