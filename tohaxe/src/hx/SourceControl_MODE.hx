package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class SourceControl_MODE
{
    public static inline var UNKNOWN:Int = 0;
    public static inline var INIT:Int = 1;
    public static inline var CVT:Int = 2;
    public static inline var INSERT:Int = 3;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 0: return "UNKNOWN";
            case 1: return "INIT";
            case 2: return "CVT";
            case 3: return "INSERT";
            default: return Std.string(e);
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "UNKNOWN": return 0;
            case "INIT": return 1;
            case "CVT": return 2;
            case "INSERT": return 3;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [0, 1, 2, 3];
    }
}
