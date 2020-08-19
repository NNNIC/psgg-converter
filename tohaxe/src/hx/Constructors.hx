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
import psggconverterlib.githash;
import psggconverterlib.MacroWork;
import psggconverterlib.SettingIniWork;
import psggconverterlib.ver;
import RefListString;
import RegexUtil;
import SourceControl;
import SourceControl_MODE;
import StateManager;
import StringUtil;
import system.TimeSpan;
class Constructors
{
    public static function init()
    {
        TimeSpan.cctor();
    }
}
