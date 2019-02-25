Set WshShell= CreateObject("wscript.shell")
WshShell.Run "cmd /c RunDll32 InetCpl.cpl,ClearMyTracksByProcess 2"
set WshShell=Nothing