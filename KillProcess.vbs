Const strComputer = "." 
'Const strProcessNames = "chromedriver.exe|IEDriverServer.exe|geckodriver.exe|MicrosoftWebDriver.exe" 

strProcessNames = InputBox("Enter Process Names" & VBNewLine & "Ex: chromedriver.exe | IEDriverServer.exe | geckodriver.exe | MicrosoftWebDriver.exe")

arrProcess = Split(strProcessNames,"|")

For Each sProcess in arrProcess
	Call KillProcess(Trim(sProcess))
Next

sub KillProcess(strProcessName)
	
	On Error Resume Next
	
	If (Len(strProcessName) > 0 ) Then
		Set WshShell = CreateObject("WScript.Shell")
		Dim objWMIService, colProcessList
		Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
		Set colProcessList = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" & strProcessName & "'")
		For Each objProcess in colProcessList
		  objProcess.Terminate()
		  
		Next
	End IF
	
	
End Sub