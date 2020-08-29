package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class RegexUtil
{
    public static inline var VARNAME_PATTERN:String = "[_a-zA-Z][_a-zA-Z0-9]+";
    public static function IsMatch(regexstr:String, s:String):Bool
    {
        if (system.Cs2Hx.IsNullOrEmpty(s))
        {
            return false;
        }
        if (system.Cs2Hx.IsNullOrEmpty(regexstr))
        {
            return false;
        }
        try
        {
            return (new system.text.regularexpressions.Regex(regexstr)).IsMatch(s);
        }
        catch (__ex:Dynamic)
        {
            return false;
        }
    }
    public static function Get1stMatch(regexstr:String, s:String):String
    {
        if (system.Cs2Hx.IsNullOrEmpty(s))
        {
            return "";
        }
        if (system.Cs2Hx.IsNullOrEmpty(regexstr))
        {
            return "";
        }
        var regex:system.text.regularexpressions.Regex = new system.text.regularexpressions.Regex(regexstr);
        var matches:system.text.regularexpressions.MatchCollection = regex.Matches(s);
        if (matches == null || matches.Count == 0)
        {
            return "";
        }
        for (i in matches.GetEnumerator())
        {
            var m:system.text.regularexpressions.Match = (function():system.text.regularexpressions.Match return i)();
            return m.Value;
        }
        return "";
    }
    public static function GetNthMatch(regexstr:String, s:String, n:Int):String
    {
        if (system.Cs2Hx.IsNullOrEmpty(s))
        {
            return "";
        }
        if (system.Cs2Hx.IsNullOrEmpty(regexstr))
        {
            return "";
        }
        var regex:system.text.regularexpressions.Regex = new system.text.regularexpressions.Regex(regexstr);
        var matches:system.text.regularexpressions.MatchCollection = regex.Matches(s);
        if (matches == null || matches.Count == 0)
        {
            return "";
        }
        var c:Int = 0;
        for (i in matches.GetEnumerator())
        {
            c++;
            if (c == n)
            {
                var m:system.text.regularexpressions.Match = (function():system.text.regularexpressions.Match return i)();
                return m.Value;
            }
        }
        return "";
    }
    public function new()
    {
    }
}
