using System;
using System.Data;
using System.Data.SQLite;
using System.Management.Automation;

namespace Proxx.SQLite
{
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

}
