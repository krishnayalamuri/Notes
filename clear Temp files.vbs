Dim wshShell, objFSO, intCounter

' Get folder paths for the folders using environment variables
Set wshShell = CreateObject("WScript.Shell")

strPath = wshShell.ExpandEnvironmentStrings("%TEMP%")

Set wshShell = Nothing

'Call EmptyFolder() to delete all files and subfolders
Set objFSO = CreateObject("Scripting.Filesystemobject")

    If objFSO.FolderExists(strPath) Then
        Call EmptyFolder(strPath)
    End If

Function EmptyFolder(strFolderPath)
    Dim objFSO, objCurrentFolder, colFilesInFolder, objFile, colFoldersInFolder, objFolder
    Set objFSO = CreateObject("Scripting.Filesystemobject")

    If objFSO.FolderExists(strFolderPath) Then
        Set objCurrentFolder = objFSO.GetFolder(strFolderPath)
        Set colFilesInFolder = objCurrentFolder.Files

        ' Delete all files in the folder
        For Each objFile In colFilesInFolder
            On Error Resume Next
            objFSO.DeleteFile(objFile), True
        Next

		' Try to delete all subfolders and their containing files
		Set colFoldersInFolder = objCurrentFolder.SubFolders

		For Each objFolder In colFoldersInFolder
			On Error Resume Next
			DeleteFilesInFolder(objFolder.Path)
			objFSO.DeleteFolder(objFolder), True
		Next
    End If

    Set objFSO = Nothing
End Function
