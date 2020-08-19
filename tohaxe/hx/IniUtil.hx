package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class IniUtil
{
    public static function GetValue(key:String, initext:String):String
    {
        var ht:system.collections.Hashtable = CreateHashtable(initext);
        return GetValueFromHashtable(key, ht);
    }
    public static function GetValue_String_String_String(category:String, key:String, initext:String):String
    {
        var ht:system.collections.Hashtable = CreateHashtable(initext);
        return GetValueFromHashtable_String_String_Hashtable(category, key, ht);
    }
    public static function GetValueFromHashtable(key:String, ht:system.collections.Hashtable):String
    {
        if (ht.Contains(key))
        {
            return ht.GetValue_Object(key).toString();
        }
        return null;
    }
    public static function GetDoubleFromHashtable(key:String, ht:system.collections.Hashtable, error:Float = -1):Float
    {
        var val:String = GetValueFromHashtable(key, ht);
        if (val == null)
        {
            return error;
        }
        var o:CsRef<Float> = new CsRef<Float>(0);
        if (Cs2Hx.TryParseFloat(val, o))
        {
            return o.Value;
        }
        return error;
    }
    public static function GetValueFromHashtable_String_String_Hashtable(category:String, key:String, ht:system.collections.Hashtable):String
    {
        if (ht != null && ht.ContainsKey(category))
        {
            var cateval:Dynamic = ht.GetValue_Object(category);
            if (cateval != null && (Std.is(cateval, system.collections.Hashtable)))
            {
                var cathash:system.collections.Hashtable = (function():system.collections.Hashtable return cateval)();
                if (cathash.ContainsKey(key))
                {
                    return cathash.GetValue_Object(key).toString();
                }
            }
        }
        return null;
    }
    public static function CreateHashtable(initext:String):system.collections.Hashtable
    {
        if (system.Cs2Hx.IsNullOrEmpty(initext))
        {
            return null;
        }
        var mainhash:system.collections.Hashtable = new system.collections.Hashtable();
        var cathash:system.collections.Hashtable = null;
        var lines:Array<String> = system.Cs2Hx.Split(initext, [ 10 ]);
        var n:Int = -1;
        while (true)
        {
            n++;
            if (n >= lines.length)
            {
                break;
            }
            var l:String = lines[n];
            if (system.Cs2Hx.IsNullOrEmpty(l) || system.Cs2Hx.IsNullOrEmpty(system.Cs2Hx.Trim(l)))
            {
                continue;
            }
            if (l.charCodeAt(0) == 59)
            {
                continue;
            }
            if (l.charCodeAt(0) == 91)
            {
                if (l.length <= 2)
                {
                    continue;
                }
                var cindex:Int = system.Cs2Hx.IndexOfChar(l, 93, 1);
                if (cindex < 0)
                {
                    continue;
                }
                var category:String = l.substr(1, cindex - 1);
                cathash = new system.collections.Hashtable();
                mainhash.Add(category, cathash);
            }
            var eqindex:Int = system.Cs2Hx.IndexOfChar(l, 61);
            if (eqindex < 0)
            {
                continue;
            }
            var key:String = system.Cs2Hx.Trim(l.substr(0, eqindex));
            if (system.Cs2Hx.IsNullOrEmpty(key))
            {
                continue;
            }
            if (eqindex + 2 > l.length)
            {
                continue;
            }
            var value:String = system.Cs2Hx.Trim(l.substr(eqindex + 1));
            if (system.Cs2Hx.IsNullOrEmpty(value))
            {
                continue;
            }
            if (value == "@@@")
            {
                var value2:String = "";
                { //for
                    var n2:Int = n + 1;
                    while (n2 < lines.length)
                    {
                        var l2:String = lines[n2];
                        l2 = system.Cs2Hx.TrimEnd(l2);
                        if (l2 == "@@@")
                        {
                            n = n2;
                            value = value2;
                            break;
                        }
                        if (!system.Cs2Hx.IsNullOrEmpty(value2))
                        {
                            value2 += system.Environment.NewLine;
                        }
                        value2 += system.Cs2Hx.TrimEnd(l2);
                        n2++;
                    }
                } //end for
            }
            if (cathash != null)
            {
                cathash.Add(key, value);
            }
            else
            {
                mainhash.Add(key, value);
            }
        }
        return mainhash;
    }
    public static function CreateHashtable_String_String(initext:String, category:String):system.collections.Hashtable
    {
        if (system.Cs2Hx.IsNullOrEmpty(initext))
        {
            return null;
        }
        var ht:system.collections.Hashtable = CreateHashtable(initext);
        if (ht != null && ht.ContainsKey(category))
        {
            var cateval:Dynamic = ht.GetValue_Object(category);
            if (cateval != null && (Std.is(cateval, system.collections.Hashtable)))
            {
                var cathash:system.collections.Hashtable = (function():system.collections.Hashtable return cateval)();
                return cathash;
            }
        }
        return null;
    }
    public function new()
    {
    }
}
