Set WshShell= CreateObject("wscript.shell")
WshShell.Run "rundll32 user32.dll,LockWorkStation"
set WshShell=Nothing