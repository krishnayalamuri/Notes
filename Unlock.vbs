' IsUserLocked.vbs
' VBScript program to determine if user account locked out. If the
' account is locked out, the program allows the user to unlock the
' account.
'
' ----------------------------------------------------------------------
' Copyright (c) 2003 Richard L. Mueller
' Hilltop Lab web site - http://www.rlmueller.net
' Version 1.0 - May 30, 2003
' Version 1.1 - June 28, 2003 - Prompt to unlock account.
' Version 1.2 - July 23, 2003 - Bug fixes.
' Version 1.3 - January 25, 2004 - Modify error trapping.
' Version 1.4 - March 18, 2004 - Modify NameTranslate constants.
'
' You have a royalty-free right to use, modify, reproduce, and
' distribute this script file in any way you find useful, provided that
' you agree that the copyright owner above has no warranty, obligations,
' or liability for such use.
' ----------------------------------------------------------------------
' Heavily modified by Alan Kobb, Herley-CTI, inc. 2007
' Added random password generator.
' Added check for same user.  8/27/09
' Fixed bugs.  Escape "/" in domain name and detect domain infinite lockout policy.  11/5/09
' ----------------------------------------------------------------------

Option Explicit
Dim objUser, objDomain, lngBias, objLockout, dtmLockout
Dim objDuration, lngDuration, lngHigh, lngLow, dtmUnLock
Dim strUserDN, strDNSDomain, strNetBIOSDomain, strUserNTName
Dim objTrans, objShell, lngBiasKey, k, objRootDSE
Dim strText, strTitle, intConstants, intAns, objNetwork

' Constants for the NameTranslate object.
Const ADS_NAME_INITTYPE_GC = 3
Const ADS_NAME_TYPE_NT4 = 3
Const ADS_NAME_TYPE_1779 = 1

strTitle = "UnlockUser"
Set objShell = CreateObject("Wscript.Shell")

' Request user sAMAccountName.
strUserNTName = Trim(InputBox("Enter User NT Logon Name", strTitle))
If strUserNTName = "" Then
  strText = "Program Aborted"
  intConstants = vbOKOnly + vbExclamation
  intAns = objShell.Popup(strText, , strTitle, intConstants)
  WScript.Quit
End If

' Retrieve DNS domain name.
Set objRootDSE = GetObject("LDAP://RootDSE")
strDNSDomain = objRootDSE.Get("defaultNamingContext")

' Convert DNS domain name to NetBIOS domain name.
Set objTrans = CreateObject("NameTranslate")
objTrans.Init ADS_NAME_INITTYPE_GC, ""
objTrans.Set ADS_NAME_TYPE_1779, strDNSDomain
strNetBIOSDomain = objTrans.Get(ADS_NAME_TYPE_NT4)
' Remove trailing backslash.
strNetBIOSDomain = Left(strNetBIOSDomain, Len(strNetBIOSDomain) - 1)

Set objNetwork = CreateObject("Wscript.Network")
If UCase(Trim(strUserNTName)) = UCase(Trim(objNetwork.UserName)) And UCase(strNetBIOSDomain) = UCase(objNetwork.UserDomain) Then
  strText = "You cannot unlock or change the password for your own account."
  intConstants = vbOKOnly + vbExclamation
  intAns = objShell.Popup(strText, , strTitle, intConstants)
  WScript.Quit
End If

' Convert user NT name to Distinguished Name.
On Error Resume Next
objTrans.Set ADS_NAME_TYPE_NT4, strNetBIOSDomain & "\" & strUserNTName
If Err.Number <> 0 Then
  On Error GoTo 0
  strText = "User " & strUserNTName & " not found"
  strText = strText & vbCrLf & "Program aborted"
  intConstants = vbOKOnly + vbCritical
  intAns = objShell.Popup(strText, , strTitle, intConstants)
  WScript.Quit
End If
On Error GoTo 0
strUserDN = objTrans.Get(ADS_NAME_TYPE_1779)

' Escape any forward slash characters, "/", with the backslash
' escape character. All other characters that should be escaped are.
strUserDN = Replace(strUserDN, "/", "\/")

' Bind to user object.
On Error Resume Next
Set objUser = GetObject("LDAP://" & strUserDN)
If Err.Number <> 0 Then
  On Error GoTo 0
  strText = "User " & strUserNTName & " not found"
  strText = strText & vbCrLf & "DN: " & strUserDN
  strText = strText & vbCrLf & "Program aborted"
  intConstants = vbOKOnly + vbCritical
  intAns = objShell.Popup(strText, , strTitle, intConstants)
  WScript.Quit
End If
On Error GoTo 0

' Bind to domain.
Set objDomain = GetObject("LDAP://" & strDNSDomain)

' Obtain local Time Zone bias from machine registry.
lngBiasKey = objShell.RegRead("HKLM\System\CurrentControlSet\Control\TimeZoneInformation\ActiveTimeBias")
If UCase(TypeName(lngBiasKey)) = "LONG" Then
  lngBias = lngBiasKey
ElseIf UCase(TypeName(lngBiasKey)) = "VARIANT()" Then
  lngBias = 0
  For k = 0 To UBound(lngBiasKey)
    lngBias = lngBias + (lngBiasKey(k) * 256^k)
  Next
End If

' Retrieve user lockoutTime, Convert to date and display lockout status.
On Error Resume Next
Set objLockout = objUser.lockoutTime
If Err.Number <> 0 Then
	On Error GoTo 0
	strText = "User " & strUserNTName & " is not locked out."
	strText = strText & vbCrLf & "Would you like to reset the password?"
	intConstants = vbYesNo + vbQuestion
	intAns = objShell.Popup(strText, , strTitle, intConstants)
	If intAns = vbYes Then Call ChangePassword(objUser)
	WScript.Quit
End If
On Error GoTo 0

dtmLockout = Integer8Date(objLockout, lngBias)
If dtmLockout = #1/1/1601# Then
	strText = "User " & strUserNTName & " is not locked out."
	strText = strText & vbCrLf & "Would you like to reset the password?"
	intConstants = vbYesNo + vbQuestion
	intAns = objShell.Popup(strText, , strTitle, intConstants)
	If intAns = vbYes Then Call ChangePassword(objUser)
	WScript.Quit
End If
strText = "User " & strUserNTName & " locked out at: " & dtmLockout

' Retrieve domain lockoutDuration policy.
Set objDuration = objDomain.lockoutDuration
lngHigh = objDuration.HighPart
lngLow = objDuration.LowPart
If (lngHigh = 0 And lngLow = 0) Then
	' There is no domain lockout duration policy.
	' Locked out accounts remain locked out Until reset.
	' Any user With value of lockoutTime greater than 0 is locked out.
	lngDuration = -999
	strText = strText & vbCrLf & "Domain locked accounts do not automatically unlock."
Else
	If (lngLow < 0) Then
	lngHigh = lngHigh + 1
	End If
	lngDuration = lngHigh * (2^32) + lngLow
	lngDuration = -lngDuration/(60 * 10000000)
	strText = strText & vbCrLf & "Domain lockout duration (minutes): " & lngDuration
End If

' Determine if account still locked out and ask user how to proceed.
Dim intUnlockAns
intUnlockAns = vbNo
If lngDuration = -999 Then
  strText = strText & vbCrLf & "Account is locked indefinately."
  strText = strText & vbCrLf & "Click ""Yes"" to unlock account now"
  strText = strText & vbCrLf & "Click ""No"" to leave account locked"
  intConstants = vbYesNo + vbExclamation
  intUnlockAns = objShell.Popup(strText, , strTitle, intConstants)
Else
	dtmUnLock = DateAdd("n", lngDuration, dtmLockout)
	If Now > dtmUnLock Then
		strText = strText & vbCrLf & "The account was unlocked at: " & dtmUnLock
		strText = strText & vbCrLf & "Would you like to reset the password?"
		intConstants = vbYesNo + vbQuestion
		intAns = objShell.Popup(strText, , strTitle, intConstants)
		If intAns = vbYes Then Call ChangePassword(objUser)
		WScript.Quit
	Else
		strText = strText & vbCrLf & "Account will unlock at: " & dtmUnLock
		strText = strText & vbCrLf & "Click ""Yes"" to unlock account now"
		strText = strText & vbCrLf & "Click ""No"" to leave account locked"
		intConstants = vbYesNo + vbExclamation
		intUnlockAns = objShell.Popup(strText, , strTitle, intConstants)
	End If
End If

If intUnlockAns = vbYes Then
 On Error Resume Next
 objUser.IsAccountLocked = False
 objUser.SetInfo
 If Err.Number <> 0 Then
   On Error GoTo 0
   strText = "Unable to unlock user " & strUserNTName
   strText = "You may not have sufficient rights"
   strText = "Program aborted"
   intConstants = vbOKOnly + vbCritical
   intAns = objShell.Popup(strText, , strTitle, intConstants)
 Else
   On Error GoTo 0
   strText = "User " & strUserNTName & " unlocked"
   intConstants = vbOKOnly + vbExclamation
   intAns = objShell.Popup(strText, , strTitle, intConstants)
 End If
ElseIf intAns = vbNo Then
 strText = "User " & strUserNTName & " account left locked out"
 intConstants = vbOKOnly + vbInformation
 intAns = objShell.Popup(strText, , strTitle, intConstants)
Else
 strText = "Program aborted"
 strText = strText & vbCrLf & "User " & strUserNTName & " still locked out"
 intConstants = vbOKOnly + vbExclamation
 intAns = objShell.Popup(strText, , strTitle, intConstants)
End If

' Clean up.
Set objUser = Nothing
Set objDomain = Nothing
Set objLockout = Nothing
Set objDuration = Nothing
Set objTrans = Nothing
Set objShell = Nothing

Function Integer8Date(objDate, lngBias)
' Function to convert Integer8 (64-bit) value to a date, adjusted for
' local time zone bias.
Dim lngAdjust, lngDate, lngHigh, lngLow
lngAdjust = lngBias
lngHigh = objDate.HighPart
lngLow = objdate.LowPart
' Account for bug in IADslargeInteger property methods.
If lngLow < 0 Then
	lngHigh = lngHigh + 1
End If
If (lngHigh = 0) And (lngLow = 0) Then
	lngAdjust = 0
End If
lngDate = #1/1/1601# + (((lngHigh * (2 ^ 32)) + lngLow) / 600000000 - lngAdjust) / 1440
Integer8Date = CDate(lngDate)
End Function

Sub ChangePassword(objUser)
Dim strPassword, intPwdValue, strText
strPassword = RandomPassword(8)
intPwdValue = 0					' Force a change of password at next logon

strText = "The user will be required to change their password when they logon."
strPassword = InputBox(strText,"The new password is:",strPassword)

If strPassword <> "" Then
	objUser.SetPassword strPassword
	objUser.Put "PwdLastSet", intPwdValue
	objUser.SetInfo
Else
	strText = "Password not changed"
	intConstants = vbOKOnly + vbExclamation
	intAns = objShell.Popup(strText, , strTitle, intConstants)
End If

End Sub

Function RandomPassword(intCharacters)
Dim intASCIIValue, i, intLowerLimit, intUpperLimit
Randomize  
intLowerLimit = 48
intUpperLimit = 122

For i = 1 To intCharacters
	intASCIIValue = Int(((intUpperLimit - intLowerLimit + 1) * Rnd) + intLowerLimit)  
	RandomPassword = RandomPassword & Chr(intASCIIValue)
Next

End Function