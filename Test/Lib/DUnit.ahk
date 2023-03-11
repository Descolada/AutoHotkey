#Requires AutoHotkey v2.0

/*
	Name: DUnit.ahk
	Version 0.1 (11.03.23)
	Created: 11.03.23
	Author: Descolada

	Description:
	Another unit testing library for AHK v2

    DUnit(TestClasses*)
    Tests the provided test classes sequentially: eq DUnit(TestSuite1, TestSuite2)
    
    A prototype TestClass:
    class TestSuite {
        __New() {
            ; Ran before calling a test method from this class
        }
        __Delete() {
            ; Ran after calling a test method from this class.
        }
        Test_Func() {
            ; The methods to test. No specific name nomenclature required. The method cannot be static.
        }
    }

    DUnit methods:

    DUnit.True(a, msg := "Not True")
        Checks whether the condition a is not false (0, '', False). msg is the error message displayed.
    DUnit.False(a, msg := "Not False")
        Checks whether the condition a is false (0, '', False). msg is the error message displayed.
    DUnit.Equal(a, b, msg?, compareFunc?)
        Checks conditions a and b for equality. msg is the error message displayed.
        Optionally compareFunc(a,b) can be provided, otherwise Print(a) == Print(b) is used to check equality.
    DUnit.NotEqual(a, b, msg?, compareFunc?)
        Checks conditions a and b for non-equality. msg is the error message displayed.
        Optionally compareFunc(a,b) can be provided, otherwise Print(a) == Print(b) is used to check equality.
    DUnit.Assert(condition, msg := "Fail", n := -1)
        Functionally equivalent to DUnit.True
        n is the What argument for Error()
    DUnit.Throws(func, errorType?, msg := "FAIL (didn't throw)")
        Checks whether the provided func throws an error (optionally the type of the error is checked)
    DUnit.SetOptions(options?)
        Applies or resets DUnit options (see more below)
    
    DUnit properties/options:

    DUnit.Verbose
        Causes DUnit to also report successful tests by name. Otherwise only failed tests are reported.
    DUnit.FailFast
        Causes DUnit to return after the first encountered error.
    
    The properties can also be provided in the main DUnit() call as a string, and will
    be applied to all tests after the string: "Verbose"/"V", "FailFast"/"F"
    Example: DUnit("C", TestSuite) will apply Coverage option to TestSuite
    Options can also be applied with SetOptions(options?), where leaving options blank will reset
    to default options.
*/

class DUnit {
    static Verbose := "", FailFast  := ""
    /**
     * Applies DUnit options
     * @param options Space-separated options to apply: Verbose (V), FailFast (F). If 
     *     left empty then will reset to default.
     */
    static SetOptions(options?) {
        if IsSet(options) {
            for option in StrSplit(options, " ") {
                Switch option, 0 {
                    case "V", "Verbose":
                        DUnit.Verbose := True
                    case "F", "FailFast":
                        DUnit.FailFast := True
                }
            }
        } else
            DUnit.Verbose := False, DUnit.FailFast := False
    }
    static __New() => DUnit.SetOptions()
    /**
     * New instance will test the provided testClasses, optionally also apply options
     * @param testClasses The classes to be tested
     * @example
     * DUnit(TestSuite1, "V", TestSuite2) ; tests two classes, and applies "Verbose" option for TestSuite2
     */
    __New(testClasses*) {
        this.Print("Beginning unit testing:`n`n")
        totalFails := 0, totalSuccesses := 0, startTime := A_TickCount
        for testClass in testClasses {
            ; If there are any options provided, reset all options and apply new ones.
            if testClass is String { 
                DUnit.SetOptions(testClass)
                continue
            }
            fails := 0, successes := 0
            this.Print(Type(testClass()) ": ")
            ; Test all methods in testClass sequentially
            for test in ObjOwnProps(testClass.Prototype) {
                ; Reset environment so one test doesn't affect another
                env := testClass() 
                ; Ignore __New/__Delete
                if SubStr(test, 1, 2) != '__' {
                    try
                        env.%test%()
                    catch as e {
                        fails++
                        this.Print("`nFAIL: " Type(env) "." test "`n" StrReplace(e.File, A_InitialWorkingDir "\") " (" e.Line ") : " e.Message)
                        if DUnit.FailFast
                            break
                    } else {
                        successes++
                        if DUnit.Verbose
                            this.Print("`nSuccess: " Type(env) "." test)
                    }
                }
                env := ""
            }
            if !fails {
                this.Print(DUnit.Verbose ? "`nAll pass." : "all pass.")
            } else {
                if DUnit.FailFast {
                    this.Print("`n`n")
                    break
                }
            }
            this.Print("`n`n")
            totalFails += fails, totalSuccesses += successes
        }
        this.Print("=========================`nTotal " (totalFails+totalSuccesses) " tests in " Round((A_TickCount-startTime)/1000, 3) "s: " totalSuccesses " successes, " totalFails " fails.")
    }
    /**
     * Checks whether the condition a is True
     * @param a Condition (value) to check
     * @param msg Optional: error message to display
     */
    static True(a, msg := "Not True") => DUnit.Assert(a, msg, -2)
    /**
     * Checks whether the condition a is False
     * @param a Condition (value) to check
     * @param msg Optional: error message to display
     */
    static False(a, msg := "Not False") => DUnit.Assert(!a, msg, -2)
    /**
     * Checks whether two conditions/values are equal
     * @param a First condition
     * @param b Second condition
     * @param msg Optional: error message to display
     * @param compareFunc Optional: the function used to compare the values. By default Print() is used.
     */
    static Equal(a, b, msg?, compareFunc?) {
        currentListLines := A_ListLines
        ListLines 0
        if IsSet(compareFunc) && HasMethod(compareFunc)
            DUnit.Assert(compareFunc(a,b), msg ?? "Not equal", -2)
        else
            DUnit.Assert((pa := DUnit.Print(a)) == (pb := DUnit.Print(b)), msg ?? pa ' != ' pb, -2)
        ListLines currentListLines
    }
    /**
     * Checks whether two conditions/values are not equal
     * @param a First condition
     * @param b Second condition
     * @param msg Optional: error message to display
     * @param compareFunc Optional: the function used to compare the values. By default Print() is used.
     */
    static NotEqual(a, b, msg?, compareFunc?) {
        currentListLines := A_ListLines
        ListLines 0
        if IsSet(compareFunc) && HasMethod(compareFunc)
            DUnit.Assert(!compareFunc(a,b), msg ?? "Are equal", -2)
        else
            DUnit.Assert((pa := DUnit.Print(a)) != (pb := DUnit.Print(b)), msg ?? pa ' == ' pb, -2)
        ListLines currentListLines
    }
    /**
     * Checks whether the condition is not 0, "", or False
     * @param a Condition (value) to check
     * @param msg Optional: error message to display
     * @param n Optional: Error message What argument. Default is -1.
     */
    static Assert(condition, msg := "Fail", n := -1) {
        if !condition
            throw Error(msg?, n)
    }
    /**
     * Checks whether the condition (function) throws an error when called.
     * @param func The function to test
     * @param errorType Optional: checks whether a specific error type needs to be thrown
     * @param msg Optional: Error message to show
     */
    static Throws(func, errorType?, msg := "FAIL (didn't throw)") {
        try 
            func()
        catch as e {
            if IsSet(errorType) && (Type(e) != errorType)
                DUnit.Assert(False, msg)
            return
        }
        DUnit.Assert(false, msg)
    }

    /**
     * Internal method used to print out the results.
     */
    Print(value) => OutputDebug(value)

    /**
     * Prints the formatted value of a variable (number, string, object).
     * Leaving all parameters empty will return the current function and newline in an Array: [func, newline]
     * @param value Optional: the variable to print. 
     *     If omitted then new settings (output function and newline) will be set.
     *     If value is an object/class that has a ToString() method, then the result of that will be printed.
     * @param func Optional: the print function to use. Default is OutputDebug.
     *     Not providing a function will cause the output to simply be returned as a string.
     * @param newline Optional: the newline character to use (applied to the end of the value). 
     *     Default is newline (`n).
     */
    static Print(value?, func?, newline?) {
        static p := "", nl := ""
        if IsSet(func)
            p := func
        if IsSet(newline)
            nl := newline
        if IsSet(value) {
            val := _Print(value) nl
            return HasMethod(p) ? p(val) : val
        }
        return [p, nl]

        _Print(val?) {
            if !IsSet(val)
                return "unset"
            valType := Type(val)
            switch valType, 0 {
                case "String":
                    return "'" StrReplace(StrReplace(StrReplace(val, "`n", "``n"), "`r", "``r"), "`t", "``t") "'"
                case "Integer", "Float":
                    return val
                default:
                    self := "", iter := "", out := ""
                    try self := _Print(val.ToString()) ; if the object has ToString available, print it
                    if valType != "Array" { ; enumerate object with key and value pair, except for array
                        try {
                            enum := val.__Enum(2) 
                            while (enum.Call(&val1, &val2))
                                iter .= _Print(val1) ":" _Print(val2?) ", "
                        }
                    }
                    if !IsSet(enum) { ; if enumerating with key and value failed, try again with only value
                        try {
                            enum := val.__Enum(1)
                            while (enum.Call(&enumVal))
                                iter .= _Print(enumVal?) ", "
                        }
                    }
                    if !IsSet(enum) && (valType = "Object") && !self { ; if everything failed, enumerate Object props
                        for k, v in val.OwnProps()
                            iter .= SubStr(_Print(k), 2, -1) ":" _Print(v?) ", "
                    }
                    iter := SubStr(iter, 1, StrLen(iter)-2)
                    if !self && !iter && !((valType = "Array" && val.Length = 0) || (valType = "Map" && val.Count = 0) || (valType = "Object" && ObjOwnPropCount(val) = 0))
                        return valType ; if no additional info is available, only print out the type
                    else if self && iter
                        out .= "value:" self ", iter:[" iter "]"
                    else
                        out .= self iter
                    return (valType = "Object") ? "{" out "}" : (valType = "Array") ? "[" out "]" : valType "(" out ")"
            }
        }
    }
}