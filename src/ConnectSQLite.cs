﻿using System.Data.SQLite;
using System.Management.Automation;
using System.IO;

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
}