#Requires AutoHotkey v2.0

class script_object_bif {
	Range() {
		DUnit.Throws(Range.Bind(0)) ; stop=0 not allowed
		DUnit.Throws(Range.Bind(2,1)) ; start>stop when step>0 not allowed
		DUnit.Throws(Range.Bind(1,2,-1)) ; stop<start when step<0 not allowed
		res := ""
		for i in Range(5)
			res .= i " "
		DUnit.Equal(res, "1 2 3 4 ") ; Range(stop) enumerates to n (not including)
		res := ""
		for i in Range(2, 5)
			res .= i " "
		DUnit.Equal(res, "2 3 4 ") ; Range(start, stop)
		res := ""
		for i in Range(3, 10, 2)
			res .= i " "
		DUnit.Equal(res, "3 5 7 9 ") ; Range(start, stop, step)
		res := ""
		for i, j in Range(5) ; Range(stop) with A_index
			res .= i " " j " "
		DUnit.Equal(res, "1 1 2 2 3 3 4 4 ")
		res := ""
		for i in Range(5,0,-1)
			res .= i " "
		DUnit.Equal(res, "5 4 3 2 1 ") ; negative step
		res := ""
		for i, j in Range(5,0,-1) ; negative step with A_index
			res .= i " " j " "
		DUnit.Equal(res, "1 5 2 4 3 3 4 2 5 1 ")
		res := ""
		for i in Range(,5) ; unset start defaults to 1
			res .= i " "
		DUnit.Equal(res, "1 2 3 4 ")
		res := ""
		for i in Range(2,,1) { ; unset stop defaults to INT_MAX with step>0
			res .= i " "
			if i > 5 ; consider 6 to be infinity...
				break
		}
		DUnit.Equal(res, "2 3 4 5 6 ")
		res := ""
		for i in Range(2,,-2) { ; unset stop defaults to INT_MIN with step<0
			res .= i " "
			if i < -5 ; consider -6 to be infinity...
				break
		}
		DUnit.Equal(res, "2 0 -2 -4 -6 ")

		res := ""
		for i in Range(2147483647, 2147483653) ; INT_MAX test
			res .= i " "
		DUnit.Equal(res, "2147483647 2147483648 2147483649 2147483650 2147483651 2147483652 ")	
	}
}