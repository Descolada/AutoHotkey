#Requires AutoHotkey v2.0
#Hotstring NoMouse
#maxThreadsPerHotkey 10

;SetTimer(ExitTest, -1000)
global lastId := 0


Loop {
	ToolTip "Still running " A_ThreadId
	Sleep 1000
}


ExitTest() {
	Test()
	Exit(1, lastId)
	Test()
}

Test() => MsgBox(A_ThreadId " " (A_ThreadId & 0xFFFF) " " (A_ThreadId >> 16))

F1::{
	global lastId := A_ThreadId
	Test()
	;DllCall(CallbackCreate(ExitTest))
	OutputDebug Exit(0, 1)
	OutputDebug Exit(0, 1)
	Test()
}
