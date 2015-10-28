using System;
using System.Collections;
using System.Data;
using System.Data.SQLite;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text;

namespace Proxx.SQLite
{
    [Cmdlet(VerbsCommunications.Connect, "SQLite")]
    public class ConnectSQLite : PSCmdlet
    {
        private SQLiteConnection Connection;
        private string connStr;
        private string path;
        private bool memory;
        private bool open;

        [Parameter(
            Position = 0,
            ParameterSetName = "File",
            HelpMessage = "Path to SQLite database"
        )]
        public string Path
        {
            get { return path; }
            set { path = value; }
        }
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "Memory",
            HelpMessage = "Create memory database"
        )]
        public SwitchParameter Memory
        {
            get { return memory; }
            set { memory = value; }
        }
        [Parameter(Mandatory = false, HelpMessage = "Opens Connection")]
        public SwitchParameter Open
        {
            get { return open; }
            set { open = value; }
        }

        protected override void BeginProcessing()
        {

            if (Memory) { Path = ":MEMORY:"; }
            else
            {
                if (string.IsNullOrEmpty(path)) { path = System.IO.Path.Combine(SessionState.Path.CurrentFileSystemLocation.Path, "database.db"); }
                else
                {
                    if (Directory.Exists(path)) { WriteObject("Throw here"); }
                    else if (!File.Exists(path))
                    {
                        if (path.StartsWith(".\\")) { path = System.IO.Path.Combine(SessionState.Path.CurrentFileSystemLocation.Path, path.Replace(".\\", "")); }
                        else { path = System.IO.Path.Combine(SessionState.Path.CurrentFileSystemLocation.Path.ToString(), path.ToString().TrimStart('\\')); }
                    }
                }
            }
            connStr = "Data Source = " + Path;
        }

        protected override void ProcessRecord()
        {
            Connection = new SQLiteConnection(connStr);
        }

        protected override void EndProcessing()
        {
            if (Open) { Connection.Open(); }
            WriteObject(Connection);
        }
    }

    [Cmdlet(VerbsCommunications.Disconnect, "SQLite", SupportsShouldProcess = true)]
    public class DisconnectSQLite : PSCmdlet
    {

        private SQLiteConnection connection;
        private string location;
        private bool dispose;
        private bool passthru;

        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true
        )]
        //[ValidateNotNullOrEmpty]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
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

    [Cmdlet(VerbsData.Compress, "SQLite", SupportsShouldProcess = true)]
    public class CompressSQLite : PSCmdlet
    {

        private SQLiteConnection connection;
        private SQLiteCommand command;
        private string location;
        private bool passthru;


        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Path to SQLite database",
            ValueFromPipeline = true
        )]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(
            Mandatory = false,
            HelpMessage = "Passthru object"
        )]
        public SwitchParameter PassThru
        {
            get { return passthru; }
            set { passthru = value; }
        }

        protected override void ProcessRecord()
        {
            if (connection != null)
            {
                location = connection.ConnectionString.Replace("Data Source = ", "");
                if (connection.State.ToString().Equals("Open"))
                {
                    if (ShouldProcess("Database", "Compress"))
                    {
                        command = new SQLiteCommand("VACUUM;", connection);
                        command.ExecuteNonQuery();
                    }
                }
                else { WriteObject(connection.State); }
                if (passthru) { WriteObject(connection); }
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "SQLite", SupportsShouldProcess = true)]
    public class GetSQLite : PSCmdlet
    {

        private SQLiteConnection connection;
        private string query;
        private bool returnobject;

        [Parameter(
            Mandatory = true
        )]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(
            Mandatory = false,
            HelpMessage = "SQLite select Query",
            ValueFromPipeline = true
        )]
        public string Query
        {
            get { return query; }
            set { query = value; }
        }
        [Parameter(
            Mandatory = false,
            HelpMessage = "return object instead of DataTable"
        )]
        public SwitchParameter ReturnObject
        {
            get { return returnobject; }
            set { returnobject = value; }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (connection.State.ToString().Equals("Open"))
            {
                SQLiteCommand command = new SQLiteCommand(query, connection);
                if (returnobject)
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

    [Cmdlet(VerbsCommunications.Write, "SQLite", SupportsShouldProcess = true)]
    public class WriteSQLite : PSCmdlet
    {
        private SQLiteCommand command;
        private SQLiteConnection connection;
        private string[] query;

        [Parameter(
            Mandatory = true
        )]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(
            Mandatory = false,
            HelpMessage = "SQLite Query",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        
        )]
        public string[] Query
        {
            get { return query; }
            set { query = value; }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            foreach (string qry in query)
            {
                command = new SQLiteCommand(qry, connection);
                command.ExecuteNonQuery();
            }
        }
    }

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
            }
            else
            {
                if (ShouldProcess("Transaction", "Commit"))
                {
                    command.Transaction.Commit();
                }
            }
        }
    }

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
        #endregion

        #region NewSQLiteTable Parameters
        [Parameter(
            Mandatory = true
        )]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }
        [Parameter(
            Mandatory = false,
            ValueFromPipeline = true
        )]
        public PSObject[] InputObject
        {
            get { return inputobject; }
            set { inputobject = value; }
        }
        [Parameter(
            Mandatory = false
        )]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }
        [Parameter(
            Mandatory = false
        )]
        public string Unique
        {
            get { return unique; }
            set { unique = value; }
        }
        [Parameter(
            Mandatory = false
        )]
        public SwitchParameter Text
        {
            get { return text; }
            set { text = value; }
        }
        [Parameter(
            Mandatory = false
        )]
        public SwitchParameter PassThru
        {
            get { return passthru; }
            set { passthru = value; }
        }
        #endregion

        protected override void BeginProcessing()
        {
            if (connection.State.ToString().Equals("Open"))
            {
                first = true;
                command = Connection.CreateCommand();
                columns = new StringBuilder();
                param = new ArrayList();
                x = "";
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
                        if (text) { type = "TEXT"; }
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
                        columns.Append(" " + type);
                        if (unique != null)
                        {
                            if (unique.Equals(property.Name.ToString())) { columns.Append(" UNIQUE"); }
                        }
                    }
                }
                if (first)
                {
                    command.CommandText = string.Format("CREATE TABLE '{0}' ({1});", name, columns.ToString());
                    WriteDebug("Executing Query: " + command.CommandText);
                    try { command.ExecuteNonQuery(); } catch (Exception ec) { WriteError((new ErrorRecord(ec, "", ErrorCategory.SyntaxError, ""))); }
                }
                first = false;

                if (passthru)
                {
                    WriteObject(row);
                }
                else
                {
                    //break;
                    break;
                }
            }
        }
    }

    [Cmdlet(VerbsLifecycle.Invoke, "SQLiteFill", SupportsShouldProcess = true)]
    public class InvokeSQLiteFill : PSCmdlet
    {
        private SQLiteConnection connection;
        private DataTable inputobject;
        private string name;
        private bool add;

        [Parameter(Mandatory = true)]
        public SQLiteConnection Connection
        {
            get { return connection; }
            set { connection = value; }
        }

        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public DataTable InputObject
        {
            get { return inputobject; }
            set { inputobject = value; }
        }

        [Parameter(Mandatory = true)]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }
        protected override void ProcessRecord()
        {
            base.BeginProcessing();
            SQLiteCommand command = connection.CreateCommand();
            command.CommandText = "SELECT * FROM '" + name + "' LIMIT 1";

            if (ShouldProcess("Database", "BeginTransaction"))
            {
                SQLiteTransaction transaction = connection.BeginTransaction();
                command.Transaction = transaction;
            }
            SQLiteDataAdapter adapter = new SQLiteDataAdapter(command);
            SQLiteCommandBuilder commandbuilder = new SQLiteCommandBuilder(adapter);
            adapter.InsertCommand = (SQLiteCommand)commandbuilder.GetInsertCommand().Clone();
            commandbuilder.DataAdapter = null;
            if (ShouldProcess("Database", "Update"))
            {
                foreach (DataRow row in inputobject.Rows)
                {
                    if (row.RowState == DataRowState.Unchanged)
                    {
                        row.SetAdded();
                    }
                }
                adapter.Update(inputobject);
            }
            if (ShouldProcess("Transaction", "Commit"))
            {
                if (command.Transaction != null)
                {
                    command.Transaction.Commit();
                }
            }
            inputobject.AcceptChanges();
        }
    }

    [Cmdlet(VerbsCommon.New, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class NewSQLiteTransaction : PSCmdlet
    {
        private SQLiteConnection connection;

        [Parameter(
            Mandatory = true,
            Position = 0
        )]
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

    [Cmdlet(VerbsLifecycle.Complete, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class CompleteSQLiteTransaction : PSCmdlet
    {
        private SQLiteTransaction transaction;

        [Parameter(
            Mandatory = true,
            Position = 0
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

    [Cmdlet(VerbsCommon.Undo, "SQLiteTransaction", SupportsShouldProcess = true)]
    public class UndoSQLiteTransaction : PSCmdlet
    {
        private SQLiteTransaction transaction;

        [Parameter(
            Mandatory = true,
            Position = 0
        )]
        public SQLiteTransaction Transaction
        {
            get { return transaction; }
            set { transaction = value; }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            transaction.Rollback();
        }
    }

}

