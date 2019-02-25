Set objShell = WScript.CreateObject("WScript.Shell")
Set objExecObject = objShell.Exec("%comspec% /c ipconfig.exe")

Do Until objExecObject.StdOut.AtEndOfStream
 strLine = objExecObject.StdOut.ReadLine()
 strIP = Instr(strLine,"IPv4 Address")
 If strIP <> 0 Then
 arrAddress = Split(strIP,":")
 strCurrAddress = arrAddress(1)
 Msgbox "Your Machine IP Address is :" & strCurrAddress

 End If
Loop
