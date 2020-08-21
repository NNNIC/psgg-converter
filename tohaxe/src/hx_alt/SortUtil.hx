package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class SortUtil
{
    public static function Sort(l:Array<String>):Array<String> {
        var l2=l.copy();
        l2.sort( 
            function(a:String, b:String):Int {
                if (a<b) return - 1;
                if (a>b) return 1;
                return 0;
            }
        );
        return l2;
    }
    public function new()
    {
    }
}
