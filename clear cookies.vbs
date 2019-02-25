Set WshShell= CreateObject("wscript.shell")
WshShell.Run "RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2"
set WshShell=Nothing