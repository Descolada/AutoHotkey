#Requires AutoHotkey v2.0

res := ""
for v in Range(2,7)
	res .= v " "
MsgBox res

res := ""
for k, v in Range(2,7)
	res .= k " " v "`n"
MsgBox res