/*
This file serves two purposes:  
    1)  It imports every type that CS2HX generated.  haXe will ignore 
        any types that aren't used by haXe code, so this ensures haXe 
        compiles all of your code.

    2)  It lists all the static constructors.  haXe doesn't have the 
        concept of static constructors, so CS2HX generated cctor()
        methods.  You must call these manually.  If you call
        Constructors.init(), all static constructors will be called 
        at once.
*/
package ;
import FunctionControl;
import IncludeFile;
import IniUtil;
import InsertCodeControl;
import MacroControl;
import psggconverterlib.CfPrepareControl;
import psggconverterlib.Convert;
import psggconverterlib.Githash;
import psggconverterlib.MacroWork;
import psggconverterlib.SettingIniWork;
import psggconverterlib.Ver;
import RefListString;
import RegexUtil;
import SortUtil;
import SourceControl;
import SourceControl_MODE;
import StateManager;
import StringUtil;
import wordstrage.Store;
import system.TimeSpan;
class Constructors
{
    public static function init()
    {
        TimeSpan.cctor();
    }
}
