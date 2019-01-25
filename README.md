# Proxx.SQLite

[![Build status](https://ci.appveyor.com/api/projects/status/jlqm3jv2hao310ml?svg=true)](https://ci.appveyor.com/project/Proxx/proxx-sqlite)

SQLite PowerShell CmdLets

``` powershell
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Complete-SQLiteTransaction                         1.1.1.1    Proxx.SQLite
Cmdlet          Compress-SQLite                                    1.1.1.1    Proxx.SQLite
Cmdlet          Connect-SQLite                                     1.1.1.1    Proxx.SQLite
Cmdlet          Disconnect-SQLite                                  1.1.1.1    Proxx.SQLite
Cmdlet          Get-SQLite                                         1.1.1.1    Proxx.SQLite
Cmdlet          Invoke-SQLiteFill                                  1.1.1.1    Proxx.SQLite
Cmdlet          New-SQLiteTable                                    1.1.1.1    Proxx.SQLite
Cmdlet          New-SQLiteTransaction                              1.1.1.1    Proxx.SQLite
Cmdlet          Out-SQLiteTable                                    1.1.1.1    Proxx.SQLite
Cmdlet          Undo-SQLiteTransaction                             1.1.1.1    Proxx.SQLite
Cmdlet          Write-SQLite                                       1.1.1.1    Proxx.SQLite
```


[PowerShell Gallery](https://www.powershellgallery.com/packages/Proxx.SQLite/)



### changelog:
 - cloned function Read-SQLite to Get-SQLite
 - added support for parameter to Get-SQLite


### todo:
 - add support for sqlite paramters to Write-SQLite
 - add parameter Transaction to Write-SQLite
 - see if Write-SQLite could support SQLiteDataAdapter INSERTS,UPDATES,DELETES 
