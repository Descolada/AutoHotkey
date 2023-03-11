#Requires AutoHotkey v2.0

class script_object {
	
	Map_Keys() {
		m := Map(1, "val", 2, "val2")
		DUnit.Assert(m.Keys().Length == 2)
	}
}