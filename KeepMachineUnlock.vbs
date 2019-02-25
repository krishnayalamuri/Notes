set wsc = CreateObject("WScript.Shell")
Do
WScript.Sleep (30*1000)
wsc.SendKeys ("{SCROLLLOCK 2}")
Loop