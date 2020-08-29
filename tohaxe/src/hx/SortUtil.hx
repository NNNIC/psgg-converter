package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class SortUtil
{
    public static function Sort(l:Array<String>):Array<String>
    {
        var l2:Array<String> = new Array<String>();
        system.Cs2Hx.AddRange(l2, l);
        l2.sort(Cs2Hx.SortStrings);
        return l2;
    }
    public function new()
    {
    }
}
